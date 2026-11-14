---
id: 04-shell-2/04-io-redirection
title: IO Redirection
minutes: 12
objectives:
  - Name the three standard streams and their numbers
  - Redirect output and errors to files, separately or together
  - Discard output with /dev/null
  - Connect commands with pipes and tee
prerequisites: [04-shell-2/03-searching-for-files-and-patterns]
tryit: ubuntu
---

# IO Redirection

## Why this matters

Mercury's start-up script mixes normal messages and errors on the screen.
Bob wants the normal output in one file and the errors in another so he can
send the errors to the developers. That's what redirection is for — and it's
the glue that makes pipelines possible.

## Concepts

### Three standard streams

Every process starts with three open streams:

| Number | Name | Default |
|---|---|---|
| 0 | **stdin** (standard input) | the keyboard |
| 1 | **stdout** (standard output) | the terminal |
| 2 | **stderr** (standard error) | the terminal |

Programs write results to stdout and problems to stderr. Because both appear
on the terminal they look the same — but the shell can send them to
different places.

### Redirection operators

| Syntax | Effect |
|---|---|
| `cmd > file` | stdout to file (**overwrite**) |
| `cmd >> file` | stdout to file (**append**) |
| `cmd 2> file` | stderr to file |
| `cmd 2>> file` | stderr, append |
| `cmd > out 2> err` | stdout and stderr to separate files |
| `cmd > all 2>&1` | stderr to wherever stdout currently goes — both in one file |
| `cmd &> all` | Bash shortcut for the line above |
| `cmd < file` | stdin read from file |
| `cmd 2> /dev/null` | throw errors away |

`/dev/null` is the character device from module 02 that discards whatever is
written to it.

Order matters with `2>&1`: `cmd > all 2>&1` works, but `cmd 2>&1 > all`
sends stderr to the terminal, because at the moment `2>&1` is processed
stdout still points at the terminal.

### Pipes

`cmd1 | cmd2` connects stdout of `cmd1` to stdin of `cmd2`. Only stdout goes
through the pipe; stderr still reaches the terminal (use `2>&1 |` or `|&`
to send both).

```bash
grep -i error app.log | sort | uniq -c | sort -rn | head
```

### `tee`: save *and* see

`tee FILE` copies its stdin to FILE and to stdout, so you can watch output
and keep a copy. `tee -a` appends. It's also the standard way to write to a
root-owned file from a normal shell: `echo x | sudo tee /etc/file` (because
in `sudo echo x > /etc/file` the redirection is done by *your* shell, without
root).

## Try it

A command that writes to both streams: `ls` of one existing and one missing
path.

```bash mayfail
ls /etc/hostname /nonexistent
```

```text
ls: cannot access '/nonexistent': No such file or directory
/etc/hostname
```

Separate them:

```bash mayfail
cd ~
ls /etc/hostname /nonexistent > out.txt 2> err.txt
echo "stdout file:"; cat out.txt
echo "stderr file:"; cat err.txt
```

```text
stdout file:
/etc/hostname
stderr file:
ls: cannot access '/nonexistent': No such file or directory
```

Combine them, append, and discard:

```bash
cd ~
ls /etc/hostname /nonexistent > all.txt 2>&1
echo "second run" >> all.txt
cat all.txt
ls /etc/hostname /nonexistent 2>/dev/null
rm out.txt err.txt all.txt
```

```text
ls: cannot access '/nonexistent': No such file or directory
/etc/hostname
second run
/etc/hostname
```

Pipes, counting and `tee`:

```bash
cut -d: -f7 /etc/passwd | sort | uniq -c | sort -rn
cut -d: -f1 /etc/passwd | head -3 | tee ~/first-users.txt
wc -l < ~/first-users.txt
rm ~/first-users.txt
```

```text
     18 /usr/sbin/nologin
      2 /bin/bash
      1 /bin/sync
root
daemon
bin
3
```

Writing to a root-owned file: the redirection runs as bob, so it fails;
`tee` running under `sudo` works:

```bash
sudo echo "test" > /etc/demo.conf 2>&1 || echo "redirect failed"
echo "test" | sudo tee /etc/demo.conf
sudo rm /etc/demo.conf
```

```text
bash: line 1: /etc/demo.conf: Permission denied
redirect failed
test
```

## Common mistakes

- **`>` when you meant `>>`.** `>` empties the file first. A single typo can
  wipe a log.
- **`cmd 2>&1 > file`** — wrong order; stderr still goes to the terminal.
- **`sort file > file`.** The shell truncates `file` before `sort` reads it,
  leaving it empty. Write to a new file, then `mv`.
- **`sudo cmd > /root/file`** fails with "Permission denied": use
  `| sudo tee`.

## Recap

- stdin 0, stdout 1, stderr 2; `>`, `>>`, `2>`, `2>&1`, `<`, `/dev/null`.
- `|` passes stdout to the next command; `tee` saves a copy while passing it
  on.
- Order matters for `2>&1`, and `>` overwrites.

## Next

Finally, editing files on servers with nothing but `vi`.
