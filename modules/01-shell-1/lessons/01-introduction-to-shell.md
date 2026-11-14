---
id: 01-shell-1/01-introduction-to-shell
title: Introduction to the Shell
minutes: 12
objectives:
  - Explain the difference between a terminal and a shell
  - Read the parts of a shell prompt
  - Run commands with arguments and options
  - Navigate with pwd and cd using absolute and relative paths
prerequisites: []
tryit: ubuntu
---

# Introduction to the Shell

## Why this matters

Bob's dev box has no graphical desktop, and neither will most of the servers
he will ever look after. Servers are usually managed remotely, over a text
connection, because text is light, scriptable and works even when the
network is slow. The program that reads what you type and runs it is called
the **shell**. Learning to use it is the single most useful Linux skill you
can have.

## Concepts

### Terminal vs shell

People use the two words interchangeably, but they are different things:

- A **terminal** (or terminal emulator) is the window that displays text and
  sends your keystrokes somewhere. GNOME Terminal, Windows Terminal, iTerm2
  and the web console of a cloud provider are all terminals.
- A **shell** is the program running *inside* the terminal. It reads a line
  of text, works out what you meant, runs the right program and shows you
  the result. Popular shells are **Bash** (the default on most Linux
  distributions), **Zsh** (the default on macOS) and **sh/dash** (small and
  fast, used mostly for scripts).

You can check which shell your account uses by default:

```bash
echo $SHELL
```

`$SHELL` is a *variable* holding the path of your login shell. You will meet
variables properly in the Bash lesson.

### Reading the prompt

When the shell is ready for input it prints a **prompt**. A typical Ubuntu
prompt looks like this:

```text
bob@ubuntu:~/projects$
```

| Part | Meaning |
|---|---|
| `bob` | the user you are logged in as |
| `ubuntu` | the hostname of the machine |
| `~/projects` | the current working directory (`~` = your home directory) |
| `$` | you are a normal user; the root (administrator) account shows `#` |

Prompts can be customised, so other machines may look different — but the
`$`/`#` convention is almost universal. Watch for `#`: it means every command
you type runs with full administrator power.

### Commands, arguments and options

A command line is split on spaces into words. The first word is the
**command**; the rest are **arguments** passed to it. Arguments that start
with a dash are usually **options** (also called flags) that change the
command's behaviour:

```text
ls  -l  /etc
│    │    └── argument: what to list
│    └─────── option: long listing format
└──────────── command
```

Short options are one letter after a single dash (`-l`) and can often be
combined (`-la` is the same as `-l -a`). Long options use two dashes and a
word (`--all`). Linux is **case-sensitive**: `-a` and `-A` are different
options, and `ls` is not the same as `LS`.

### Where am I? Paths and the working directory

Linux organises files in a single tree that starts at `/`, the **root
directory**. Every process, including your shell, has a **current working
directory**. `pwd` (print working directory) shows it, and `cd` (change
directory) moves you.

A **path** names a location in the tree:

- An **absolute path** starts with `/` and is spelled out from the root:
  `/home/bob/projects`. It means the same thing no matter where you are.
- A **relative path** does not start with `/` and is interpreted from your
  current directory: if you are in `/home/bob`, then `projects` means
  `/home/bob/projects`.

A few special names help you move quickly:

| Name | Meaning |
|---|---|
| `.` | the current directory |
| `..` | the parent directory (one level up) |
| `~` | your home directory (`/home/bob` for Bob) |
| `-` | with `cd`: the previous directory you were in |

Running `cd` with no argument always takes you home.

## Try it

Check which shell you are using and where you are:

```bash
echo $SHELL
pwd
```

```text
/bin/bash
/home/bob
```

Move around using an absolute path, then relative paths:

```bash
cd /usr/share
pwd
cd doc
pwd
cd ..
pwd
```

```text
/usr/share
/usr/share/doc
/usr/share
```

Jump home, and back to where you were with `cd -` (it prints the directory it
returns to):

```bash
cd /etc
cd ~
pwd
cd -
```

```text
/home/bob
/etc
```

Options change behaviour, and case matters:

```bash
ls /etc/skel
ls -a /etc/skel
ls -A /etc/skel
```

```text
.  ..  .bash_logout  .bashrc  .profile
.bash_logout  .bashrc  .profile
```

The first `ls` printed nothing at all: the directory only contains *hidden*
files (names starting with a dot), which `ls` skips unless you ask with
`-a` (all, including `.` and `..`) or `-A` (almost all).

## Common mistakes

- **Typing `cd/etc`** without a space. The shell looks for a command called
  `cd/etc` and fails. Commands and arguments are separated by spaces.
- **Forgetting that paths are case-sensitive.** `/home/Bob` and `/home/bob`
  are different directories.
- **Mixing up `/` and `~`.** `/` is the root of the whole system; `~` is your
  own home directory.
- **Working as root "just because".** If your prompt ends in `#`, double-check
  every command before pressing Enter.

## Recap

- The terminal shows text; the shell (usually Bash) interprets your commands.
- A command line is a command followed by options and arguments, separated by
  spaces, and everything is case-sensitive.
- `pwd` shows where you are; `cd` moves you using absolute (`/…`) or relative
  paths, with `.`, `..`, `~` and `-` as shortcuts.

## Next

Now that Bob can move around, the next lesson shows how to create, copy,
move and delete files and directories.
