# Hints — The web server that nobody can reach

## t1

### Level 1

Applications look in a local file before asking DNS. Compare what `getent hosts web01` says with web01's real address.

### Level 2

`getent hosts web01` on the client vs `ip -br addr` on web01. Look for a stale line in the client's `/etc/hosts`.

### Level 3

Delete (or fix) the `10.10.1.8 web01` line in the client's `/etc/hosts` with `sudo vi /etc/hosts`.

## t2

### Level 1

On web01, find out which port the app is actually listening on, and where that number comes from.

### Level 2

`sudo ss -tlnp` shows listening sockets; `/etc/webapp/webapp.conf` sets `LISTEN_PORT`. Restart the app after changing it.

### Level 3

Set `LISTEN_PORT=80` in `/etc/webapp/webapp.conf`, then `sudo webctl restart`.

## t3

### Level 1

Look closely at the *address* part of the listening socket in `ss` output.

### Level 2

`127.0.0.1` accepts only local connections. `LISTEN_ADDR` in the same config file controls it.

### Level 3

Set `LISTEN_ADDR=0.0.0.0`, then `sudo webctl restart` and check `ss -tln` shows `0.0.0.0:80`.

## t4

### Level 1

If t1–t3 pass, this should just work. If not, test step by step from the client.

### Level 2

`curl -v http://web01/` on the client shows the resolved IP, the connection and the response.

### Level 3

From client: `getent hosts web01` → `10.10.1.80`; `nc -zv web01 80` → succeeded; `curl http://web01/` → the page.
