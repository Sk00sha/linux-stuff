# Solution — Teach the client to find the database

All on `client` as `bob`, using `sudo` for root-owned files.

## t1 — a local hosts entry

`/etc/hosts` is consulted first (`hosts: files dns` in `/etc/nsswitch.conf`).
`tee -a` appends as root; a plain `>>` redirection would run as bob and fail.

```bash solution target=client user=bob
echo "10.10.2.20 db01" | sudo tee -a /etc/hosts
getent hosts db01
```

## t2 and t3 — use the company DNS server and search domain

The new file has exactly one nameserver and a search domain. `sudo tee`
overwrites the bind-mounted file in place.

```bash solution target=client user=bob
printf 'nameserver 10.10.1.53\nsearch company.local\n' | sudo tee /etc/resolv.conf
getent hosts db.company.local
getent hosts www
```

`www` → `www.company.local`, a CNAME for `web01.company.local` →
`10.10.1.80`. Names outside `company.local` still work because dnsmasq
forwards them upstream.

## t4 — the mail server

```bash solution target=client user=bob
dig company.local MX +short
dig company.local MX +short | awk '{print $2}' | sed 's/\.$//' > /home/bob/mx.txt
cat /home/bob/mx.txt
```
