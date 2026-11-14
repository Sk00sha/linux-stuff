# Cheatsheet — Networking

## Names

| Command / file | Does |
|---|---|
| `/etc/hosts` | local IP → name list (wins with `hosts: files dns`) |
| `/etc/resolv.conf` | `nameserver IP`, `search domain` |
| `/etc/nsswitch.conf` | lookup order |
| `getent hosts NAME` | resolve like applications do |
| `dig NAME [A\|AAAA\|MX\|CNAME\|TXT] [+short] [@server]` | query DNS |
| `nslookup NAME [server]`, `host NAME` | simpler DNS queries |

## Addresses and routes

| Command | Does |
|---|---|
| `ip -br link` / `sudo ip link set eth0 up` | interfaces / bring up |
| `ip -br addr` / `sudo ip addr add 10.0.0.5/24 dev eth0` | addresses / add one |
| `ip route` / `ip route get IP` | routing table / route used for IP |
| `sudo ip route add NET/PFX via GW` / `del` | add / remove route |
| `ip neigh` | ARP cache |
| `cat /proc/sys/net/ipv4/ip_forward`, `sysctl -w net.ipv4.ip_forward=1` | forwarding |

/24 = 256 addresses · /16 = 65,536 · private: 10/8, 172.16/12, 192.168/16

## Troubleshooting ladder

link (`ip link`) → address (`ip addr`) → route (`ip route get`, `ping`, `traceroute`)
→ name (`getent`, `dig`) → port (`ss -tlnp` on server; `nc -zv`, `curl -v` from client)

Refused = host answered, nothing listening · Timeout = network/firewall · `127.0.0.1:port` = local only
