---
id: 05-networking/04-troubleshooting
title: Network Troubleshooting
minutes: 20
objectives:
  - Troubleshoot connectivity layer by layer
  - Test reachability with ping and traceroute
  - See which ports are listening with ss
  - Test TCP ports and HTTP services with nc and curl
prerequisites: [05-networking/03-networking-basics]
tryit: lab:client
tryit_services: [client, dns, web01, db01, router]
---

# Network Troubleshooting

## Why this matters

In the afternoon incident, `web01` was "up" but nobody could load the site.
Guessing ("restart it!") wastes time. A layered method finds the broken
layer in minutes and gives you evidence to show the team.

## Concepts

### Climb the ladder

Work from the bottom up, testing **from the machine that has the problem**:

| Layer | Question | Commands |
|---|---|---|
| 1. Link | Is the interface up? | `ip link` |
| 2. Address | Do I have the right IP/subnet? | `ip addr` |
| 3. Route | Is there a path to the target? | `ip route get IP`, `ping IP`, `traceroute IP` |
| 4. Name | Does the name resolve to the right IP? | `getent hosts NAME`, `dig NAME` |
| 5. Port | Is the service listening and reachable? | on the server: `ss -tlnp`; from the client: `nc -zv`, `curl -v` |

The first layer that fails is where to look.

### Reachability: `ping` and `traceroute`

- `ping -c 3 HOST` sends ICMP echo requests. Replies prove layers 1–3 (and
  4, if you used a name) work in both directions. No reply doesn't always
  mean down — firewalls often drop ICMP.
- `traceroute HOST` (or `tracepath`) lists every router on the way, which
  shows *where* packets stop.

### What's listening? `ss`

On the **server**, `ss -tlnp` lists **t**CP sockets in **l**isten state,
with **n**umeric ports and the owning **p**rocess (`sudo` to see other
users' processes). The local address column matters:

| Local address | Reachable from |
|---|---|
| `0.0.0.0:80` or `*:80` | any interface — other machines can connect |
| `127.0.0.1:80` | **only the machine itself** |
| `10.10.1.80:80` | only via that address |

A service bound to `127.0.0.1` works perfectly with `curl localhost` on the
server and fails from everywhere else — a classic.

(`netstat -tlnp` is the older equivalent; `ss` replaces it.)

### Testing ports from the client: `nc`, `curl`, `telnet`

- `nc -zv HOST PORT` (netcat) tries a TCP connection and reports
  `succeeded` or `Connection refused` / timeout. Add `-w 2` for a 2-second
  timeout.
  - **Refused** = the host answered, but nothing listens on that port.
  - **Timeout** = no answer at all: routing problem, host down, or a
    firewall dropping packets.
- `curl -v http://HOST:PORT/` makes a real HTTP request and shows each step:
  name resolution, connection, request, response headers.
- `telnet HOST PORT` is the old way to poke at a port interactively.

## Try it

These run on the lab `client`. The web server `web01` runs a small app
controlled by `webctl`; in this lesson it may or may not be running
correctly — that's fine, read the output either way.

Layers 1–3: link, address and a ping across the local subnet:

```bash
ip -br link show eth0
ip -br addr show eth0
ping -c 2 -W 1 10.10.1.80
```

```text
eth0@if178       UP             5e:cf:1a:0e:0d:bb <BROADCAST,MULTICAST,UP,LOWER_UP>
eth0@if178       UP             10.10.1.10/24
PING 10.10.1.80 (10.10.1.80) 56(84) bytes of data.
64 bytes from 10.10.1.80: icmp_seq=1 ttl=64 time=0.122 ms
64 bytes from 10.10.1.80: icmp_seq=2 ttl=64 time=0.071 ms

--- 10.10.1.80 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1012ms
rtt min/avg/max/mdev = 0.071/0.096/0.122/0.025 ms
```

The router is on our subnet, so it's a single hop away:

```bash
traceroute -n -w 1 -q 1 10.10.1.254
```

```text
traceroute to 10.10.1.254 (10.10.1.254), 30 hops max, 60 byte packets
 1  10.10.1.254  0.077 ms
```

Layer 4: does the name resolve, and to what?

```bash
getent hosts web01
```

```text
10.10.1.80      web01
```

Layer 5: "refused" versus "succeeded". The router has SSH (22) open but
nothing on 81:

```bash mayfail
nc -zv -w 2 10.10.1.254 22
nc -zv -w 2 10.10.1.254 81
```

```text
Connection to 10.10.1.254 22 port [tcp/ssh] succeeded!
nc: connect to 10.10.1.254 port 81 (tcp) failed: Connection refused
```

What is listening on this machine? `ss` on the client itself:

```bash
ss -tln
```

```text
State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess
LISTEN 0      128          0.0.0.0:22         0.0.0.0:*
LISTEN 0      4096      127.0.0.11:37717      0.0.0.0:*
```

`127.0.0.11` is Docker's internal DNS resolver: listening only on a loopback
address, so nobody else can reach it. `sshd` listens on all addresses.

A verbose HTTP request shows every step (here against the router's SSH
port, which isn't HTTP — notice where it fails):

```bash mayfail
curl -sv -m 3 http://10.10.1.254:22/ 2>&1 | grep -E '^\*' | head -3
```

```text
*   Trying 10.10.1.254:22...
* Connected to 10.10.1.254 (10.10.1.254) port 22
* Received HTTP/0.9 when not allowed
```

## Common mistakes

- **Concluding "the host is down" because ping fails.** ICMP may be blocked;
  test the actual port with `nc` or `curl`.
- **Testing on the server only.** `curl localhost` succeeding on web01 proves
  nothing about the client's path, firewall or DNS.
- **Ignoring the difference between "refused" and "timed out".** Refused
  points at the service; timeout points at the network or a firewall.
- **Missing a `127.0.0.1` bind address in `ss` output.** The service is up
  but private.

## Recap

- Bottom-up: link → address → route → name → port, from the affected
  machine.
- `ping`, `traceroute` for paths; `getent`/`dig` for names; `ss -tlnp` on the
  server; `nc -zv` and `curl -v` from the client.
- Refused = nothing listening; timeout = network or firewall.

## Next

Three labs: `make lab ID=dns`, `make lab ID=network-basics` and
`make lab ID=troubleshooting`.
