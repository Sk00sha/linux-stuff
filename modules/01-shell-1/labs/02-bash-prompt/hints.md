# Hints — Configure Bob's shell to the team standard

## t1

### Level 1

The prompt is the value of the `PS1` variable. Setting it in your current shell is a good test, but it must also be set every time a new shell starts.

### Level 2

Put the assignment at the **end** of `~/.bashrc` (so nothing later in the file overrides it). Use single quotes so the backslashes are kept.

### Level 3

`echo "PS1='[\u@\h \W]\$ '" >> ~/.bashrc` then `source ~/.bashrc`. Check with `tail -1 ~/.bashrc` that the line reads `PS1='[\u@\h \W]$ '`.

## t2

### Level 1

`PATH` is a colon-separated list. You want to add one directory to the end of the existing list, in a startup file.

### Level 2

`export PATH="$PATH:/opt/tools/bin"` adds the directory. Put that line in `~/.bashrc`.

### Level 3

`echo 'export PATH="$PATH:/opt/tools/bin"' >> ~/.bashrc` — single quotes, so `$PATH` is written literally into the file and expanded each time the shell starts.

## t3

### Level 1

Aliases are defined with the `alias` builtin and, like the prompt, must be in a startup file to persist.

### Level 2

The syntax is `alias name='command with options'`, with no spaces around `=`.

### Level 3

`echo "alias ll='ls -la'" >> ~/.bashrc`, then open a new shell and run `type ll`.
