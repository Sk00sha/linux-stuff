---
id: 01-shell-1/02-basic-linux-commands
title: Basic Linux Commands
minutes: 13
objectives:
  - List directory contents and read the long listing format
  - Create, copy, move, rename and remove files and directories
  - View file contents with cat, less and more
  - Use pushd/popd, type and which
prerequisites: [01-shell-1/01-introduction-to-shell]
tryit: ubuntu
---

# Basic Linux Commands

## Why this matters

Bob's first ticket is mostly housekeeping: build a folder structure, copy a
file into it, rename a badly named directory and delete some junk. These are
the commands you will type hundreds of times a week, so it is worth learning
their most useful options now.

## Concepts

### Listing: `ls`

`ls` lists the contents of a directory (the current one if you give no
argument). The options you will use most:

| Option | Effect |
|---|---|
| `-l` | long format: permissions, owner, size, date |
| `-a` | include hidden files (names starting with `.`) |
| `-h` | human-readable sizes (`4.0K`, `12M`) together with `-l` |
| `-t` | sort by modification time, newest first |
| `-r` | reverse the sort order |
| `-R` | recurse into subdirectories |

A long listing line reads like this:

```text
-rw-r--r-- 1 bob bob 220 Mar 31 08:41 .bash_logout
│          │ │   │   │   │            └── name
│          │ │   │   │   └── last modification time
│          │ │   │   └── size in bytes
│          │ │   └── group owner
│          │ └── user owner
│          └── number of hard links
└── type (- file, d directory, l link) and permissions
```

Permissions are covered in module 06; for now, notice that the first
character tells you whether an entry is a file (`-`) or a directory (`d`).

### Creating: `mkdir` and `touch`

- `mkdir NAME` creates a directory. `mkdir -p a/b/c` creates the whole chain
  and does not complain if parts already exist.
- `touch FILE` creates an empty file if it does not exist (and otherwise just
  updates its timestamp).

### Copying, moving, renaming: `cp` and `mv`

- `cp SOURCE DEST` copies a file. If `DEST` is an existing directory the copy
  goes inside it with the same name.
- `cp -r SRCDIR DEST` copies a directory recursively. Without `-r`, `cp`
  refuses to copy directories.
- `mv SOURCE DEST` moves **or renames** — on Linux they are the same
  operation. `mv draft.txt final.txt` renames; `mv final.txt docs/` moves.

Add `-i` to `cp` or `mv` to be asked before overwriting an existing file, and
`-v` to see what is being done.

### Removing: `rm` and `rmdir`

- `rm FILE` deletes a file. There is **no recycle bin**.
- `rmdir DIR` removes an *empty* directory.
- `rm -r DIR` removes a directory and everything in it. `rm -ri` asks for
  each item, which is a good habit while you are learning.

### Reading files: `cat`, `less`, `more`

- `cat FILE` prints a whole file. Ideal for short files.
- `less FILE` opens a scrollable viewer: arrow keys or Space to move, `/word`
  to search, `q` to quit. Use it for anything longer than a screen.
- `more FILE` is the older, simpler pager; it only scrolls forward.

### Directory stack: `pushd` and `popd`

`pushd DIR` changes to `DIR` and remembers where you came from on a stack;
`popd` returns to the last remembered directory. Handy when you need to pop
into `/etc` for a moment and come back.

### What is this command? `type` and `which`

- `type NAME` tells you how the shell will interpret `NAME`: a shell
  **builtin** (part of Bash itself, like `cd`), an **alias**, a **function**
  or an external **file** on disk.
- `which NAME` prints the path of the external program that would run.
  It knows nothing about builtins or aliases, so `type` is more accurate.

## Try it

Build a small directory tree in one go and look at it:

```bash
mkdir -p ~/practice/2024/reports
touch ~/practice/2024/reports/january.txt ~/practice/todo.txt
ls -R ~/practice
```

```text
/home/bob/practice:
2024  todo.txt

/home/bob/practice/2024:
reports

/home/bob/practice/2024/reports:
january.txt
```

Copy, rename and remove:

```bash
cd ~/practice
cp todo.txt todo-backup.txt
mv 2024/reports/january.txt 2024/reports/jan.txt
cp -r 2024 2025
rm todo-backup.txt
ls -R
```

```text
.:
2024  2025  todo.txt

./2024:
reports

./2024/reports:
jan.txt

./2025:
reports

./2025/reports:
jan.txt
```

Use the directory stack to visit `/etc` and come back:

```bash
cd ~/practice
pushd /etc
pwd
popd
pwd
```

```text
/etc ~/practice
/etc
~/practice
/home/bob/practice
```

Ask the shell what kind of command something is:

```bash
type cd
type ls
type cat
which cat
```

```text
cd is a shell builtin
ls is /usr/bin/ls
cat is /usr/bin/cat
/usr/bin/cat
```

Finally, clean up:

```bash
rm -r ~/practice
ls ~
```

```text
(no output)
```

## Common mistakes

- **`cp dir1 dir2` without `-r`** fails with "omitting directory". Directories
  need `-r`.
- **Accidentally overwriting a file with `cp` or `mv`.** Both silently replace
  an existing destination. Use `-i` until you are confident.
- **`rm -r` in the wrong directory.** Run `pwd` (or use an absolute path)
  before recursive deletes. Never run `rm -rf /` or `rm -rf ~` "to see what
  happens".
- **Spaces in names.** `mkdir my files` creates *two* directories, `my` and
  `files`. Quote the name: `mkdir "my files"`.

## Recap

- `ls -la` shows everything, including hidden files, in long format.
- `mkdir -p`, `touch`, `cp -r`, `mv` and `rm -r` cover creating, copying,
  moving/renaming and deleting — and deletions are permanent.
- `type` explains how the shell will run a name; `which` finds external
  programs.

## Next

Nobody remembers every option. The next lesson shows how to get help from
the system itself.
