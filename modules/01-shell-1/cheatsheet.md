# Cheatsheet — Working with Shell I

## Where am I?

| Command | Does |
|---|---|
| `pwd` | print working directory |
| `cd DIR` / `cd` / `cd -` / `cd ..` | change directory / go home / previous dir / up one |
| `pushd DIR` / `popd` | change dir and remember / go back |
| `echo $SHELL` | your login shell |

## Files and directories

| Command | Does |
|---|---|
| `ls -la` / `ls -lh` / `ls -ltr` / `ls -R` | all + long / human sizes / oldest first / recursive |
| `mkdir -p a/b/c` | create a directory chain |
| `touch FILE` | create empty file / update timestamp |
| `cp SRC DST` / `cp -r SRCDIR DST` | copy file / copy directory |
| `mv OLD NEW` | rename or move |
| `rm FILE` / `rm -r DIR` / `rm -ri DIR` | delete file / directory tree / asking first |
| `rmdir DIR` | remove empty directory |
| `cat FILE` / `less FILE` / `more FILE` | print / page (q quits, /word searches) |
| `type NAME` / `which NAME` | how Bash runs NAME / path of external program |

## Help

| Command | Does |
|---|---|
| `whatis CMD` | one-line description |
| `man CMD` / `man 5 FILE` | manual page / from a specific section |
| `CMD --help` | quick usage summary |
| `help BUILTIN` | help for builtins like `cd` |
| `apropos WORD` / `apropos -s 8 WORD` | search man page descriptions |
| `sudo mandb` | rebuild the whatis/apropos database |

## Bash

| Command | Does |
|---|---|
| `NAME=value` / `export NAME=value` | shell variable / environment variable |
| `env` / `printenv NAME` | show environment |
| `export PATH="$PATH:/opt/tools/bin"` | append to PATH |
| `alias ll='ls -la'` / `unalias ll` / `alias` | define / remove / list aliases |
| `PS1='[\u@\h \W]$ '` | prompt: user, host, dir basename |
| `source ~/.bashrc` | re-read startup file |
| `history` / `!!` / `!42` / Ctrl+R | history / last / number 42 / search |

Startup files: `~/.bashrc` (interactive shells), `~/.profile` (login shells).
