# Hints — Make Project Mercury a real service

## t1

### Level 1

A service unit is a text file with three sections. Yours goes in `/etc/systemd/system/`.

### Level 2

`[Unit]`, `[Service]` with `ExecStart=` (absolute path), `[Install]`. Then `sudo systemctl daemon-reload`.

### Level 3

`sudo vi /etc/systemd/system/project-mercury.service` with `[Service]` → `ExecStart=/usr/bin/project-mercury.sh`, then `sudo systemctl daemon-reload` and `systemctl cat project-mercury`.

## t2

### Level 1

One line in the `[Service]` section chooses the account.

### Level 2

`User=` (and optionally `Group=`).

### Level 3

`User=mercury` in `[Service]`, then `daemon-reload` and restart the service.

## t3

### Level 1

Two settings: *when* to restart and *how long* to wait.

### Level 2

`Restart=` and `RestartSec=` in `[Service]`.

### Level 3

`Restart=on-failure` and `RestartSec=10`.

## t4

### Level 1

Ordering between units is declared in the `[Unit]` section.

### Level 2

`After=` takes a space-separated list of units.

### Level 3

`After=network.target postgresql.service` (and `Wants=postgresql.service` to pull it in).

## t5

### Level 1

"At boot" needs an `[Install]` section and one command; "now" needs another — or one command with an option.

### Level 2

`WantedBy=multi-user.target`, then `systemctl enable --now`.

### Level 3

`sudo systemctl enable --now project-mercury.service`, then `systemctl status project-mercury`.

## t6

### Level 1

If t3 and t5 pass, this should work. Try it yourself first.

### Level 2

`sudo systemctl kill -s KILL project-mercury`, wait ten seconds, `systemctl status project-mercury`.

### Level 3

If it doesn't come back, check `systemctl show project-mercury -p Restart,RestartUSec` and `journalctl -u project-mercury -n 20`.
