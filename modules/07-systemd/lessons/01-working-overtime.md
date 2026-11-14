---
id: 07-systemd/01-working-overtime
title: "Working Overtime: Why Services Need a Manager"
minutes: 6
objectives:
  - Explain what a service manager does that nohup and & don't
  - Name the main kinds of systemd units
prerequisites: [02-linux-core-concepts/05-runlevels]
quiz: false
tryit: systemd
---

# Working Overtime: Why Services Need a Manager

## Why this matters

Starting a long-running program by hand works until the first reboot, crash
or holiday. A **service manager** owns the program's whole life cycle, so
humans don't have to.

## Concepts

| Need | By hand (`nohup cmd &`) | systemd service |
|---|---|---|
| start at boot | no | `systemctl enable` |
| restart after a crash | no | `Restart=on-failure` |
| run as a specific user | whoever typed it | `User=mercury` |
| start after the database | hope | `After=postgresql.service` |
| logs | a stray `nohup.out` | the journal: `journalctl -u NAME` |
| status at a glance | `ps aux \| grep` | `systemctl status NAME` |

systemd manages **units**. Each unit is a small text file describing one
thing; the suffix tells you what kind:

| Unit type | Describes | Example |
|---|---|---|
| `.service` | a process or daemon | `ssh.service`, `cron.service` |
| `.target` | a group of units / system state | `multi-user.target` |
| `.timer` | a schedule that triggers a service (cron alternative) | `logrotate.timer` |
| `.socket` | a socket that starts a service on demand | `ssh.socket` |
| `.mount` | a mount point | `home.mount` |
| `.path` | watch a file path | |

## Try it

These run in a systemd environment (the course VM or the systemd container).

What is PID 1, and how is the system doing overall?

```bash
ps -p 1 -o comm=
systemctl is-system-running
```

```text
systemd
running
```

A few of the units on this machine:

```bash
systemctl list-units --type=service --state=running --no-pager --no-legend | head -5
systemctl list-timers --all --no-pager | head -3
```

```text
  cron.service             loaded active running Regular background program processing daemon
  dbus.service             loaded active running D-Bus System Message Bus
  ssh.service              loaded active running OpenBSD Secure Shell server
  systemd-journald.service loaded active running Journal Service
  systemd-logind.service   loaded active running User Login Management
NEXT                           LEFT LAST PASSED UNIT                         ACTIVATES
Sat 2026-11-14 21:09:35 UTC   14min -         - systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Sun 2026-11-15 00:00:00 UTC 3h 5min -         - dpkg-db-backup.timer         dpkg-db-backup.service
```

## Common mistakes

- **Running services from a terminal with `&`.** They die with your session
  (or survive as orphans nobody manages).

## Recap

- A service manager starts, restarts, sequences, isolates and logs services.
- systemd units: `.service`, `.target`, `.timer`, `.socket`, `.mount`…
- `systemctl` controls units; the journal collects their logs.

## Next

Writing a unit file for Mercury.
