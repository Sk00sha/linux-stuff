---
id: 06-security-and-permissions/04-user-management
title: User Management
minutes: 12
objectives:
  - Create users with a chosen UID, home, shell, comment and groups
  - Set, lock and expire passwords
  - Create and delete groups and change group membership
  - Delete users safely
prerequisites: [06-security-and-permissions/03-access-control-files]
tryit: ubuntu
---

# User Management

## Why this matters

Caleston's identity standard says every engineer gets the same UID on every
server (so files copied between machines keep their owner), engineers
belong to a `devops` group, and departed or suspicious accounts are locked,
not just forgotten. Bob needs the tools that do this correctly — not a text
editor on `/etc/passwd`.

## Concepts

### Creating users: `useradd`

```bash
sudo useradd -m -u 2000 -g bob -G devops -s /bin/bash -c "Bob (platform)" bob
```

| Option | Sets |
|---|---|
| `-m` | create the home directory (copying `/etc/skel`) |
| `-d DIR` | home directory path (default `/home/NAME`) |
| `-u UID` | user ID |
| `-g GROUP` | primary group (must exist) |
| `-G G1,G2` | secondary groups |
| `-s SHELL` | login shell |
| `-c "TEXT"` | comment / full name |
| `-r` | create a system account (UID below 1000, no home by default) |

Without `-g`, most distributions create a group with the same name as the
user (user private groups). Ubuntu also ships `adduser`, an interactive
wrapper that asks questions — handy by hand, but `useradd` is identical
everywhere and better in scripts.

### Passwords: `passwd` and `chage`

| Command | Does |
|---|---|
| `passwd` | change your own password |
| `sudo passwd USER` | set someone else's |
| `sudo passwd -l USER` / `-u USER` | lock / unlock the password |
| `sudo passwd -S USER` | status: `P` usable, `L` locked, `NP` none |
| `sudo chage -l USER` | password ageing details |
| `sudo chage -E 0 USER` | expire the whole account (no logins at all) |

Note: `passwd -l` blocks **password** logins only. A user with SSH keys can
still log in. To stop *all* logins, also expire the account
(`usermod -e 1` or `chage -E 0`) or set the shell to `/usr/sbin/nologin`.

### Changing users: `usermod`

| Command | Does |
|---|---|
| `sudo usermod -aG devops bob` | **a**ppend a secondary group |
| `sudo usermod -s /usr/sbin/nologin USER` | change shell |
| `sudo usermod -L USER` / `-U USER` | lock / unlock (same as `passwd -l/-u`) |
| `sudo usermod -e 1 USER` | expire the account |
| `sudo usermod -c "New name" USER` | change the comment |

Group membership changes apply at the next login; `id USER` shows them
immediately, but a running shell keeps its old groups (`newgrp` or a new
login refreshes them).

### Groups: `groupadd`, `groupdel`, `gpasswd`

- `sudo groupadd -g 2001 devops` creates a group (optionally with a GID).
- `sudo groupdel devops` deletes it (not if it's someone's primary group).
- `sudo gpasswd -d bob devops` removes one member from a group.

### Deleting users: `userdel`

`sudo userdel USER` removes the account; `-r` also deletes the home
directory and mail spool. Before deleting, consider locking first and
archiving the home directory — and remember that files elsewhere owned by
the old UID will show up as a bare number afterwards.

## Try it

Create a group and a user with an explicit UID, shell and comment:

```bash
sudo groupadd -g 3001 testers
sudo useradd -m -u 3000 -G testers -s /bin/bash -c "Tess Ter" tess
id tess
getent passwd tess
sudo ls -A /home/tess
ls -ld /home/tess
```

```text
uid=3000(tess) gid=3000(tess) groups=3000(tess),3001(testers)
tess:x:3000:3000:Tess Ter:/home/tess:/bin/bash
.bash_logout  .bashrc  .profile
drwxr-x--- 2 tess tess 4096 Nov 14 20:43 /home/tess
```

(Ubuntu 24.04 creates home directories with mode `750`, so other users —
including bob — can't look inside without `sudo`.)

Set a password non-interactively (normally you'd just run `sudo passwd tess`),
then lock it:

```bash
echo 'tess:Sup3r-secret' | sudo chpasswd
sudo passwd -S tess
sudo passwd -l tess
sudo passwd -S tess
sudo grep '^tess:' /etc/shadow | cut -c1-12
```

```text
tess P 2026-11-14 0 99999 7 -1
passwd: password changed.
tess L 2026-11-14 0 99999 7 -1
tess:!$y$j9T
```

The `!` in front of the hash is the lock.

Add a secondary group without losing the existing ones — note the `-a`:

```bash
sudo groupadd demo
sudo usermod -aG demo tess
id -nG tess
```

```text
tess testers demo
```

Clean up:

```bash
sudo userdel -r tess
sudo groupdel testers
sudo groupdel demo
id tess || true
```

```text
userdel: tess mail spool (/var/mail/tess) not found
id: ‘tess’: no such user
```

## Common mistakes

- **`usermod -G devops bob` without `-a`.** It *replaces* all secondary
  groups — bob silently loses `sudo`. Always `-aG`.
- **Forgetting `-m`** with `useradd`: the user has no home directory.
- **Locking the password and thinking the account is closed.** SSH keys
  still work; expire the account or change the shell too.
- **Deleting before investigating.** For an incident, lock first and keep
  the evidence.

## Recap

- `useradd -m -u -g -G -s -c -d` creates users; `groupadd`, `groupdel` manage
  groups.
- `passwd`, `chpasswd`, `passwd -l/-S`, `chage` manage passwords and expiry.
- `usermod -aG` appends groups (never forget `-a`); `userdel -r` removes a
  user and their home.

## Next

Now that accounts are right: what can each of them do with each file?
