---
id: 04-shell-2/01-behind-schedule
title: "Behind Schedule: A Plan of Attack"
minutes: 5
objectives:
  - See how the tools of this module fit together
prerequisites: [01-shell-1/05-bash-shell]
tryit: ubuntu
---

# Behind Schedule: A Plan of Attack

## Why this matters

Bob's problems — too much data, hard to find, hard to read, hard to edit —
are the everyday problems of anyone running servers. The Unix answer is a
set of small tools that each do one job well and can be **combined**.

## Concepts

The plan for today, and the lesson that covers each part:

| Problem | Tool | Lesson |
|---|---|---|
| Old reports filling the disk | `du`, `tar`, `gzip`/`xz` | File Compression and Archival |
| Which log files are huge or old? | `find` | Searching for Files and Patterns |
| Which lines mention errors? | `grep` | Searching for Files and Patterns |
| Output and errors mixed together | `>`, `2>`, `|`, `tee` | IO Redirection |
| Config must be edited on a bare server | `vi` | VI Editor |

The key idea is the **pipeline**: the output of one command becomes the
input of the next, joined by `|`. Marco's sticky note chains `find` (select
files), `ls -lh` (describe them) and `tee` (show *and* save the result),
while `2>/dev/null` hides "permission denied" noise.

## Try it

A taste of what's coming — each piece is explained in the next lessons.

How big is the documentation directory?

```bash
du -sh /usr/share/doc
```

```text
11M	/usr/share/doc
```

Which files in `/etc` are bigger than 20 KB?

```bash
find /etc -type f -size +20k 2>/dev/null | head -3
```

```text
/etc/ssh/moduli
/etc/mime.types
```

How many lines in `/etc/passwd` mention `nologin`?

```bash
grep -c nologin /etc/passwd
```

```text
18
```

## Common mistakes

- **Trying to do everything with one giant command.** Build pipelines step by
  step: run the first command, check its output, then add the next stage.

## Recap

- Small tools, combined with pipes, solve big problems.
- This module: archive/compress, find/grep, redirection, vi.
- Build pipelines incrementally.

## Next

Start with the disk: archiving and compressing.
