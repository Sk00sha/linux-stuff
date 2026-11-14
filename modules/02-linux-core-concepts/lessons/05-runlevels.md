---
id: 02-linux-core-concepts/05-runlevels
title: Runlevels and systemd Targets
minutes: 10
objectives:
  - Map classic runlevels to systemd targets
  - Show and change the default boot target
  - Switch the running system to another target
prerequisites: [02-linux-core-concepts/04-linux-boot-sequence]
tryit: vm
---

# Runlevels and systemd Targets

## Why this matters

bob-vm was built from a desktop image, so it boots into a graphical login
screen nobody ever sees, wasting memory. Priya wants it to boot straight into
text-only multi-user mode. That's a one-command change once you understand
targets.

## Concepts

### Runlevels (the old way)

SysV init described the state of a system with a number from 0 to 6 — the
**runlevel**. Each runlevel had a directory of scripts to start or stop.

### Targets (the systemd way)

systemd replaces runlevels with **targets**: units whose name ends in
`.target` and which group other units together. A target can depend on
other targets, so `graphical.target` is "everything in `multi-user.target`
plus a display manager". For compatibility, systemd provides aliases named
`runlevel0.target` … `runlevel6.target`.

| Runlevel | systemd target | State |
|---|---|---|
| 0 | `poweroff.target` | shut down |
| 1 | `rescue.target` | single user, minimal services, for repairs |
| 3 | `multi-user.target` | full multi-user system, text console, networking |
| 5 | `graphical.target` | multi-user plus graphical login |
| 6 | `reboot.target` | reboot |

(Runlevels 2 and 4 map to `multi-user.target` too.) The article in the next
lesson covers the history in more depth.

### Commands

| Command | Effect |
|---|---|
| `systemctl get-default` | show the target used at boot |
| `sudo systemctl set-default multi-user.target` | change it (takes effect at next boot) |
| `sudo systemctl isolate multi-user.target` | switch **now**, stopping units not needed by that target |
| `systemctl list-units --type=target` | targets currently active |
| `runlevel` | old-style view: previous and current runlevel |

`set-default` just replaces the symlink `/etc/systemd/system/default.target`,
which points at the chosen target unit.

`isolate` is powerful: isolating `rescue.target` over SSH will stop the
network and lock you out. Only isolate to targets that keep what you need.

You can also choose a target for a single boot by adding
`systemd.unit=rescue.target` to the kernel command line in the GRUB menu —
the standard way to repair a machine that no longer boots normally.

## Try it

Run on the course VM.

```bash novmcheck
systemctl get-default
ls -l /etc/systemd/system/default.target
```

```text
graphical.target
lrwxrwxrwx 1 root root 40 Nov 14 09:20 /etc/systemd/system/default.target -> /usr/lib/systemd/system/graphical.target
```

Which targets are active right now?

```bash
systemctl list-units --type=target --no-pager | head -8
```

```text
  UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
  basic.target           loaded active active Basic System
  cryptsetup.target      loaded active active Local Encrypted Volumes
  getty.target           loaded active active Login Prompts
  graphical.target       loaded active active Graphical Interface
  local-fs-pre.target    loaded active active Preparation for Local File Systems
  local-fs.target        loaded active active Local File Systems
  multi-user.target      loaded active active Multi-User System
```

What does `graphical.target` pull in? (It requires `multi-user.target`.)

```bash
systemctl show -p Requires -p Wants graphical.target
runlevel
```

```text
Requires=multi-user.target
Wants=display-manager.service
N 5
```

(Changing the default is the lab task, so it is not shown here.)

## Common mistakes

- **Using `isolate` when you meant `set-default`.** `isolate` changes the
  running system immediately; `set-default` only affects the next boot.
- **Isolating rescue mode over SSH.** You will lose your session.
- **Hunting for `/etc/inittab`.** systemd ignores it; the default is the
  `default.target` symlink.

## Recap

- Runlevels 0–6 map to targets: rescue (1), multi-user (3), graphical (5),
  poweroff (0), reboot (6).
- `systemctl get-default` / `set-default` control the boot target.
- `systemctl isolate` switches the running system to another target.

## Next

A short reading on runlevels, then a look at the kinds of files Linux knows
about.
