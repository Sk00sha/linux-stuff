---
id: 04-shell-2/03-searching-for-files-and-patterns
title: Searching for Files and Patterns
minutes: 13
objectives:
  - Find files by name with locate and by properties with find
  - Run a command on every file find returns
  - Search inside files with grep and its most useful options
  - Write simple regular expressions
prerequisites: [04-shell-2/02-file-compression-and-archival]
tryit: ubuntu
---

# Searching for Files and Patterns

## Why this matters

Somewhere under `/var/app` are the log files that keep growing, and inside
one of them are the error lines that explain the weekend's crashes. Bob
needs to search two different ways: for **files** by their name, size or
age, and for **text** inside files.

## Concepts

### `locate`: fast name search from a database

`locate NAME` searches a pre-built database of file paths, so it's instant —
but only as fresh as the database. `sudo updatedb` rebuilds it (a daily job
usually does). New files won't show up until then.

### `find`: search the live filesystem by any property

```text
find WHERE  TESTS...  ACTION
find /var/app -name '*.log' -size +1M -print
```

Common tests:

| Test | Matches |
|---|---|
| `-name 'pat'` / `-iname 'pat'` | name matches a wildcard pattern (case-insensitive with `i`) — **quote it** |
| `-type f` / `-type d` / `-type l` | regular files / directories / symlinks |
| `-size +1M` / `-size -10k` | bigger than 1 MiB / smaller than 10 KiB |
| `-mtime -7` / `-mtime +30` | modified less than 7 / more than 30 days ago |
| `-user bob` / `-perm -o+w` | owned by bob / writable by others |
| `-maxdepth 2` | don't descend more than two levels |

Tests are combined with AND by default; `-o` means OR and `!` means NOT.

Actions:

- `-print` (the default) prints each path.
- `-delete` deletes matches — run without it first.
- `-exec CMD {} \;` runs `CMD` once per match, with `{}` replaced by the
  path. `-exec CMD {} +` passes many paths at once (faster).

### `grep`: search inside files

`grep PATTERN FILE...` prints lines that match.

| Option | Effect |
|---|---|
| `-i` | ignore case |
| `-v` | invert: lines that do **not** match |
| `-w` | match whole words only (`error` but not `errors`) |
| `-r` | recurse into directories |
| `-n` | show line numbers |
| `-c` | count matching lines |
| `-l` | list only file names that contain a match |
| `-A N` / `-B N` / `-C N` | also show N lines **a**fter / **b**efore / around |
| `-E` | extended regular expressions (`a\|b`, `+`, `?`, `()`) |

### A little regular expression

| Pattern | Means |
|---|---|
| `^ERROR` | ERROR at the start of the line |
| `timeout$` | timeout at the end |
| `.` | any one character |
| `[0-9]` | one digit |
| `x*` | zero or more `x` |
| `(warn\|error)` with `-E` | either word |

Quote patterns with single quotes so the shell doesn't interpret `*`, `$` or
`|` itself.

## Try it

Set up a small log directory to search:

```bash
mkdir -p ~/app/logs/old
printf 'INFO start\nWARN slow query\nERROR db timeout\ninfo done\nError: disk full\n' > ~/app/logs/app.log
printf 'INFO ok\n' > ~/app/logs/old/app-2026-10.log
head -c 2M /dev/zero > ~/app/logs/huge.log
touch -d '45 days ago' ~/app/logs/old/app-2026-10.log
find ~/app -type f
```

```text
/home/bob/app/logs/huge.log
/home/bob/app/logs/app.log
/home/bob/app/logs/old/app-2026-10.log
```

Find by size, by age, and act on the results:

```bash
find ~/app -name '*.log' -size +1M
find ~/app -type f -mtime +30
find ~/app -name '*.log' -exec ls -sh {} \;
```

```text
/home/bob/app/logs/huge.log
/home/bob/app/logs/old/app-2026-10.log
2.0M /home/bob/app/logs/huge.log
4.0K /home/bob/app/logs/app.log
4.0K /home/bob/app/logs/old/app-2026-10.log
```

Search inside files — note how `-i`, `-w` and `-v` change the result:

```bash
cd ~/app/logs
grep ERROR app.log
grep -i error app.log
grep -vi info app.log
grep -n -E '^(WARN|ERROR)' app.log
grep -rl timeout ~/app
```

```text
ERROR db timeout
ERROR db timeout
Error: disk full
WARN slow query
ERROR db timeout
Error: disk full
2:WARN slow query
3:ERROR db timeout
/home/bob/app/logs/app.log
```

Context around a match:

```bash
grep -A1 -B1 timeout ~/app/logs/app.log
```

```text
WARN slow query
ERROR db timeout
info done
```

`locate` uses its database — a new file isn't there until `updatedb` runs:

```bash
locate -c app.log
sudo updatedb
locate app.log
rm -rf ~/app
```

```text
0
/home/bob/app/logs/app.log
```

## Common mistakes

- **Unquoted wildcards in `find -name`.** `find . -name *.log` lets the shell
  expand `*.log` first; quote it: `-name '*.log'`.
- **Forgetting `\;` at the end of `-exec`.** It must be there (escaped).
- **Running `find … -delete` before checking.** Run it without `-delete`
  first.
- **Expecting `locate` to find a brand-new file.** Run `sudo updatedb`.
- **Using `grep -r` on `/`.** It reads `/proc` and `/sys`; search a specific
  directory.

## Recap

- `locate` is fast but database-based; `find` searches live by name, type,
  size, time, owner and permissions, and can `-exec` commands.
- `grep` searches text: `-i`, `-v`, `-w`, `-r`, `-n`, `-c`, `-l`, `-A/-B/-C`,
  `-E`.
- Quote patterns and wildcards with single quotes.

## Next

Sending output — and errors — exactly where you want them.
