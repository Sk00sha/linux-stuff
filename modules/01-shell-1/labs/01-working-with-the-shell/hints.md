# Hints — Organise the Asia office notes

## t1

### Level 1

You need three nested directories. One command can create all of them at once.

### Level 2

`mkdir` has an option that creates missing parent directories. Check `mkdir --help`.

### Level 3

`mkdir -p /home/bob/asia/india/mumbai` — run it as bob, without sudo, so bob owns the directories.

## t2

### Level 1

Copy, don't move: the original file must stay in `/home/bob/notes`.

### Level 2

Use `cp SOURCE DESTINATION`. If the destination is a directory, the file keeps its name.

### Level 3

`cp /home/bob/notes/city-guide.txt /home/bob/asia/india/mumbai/`

## t3

### Level 1

On Linux, renaming is the same operation as moving.

### Level 2

`mv OLD NEW` renames a directory and keeps everything inside it.

### Level 3

`mv /home/bob/projetcs /home/bob/projects`

## t4

### Level 1

`rmdir` only removes empty directories, and this one is not empty.

### Level 2

`rm` needs an option to remove directories recursively. Consider `-i` to see what is deleted.

### Level 3

`rm -r /home/bob/old-contractor-tmp` — double-check the path before pressing Enter.

## t5

### Level 1

First run the command and look at what it prints. Then send that output into a file instead of the screen.

### Level 2

`whatis ls` prints the description. The `>` operator redirects output into a file.

### Level 3

`whatis ls > /home/bob/whatis.txt`, then `cat /home/bob/whatis.txt` to confirm.
