# Solution — Route the client to the backend

All on `client` as `bob`.

## t1 — the client's address

`-4` limits output to IPv4; `-br` is the brief format, whose third column is
the address in CIDR notation.

```bash solution target=client user=bob
ip -4 -br addr show eth0 | awk '{print $3}' > /home/bob/client-ip.txt
cat /home/bob/client-ip.txt
```

## t2 — a route through the router

The router has two addresses; only `10.10.1.254` is on the client's subnet
(`10.10.1.0/24`), so that is the next hop. Docker's DNS resolves `router` to
that address for us.

```bash solution target=client user=bob
getent hosts router
sudo ip route add 10.10.2.0/24 via 10.10.1.254
ip route get 10.10.2.20
```

## t3 — test

The router has `ip_forward=1`, and db01 has a route back to `10.10.1.0/24`
via the router's backend address, so replies find their way home.

```bash solution target=client user=bob
ping -c 2 10.10.2.20
```

## t4 — read the banner

`nc` opens a TCP connection and prints whatever the server sends; `-w 2`
gives up after two idle seconds.

```bash solution target=client user=bob
nc -w 2 10.10.2.20 5432 > /home/bob/db-banner.txt
cat /home/bob/db-banner.txt
```
