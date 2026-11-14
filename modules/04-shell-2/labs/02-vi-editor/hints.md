# Hints — Fix the Mercury config with vi

## t1

### Level 1

Open the file with `vi /home/bob/mercury.conf`, find the line, and change the number. Esc gets you back to normal mode.

### Level 2

Search with `/8080` and Enter. On the match, `cw` (change word) or `x` to delete characters and `i` to insert.

### Level 3

`/8080` Enter, then `cw80` Esc. Or the command `:%s/8080/80/` and Enter.

## t2

### Level 1

Several lines contain the word. vi can substitute across the whole file in one command.

### Level 2

`:%s/OLD/NEW/g` — `%` means every line, `g` every match on a line.

### Level 3

`:%s/development/production/g`

## t3

### Level 1

Go to the line, then use the normal-mode command that deletes a whole line.

### Level 2

`/debug_password` to jump there, then `dd`.

### Level 3

`/^debug_password` Enter `dd` (and `u` if you deleted the wrong line).

## t4

### Level 1

Jump to the last line, open a new line below it and type.

### Level 2

`G` goes to the last line; `o` opens a new line below and enters insert mode.

### Level 3

`G` `o` `demo_client = halvorsen` Esc `:wq`

## t5

### Level 1

Swap files are hidden files whose names start with a dot. `ls -a` shows them.

### Level 2

When vim warns about the swap file, it offers to delete it. Otherwise remove it with `rm` after quitting vim.

### Level 3

`ls -a /home/bob | grep swp`, then `rm /home/bob/.mercury.conf.swp`.
