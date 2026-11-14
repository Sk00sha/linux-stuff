# Solution — Finale: save the client demonstration

The faults vary with `SEED`, but the method — and the commands below — work
for every seed. In real life you'd run them as bob with `sudo`; the
automated test runs them as root on demo-web.

## 1. Observe

```text
$ curl -v http://localhost/         -> Connection refused: nothing on port 80
$ systemctl status mercury-web      -> inactive (dead), disabled
$ systemctl cat mercury-web         -> ExecStart points at a file that doesn't exist,
                                       and Environment=PATH=… lacks /usr/bin
```

## 2. The unit file (t2, t3)

`ExecStart` must point at the real program; the bogus `PATH` must go,
otherwise `#!/usr/bin/env python3` can't find Python (`status=127`).

```bash solution target=demo-web user=root
ls -l /usr/local/bin/mercury*
sed -i 's#^ExecStart=.*#ExecStart=/usr/local/bin/mercury-web#; /^Environment=PATH=/d' /etc/systemd/system/mercury-web.service
systemctl daemon-reload
systemctl enable mercury-web
systemctl restart mercury-web || true
sleep 2; journalctl -u mercury-web -n 5 --no-pager -o cat
```

## 3. Missing package (t9)

The journal now says `No module named 'psycopg'`. The package is in the
local APT cache, so this works offline.

```bash solution target=demo-web user=root
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-psycopg
systemctl restart mercury-web; sleep 2; journalctl -u mercury-web -n 3 --no-pager -o cat
```

## 4. Configuration permissions (t4)

Next error: `Permission denied` on `/etc/mercury/app.conf`. The file holds a
password: readable by root and the `mercury` group, nobody else.

```bash solution target=demo-web user=root
ls -l /etc/mercury/app.conf
chown root:mercury /etc/mercury/app.conf
chmod 640 /etc/mercury/app.conf
systemctl restart mercury-web; sleep 2; systemctl is-active mercury-web
curl -s http://localhost/ || true
```

## 5. Disk full (t7)

The site answers `500 storage error: … No space left on device`.

```bash solution target=demo-web user=root
df -h /var/lib/mercury
du -ah /var/lib/mercury | sort -h | tail -3
find /var/lib/mercury -type f -size +256k -print -delete
df -h /var/lib/mercury
```

## 6. Name resolution (t5)

Now `503 database error: … failed to resolve host` (or a timeout if the IP
is wrong). `/etc/hosts` has a typo in the name or address. Docker
bind-mounts the file, so write it in place.

```bash solution target=demo-web user=root
getent hosts db01.caleston.local || echo "does not resolve"
grep caleston /etc/hosts
grep -v 'caleston\.l' /etc/hosts > /tmp/hosts.new
echo "10.10.9.20  db01.caleston.local db01" >> /tmp/hosts.new
cat /tmp/hosts.new > /etc/hosts
getent hosts db01.caleston.local
```

## 7. Firewall (t6)

Still `503`: connection timed out (DROP) or refused (REJECT). An OUTPUT rule
from someone's test blocks port 5432. Remove that rule, not the whole
firewall.

```bash solution target=demo-web user=root
iptables -L OUTPUT -n --line-numbers
iptables -S OUTPUT | grep -- '--dport 5432' | sed 's/^-A /-D /' | while read -r rule; do eval iptables "$rule"; done
nc -zv -w 3 10.10.9.20 5432
curl -s http://localhost/
```

## 8. Log rotation (t8)

Not visible from the site, but part of a healthy server: the nightly job was
deleted or commented out.

```bash solution target=demo-web user=root
ls -l /etc/cron.d/
echo '15 2 * * * root /usr/local/bin/mercury-rotate' > /etc/cron.d/mercury-logrotate
chmod 644 /etc/cron.d/mercury-logrotate
systemctl is-active cron
```

## 9. Final verification

```bash solution target=demo-web user=root
systemctl is-enabled mercury-web; systemctl is-active mercury-web
curl -s -w ' (HTTP %{http_code})\n' http://localhost/
```

`Caleston demo: Caleston Mercury is live! (HTTP 200)` — with minutes to
spare.
