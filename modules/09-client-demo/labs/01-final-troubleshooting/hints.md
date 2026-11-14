# Hints — Finale: save the client demonstration

## t1

### Level 1

t1 passes when t2–t9 do. Work through the others, testing `curl http://localhost/` after each fix.

### Level 2

Read what the site and the service tell you: `curl -v http://localhost/`, `systemctl status mercury-web`, `journalctl -u mercury-web -n 30`.

### Level 3

Fix in this order: unit file (t2, t3) → package (t9) → config (t4) → disk (t7) → name (t5) → firewall (t6) → cron (t8).

## t2

### Level 1

Is the service running? Is it enabled? What exactly does it try to start?

### Level 2

`systemctl status mercury-web`, `systemctl cat mercury-web`, `ls -l /usr/local/bin/mercury*`. Look for `status=203/EXEC`.

### Level 3

Fix `ExecStart=` in `/etc/systemd/system/mercury-web.service` to `/usr/local/bin/mercury-web`, then `sudo systemctl daemon-reload && sudo systemctl enable --now mercury-web`.

## t3

### Level 1

The program is a script that finds its interpreter through the environment.

### Level 2

`head -1 /usr/local/bin/mercury-web` and `systemctl show mercury-web -p Environment`. The journal may say `env: 'python3': No such file or directory`.

### Level 3

Delete the `Environment=PATH=…` line from the unit (or make it include `/usr/bin`), `daemon-reload`, restart.

## t4

### Level 1

The service runs as `mercury`. Can `mercury` read its configuration? Can everyone else?

### Level 2

`ls -l /etc/mercury/app.conf` and `sudo -u mercury cat /etc/mercury/app.conf`. The file holds a password.

### Level 3

`sudo chown root:mercury /etc/mercury/app.conf && sudo chmod 640 /etc/mercury/app.conf`, then restart the service.

## t5

### Level 1

The config names the database server. How does demo-web turn that name into an address?

### Level 2

`grep DB_HOST /etc/mercury/app.conf`, `getent hosts db01.caleston.local`, `cat /etc/hosts`. The database is 10.10.9.20.

### Level 3

Make `/etc/hosts` contain exactly `10.10.9.20 db01.caleston.local db01` for that name (watch for typos in the name or the address). Edit it with `sudo vi` — `sed -i` can't replace this bind-mounted file.

## t6

### Level 1

The name resolves and the database is up, yet connections fail. Something on demo-web stands in the way.

### Level 2

`nc -zv 10.10.9.20 5432`, then `sudo iptables -L OUTPUT -n -v --line-numbers`.

### Level 3

Delete the rule for port 5432: `sudo iptables -D OUTPUT <number>` — don't flush everything.

## t7

### Level 1

The site answers, but with a storage error. Where does the app write, and how full is it?

### Level 2

`df -h /var/lib/mercury`, then `sudo du -ah /var/lib/mercury | sort -h | tail` — hidden directories count too.

### Level 3

Remove the huge leftover file you find under `/var/lib/mercury` (it's not the heartbeat), then `df -h` again.

## t8

### Level 1

Nightly jobs are defined in a directory under `/etc`. Is Mercury's rotation job there, and is it active?

### Level 2

`ls -l /etc/cron.d/`, `cat /etc/cron.d/*`. System cron lines need a user field.

### Level 3

`echo '15 2 * * * root /usr/local/bin/mercury-rotate' | sudo tee /etc/cron.d/mercury-logrotate` (or un-comment the existing line).

## t9

### Level 1

The journal shows a Python error about a missing module. Which package provides it?

### Level 2

`journalctl -u mercury-web | grep -i module`; `apt-cache search psycopg`; `dpkg -l | grep psycopg`.

### Level 3

`sudo apt-get install python3-psycopg` (works offline from the local cache), then restart the service.
