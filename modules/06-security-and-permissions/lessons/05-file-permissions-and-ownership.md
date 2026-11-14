---
id: 06-security-and-permissions/05-file-permissions-and-ownership
title: File Permissions and Ownership
minutes: 20
objectives:
  - Read rwx permissions for user, group and others
  - Change permissions with chmod in symbolic and octal notation
  - Change owners and groups with chown and chgrp
  - Explain umask and the setuid, setgid and sticky bits
prerequisites: [06-security-and-permissions/04-user-management]
tryit: ubuntu
---

# File Permissions and Ownership

## Why this matters

On devbox the project files were world-writable: any account — including
`intruder` — could change Mercury's code. The fix is the Linux permission
model, which is simple enough to learn in an afternoon and important enough
to use every day.

## Concepts

### Three classes, three permissions

Every file has an owner **user**, an owner **group** and permissions for
three classes:

```text
-rwxr-x---  1 bob devops 1204 Nov 14 09:00 deploy.sh
 └┬┘└┬┘└┬┘      │    │
  u  g  o       │    └─ group owner
                └─ user owner
```

| Bit | On a file | On a directory |
|---|---|---|
| `r` read | read the contents | list the names inside (`ls`) |
| `w` write | change the contents | create, delete, rename entries inside |
| `x` execute | run it as a program | enter it (`cd`) and access entries by name |

The kernel checks **one** class: if you're the owner, the user bits apply;
else if you're in the group, the group bits; else the others bits. (Root
bypasses these checks.)

Deleting a file depends on the **directory's** `w` permission, not the
file's.

### Octal notation

Each class is a sum: r=4, w=2, x=1.

| Octal | Bits | Typical use |
|---|---|---|
| `7` | rwx | |
| `6` | rw- | |
| `5` | r-x | |
| `4` | r-- | |
| `0` | --- | |
| `644` | rw-r--r-- | ordinary files |
| `755` | rwxr-xr-x | programs and public directories |
| `640` | rw-r----- | config readable by a service's group |
| `600` | rw------- | private keys, secrets |
| `750` | rwxr-x--- | team directories |

### `chmod`

- Octal: `chmod 640 app.conf`
- Symbolic: `chmod u+x script.sh`, `chmod go-w file`, `chmod o= file`
  (remove all for others), `chmod a+r file` (`a` = all),
  `chmod u=rwx,g=rx,o= dir`.
- `-R` recurses — careful: `chmod -R 644 dir` also removes `x` from the
  subdirectories, making them unenterable. Use `X` (capital: "x only for
  directories") or `find -type d/-type f` with separate modes.

### `chown` and `chgrp`

- `sudo chown bob file` — change the owner.
- `sudo chown bob:devops file` — owner and group.
- `sudo chown :devops file` or `chgrp devops file` — group only.
- `-R` for whole trees.

Only root can give a file away to another user. The owner may change the
group to any group they belong to.

### umask: the default permissions

New files start from `666` and directories from `777`, minus the **umask**.
With umask `0022`: files `644`, directories `755`. With `0002` (Ubuntu's
default for normal users with private groups): `664` and `775`. `umask`
shows it; set it in `~/.bashrc` or system-wide.

### Special bits (introduction)

| Bit | Octal | On | Effect | Seen as |
|---|---|---|---|---|
| setuid | 4000 | executable | runs as the file's **owner** (e.g. `/usr/bin/passwd` runs as root) | `rws` in user |
| setgid | 2000 | directory | new files inherit the directory's **group** | `rws` in group |
| sticky | 1000 | directory | only a file's owner (or root) may delete/rename it, even if others can write the directory | `rwt` in others |

`/tmp` is the classic sticky directory: `drwxrwxrwt` (mode `1777`). A
shared team directory is commonly `2770` (setgid, group-writable) and a
directory shared by everyone `1777`. Set them with `chmod +t DIR`,
`chmod g+s DIR`, or the four-digit octal form.

## Try it

Default permissions from the umask:

```bash
cd ~
umask
touch f.txt; mkdir d
ls -ld f.txt d
```

```text
0002
drwxrwxr-x 2 bob bob 4096 Nov 14 20:43 d
-rw-rw-r-- 1 bob bob    0 Nov 14 20:43 f.txt
```

Octal and symbolic `chmod`:

```bash
cd ~
chmod 640 f.txt;        stat -c '%A %a %n' f.txt
chmod u+x,o-rx d;       stat -c '%A %a %n' d
chmod a=r f.txt;        stat -c '%A %a %n' f.txt
```

```text
-rw-r----- 640 f.txt
drwxrwx--- 770 d
-r--r--r-- 444 f.txt
```

Permissions on a directory decide who can delete files in it — even a
read-only file:

```bash
cd ~
chmod 444 f.txt
rm -f f.txt && echo "deleted a read-only file (the directory is writable)"
```

```text
deleted a read-only file (the directory is writable)
```

Ownership needs root to give files away:

```bash mayfail
cd ~
touch owned.txt
chown root owned.txt
sudo chown root:sudo owned.txt
ls -l owned.txt
```

```text
chown: changing ownership of 'owned.txt': Operation not permitted
-rw-rw-r-- 1 root sudo 0 Nov 14 20:43 owned.txt
```

Special bits in the wild, and setting a sticky bit:

```bash
ls -ld /tmp
ls -l /usr/bin/passwd
mkdir ~/shared && chmod 1777 ~/shared
ls -ld ~/shared
sudo rm -rf ~/d ~/owned.txt ~/shared
```

```text
drwxrwxrwt 1 root root 4096 Nov 14 20:05 /tmp
-rwsr-xr-x 1 root root 64152 May 30  2024 /usr/bin/passwd
drwxrwxrwt 2 bob bob 4096 Nov 14 20:43 /home/bob/shared
```

## Common mistakes

- **`chmod 777` to "fix" a permission problem.** It makes the file writable
  by every account on the system. Find out *which* user needs *what*.
- **`chmod -R 644` on a directory tree**: subdirectories lose `x` and become
  unusable. Use `chmod -R u=rwX,go=rX`.
- **Forgetting that the directory's permissions matter**: a user can't read
  `/srv/app/config` if they can't enter `/srv/app`.
- **Three-digit octal clearing special bits**: `chmod 755` on a sticky
  directory removes the sticky bit; use `1755` (or `+t`).

## Recap

- `rwx` for user, group, others; octal r=4 w=2 x=1 (e.g. 640, 755).
- `chmod` (octal or `u+x` style), `chown user:group`, `chgrp`, `-R`; umask
  sets defaults.
- setuid 4000, setgid 2000 (group inheritance on directories), sticky 1000
  (only owners delete, like `/tmp`).

## Next

Labs: `make lab ID=account-management`, then
`make lab ID=permissions-and-ownership`. After that: logging in safely with
SSH keys.
