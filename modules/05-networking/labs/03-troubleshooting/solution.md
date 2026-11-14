# Solution — The web server that nobody can reach

Climbing the ladder from the client:

1. **Name** — `getent hosts web01` returns `10.10.1.8`, but web01 is
   `10.10.1.80`. `/etc/hosts` has a stale entry, and it wins over DNS.
2. **Route** — `ping 10.10.1.80` works (same subnet).
3. **Port** — `nc -zv 10.10.1.80 80` → *Connection refused*: the host
   answers, nothing listens. On web01, `sudo ss -tlnp` shows
   `127.0.0.1:8080`: wrong port **and** loopback-only.

## t1 — remove the stale hosts entry (on client)

Docker bind-mounts `/etc/hosts`, so filter into a temporary file and write
it back in place (an editor works just as well).

```bash solution target=client user=bob
getent hosts web01
grep -v '^10\.10\.1\.8[[:space:]]' /etc/hosts > /tmp/hosts.new
sudo tee /etc/hosts < /tmp/hosts.new > /dev/null
getent hosts web01
```

## t2 + t3 — fix the listener (on web01)

`LISTEN_ADDR=0.0.0.0` means "all addresses". Port 80 is a privileged port
(below 1024), which is why webctl runs the app as root.

```bash solution target=web01 user=bob
sudo ss -tlnp
sudo sed -i 's/^LISTEN_ADDR=.*/LISTEN_ADDR=0.0.0.0/; s/^LISTEN_PORT=.*/LISTEN_PORT=80/' /etc/webapp/webapp.conf
sudo webctl restart
sudo ss -tlnp | grep ':80 '
```

## t4 — test end to end (on client)

```bash solution target=client user=bob
curl -s http://web01/
```
