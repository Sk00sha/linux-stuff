---
id: 05-networking/03-networking-basics
title: Networking Basics
minutes: 20
objectives:
  - Read IP addresses, subnet masks and CIDR notation
  - Explain what a gateway and a routing table do
  - Inspect interfaces, addresses and routes with the ip command
  - Add and remove routes, and enable forwarding on a router
prerequisites: [05-networking/02-dns]
tryit: lab:client
tryit_services: [client, dns, web01, db01, router]
---

# Networking Basics

## Why this matters

Once the client could resolve `db.company.local` to `10.10.2.20`, the
connection still failed: the client had no idea how to reach the
`10.10.2.0/24` network. Understanding addresses, subnets and routes lets Bob
fix that — and explains half of all "connection timed out" errors.

## Concepts

### IP addresses and subnets

An IPv4 address is 32 bits, written as four numbers from 0–255:
`10.10.1.10`. Every address belongs to a **subnet** (network). The **prefix
length** says how many leading bits identify the network:

```text
10.10.1.10/24
└──────┘└┘
 network  host part (8 bits -> 256 addresses, 254 usable)
```

| CIDR | Netmask | Addresses |
|---|---|---|
| `/8` | 255.0.0.0 | 16,777,216 |
| `/16` | 255.255.0.0 | 65,536 |
| `/24` | 255.255.255.0 | 256 |
| `/32` | 255.255.255.255 | 1 (a single host) |

Hosts in the same subnet talk to each other directly (via the switch or
bridge). To reach any other subnet, a packet must go through a **router**.

Private ranges used inside companies: `10.0.0.0/8`, `172.16.0.0/12`,
`192.168.0.0/16`.

### Gateways and the routing table

Every host has a **routing table**: a list of "to reach network X, send the
packet to Y". The kernel picks the most specific matching route (longest
prefix). The **default route** (`default` or `0.0.0.0/0`) matches
everything; its next hop is the **default gateway**.

```text
default via 10.10.1.1 dev eth0                 # everything else -> 10.10.1.1
10.10.1.0/24 dev eth0 scope link               # my own subnet: deliver directly
10.10.2.0/24 via 10.10.1.254 dev eth0          # backend -> through the router
```

### The `ip` command

`ip` (from iproute2) replaces the old `ifconfig`, `route` and `arp` tools.

| Command | Shows / does |
|---|---|
| `ip link` | interfaces and whether they're UP |
| `sudo ip link set eth0 up` | bring an interface up |
| `ip addr` / `ip -br addr` | addresses per interface (`-br` = brief) |
| `sudo ip addr add 10.0.0.5/24 dev eth0` | add an address |
| `ip route` (`ip r`) | routing table |
| `sudo ip route add 10.10.2.0/24 via 10.10.1.254` | add a route |
| `sudo ip route del 10.10.2.0/24` | remove it |
| `ip route get 10.10.2.20` | which route would be used for this destination? |
| `ip neigh` | the ARP/neighbour cache (IP → MAC on the local subnet) |

Changes made with `ip` are **not persistent**; they vanish at reboot. To make
them permanent, use the distribution's network configuration: netplan
(`/etc/netplan/*.yaml`) on Ubuntu, NetworkManager (`nmcli`) on Rocky.

### Routers forward

A Linux machine with two interfaces becomes a router when **IP forwarding**
is enabled:

```bash
cat /proc/sys/net/ipv4/ip_forward        # 0 = off, 1 = on
sudo sysctl -w net.ipv4.ip_forward=1     # enable now
```

Persist it with a file in `/etc/sysctl.d/`. Return traffic matters too: the
destination host needs a route back (the lab's `db01` has one via the
router).

## Try it

These run on the lab `client`.

Interfaces and addresses:

```bash
ip -br link
ip -br addr
```

```text
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0@if178       UP             5e:cf:1a:0e:0d:bb <BROADCAST,MULTICAST,UP,LOWER_UP>
lo               UNKNOWN        127.0.0.1/8
eth0@if178       UP             10.10.1.10/24
```

The routing table, and the route the kernel would choose:

```bash
ip route
ip route get 10.10.1.80
ip route get 8.8.8.8
```

```text
default via 10.10.1.1 dev eth0
10.10.1.0/24 dev eth0 proto kernel scope link src 10.10.1.10
10.10.1.80 dev eth0 src 10.10.1.10 uid 1000
    cache
8.8.8.8 via 10.10.1.1 dev eth0 src 10.10.1.10 uid 1000
    cache
```

`10.10.1.80` is on our own subnet (delivered directly); `8.8.8.8` would go
to the default gateway.

Neighbours on the local subnet after talking to them:

```bash
ping -c1 -W1 10.10.1.254 > /dev/null
ip neigh show 10.10.1.254
```

```text
10.10.1.254 dev eth0 lladdr aa:69:ac:c7:11:3a REACHABLE
```

Add and remove a route (it needs `sudo`; the lab's `client` is allowed to
change its own network settings):

```bash
sudo ip route add 192.168.77.0/24 via 10.10.1.254
ip route | grep 192.168.77
ip route get 192.168.77.5
sudo ip route del 192.168.77.0/24
```

```text
192.168.77.0/24 via 10.10.1.254 dev eth0
192.168.77.5 via 10.10.1.254 dev eth0 src 10.10.1.10 uid 1000
    cache
```

Is forwarding enabled here?

```bash
cat /proc/sys/net/ipv4/ip_forward
```

```text
1
```

Docker switches forwarding on inside every container's network namespace,
so you'll see `1` on the lab machines. On a typical workstation or server
it's `0` — and on a machine meant to be a router, like the lab's `router`,
it must be `1`.

## Common mistakes

- **Adding a route via a gateway that isn't on your subnet.** The next hop
  must be directly reachable: `via 10.10.2.254` from the client fails with
  "Nexthop has invalid gateway".
- **Forgetting the return path.** The packet arrives but the reply has no
  route back; it looks exactly like "no route" from the sender's side.
- **Expecting `ip` changes to survive a reboot.** Persist them in netplan or
  NetworkManager.
- **Using `ifconfig`.** It's deprecated and often not installed; it also
  can't show everything `ip` can.

## Recap

- An address plus prefix (`/24`) defines the subnet; other subnets are
  reached through routers.
- `ip link`, `ip addr`, `ip route`, `ip route get`, `ip neigh` inspect;
  `ip route add/del` changes routes (not persistent).
- A Linux router needs `net.ipv4.ip_forward=1` and hosts need return routes.

## Next

Put it all together: a systematic troubleshooting method.
