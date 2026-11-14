---
id: 07-systemd/02-creating-a-systemd-service
title: Creating a systemd Service
minutes: 20
objectives:
  - Write a unit file with [Unit], [Service] and [Install] sections
  - Choose ExecStart, User, Restart, RestartSec, After/Wants and WantedBy
  - Install a unit in /etc/systemd/system and load it with daemon-reload
prerequisites: [07-systemd/01-working-overtime]
tryit: systemd
---

# Creating a systemd Service

## Why this matters

The fix for Bob's overtime is one text file of about fifteen lines. Each
line answers one of Priya's requirements.

## Concepts

### Where unit files live

| Directory | For |
|---|---|
| `/usr/lib/systemd/system/` (or `/lib/systemd/system/`) | units shipped by packages — don't edit |
| `/etc/systemd/system/` | **your** units and overrides — they take precedence |
| `/run/systemd/system/` | runtime units, gone after reboot |

### Anatomy of a service unit

```ini
[Unit]
Description=Project Mercury reporting worker
Documentation=https://wiki.caleston.example/mercury
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=mercury
Group=mercury
ExecStart=/usr/bin/project-mercury.sh
Restart=on-failure
RestartSec=10
Environment=MERCURY_ENV=production

[Install]
WantedBy=multi-user.target
```

**`[Unit]`** — what it is and how it relates to other units:

- `Description=` — shown in `systemctl status` and logs.
- `After=` — **ordering**: if both are being started, start this one after
  those. It does *not* pull them in.
- `Wants=` / `Requires=` — **dependency**: starting this unit also starts
  those. `Requires=` additionally stops this unit if they fail. Usually you
  combine `After=` with `Wants=` or `Requires=`.

**`[Service]`** — how to run it:

- `ExecStart=` — the command, with an **absolute path**.
- `Type=` — `simple` (default: the process started *is* the service),
  `forking` (old-style daemons that background themselves), `oneshot` (runs
  and exits, e.g. setup tasks), `notify`.
- `User=` / `Group=` — run unprivileged. The user must exist.
- `Restart=` — `no` (default), `on-failure` (non-zero exit, crash, kill
  signal), `always`.
- `RestartSec=` — wait this long before restarting (default 100 ms).
- `Environment=` / `EnvironmentFile=` — variables for the process.
- `WorkingDirectory=`, `ExecReload=`, `ExecStop=` — as needed.

**`[Install]`** — what `systemctl enable` does:

- `WantedBy=multi-user.target` — enabling creates a symlink in
  `/etc/systemd/system/multi-user.target.wants/`, so the service starts
  whenever the system reaches multi-user mode — i.e. at every normal boot.

### Loading and starting

After creating or editing a unit file, tell systemd to re-read its
configuration:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now project-mercury.service   # enable at boot AND start now
```

`systemd-analyze verify FILE` checks a unit file for mistakes.

### A dedicated service user

Create a system account with no login shell:

```bash
sudo useradd --system --no-create-home --shell /usr/sbin/nologin mercury
```

## Try it

Run these in a systemd environment. We build a tiny service, `hello-demo`,
step by step.

A script that runs forever, plus a service user:

```bash
printf '#!/bin/bash\nwhile true; do echo "hello from $(whoami)"; sleep 5; done\n' | sudo tee /usr/local/bin/hello-demo.sh >/dev/null
sudo chmod 755 /usr/local/bin/hello-demo.sh
sudo useradd --system --no-create-home --shell /usr/sbin/nologin hellouser
id hellouser
```

```text
uid=999(hellouser) gid=996(hellouser) groups=996(hellouser)
```

The unit file — check it, load it, enable and start it:

```bash
sudo tee /etc/systemd/system/hello-demo.service >/dev/null <<'UNIT'
[Unit]
Description=Hello demo service
After=network.target

[Service]
User=hellouser
ExecStart=/usr/local/bin/hello-demo.sh
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
UNIT
sudo systemd-analyze verify /etc/systemd/system/hello-demo.service 2>/dev/null && echo "unit OK"
sudo systemctl daemon-reload
sudo systemctl enable --now hello-demo.service
```

```text
unit OK
Created symlink /etc/systemd/system/multi-user.target.wants/hello-demo.service → /etc/systemd/system/hello-demo.service.
```

Is it running, as the right user, and will it start at boot?

```bash
systemctl is-active hello-demo
systemctl is-enabled hello-demo
ps -o user:12=,cmd= -C hello-demo.sh
```

```text
active
enabled
hellouser    /bin/bash /usr/local/bin/hello-demo.sh
```

Kill it hard and watch `Restart=on-failure` bring it back:

```bash
systemctl show -p MainPID --value hello-demo
sudo systemctl kill -s KILL hello-demo
sleep 1; systemctl is-active hello-demo
sleep 4; systemctl is-active hello-demo
systemctl show -p NRestarts --value hello-demo
```

```text
186
activating
active
1
```

Clean up:

```bash
sudo systemctl disable --now hello-demo
sudo rm /etc/systemd/system/hello-demo.service /usr/local/bin/hello-demo.sh
sudo systemctl daemon-reload
sudo userdel hellouser
```

```text
Removed "/etc/systemd/system/multi-user.target.wants/hello-demo.service".
```

## Common mistakes

- **Relative paths in `ExecStart=`** (`ExecStart=project-mercury.sh`).
  systemd needs the absolute path.
- **Forgetting `daemon-reload`** after editing — systemd keeps using the old
  version and warns that the unit file changed on disk.
- **Thinking `After=` starts the other unit.** It only orders; add `Wants=`
  or `Requires=` to pull it in.
- **A script that backgrounds itself (`&`) with `Type=simple`.** systemd
  thinks the service exited. Run the program in the foreground.
- **No `[Install]` section** — `systemctl enable` then has nothing to do.

## Recap

- Your units go in `/etc/systemd/system/NAME.service`: `[Unit]`
  (Description, After, Wants/Requires), `[Service]` (ExecStart, User,
  Restart, RestartSec), `[Install]` (WantedBy).
- `daemon-reload` after every edit; `enable --now` to start now and at boot.
- Run services as a dedicated unprivileged user.

## Next

The day-to-day tools: systemctl, journalctl and drop-in overrides.
