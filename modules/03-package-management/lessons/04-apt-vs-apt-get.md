---
id: 03-package-management/04-apt-vs-apt-get
title: APT vs APT-GET
minutes: 8
objectives:
  - Explain the difference between apt and apt-get/apt-cache
  - Choose the right one for interactive use and for scripts
prerequisites: [03-package-management/03-dpkg-and-apt]
short: true  # spec: no quiz or 3 questions
tryit: ubuntu
---

# APT vs APT-GET

## Why this matters

Bob notices that Marco's old setup scripts all use `apt-get`, while the
Ubuntu documentation says `apt`. Both work — but one of them prints a
warning when used in scripts, and there's a good reason.

## Concepts

`apt-get` and `apt-cache` are the original APT front ends, dating from 1998.
`apt-get` installs and removes; `apt-cache` searches and shows. Over the
years they collected many options, and their output format became something
scripts depend on.

In 2014 APT 1.0 introduced **`apt`**: a single command combining the most
common operations of both, with friendlier defaults for humans — a progress
bar, colour, and a summary of upgradable packages after `apt update`.

| Task | `apt` | Classic equivalent |
|---|---|---|
| refresh indexes | `apt update` | `apt-get update` |
| install / remove | `apt install`, `apt remove` | `apt-get install`, `apt-get remove` |
| upgrade, allowing new dependencies | `apt upgrade` | `apt-get upgrade --with-new-pkgs` |
| search | `apt search` | `apt-cache search` |
| details | `apt show` | `apt-cache show` |
| list packages | `apt list --installed` | `dpkg -l` |
| edit sources | `apt edit-sources` | (edit files by hand) |

### Which one to use?

- **At the keyboard:** `apt`. It's shorter and clearer.
- **In scripts, Dockerfiles and automation:** `apt-get` and `apt-cache`.
  Their command-line interface and output are kept stable between releases;
  `apt`'s output may change and it warns you when it isn't talking to a
  terminal.

Both use the same repositories, cache and database, so you can mix them
freely on one machine.

## Try it

Both find the same package:

```bash
apt-cache policy tree | head -3
apt policy tree 2>/dev/null | head -3
```

```text
tree:
  Installed: 2.1.1-2ubuntu3.24.04.2
  Candidate: 2.1.1-2ubuntu3.24.04.2
tree:
  Installed: 2.1.1-2ubuntu3.24.04.2
  Candidate: 2.1.1-2ubuntu3.24.04.2
```

`apt` warns when its output goes to a pipe instead of a person:

```bash keepoutput
apt list --installed 2>&1 | head -1
```

```text
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
```

`apt-cache` is the scripting-friendly way to ask questions:

```bash
apt-cache show tree | grep -m1 '^Version'
apt-cache rdepends --installed libc6 | head -3
```

```text
Version: 2.1.1-2ubuntu3.24.04.2
libc6
Reverse Depends:
  libsqlite3-0
```

## Common mistakes

- **Using `apt` in a Dockerfile** and being surprised by the warning, or by
  output changing after an upgrade. Use `apt-get` in automation.
- **Believing they install different things.** Same repositories, same
  packages, same database.

## Recap

- `apt` is the friendly interactive front end; `apt-get`/`apt-cache` are the
  stable, script-friendly originals.
- They share configuration, cache and package database.
- Rule of thumb: humans type `apt`, scripts call `apt-get`.

## Next

Time for the labs: `make lab ID=yum-and-rpm` (Rocky) and
`make lab ID=dpkg-and-apt` (Ubuntu).
