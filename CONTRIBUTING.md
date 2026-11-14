# Contributing

Thanks for helping improve Linux Basics — Hands-On. This page explains how
the course is put together and the rules every change must follow.

## Ground rules

- **Original content only.** Don't paste text, slides or lab wording from
  other courses, books or blogs. Topic lists are fine; prose is not.
- **Beginner-friendly but accurate.** Introduce a command before using it
  (check the lesson's `prerequisites`), call out distribution differences
  (`cron` vs `crond`, `/var/log/syslog` vs `/var/log/messages`, `sudo` vs
  `wheel`), and prefer modern tools (`ip`, `ss`, `dnf`, systemd targets),
  mentioning the classic ones they replace.
- **Never touch the learner's host.** Kernel and disk work happens only on
  the course VM; every VM lab's `setup.sh` calls `require_vm`.
- Content is CC BY-SA 4.0, tooling MIT (see the licence files). By
  contributing you agree to license your work under them.

## Layout and the single source of truth

`course.yaml` lists every module and, in order, its items:

```yaml
- id: 01-shell-1
  title: Working with Shell I
  runtime: docker
  items:
    - {type: story,  path: modules/01-shell-1/00-story.md}
    - {type: lesson, path: modules/01-shell-1/lessons/01-introduction-to-shell.md, minutes: 7}
    - {type: quiz,   path: modules/01-shell-1/quizzes/01-introduction-to-shell.yaml}
    - {type: lab,    path: modules/01-shell-1/labs/01-working-with-the-shell}
```

A lesson's quiz must come right after it. After changing `course.yaml`, run
`make syllabus` (a test fails if `SYLLABUS.md` is stale).

## YAML subset

The CLI uses only the Python standard library, so YAML is read by
`lib/miniyaml.py`, which supports a subset: block mappings and sequences,
one-line flow collections (`{a: b}`, `[a, b]`), plain/quoted scalars and
`|`/`>` block scalars. No anchors, tags or multi-line flow collections.
**Quote any value containing `: `, ` #` or a comma inside a flow
collection.** The tests compare miniyaml with PyYAML whenever PyYAML is
installed.

## Lessons

Front-matter, then the sections in exactly this order:

```markdown
---
id: 04-shell-2/03-searching-for-files-and-patterns
title: Searching for Files and Patterns
minutes: 12
objectives: [...]
prerequisites: [04-shell-2/02-file-compression-and-archival]
tryit: ubuntu            # ubuntu | rocky | systemd | vm | none | lab:<service>
quiz: false              # only for lessons without a quiz (story-style intros)
---

# Title
## Why this matters      (tie it to Bob)
## Concepts
## Try it                (>= 3 runnable bash blocks, each followed by a text block with its output)
## Common mistakes
## Recap                 (exactly three bullets)
## Next
```

Lessons with a quiz are 600–1,500 words. `minutes` is computed as words/150
plus 1.5 minutes per runnable exercise.

### Try it blocks

`tests/tryit.py` runs every `bash` block of the "Try it" section inside the
lesson's runtime, as bob, in one container per lesson, and fails if a block
exits non-zero. With `--update` it pastes the **real** output into the
`text` block that follows each command block. Fence flags:

| Flag | Meaning |
|---|---|
| `norun` | shown to the learner but never executed (host commands, interactive programs) |
| `mayfail` | a non-zero exit is expected (e.g. demonstrating an error) |
| `keepoutput` | run it, but keep the hand-checked output (TTY artefacts) |
| `novmcheck` | for `tryit: vm` lessons: skip when verifying inside a container (needs a real kernel or disks) |

```bash
python3 tests/tryit.py modules/04-shell-2                  # verify
python3 tests/tryit.py --update modules/04-shell-2         # refresh outputs, then review the diff
python3 tests/tryit.py --vm-in-docker modules/02-linux-core-concepts
```

## Quizzes

4–6 questions (3 allowed for lessons marked `short: true`), options `a`–`d`
(up to `f`), exactly one `answer`, an `explanation` for every question, no
trick questions, plausible distractors. Vary the position of the correct
answer.

## Labs

```text
labs/NN-name/
  lab.yaml      id, title, runtime (docker|vm), services, login, minutes, tasks t1..tN
                optional: fallback {runtime, services, login}, hide_tasks
  README.md     the assignment, with a task table; mention make lab/check ID=<name>
  setup.sh      idempotent: reset to the starting state; ends with mark_lab
  check.sh      read-only grader: check_t1..check_tN, then run_tasks t1 .. tN
  hints.md      "## tN" sections, each with exactly three "###" levels
  solution.md   explanation + "bash solution target=<svc> user=<user>" code blocks
```

### check.sh contract

- `set -uo pipefail`, source `lib/check-helpers.sh`, `require_lab SVC LAB`.
- One function per task printing `PASS tN` or `FAIL tN: <what was
  observed>` — describe the observation, never the fix.
- Never change state. (Exceptions must be part of the task text, like the
  systemd lab's kill-and-restart check.)
- Use `run_on SVC CMD`, `run_as SVC USER CMD` and the `assert_*` helpers; they
  work the same for Docker (`docker exec`) and the VM (Vagrant, Multipass,
  Incus, Lima).

### Solutions are tested

`tests/test_labs.sh` extracts the `bash solution` blocks and proves each lab
is solvable: setup → check fails → solution → check passes → reset → check
fails again.

```bash
make test                              # unit tests + shellcheck + markdownlint
make test-labs MODULE=06               # end-to-end, needs Docker
RUNTIME=vm bash tests/test_labs.sh 08  # VM labs, needs a running course VM
```

Docker labs must not depend on the internet at check time: bake packages
into the images (see the Dockerfiles' offline caches).
