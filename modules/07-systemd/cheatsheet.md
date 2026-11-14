# Cheatsheet — Service Management with systemd

## Unit file (`/etc/systemd/system/NAME.service`)

```ini
[Unit]
Description=...
After=network.target postgresql.service
Wants=postgresql.service          # or Requires=

[Service]
Type=simple                       # forking | oneshot | notify
User=svcuser
ExecStart=/absolute/path --args
Restart=on-failure                # no | always
RestartSec=10
Environment=KEY=value             # or EnvironmentFile=/etc/default/NAME

[Install]
WantedBy=multi-user.target
```

`useradd --system --no-create-home --shell /usr/sbin/nologin svcuser`

## systemctl

| Command | Does |
|---|---|
| `daemon-reload` | re-read unit files (after every edit) |
| `start` / `stop` / `restart` / `reload NAME` | control now |
| `enable` / `disable [--now] NAME` | at boot (and now) |
| `status NAME` / `is-active` / `is-enabled` / `is-failed` | state |
| `cat NAME` / `show NAME -p Prop1,Prop2` | effective config / properties |
| `edit NAME` / `revert NAME` | drop-in override / remove overrides |
| `list-units --type=service [--state=failed]` | loaded units |
| `list-unit-files --state=enabled` / `list-timers` | boot units / timers |
| `kill -s KILL NAME` / `mask` / `unmask` | signal / forbid starting |
| `systemd-analyze verify FILE` | check a unit file |

## journalctl

`-u NAME` · `-f` follow · `-n 50` · `-b` this boot · `--since "1 hour ago"` · `-p err` · `-k` kernel · `--no-pager` · `-o cat`
