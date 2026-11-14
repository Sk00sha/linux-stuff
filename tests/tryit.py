#!/usr/bin/env python3
"""Run the "## Try it" blocks of lessons inside the lesson's runtime image.

Every ```bash block in a lesson's "Try it" section is executed (in order, in
one throw-away container per lesson, as user bob, starting in /home/bob).
A ```text block that directly follows a bash block is its expected output.

    tests/tryit.py modules/01-shell-1            # verify: every block exits 0
    tests/tryit.py --update modules/01-shell-1   # also paste the real output

Front-matter key `tryit` picks the image: ubuntu (default), systemd, rocky,
vm or none (vm/none/rocky-without-image are skipped and reported).
Blocks whose fence is ```bash norun are shown but never executed.
"""

import argparse
import glob
import os
import re
import subprocess
import sys
import uuid

ROOT = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "lib"))
import miniyaml  # noqa: E402

VM_IN_DOCKER = "--vm-in-docker" in sys.argv
IMAGES = {"ubuntu": "lbc/ubuntu:1.0", "systemd": "lbc/systemd-ubuntu:1.0", "rocky": "lbc/rocky:1.0"}
MAX_LINES = 30


def split_front_matter(text):
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        return miniyaml.loads(text[4:end]) or {}
    return {}


def tryit_blocks(lines):
    """Yield (start, end, kind, info) of fenced blocks inside '## Try it'."""
    in_section = False
    i = 0
    while i < len(lines):
        ln = lines[i]
        if ln.startswith("## "):
            in_section = ln.strip().lower().startswith("## try it")
        if in_section and ln.startswith("```") and len(ln.strip()) > 3:
            info = ln.strip()[3:]
            j = i + 1
            while j < len(lines) and not lines[j].startswith("```"):
                j += 1
            yield i, j, info.split()[0], info
            i = j + 1
            continue
        i += 1


def image_exists(img):
    return subprocess.run(["docker", "image", "inspect", img], stdout=subprocess.DEVNULL,
                          stderr=subprocess.DEVNULL).returncode == 0


def run_lesson(path, update):
    text = open(path, encoding="utf-8").read()
    fm = split_front_matter(text)
    kind = fm.get("tryit", "ubuntu")
    lines = text.split("\n")
    blocks = list(tryit_blocks(lines))
    bash = [b for b in blocks if b[2] == "bash"]
    rel = os.path.relpath(path, ROOT)
    if not bash:
        return rel, "no-blocks", []
    verify_only = False
    if kind == "vm" and VM_IN_DOCKER:
        # No VM available: execute the commands in the systemd container to
        # prove they exist and run, but keep the representative VM output.
        kind, verify_only = "systemd", True
    if kind not in IMAGES or not image_exists(IMAGES[kind]):
        return rel, "skipped (%s runtime)" % kind, []
    name = "tryit-" + uuid.uuid4().hex[:8]
    args = ["docker", "run", "-d", "--name", name, "--hostname", "ubuntu", "--label", "course=linux-basics"]
    if kind == "systemd":
        args += ["--privileged", "--cgroupns=host", "--tmpfs", "/run", "--tmpfs", "/run/lock"]
    else:
        args += ["--cap-add", "NET_ADMIN"]
    args += ["-v", ROOT + ":/course:ro", IMAGES[kind]]
    subprocess.run(args, check=True, stdout=subprocess.DEVNULL)
    failures = []
    replacements = []
    try:
        if kind == "systemd":
            subprocess.run(["docker", "exec", name, "bash", "-c",
                            "for i in $(seq 30); do systemctl is-system-running 2>/dev/null | grep -qE 'running|degraded' && break; sleep 1; done"])
        subprocess.run(["docker", "exec", name, "bash", "-c", "sleep 1"])
        for idx, (s, e, k, info) in enumerate(blocks):
            if k != "bash":
                continue
            code = "\n".join(lines[s + 1:e])
            if "norun" in info or (verify_only and "novmcheck" in info):
                continue
            r = subprocess.run(["docker", "exec", "-t", "-u", "bob", "-w", "/home/bob", "-e", "HOME=/home/bob",
                                "-e", "USER=bob", "-e", "TERM=xterm", "-e", "COLUMNS=80", "-e", "LANG=C.UTF-8", name, "bash", "--noprofile", "-c",
                                "umask 0002; source ~/.bashrc >/dev/null 2>&1; " + code],
                               capture_output=True, text=True, timeout=120)
            out = "\n".join(l.rstrip() for l in (r.stdout + r.stderr).replace("\r\n", "\n").replace("\r", "").split("\n")).strip("\n")
            if r.returncode != 0 and "mayfail" not in info:
                failures.append("line %d: exit %d\n%s\n---\n%s" % (s + 1, r.returncode, code, out[-800:]))
            # expected output block directly after?
            j = e + 1
            while j < len(lines) and lines[j].strip() == "":
                j += 1
            if j < len(lines) and lines[j].strip() == "```text":
                k2 = j + 1
                while k2 < len(lines) and not lines[k2].startswith("```"):
                    k2 += 1
                olines = out.split("\n") if out else ["(no output)"]
                if len(olines) > MAX_LINES:
                    olines = olines[:MAX_LINES - 1] + ["..."]
                replacements.append((j + 1, k2, olines))
    finally:
        subprocess.run(["docker", "rm", "-f", name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if update and replacements and not verify_only:
        for a, b, new in sorted(replacements, reverse=True):
            lines[a:b] = new
        with open(path, "w", encoding="utf-8") as fh:
            fh.write("\n".join(lines))
    return rel, ("FAIL" if failures else ("ok (verified in container)" if verify_only else "ok")), failures


def main():
    p = argparse.ArgumentParser()
    p.add_argument("paths", nargs="*", default=[os.path.join(ROOT, "modules")])
    p.add_argument("--update", action="store_true", help="paste real output into ```text blocks")
    p.add_argument("--vm-in-docker", action="store_true",
                   help="run tryit: vm lessons in the systemd container (verify only, no update)")
    a = p.parse_args()
    files = []
    for path in a.paths:
        if os.path.isdir(path):
            files += sorted(glob.glob(os.path.join(path, "**", "lessons", "*.md"), recursive=True))
        else:
            files.append(path)
    bad = 0
    for f in files:
        rel, status, failures = run_lesson(f, a.update)
        print("%-70s %s" % (rel, status))
        for fl in failures:
            bad += 1
            print("    " + fl.replace("\n", "\n    "))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
