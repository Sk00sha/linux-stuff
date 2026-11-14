# Cheatsheet — The Client Demonstration

## The loop

observe → hypothesise → test (read-only) → fix one thing → verify → repeat

## First five minutes

| Command | Tells you |
|---|---|
| `curl -sv http://localhost/` | refused / timeout / HTTP status and body |
| `systemctl status NAME` / `is-enabled` | running? at boot? last log lines |
| `journalctl -u NAME -n 50 --no-pager` | why it failed |
| `systemctl cat NAME` / `show NAME -p Environment,User,ExecStart` | what it really runs, how |
| `sudo -u SVCUSER cat FILE` | the service's view of a file |

## Error → layer

| Message | Look at |
|---|---|
| `status=203/EXEC` | `ExecStart=` path, `ls -l`, `chmod +x` |
| `env: 'python3': No such file` | `Environment=PATH=` in the unit |
| `ModuleNotFoundError` / `command not found` | `dpkg -l`, `apt-get install` |
| `Permission denied` | `ls -l`, `id`, `chown`, `chmod`, `User=` |
| `could not translate host name` | `getent hosts`, `/etc/hosts`, `/etc/resolv.conf` |
| `timed out` | `ip route get`, `iptables -L -n -v --line-numbers` (DROP) |
| `refused` | `ss -tlnp` on the server, REJECT rules |
| `No space left on device` | `df -h`, `df -i`, `du -ah DIR \| sort -h \| tail` |
| job didn't run | `/etc/cron.d/*`, `crontab -l`, `systemctl is-active cron` |

## Don'ts

`chmod 777` · `iptables -F` on a shared box · running the app as root · two changes at once · forgetting `daemon-reload`
