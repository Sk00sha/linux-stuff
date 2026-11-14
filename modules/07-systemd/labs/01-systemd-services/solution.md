# Solution — Make Project Mercury a real service

On the lab machine as `bob`, with `sudo`.

## t1–t4 — the unit file

```bash solution user=bob
sudo tee /etc/systemd/system/project-mercury.service >/dev/null <<'UNIT'
[Unit]
Description=Project Mercury reporting worker
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=mercury
Group=mercury
ExecStart=/usr/bin/project-mercury.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT
sudo systemd-analyze verify /etc/systemd/system/project-mercury.service 2>/dev/null || true
sudo systemctl daemon-reload
```

Line by line:

- `After=network.target postgresql.service` — start only once networking is
  up and after the database; `Wants=postgresql.service` also starts the
  database if it isn't running.
- `User=mercury` / `Group=mercury` — run unprivileged, not as root.
- `ExecStart=` — absolute path; the script stays in the foreground, which is
  what `Type=simple` expects.
- `Restart=on-failure` + `RestartSec=10` — a crash, a non-zero exit or a
  kill signal leads to a restart ten seconds later. A clean `systemctl stop`
  does not.
- `WantedBy=multi-user.target` — what `enable` hooks into.

## t5 — enable and start

```bash solution user=bob
sudo systemctl enable --now project-mercury.service
systemctl status project-mercury --no-pager | head -5
```

## t6 — test the restart yourself

```bash solution user=bob
sudo systemctl kill -s KILL project-mercury
sleep 12
systemctl is-active project-mercury
journalctl -u project-mercury --no-pager -n 3 -o cat
```

The journal shows the main process being killed, `Scheduled restart job`,
and the worker starting again.
