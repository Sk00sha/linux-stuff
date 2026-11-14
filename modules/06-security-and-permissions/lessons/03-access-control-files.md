---
id: 06-security-and-permissions/03-access-control-files
title: Access Control Files
minutes: 11
objectives:
  - Read the fields of /etc/passwd, /etc/shadow and /etc/group
  - Explain why passwords live in /etc/shadow
  - Edit sudo rules safely with visudo and /etc/sudoers.d
prerequisites: [06-security-and-permissions/02-linux-accounts]
tryit: ubuntu
---

# Access Control Files

## Why this matters

The security team asked Bob three questions: does `intruder` have a
password, which groups is it in, and can it use `sudo`? All three answers
are in four text files under `/etc`.

## Concepts

### `/etc/passwd` — the account list

World-readable, one line per account, seven colon-separated fields:

```text
bob:x:1000:1000:Bob (new hire):/home/bob:/bin/bash
│   │ │    │    │              │         └─ login shell
│   │ │    │    │              └─ home directory
│   │ │    │    └─ comment (GECOS): full name etc.
│   │ │    └─ primary GID
│   │ └─ UID
│   └─ "x" = password is in /etc/shadow
└─ user name
```

### `/etc/shadow` — the passwords

Readable only by root. Splitting passwords out of the world-readable
`/etc/passwd` means nobody can copy the hashes to crack them offline.

```text
bob:$y$j9T$Qm...$x8Zh...:20407:0:99999:7:::
│   │                    │     │ │     │
│   │                    │     │ │     └─ warn N days before expiry
│   │                    │     │ └─ max days between changes
│   │                    │     └─ min days between changes
│   │                    └─ last change (days since 1970-01-01)
│   └─ password hash ($y$ = yescrypt, $6$ = SHA-512)
└─ user name
```

Special values in the hash field: `*` or `!` alone = no password login
possible; a `!` **in front of** a hash = the account is **locked** (the
original hash is kept, so unlocking restores it).

### `/etc/group` — the groups

```text
devops:x:2001:bob,priya
│      │ │    └─ secondary members, comma-separated
│      │ └─ GID
│      └─ group password (rarely used; in /etc/gshadow)
└─ group name
```

A user's **primary** group is not listed here — it's the GID in
`/etc/passwd`.

### `/etc/sudoers` and `/etc/sudoers.d/`

Rules have the form:

```text
WHO   WHERE=(AS_WHOM)   [NOPASSWD:] WHAT
bob   ALL=(ALL:ALL)     ALL
%sudo ALL=(ALL:ALL)     ALL                         # % = a group
%devops ALL=(root) NOPASSWD: /usr/bin/systemctl     # only this command
```

- `WHO` is a user or `%group`.
- `WHERE` is the host the rule applies to (almost always `ALL`).
- `(AS_WHOM)` is the target user (and group).
- `WHAT` is a list of commands with **full paths**, or `ALL`.

Never edit these files with a normal editor: a syntax error can lock
**everyone** out of sudo. Use `visudo`, which checks the syntax before
saving:

- `sudo visudo` edits `/etc/sudoers`.
- `sudo visudo -f /etc/sudoers.d/devops` edits a drop-in file — the preferred
  way to add rules, because package updates won't touch it.
- `sudo visudo -c` checks everything; drop-in files must have mode `0440`
  and must not contain a `.` or end in `~`, or they are ignored.

## Try it

The fields of an account and the shells in use:

```bash
grep '^bob:' /etc/passwd
cut -d: -f1,7 /etc/passwd | tail -3
```

```text
bob:x:1000:1000:Bob (new hire):/home/bob:/bin/bash
systemd-network:/usr/sbin/nologin
sshd:/usr/sbin/nologin
bob:/bin/bash
```

`/etc/shadow` is protected; root can read it, and `passwd -S` summarises it:

```bash mayfail
ls -l /etc/passwd /etc/shadow
cat /etc/shadow
sudo passwd -S bob
```

```text
-rw-r--r-- 1 root root   1009 Nov 14 20:16 /etc/passwd
-rw-r----- 1 root shadow  621 Nov 14 20:16 /etc/shadow
cat: /etc/shadow: Permission denied
bob P 2026-11-14 0 99999 7 -1
```

`P` means bob has a usable password; `L` would mean locked.

Groups and their members:

```bash
grep -E '^(sudo|bob):' /etc/group
getent group sudo
```

```text
sudo:x:27:bob
bob:x:1000:
sudo:x:27:bob
```

The sudo configuration and a syntax check:

```bash
sudo grep -v -e '^#' -e '^$' /etc/sudoers
ls -l /etc/sudoers.d/
sudo visudo -c
```

```text
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
Defaults	use_pty
root	ALL=(ALL:ALL) ALL
%admin ALL=(ALL) ALL
%sudo	ALL=(ALL:ALL) ALL
@includedir /etc/sudoers.d
total 8
-r--r----- 1 root root   28 Nov 14 20:16 90-bob
-r--r----- 1 root root 1068 Jan 29  2024 README
/etc/sudoers: parsed OK
/etc/sudoers.d/90-bob: parsed OK
/etc/sudoers.d/README: parsed OK
```

## Common mistakes

- **Editing `/etc/sudoers` with `vi` directly.** One typo and sudo stops
  working for everyone. Always `visudo`.
- **Relative command paths in sudoers** (`NOPASSWD: systemctl`). sudo
  requires full paths: `/usr/bin/systemctl`.
- **A drop-in file named `devops.conf`** — files with a dot are ignored.
- **Deleting the `x` in `/etc/passwd`**, which can make the account
  passwordless. Use the tools from the next lesson instead of editing these
  files by hand.

## Recap

- `/etc/passwd` (7 fields, world-readable), `/etc/shadow` (hashes, root
  only, `!` = locked), `/etc/group` (secondary members).
- sudo rules: `who where=(as_whom) [NOPASSWD:] commands`, groups with `%`.
- Edit with `visudo`; prefer drop-ins in `/etc/sudoers.d/` with mode 0440.

## Next

Creating, modifying and removing users and groups with the proper tools.
