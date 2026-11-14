---
id: 01-shell-1/05-bash-shell
title: The Bash Shell
minutes: 14
objectives:
  - Tell shell variables and environment variables apart
  - Understand PATH and how commands are found
  - Make settings persistent in ~/.bashrc and ~/.profile
  - Create aliases, customise PS1 and use the history
prerequisites: [01-shell-1/02-basic-linux-commands]
tryit: ubuntu
---

# The Bash Shell

## Why this matters

Priya's team has a convention: every engineer's prompt shows the user, the
host and the current directory in square brackets, so screenshots in tickets
are unambiguous. The team's tools live in `/opt/tools/bin`, and everyone uses
the same short alias for long listings. To fit in, Bob needs to understand how
Bash is configured — and how to make settings survive a logout.

## Concepts

### Variables

Bash stores settings in **variables**. You create one with `NAME=value` (no
spaces around `=`) and read it with `$NAME`:

```bash
greeting="hello"
echo "$greeting, world"
```

There are two kinds:

- A **shell variable** exists only in the current shell.
- An **environment variable** is also copied to every program the shell
  starts. `export NAME` turns a shell variable into an environment variable
  (`export NAME=value` does both in one step).

`env` (or `printenv`) lists the environment. Well-known environment variables
include `HOME`, `USER`, `SHELL`, `LANG` and — most importantly — `PATH`.

### `PATH`: how commands are found

When you type `ls`, Bash does not search the whole disk. It looks through
the directories listed in `PATH`, separated by colons, **in order**, and runs
the first match:

```text
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

To add a directory, *append* (or prepend) to the existing value — never
replace it, or common commands will stop working in that shell:

```bash
export PATH="$PATH:/opt/tools/bin"
```

### Making it stick: startup files

Anything you type disappears when the shell exits. To make settings
permanent, put them in a startup file that Bash reads when it starts:

| File | Read by | Typical contents |
|---|---|---|
| `~/.bashrc` | every interactive non-login shell (new terminal tabs, `bash`) | aliases, prompt, functions |
| `~/.profile` (or `~/.bash_profile`) | login shells (SSH logins, console logins) | environment variables such as `PATH` |
| `/etc/profile`, `/etc/bash.bashrc` | the same, for all users | system-wide defaults |

On Ubuntu, the default `~/.profile` also *sources* (runs) `~/.bashrc`, so
settings in `~/.bashrc` apply to login shells too. Putting your `PATH` change
in `~/.bashrc` is the simplest choice for this course; on other distributions
check how the two files relate before relying on that.

After editing a startup file, either open a new shell or apply it to the
current one with `source ~/.bashrc` (or the shorter `. ~/.bashrc`).

### Aliases

An **alias** is a shortcut that Bash expands before running the command:

```bash
alias ll='ls -la'
```

`alias` alone lists the current aliases, `unalias ll` removes one, and
`type ll` tells you what it expands to. Aliases belong in `~/.bashrc`.

### The prompt: `PS1`

The prompt is just the value of the `PS1` variable. Bash replaces special
backslash sequences when it prints it:

| Sequence | Expands to |
|---|---|
| `\u` | user name |
| `\h` | short hostname |
| `\w` | full current directory (with `~`) |
| `\W` | only the last part of the current directory |
| `\d`, `\t` | date, time |
| `\$` | `#` for root, `$` for everyone else |

Use **single quotes** when setting `PS1` so the backslashes reach Bash
unchanged: `PS1='[\u@\h \W]$ '`.

### History

Bash remembers what you type. `history` lists previous commands with numbers;
`!42` re-runs command 42, `!!` re-runs the last one, and **Ctrl+R** searches
backwards interactively. The history is saved to `~/.bash_history` when the
shell exits. Use the Up/Down arrows to step through it.

## Try it

Shell versus environment variables — a child process only sees exported ones:

```bash
project=mercury
bash -c 'echo "child sees: [$project]"'
export project
bash -c 'echo "child sees: [$project]"'
```

```text
child sees: []
child sees: [mercury]
```

Inspect `PATH` one directory per line and see where a command comes from:

```bash
echo "$PATH" | tr ':' '\n'
type -a bash
```

```text
/usr/local/sbin
/usr/local/bin
/usr/sbin
/usr/bin
/sbin
/bin
bash is /usr/bin/bash
bash is /bin/bash
```

Create a personal script directory and make it findable:

```bash
mkdir -p ~/bin-demo
printf '#!/bin/bash\necho "hi from my script"\n' > ~/bin-demo/hello
chmod +x ~/bin-demo/hello
export PATH="$PATH:$HOME/bin-demo"
hello
rm -r ~/bin-demo
```

```text
hi from my script
```

Define an alias and ask Bash what it means. (Interactive shells expand
aliases automatically; the `shopt` line is only needed because these
examples run non-interactively.)

```bash
shopt -s expand_aliases
alias lt='ls -lt'
type lt
```

```text
lt is aliased to `ls -lt'
```

Try a new prompt. `${PS1@P}` asks Bash to expand the prompt string exactly as
it would when printing the prompt:

```bash
PS1='[\u@\h \W]$ '
echo "${PS1@P}"
cd /etc
echo "${PS1@P}"
```

```text
[bob@ubuntu ~]$
[bob@ubuntu etc]$
```

## Common mistakes

- **Spaces around `=`.** `PATH = /opt/x` runs a command named `PATH`. Write
  `PATH=/opt/x` (and usually `PATH="$PATH:/opt/x"`).
- **Overwriting `PATH`.** `export PATH=/opt/tools/bin` hides `/usr/bin`, and
  suddenly `ls` is "command not found". Start a new shell to recover, then
  append instead.
- **Double quotes around `PS1`.** Inside double quotes some sequences may be
  expanded once at assignment time; single quotes are safer.
- **Editing `~/.bashrc` and expecting the current shell to change.** Run
  `source ~/.bashrc` or open a new shell.

## Recap

- `NAME=value` sets a shell variable; `export` makes it an environment
  variable that child programs inherit.
- `PATH` is a colon-separated, ordered list of directories searched for
  commands — append to it, don't replace it.
- Persistent aliases, prompts (`PS1`) and variables go in `~/.bashrc` (and
  `~/.profile` for login shells).

## Next

Apply it: `make lab ID=bash-prompt` and configure Bob's shell to the team
standard. Then move on to module 03 (package management) or module 02 once
your VM is ready.
