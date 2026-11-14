---
id: 01-shell-1/03-command-line-help
title: Command-line Help
minutes: 14
objectives:
  - Get a one-line description of a command with whatis
  - Read manual pages and understand man sections
  - Use --help, apropos and info
prerequisites: [01-shell-1/02-basic-linux-commands]
tryit: ubuntu
---

# Command-line Help

## Why this matters

Marco, the most experienced engineer on Bob's team, still looks things up
every day. The difference between a beginner and an expert is not memory —
it is knowing *where* to look. Linux ships with its documentation built in,
and it works even on a server with no internet access.

## Concepts

### `whatis`: one line, fast

`whatis COMMAND` prints a one-line summary taken from the manual page. It is
the quickest way to answer "what does this command do again?".

### `man`: the manual

`man COMMAND` opens the command's **manual page** in a pager (usually
`less`, so the same keys apply: Space/arrows to scroll, `/text` to search,
`n` for the next match, `q` to quit).

Man pages follow a common layout: **NAME**, **SYNOPSIS** (how to call it —
square brackets mean optional, `...` means "can repeat"), **DESCRIPTION**
(every option explained), and often **EXAMPLES** and **SEE ALSO**.

The manual is divided into numbered **sections**:

| Section | Contents |
|---|---|
| 1 | user commands (`ls`, `cp`) |
| 5 | file formats (`/etc/passwd`, `crontab` files) |
| 8 | system administration commands (`useradd`, `mount`) |
| 2, 3 | system calls and library functions (for programmers) |

Some names exist in several sections. `passwd` is both a command (section 1)
and a file (section 5). `man passwd` shows the first match; `man 5 passwd`
asks for the file format explicitly. When you see `crontab(5)` written in
documentation, it means "the crontab page in section 5".

### `--help`: the built-in summary

Most commands print a compact usage summary with `--help` (some older tools
use `-h`). It is shorter than the man page and often all you need.

Shell builtins such as `cd` do not have their own man pages; use
`help cd` instead.

### `apropos`: search by keyword

When you don't know the command's name, `apropos KEYWORD` searches the
one-line descriptions of all man pages. `apropos -s 8 user` limits the search
to section 8. (`man -k` is the same thing.)

`whatis` and `apropos` read a small database built by `mandb`; on a freshly
installed system it may need to be built once with `sudo mandb`.

### `info` and friends

GNU tools also ship longer manuals in the `info` format (`info coreutils`),
which are organised like a small book with hyperlinks. You will use `man`
far more often, but it is good to know `info` exists.

Outside the system, community projects such as **tldr** offer short,
example-first pages (`tldr tar`). They are a great complement, but always
check the real man page for the version on *your* machine.

## Try it

Get a one-line description of a few commands:

```bash
whatis ls
whatis pwd mkdir
```

```text
ls (1)               - list directory contents
pwd (1)              - print name of current/working directory
mkdir (1)            - make directories
```

The same name in two sections:

```bash
whatis passwd
```

```text
passwd (1)           - change user password
passwd (5)           - the password file
```

Search for commands related to a keyword, then narrow to section 8:

```bash
apropos "user account" 
apropos -s 8 group | head -5
```

```text
userdel (8)          - delete a user account and related files
usermod (8)          - modify a user account
addgroup (8)         - add or manipulate users or groups
adduser (8)          - add or manipulate users or groups
tc-cgroup (8)        - control group based traffic control filter
chgpasswd (8)        - update group passwords in batch mode
cpgr (8)             - copy with locking the given file to the password or gr...
```

Read just the first lines of a man page and a `--help` summary (in real use
you would simply run `man ls` and press `q` to leave). `| head -12` is a
*pipe*: it hands the output to `head`, which keeps the first 12 lines — the
next lesson and module 04 explain pipes properly:

```bash
man ls | head -12
mkdir --help | head -6
help cd | head -3
```

```text
LS(1)                            User Commands                           LS(1)

NAME
       ls - list directory contents

SYNOPSIS
       ls [OPTION]... [FILE]...

DESCRIPTION
       List  information  about  the FILEs (the current directory by default).
       Sort entries alphabetically if none of -cftuvSUX nor --sort  is  speci‐
       fied.
Usage: mkdir [OPTION]... DIRECTORY...
Create the DIRECTORY(ies), if they do not already exist.

Mandatory arguments to long options are mandatory for short options too.
  -m, --mode=MODE   set file mode (as in chmod), not a=rwx - umask
  -p, --parents     no error if existing, make parent directories as needed,
cd: cd [-L|[-P [-e]] [-@]] [dir]
    Change the shell working directory.
```

Save a description to a file — exactly what the first lab will ask of you.
`>` sends a command's output into a file instead of to the screen:

```bash
whatis tree > ~/tree-info.txt
cat ~/tree-info.txt
rm ~/tree-info.txt
```

```text
tree (1)             - list contents of directories in a tree-like format.
```

## Common mistakes

- **"No manual entry for …"** inside minimal containers or cloud images: man
  pages may have been stripped to save space. The course images have them
  restored; on your own servers install the `man-db` package (and on Ubuntu
  minimal images run `unminimize`).
- **Looking for `man cd`.** `cd` is a builtin; use `help cd`.
- **Reading the wrong section.** If a page doesn't make sense, check
  `whatis NAME` to see which sections exist.
- **Getting stuck in the pager.** Press `q` to quit `man` or `less`.

## Recap

- `whatis` for a one-liner, `--help` for a quick summary, `man` for the full
  reference, `apropos` when you don't know the name.
- Man pages are grouped in sections (1 commands, 5 files, 8 admin tools);
  `man 5 passwd` picks a section explicitly.
- Builtins like `cd` are documented with `help`.

## Next

Time to put this into practice. The next lesson explains how the course labs
work, and then you will tackle Bob's first ticket.
