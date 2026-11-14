---
id: 02-linux-core-concepts/06-article-runlevels
title: "Article: From Runlevels to Targets"
minutes: 5
objectives:
  - Understand why runlevels still appear in documentation
  - Know the full runlevel-to-target table and its distribution quirks
prerequisites: [02-linux-core-concepts/05-runlevels]
tryit: none
---

# Article: From Runlevels to Targets

## Why this matters

Bob will meet runlevels in old runbooks, vendor installation guides and
interview questions long after the last SysV init server is switched off.
This reading-only lesson gives the background so the terms don't confuse
him.

## Concepts

### Where runlevels came from

SysV init, inherited from AT&T's System V Unix, read `/etc/inittab` at boot.
A line such as `id:3:initdefault:` set the default runlevel. For each
runlevel there was a directory, `/etc/rc3.d/` for example, full of symlinks
to scripts in `/etc/init.d/`. Links named `S20sshd` were **S**tarted in
numeric order; links named `K80cups` were **K**illed. Changing runlevel meant
running `init 3` or `telinit 3`, which ran the kill scripts and then the
start scripts.

The model was simple and transparent, but slow — scripts ran one after the
other — and it could not express "start this service only once the network
is really up".

### What the numbers meant

Only 0, 1 and 6 were truly universal. The meaning of 2–5 depended on the
distribution:

| Runlevel | Red Hat family (classic) | Debian family (classic) | systemd target today |
|---|---|---|---|
| 0 | halt | halt | `poweroff.target` |
| 1 / S | single user | single user | `rescue.target` |
| 2 | multi-user, no NFS | full multi-user (default) | `multi-user.target` |
| 3 | full multi-user, text | same as 2 | `multi-user.target` |
| 4 | unused / custom | same as 2 | `multi-user.target` |
| 5 | multi-user + X11 GUI | same as 2 | `graphical.target` |
| 6 | reboot | reboot | `reboot.target` |

So "runlevel 3" on an old Red Hat machine and "runlevel 2" on an old Debian
machine meant the same thing — which is one reason systemd switched to
descriptive names.

### How systemd keeps compatibility

- `runlevelN.target` units are symlinks to the matching targets, so
  `systemctl isolate runlevel3.target` still works.
- `init 3`, `telinit 5`, `runlevel`, `halt` and `reboot` still exist as
  small compatibility programs that talk to systemd.
- `/etc/init.d/` scripts are wrapped automatically into units by the
  `systemd-sysv-generator`, so old packages keep working.

### Other targets worth knowing

- `emergency.target` — even more minimal than rescue: the root filesystem is
  mounted read-only and almost nothing else runs.
- `network-online.target` — reached when the network is actually configured;
  services that need it say so (module 07).
- `default.target` — not a real target but the alias for whichever one boots
  by default.

## Try it

Nothing to run in this reading — but if you're curious, on the course VM:

```bash norun
ls -l /usr/lib/systemd/system/runlevel*.target
```

```text
lrwxrwxrwx 1 root root 15 Aug  9  2024 /usr/lib/systemd/system/runlevel0.target -> poweroff.target
lrwxrwxrwx 1 root root 13 Aug  9  2024 /usr/lib/systemd/system/runlevel1.target -> rescue.target
lrwxrwxrwx 1 root root 17 Aug  9  2024 /usr/lib/systemd/system/runlevel2.target -> multi-user.target
lrwxrwxrwx 1 root root 17 Aug  9  2024 /usr/lib/systemd/system/runlevel3.target -> multi-user.target
lrwxrwxrwx 1 root root 17 Aug  9  2024 /usr/lib/systemd/system/runlevel4.target -> multi-user.target
lrwxrwxrwx 1 root root 16 Aug  9  2024 /usr/lib/systemd/system/runlevel5.target -> graphical.target
lrwxrwxrwx 1 root root 13 Aug  9  2024 /usr/lib/systemd/system/runlevel6.target -> reboot.target
```

```bash norun
ls /etc/init.d | head -5
```

```bash norun
systemctl list-dependencies rescue.target --no-pager | head
```

## Common mistakes

- **Assuming runlevel 3 means the same everywhere.** On classic Debian, 2–5
  were identical.
- **Editing `/etc/inittab` on a systemd machine.** It is ignored.

## Recap

- Runlevels were SysV init's numbered system states, driven by `rc?.d`
  script links.
- systemd targets replace them with names and dependency-based parallel
  startup, while keeping `runlevelN.target` aliases.
- Only 0, 1 and 6 had universal meanings in the old world.

## Next

On to file types: not everything in a Linux directory is an ordinary file.
