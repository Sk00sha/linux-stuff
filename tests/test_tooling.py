"""Tests for the tooling: the YAML subset parser and the course CLI."""

import os
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "lib"))
import miniyaml  # noqa: E402

COURSE = [sys.executable, os.path.join(ROOT, "bin", "course")]


def run(*args, **kw):
    env = dict(os.environ, NO_COLOR="1")
    env.update(kw.pop("env", {}))
    return subprocess.run(COURSE + list(args), capture_output=True, text=True, env=env, **kw)


class MiniYamlTest(unittest.TestCase):
    def test_scalars(self):
        doc = miniyaml.loads("a: 1\nb: 0.7\nc: true\nd: null\ne: plain text\nf: 'it''s'\ng: \"x: y # z\"\n")
        self.assertEqual(doc, {"a": 1, "b": 0.7, "c": True, "d": None, "e": "plain text",
                               "f": "it's", "g": "x: y # z"})

    def test_comments_and_document_marker(self):
        self.assertEqual(miniyaml.loads("---\n# c\na: b  # trailing\n"), {"a": "b"})

    def test_nested(self):
        doc = miniyaml.loads("m:\n  - id: x\n    items:\n      - {type: a, n: 2}\n      - [p, q]\n  - id: y\n")
        self.assertEqual(doc, {"m": [{"id": "x", "items": [{"type": "a", "n": 2}, ["p", "q"]]}, {"id": "y"}]})

    def test_block_scalars(self):
        doc = miniyaml.loads("lit: |\n  one\n    two\nfold: >-\n  a\n  b\n\n  c\n")
        self.assertEqual(doc, {"lit": "one\n  two\n", "fold": "a b\nc"})

    def test_errors(self):
        with self.assertRaises(miniyaml.YAMLError):
            miniyaml.loads("a: 1\na: 2\n")
        with self.assertRaises(miniyaml.YAMLError):
            miniyaml.loads("a:\n\tb: 1\n")


class CliTest(unittest.TestCase):
    def test_list_and_syllabus(self):
        r = run("list")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("01-shell-1", r.stdout)
        self.assertIn("09-client-demo", r.stdout)
        r = run("syllabus")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(r.stdout.startswith("# Syllabus"))

    def test_syllabus_file_is_current(self):
        with open(os.path.join(ROOT, "SYLLABUS.md"), encoding="utf-8") as fh:
            self.assertEqual(fh.read().rstrip("\n"), run("syllabus").stdout.rstrip("\n"),
                             "SYLLABUS.md is stale: run `make syllabus`")

    def test_lab_lookup_and_info(self):
        r = run("info", "iptables", "runtime")
        self.assertEqual(r.stdout.strip(), "docker")
        r = run("info", "systemd-services", "services", "--runtime", "docker")
        self.assertEqual(r.stdout.strip(), "systemd")
        r = run("info", "no-such-lab")
        self.assertNotEqual(r.returncode, 0)

    def test_hints_are_progressive(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = {"COURSE_PROGRESS_FILE": os.path.join(tmp, "p.json")}
            levels = [run("hint", "working-with-the-shell", "t1", env=env).stdout.splitlines()[0] for _ in range(4)]
        self.assertTrue(levels[0].startswith("Hint 1/3"))
        self.assertTrue(levels[1].startswith("Hint 2/3"))
        self.assertTrue(levels[2].startswith("Hint 3/3"))
        self.assertTrue(levels[3].startswith("Hint 3/3"))

    def test_solution_script_is_valid_bash(self):
        for lab in run("labs").stdout.split():
            with self.subTest(lab=lab):
                rt = run("info", lab, "runtime").stdout.strip()
                args = ["--runtime", "docker"] if lab.endswith("systemd-services") else []
                script = run("solution-script", lab, *args).stdout
                self.assertIn("_remote", script, rt)
                r = subprocess.run(["bash", "-n"], input=script, capture_output=True, text=True)
                self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == "__main__":
    unittest.main()
