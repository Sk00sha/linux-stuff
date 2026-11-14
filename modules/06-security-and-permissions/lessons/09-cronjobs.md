---
id: 06-security-and-permissions/09-cronjobs
title: Cron Jobs
minutes: 12
objectives:
  - Read and write the five time fields of a crontab line
  - Manage per-user crontabs with crontab -e/-l/-u
  - Use system cron files in /etc/cron.d and the cron.daily directories
  - Find out whether a job ran
prerequisites: [06-security-and-permissions/04-user-management]
tryit: ubuntu
---

# Cron Jobs

## Why this matters

The intruder's scripts filled `/tmp` and the shared directories with junk.
Priya wants a clean-up script to run every evening at 21:00 as bob — not as
root, and not "whenever someone remembers". Linux's job scheduler, **cron**,
does exactly that.

## Concepts

### The cron daemon

`cron` (Debian/Ubuntu, service `cron`) or `cronie` (Rocky, service
`crond`) wakes up every minute, reads the schedules, and runs whatever is
due. Output of a job is mailed to its owner if mail is set up — otherwise
it's lost, so redirect it to a log file.

### Crontab syntax

```text
┌───────── minute        0-59
│ ┌─────── hour          0-23
│ │ ┌───── day of month  1-31
│ │ │ ┌─── month         1-12 (or jan-dec)
│ │ │ │ ┌─ day of week   0-7 (0 and 7 = Sunday, or sun-sat)
│ │ │ │ │
0 21 * * *  /opt/scripts/cleanup.sh >> /home/bob/cleanup.log 2>&1
```

| Syntax | Means | Example |
|---|---|---|
| `*` | every value | `* * * * *` = every minute |
| `a,b` | list | `0 9,17 * * *` = 09:00 and 17:00 |
| `a-b` | range | `0 9 * * 1-5` = 09:00 Monday–Friday |
| `*/n` | every n | `*/15 * * * *` = every 15 minutes |
| `@daily`, `@hourly`, `@reboot` | shortcuts | `@reboot /opt/start.sh` |

When both day-of-month and day-of-week are restricted, the job runs when
**either** matches — a classic surprise. Sites like crontab.guru explain any
expression in plain English.

### Per-user crontabs

| Command | Does |
|---|---|
| `crontab -e` | edit your crontab (opens `$EDITOR`, checks syntax on save) |
| `crontab -l` | list it |
| `crontab -r` | remove it (no confirmation!) |
| `sudo crontab -u bob -l` / `-e` | list / edit another user's crontab |
| `crontab FILE` | replace your crontab with FILE's contents |

User crontabs are stored in `/var/spool/cron/crontabs/` (Ubuntu) or
`/var/spool/cron/` (Rocky), but always use the `crontab` command to change
them. Access can be limited with `/etc/cron.allow` and `/etc/cron.deny`.

### System cron

- `/etc/crontab` and files in `/etc/cron.d/` have an **extra sixth field:
  the user** to run as:
  `30 2 * * * root /usr/local/sbin/backup.sh`
- `/etc/cron.hourly/`, `cron.daily/`, `cron.weekly/`, `cron.monthly/` hold
  scripts run on that schedule (by `run-parts`; no dots in file names).

### Environment gotchas

Cron runs jobs with a minimal environment: `PATH` is usually just
`/usr/bin:/bin`, there's no `~/.bashrc`, and the working directory is the
home directory. Use absolute paths in jobs, or set `PATH=` at the top of
the crontab.

### Did it run?

- Ubuntu: `grep CRON /var/log/syslog` or `journalctl -u cron`
- Rocky: `/var/log/cron` or `journalctl -u crond`
- And your own redirected output file.

systemd **timers** are a modern alternative (module 07 touches on units);
cron remains everywhere.

## Try it

Install a crontab for bob from a file and list it:

```bash
cat > /tmp/mycron <<'CRON'
# m h dom mon dow command
*/5 * * * * date >> /tmp/heartbeat.log
0 21 * * * /usr/bin/find /tmp -name '*.tmp' -mtime +1 -delete
CRON
crontab /tmp/mycron
crontab -l
```

```text
# m h dom mon dow command
*/5 * * * * date >> /tmp/heartbeat.log
0 21 * * * /usr/bin/find /tmp -name '*.tmp' -mtime +1 -delete
```

The file actually lives in the spool directory, which only root can read:

```bash
sudo ls -l /var/spool/cron/crontabs/
sudo crontab -u bob -l | grep -c date
```

```text
total 4
-rw------- 1 bob crontab 312 Nov 14 20:45 bob
1
```

A system cron file needs the user field — and is checked by cron, not by
`crontab`:

```bash keepoutput
echo '15 3 * * 0 root /usr/bin/apt-get -qq clean' | sudo tee /etc/cron.d/apt-clean
ls /etc/cron.daily
sudo rm /etc/cron.d/apt-clean
```

```text
15 3 * * 0 root /usr/bin/apt-get -qq clean
apt-compat  dpkg  man-db  plocate
```

Is the daemon running? Then remove the demo crontab:

```bash mayfail
pgrep -a cron
crontab -r
crontab -l
```

```text
12 cron
no crontab for bob
```

## Common mistakes

- **Six fields in a user crontab** (copying the user column from
  `/etc/crontab`): cron tries to run a command called `bob`.
- **Relative paths and missing PATH**: the job works in your shell and fails
  in cron. Use absolute paths.
- **No output redirection**: errors vanish. Append `>> /path/job.log 2>&1`.
- **`crontab -r` instead of `-e`** — they're next to each other on the
  keyboard and `-r` deletes everything without asking.
- **`%` in commands**: cron treats `%` as a newline; escape it as `\%`
  (e.g. in `date +\%F`).

## Recap

- Five fields: minute hour day-of-month month day-of-week, then the command.
- `crontab -e/-l/-r`, `-u USER` as root; system files in `/etc/crontab` and
  `/etc/cron.d/` include a user field.
- Use absolute paths, redirect output, and check the cron log.

## Next

Last lab of the module: `make lab ID=cronjob`. Then module 07: making
Mercury a proper service with systemd.
