---
id: 06-security-and-permissions/02-linux-accounts
title: Linux Accounts
minutes: 10
objectives:
  - Explain users, groups, UIDs and GIDs
  - Distinguish the root, system and normal accounts
  - Inspect identity and logins with id, who, w and last
  - Switch users with su and run commands as root with sudo
prerequisites: [06-security-and-permissions/01-security-incident]
tryit: ubuntu
---

# Linux Accounts

## Why this matters

Before Bob can deal with the `intruder` account, he needs to understand
what an account *is* on Linux, how the system tells accounts apart, and how
people become root.

## Concepts

### Users and groups

Every process runs as a **user**, and every file is owned by a user and a
**group**. Linux doesn't really care about names: it identifies users by a
number, the **UID**, and groups by a **GID**. The names live in
`/etc/passwd` and `/etc/group` (next lesson).

Each user has:

- a **primary group** (the GID recorded in `/etc/passwd`; new files get this
  group), and
- zero or more **secondary** (supplementary) groups that grant extra access —
  for example the `sudo` group on Ubuntu or `wheel` on Rocky.

### Kinds of accounts

| Account | UID | Purpose |
|---|---|---|
| `root` | 0 | the superuser; bypasses permission checks |
| system accounts | 1–999 | run services (`www-data`, `sshd`, `postgres`); usually can't log in |
| normal users | 1000+ | people like bob |

The ranges come from `/etc/login.defs` (`UID_MIN`, `SYS_UID_MAX`) and can
differ slightly between distributions. System accounts typically have the
shell `/usr/sbin/nologin`, so even with a password they can't get an
interactive session.

### Who am I, who is here?

| Command | Shows |
|---|---|
| `whoami` | your user name |
| `id [USER]` | UID, primary GID, all groups |
| `groups [USER]` | group names only |
| `who` / `w` | who is logged in now (`w` adds what they're doing) |
| `last` | login history (from `/var/log/wtmp`) |
| `lastlog` | each account's most recent login |

### Becoming someone else: `su` and `sudo`

- `su - USER` starts a login shell as USER and asks for **that user's**
  password. `su -` alone means root — which requires knowing root's password,
  and leaves little trace of who did what.
- `sudo COMMAND` runs one command as root (or `-u USER` as another user) and
  asks for **your own** password. Who may do what is defined in
  `/etc/sudoers`. Every use is logged, so it is auditable.

Modern practice: lock or disable the root password, give administrators
`sudo`, and log in as yourself. `sudo -i` gives a root shell when you really
need one; `sudo -l` lists what you're allowed to run.

## Try it

Who are you, and which groups give you extra powers?

```bash
whoami
id
groups
```

```text
bob
uid=1000(bob) gid=1000(bob) groups=1000(bob),27(sudo)
bob sudo
```

Compare with root and a system account:

```bash
id root
id www-data
getent passwd www-data
```

```text
uid=0(root) gid=0(root) groups=0(root)
uid=33(www-data) gid=33(www-data) groups=33(www-data)
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
```

The range for normal accounts on this distribution (system accounts get UIDs below `UID_MIN`):

```bash
grep -E '^(UID_MIN|UID_MAX)' /etc/login.defs
```

```text
UID_MIN			 1000
UID_MAX			60000
```

`sudo` runs a command as root; `sudo -u` as anyone else:

```bash
sudo whoami
sudo -u www-data whoami
sudo -l | tail -2
```

```text
root
www-data
    (ALL : ALL) ALL
    (ALL) NOPASSWD: ALL
```

(In the lab machines bob may use sudo without a password, for convenience.
Real systems ask for your password.)

## Common mistakes

- **Sharing the root password** instead of giving people sudo: you lose
  the audit trail of who ran what.
- **Assuming the name is what matters.** Rename a user and keep the UID, and
  they still own the same files. Reuse a UID for a new user, and the new
  user inherits the old one's files.
- **`su` without `-`.** `su root` keeps your environment (PATH, home), which
  causes subtle surprises; `su -` gives a clean login shell.

## Recap

- Users and groups are numbers (UID/GID) with names attached; root is UID 0,
  system accounts are below 1000, people from 1000.
- `id`, `groups`, `who`, `w`, `last` show identity and logins.
- `su -` switches user with the target's password; `sudo` runs commands as
  root with your own password and is logged.

## Next

Where all this is stored: `/etc/passwd`, `/etc/shadow`, `/etc/group` and
`/etc/sudoers`.
