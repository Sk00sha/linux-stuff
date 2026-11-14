---
id: 02-linux-core-concepts/07-file-types
title: Linux File Types
minutes: 15
objectives:
  - Name the seven Linux file types and recognise them in ls -l output
  - Identify files with the file and stat commands
  - Create hard and symbolic links and explain the difference
prerequisites: [02-linux-core-concepts/03-working-with-hardware]
tryit: ubuntu
---

# Linux File Types

## Why this matters

"Everything is a file" is the Linux motto — disks, terminals and even
communication channels between programs appear as entries in the
filesystem. Bob's lab includes a directory of oddly behaving entries: one
can't be opened with an editor, another seems to contain nothing yet makes
`cat` hang. Knowing the file types explains both.

## Concepts

### The seven types

The first character of each `ls -l` line tells you the type:

| Char | Type | Example | What it is |
|---|---|---|---|
| `-` | regular file | `/etc/hostname`, `/usr/bin/ls` | text, binaries, images — data |
| `d` | directory | `/etc` | a list of names pointing to other files |
| `l` | symbolic link | `/bin -> usr/bin` | a pointer to another path |
| `c` | character device | `/dev/null`, `/dev/tty` | a device read/written as a stream of bytes |
| `b` | block device | `/dev/sda`, `/dev/loop0` | a device read/written in blocks (disks) |
| `p` | named pipe (FIFO) | created with `mkfifo` | a one-way channel between two processes |
| `s` | socket | `/run/systemd/notify` | a two-way communication endpoint |

Device files don't contain data; they are doorways into a kernel driver,
identified by a **major** and **minor** number (shown by `ls -l` where the
size normally appears). Writing to `/dev/null` throws data away; reading a
named pipe waits until another process writes to it — which is why `cat`
"hangs".

### Identifying files

- `ls -l` / `ls -ld DIR` — type character and permissions.
- `file PATH` — inspects the *content* and reports what it looks like
  ("ASCII text", "ELF 64-bit executable", "symbolic link to …",
  "block special", "fifo (named pipe)").
- `stat PATH` — full metadata, including a plain-English type line such as
  `regular file` or `character special file`.

Linux does not care about file name extensions: a file called `photo.txt`
can be a JPEG. `file` looks inside to tell you.

### Hard links and symbolic links

A file's data and metadata live in an **inode**; a directory entry is just a
name pointing to an inode.

- A **hard link** (`ln TARGET NAME`) is a second name for the same inode. Both
  names are equal; the data disappears only when the last name is removed.
  Hard links can't point to directories or cross filesystems.
- A **symbolic (soft) link** (`ln -s TARGET NAME`) is a small file that
  contains a *path*. It can point anywhere — another filesystem, a directory,
  even a path that doesn't exist (a "dangling" link). If the target is
  removed, the link breaks.

`readlink NAME` prints where a symlink points; `readlink -f NAME` resolves it
all the way to the final real path. `ls -i` shows inode numbers, so you can
see that hard links share one.

Order matters: `ln -s TARGET LINKNAME` — target first, like `cp SOURCE DEST`.

## Try it

Look at the type character for a few well-known paths:

```bash
ls -ld /etc /etc/hostname /bin /dev/null
```

```text
lrwxrwxrwx 1 root root    7 Apr 22  2024 /bin -> usr/bin
crw-rw-rw- 1 root root 1, 3 Nov 14 20:20 /dev/null
drwxr-xr-x 1 root root 4096 Nov 14 20:20 /etc
-rw-r--r-- 1 root root    7 Nov 14 20:20 /etc/hostname
```

Ask `file` and `stat` for a second opinion:

```bash
file /etc/hostname /usr/bin/ls /bin /dev/null
stat -c '%n: %F' /etc /dev/null
```

```text
/etc/hostname: ASCII text
/usr/bin/ls:   ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=44900829b39271d878615772bb2a6ffa422f0891, for GNU/Linux 3.2.0, stripped
/bin:          symbolic link to usr/bin
/dev/null:     character special (1/3)
/etc: directory
/dev/null: character special file
```

Create a named pipe and see its type:

```bash
mkfifo ~/mypipe
ls -l ~/mypipe
file ~/mypipe
rm ~/mypipe
```

```text
prw-rw-r-- 1 bob bob 0 Nov 14 20:20 /home/bob/mypipe
/home/bob/mypipe: fifo (named pipe)
```

Hard link versus symbolic link:

```bash
cd ~
echo "version 1" > original.txt
ln original.txt hard.txt
ln -s original.txt soft.txt
ls -li original.txt hard.txt soft.txt
rm original.txt
cat hard.txt
cat soft.txt
rm hard.txt soft.txt
```

```text
934900 -rw-rw-r-- 2 bob bob 10 Nov 14 20:20 hard.txt
934900 -rw-rw-r-- 2 bob bob 10 Nov 14 20:20 original.txt
934897 lrwxrwxrwx 1 bob bob 12 Nov 14 20:20 soft.txt -> original.txt
version 1
cat: soft.txt: No such file or directory
```

## Common mistakes

- **Swapping the arguments of `ln -s`.** It's `ln -s TARGET LINKNAME`. If you
  get "File exists", you probably reversed them.
- **Relative symlink targets.** `ln -s file.txt /tmp/link` stores the text
  `file.txt`, which is resolved relative to `/tmp`, not your current
  directory. Use an absolute target when in doubt.
- **Opening device files with an editor.** Never `vi /dev/sda`.
- **Trusting extensions.** Use `file` to see what something really is.

## Recap

- `ls -l` type characters: `-` file, `d` dir, `l` symlink, `c`/`b` character
  and block devices, `p` named pipe, `s` socket.
- `file` inspects content; `stat` reports the type in words.
- Hard links are extra names for an inode; symlinks are pointers to a path
  and can dangle.

## Next

Where do all these files live? The Filesystem Hierarchy Standard.
