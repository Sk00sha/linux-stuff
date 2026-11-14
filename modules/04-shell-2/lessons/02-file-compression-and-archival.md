---
id: 04-shell-2/02-file-compression-and-archival
title: File Compression and Archival
minutes: 15
objectives:
  - Measure disk usage with du
  - Create, list and extract tar archives
  - Compress and decompress with gzip, bzip2 and xz
  - Read compressed files without extracting them
prerequisites: [04-shell-2/01-behind-schedule]
tryit: ubuntu
---

# File Compression and Archival

## Why this matters

A month of CSV reports is eating Bob's disk. The standard fix is to bundle
them into one **archive** and **compress** it, then remove the originals.
These are separate steps on Linux — `tar` archives, `gzip` (and friends)
compress — though `tar` can call the compressor for you.

## Concepts

### How much space? `du`

`du` (disk usage) adds up the space used by files and directories.

- `du -sh DIR` — **s**ummary of one directory, **h**uman-readable.
- `du -h --max-depth=1 DIR` — one line per subdirectory.
- `du -sh * | sort -h` — what's biggest here?

(`df -h`, covered in module 08, shows free space per filesystem.)

### Archiving: `tar`

`tar` (tape archive) packs many files and directories, with their
permissions and timestamps, into one file. It doesn't compress by itself.

| Option | Meaning |
|---|---|
| `-c` | **c**reate an archive |
| `-x` | e**x**tract |
| `-t` | lis**t** contents |
| `-f FILE` | the archive **f**ile to use (always needed; put it right after the options) |
| `-v` | **v**erbose: print each file |
| `-z` / `-j` / `-J` | compress with gzip / bzip2 / xz |
| `-C DIR` | change to DIR first (extract somewhere else, or archive relative paths) |

Typical commands:

```bash
tar -czvf reports.tar.gz reports/     # create gzip-compressed archive
tar -tzf reports.tar.gz               # list it
tar -xzf reports.tar.gz -C /tmp       # extract into /tmp
```

Modern GNU tar detects compression when extracting, so `tar -xf file.tar.xz`
works too.

### Compressing single files

| Tool | Compress | Decompress | Extension | Notes |
|---|---|---|---|---|
| gzip | `gzip f` | `gunzip f.gz` | `.gz` | fast, everywhere |
| bzip2 | `bzip2 f` | `bunzip2 f.bz2` | `.bz2` | smaller, slower |
| xz | `xz f` | `unxz f.xz` | `.xz` | smallest, slowest to compress |

By default these tools **replace** the original file with the compressed
one. Use `-k` to keep the original, and `-d` as an alternative way to
decompress (`gzip -d`).

### Reading compressed files directly

`zcat`, `zless` and `zgrep` work on `.gz` files without decompressing them
on disk (`bzcat`/`xzcat` exist for the others). Rotated logs such as
`/var/log/syslog.2.gz` are read this way.

## Try it

Create some sample "reports" and see how much space they use:

```bash
mkdir -p ~/reports
for d in 01 02 03 04 05; do seq 1 20000 | sed "s/$/,report-2026-11-$d/" > ~/reports/day-$d.csv; done
du -sh ~/reports
ls ~/reports
```

```text
2.3M	/home/bob/reports
day-01.csv  day-02.csv	day-03.csv  day-04.csv	day-05.csv
```

Archive and compress in one step, then compare sizes:

```bash
cd ~
tar -czf reports.tar.gz reports
ls -lh reports.tar.gz
tar -tzf reports.tar.gz
```

```text
-rw-rw-r-- 1 bob bob 271K Nov 14 20:28 reports.tar.gz
reports/
reports/day-05.csv
reports/day-01.csv
reports/day-03.csv
reports/day-04.csv
reports/day-02.csv
```

Extract somewhere else to check it's complete:

```bash
mkdir -p /tmp/restore
tar -xzf ~/reports.tar.gz -C /tmp/restore
diff -r ~/reports /tmp/restore/reports && echo "identical"
```

```text
identical
```

Compress a single file, keep the original, and read it without unpacking:

```bash
cd ~/reports
gzip -k day-01.csv
xz -k day-02.csv
ls -lh day-01.csv* day-02.csv*
zcat day-01.csv.gz | head -2
zgrep -c report day-01.csv.gz
```

```text
-rw-rw-r-- 1 bob bob 458K Nov 14 20:28 day-01.csv
-rw-rw-r-- 1 bob bob  54K Nov 14 20:28 day-01.csv.gz
-rw-rw-r-- 1 bob bob 458K Nov 14 20:28 day-02.csv
-rw-rw-r-- 1 bob bob 7.8K Nov 14 20:28 day-02.csv.xz
1,report-2026-11-01
2,report-2026-11-01
20000
```

Clean up:

```bash
rm -rf ~/reports ~/reports.tar.gz /tmp/restore
```

## Common mistakes

- **Putting something between `-f` and the file name.** `tar -cfz x.tgz dir`
  creates an archive literally called `z`. Keep `f` last: `-czf x.tgz`.
- **Archiving with absolute paths.** `tar -czf r.tgz /home/bob/reports`
  stores `home/bob/reports/…`; use `-C /home/bob reports` to store a short
  path.
- **Expecting `gzip` to keep the original.** It replaces it unless you add
  `-k`.
- **Compressing already-compressed data** (`.jpg`, `.gz`, `.zip`): it won't
  get smaller.

## Recap

- `du -sh` measures; `tar -czf` creates, `-tzf` lists, `-xzf` extracts
  (`-j` bzip2, `-J` xz, `-C` to change directory).
- `gzip`, `bzip2`, `xz` compress single files (replace by default, `-k` to
  keep).
- `zcat`, `zless`, `zgrep` read `.gz` files directly.

## Next

Finding the files you need — and the lines inside them.
