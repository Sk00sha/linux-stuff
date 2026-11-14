---
id: 07-systemd/03-systemd-tools
title: systemd Tools
minutes: 20
objectives:
  - Start, stop, restart, reload, enable and disable services
  - Read status output and unit properties
  - Read logs with journalctl
  - Override settings with drop-in files using systemctl edit
prerequisites: [07-systemd/02-creating-a-systemd-service]
tryit: systemd
---

# systemd Tools

## Why this matters

Writing the unit is the first 10 %. The rest of a service's life is
checking whether it's healthy, reading its logs at 2 a.m., and changing a
setting without editing a vendor's file. Two commands cover almost all of
it: `systemctl` and `journalctl`.

## Concepts

### `systemctl`

| Command | Does |
|---|---|
| `systemctl status NAME` | state, main PID, memory, last log lines |
| `sudo systemctl start` / `stop` / `restart NAME` | control now |
| `sudo systemctl reload NAME` | ask the service to re-read its config without stopping (if supported) |
| `sudo systemctl enable` / `disable NAME` | start / don't start at boot (`--now` also starts/stops) |
| `systemctl is-active` / `is-enabled` / `is-failed NAME` | one-word answers, good for scripts |
| `systemctl cat NAME` | show the unit file(s) in effect, including drop-ins |
| `systemctl show NAME -p Restart,User` | individual properties |
| `systemctl list-units --type=service [--state=failed]` | what's loaded / failed |
| `systemctl list-unit-files --state=enabled` | what starts at boot |
| `sudo systemctl daemon-reload` | re-read unit files after changes |
| `sudo systemctl mask NAME` | make it impossible to start (until `unmask`) |

Reading `systemctl status`:

```text
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/usr/lib/systemd/system/ssh.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-11-14 19:58:02 UTC; 2h ago
   Main PID: 41 (sshd)
```

`Loaded:` shows the file and whether it's **enabled** (boot); `Active:`
shows whether it's **running now**. They are independent: a service can be
enabled but stopped, or running but disabled.

### `journalctl`

systemd's journal collects the output (stdout/stderr) of every service plus
kernel and system messages.

| Command | Shows |
|---|---|
| `journalctl -u NAME` | logs of one unit |
| `journalctl -u NAME -f` | follow live (like `tail -f`) |
| `journalctl -u NAME -n 20` | last 20 lines |
| `journalctl -b` / `-b -1` | this boot / previous boot |
| `journalctl --since "10 min ago"` / `--since today` | time window |
| `journalctl -p err` | priority error and worse |
| `journalctl -k` | kernel messages |

Add `--no-pager` in scripts. Regular users see their own logs; members of
the `adm` or `systemd-journal` group (or root) see everything.

### Drop-in overrides

Never edit unit files under `/usr/lib/systemd/system` — package updates
overwrite them. Instead create a **drop-in**:

```bash
sudo systemctl edit ssh.service
```

This opens an editor for
`/etc/systemd/system/ssh.service.d/override.conf`. Only the settings you
write there change, e.g.:

```ini
[Service]
Restart=always
RestartSec=5
```

It reloads automatically when you save. `systemctl cat` shows the original
plus the drop-ins. To *clear* a list setting like `ExecStart=` you first
assign it empty, then the new value. `systemctl revert NAME` removes all
drop-ins.

## Try it

Run in a systemd environment.

Status of a real service, and two of its properties:

```bash
systemctl status cron --no-pager | head -4
systemctl show cron -p Restart -p MainPID
```

```text
● cron.service - Regular background program processing daemon
     Loaded: loaded (/usr/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-11-14 20:54:46 UTC; 2s ago
       Docs: man:cron(8)
Restart=on-failure
MainPID=85
```

Stop and start it; enabled and active are independent:

```bash
sudo systemctl stop cron
systemctl is-active cron; systemctl is-enabled cron
sudo systemctl start cron
systemctl is-active cron
```

```text
inactive
enabled
active
```

Its logs:

```bash
sudo journalctl -u cron --no-pager -o cat | grep -v EXTRA_OPTS | tail -3
```

```text
Started cron.service - Regular background program processing daemon.
(CRON) INFO (pidfile fd = 3)
(CRON) INFO (Skipping @reboot jobs -- not system startup)
```

A drop-in override (written non-interactively here; normally
`sudo systemctl edit cron`):

```bash
sudo mkdir -p /etc/systemd/system/cron.service.d
printf '[Service]\nRestartSec=7\n' | sudo tee /etc/systemd/system/cron.service.d/override.conf >/dev/null
sudo systemctl daemon-reload
systemctl cat cron --no-pager | tail -3
systemctl show cron -p RestartUSec
sudo systemctl revert cron
systemctl show cron -p RestartUSec
```

```text
# /etc/systemd/system/cron.service.d/override.conf
[Service]
RestartSec=7
RestartUSec=7s
Removed "/etc/systemd/system/cron.service.d/override.conf".

Removed "/etc/systemd/system/cron.service.d".

RestartUSec=100ms
```

## Common mistakes

- **`enable` without `start`** (or vice versa): it runs now but not after
  reboot, or the reverse. Use `enable --now`.
- **Editing vendor units in `/usr/lib/systemd/system`.** Use
  `systemctl edit`.
- **Reading only `status`** — it shows the last few lines; use
  `journalctl -u NAME` for the full story.
- **`restart` when `reload` would do** — restarting drops connections.

## Recap

- `systemctl status/start/stop/restart/reload/enable/disable/is-active/cat/show`.
- `journalctl -u NAME [-f] [-n N] [--since …] [-b]` for logs.
- Change units safely with `systemctl edit` drop-ins; `revert` undoes them.

## Next

The lab: `make lab ID=systemd-services` — make Mercury a proper service.
