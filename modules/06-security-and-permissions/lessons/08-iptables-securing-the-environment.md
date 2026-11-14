---
id: 06-security-and-permissions/08-iptables-securing-the-environment
title: "IPTABLES: Securing the Environment"
minutes: 20
objectives:
  - Design a default-deny inbound policy for a server
  - Allow return traffic with connection tracking
  - Restrict services to specific source hosts
  - Save and restore rules
prerequisites: [06-security-and-permissions/07-iptables-introduction]
tryit: ubuntu
---

# IPTABLES: Securing the Environment

## Why this matters

Marco's plan for the Mercury servers fits on a sticky note:

```text
app01: SSH only from devbox · HTTP from anyone · nothing else
db01:  PostgreSQL (5432) only from app01 · nothing else
```

Turning that into rules safely requires three ideas: a default-deny policy,
connection tracking, and source restrictions.

## Concepts

### Default deny

Instead of blocking the bad things (an endless list), allow the few good
things and drop the rest. For inbound traffic that means `INPUT` policy
`DROP` and explicit `ACCEPT` rules above it.

### Don't forget the essentials

A default-deny INPUT chain also drops things you didn't think of:

1. **Loopback traffic** — local programs talk to each other over `lo`
   (including, on the lab containers, Docker's DNS resolver at
   `127.0.0.11`). Allow it: `-A INPUT -i lo -j ACCEPT`.
2. **Replies to your own outgoing connections** — when app01 connects to
   db01, db01's answers arrive on app01's INPUT chain. Without a rule they're
   dropped and app01 can't reach anything. Connection tracking solves it:
   `-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT`.

### A template for a server

```bash
iptables -F INPUT                                                     # start clean
iptables -A INPUT -i lo -j ACCEPT                                     # loopback
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT # replies
iptables -A INPUT -p tcp --dport 22 -s 10.10.2.10 -j ACCEPT           # SSH from admin host
iptables -A INPUT -p tcp --dport 80 -j ACCEPT                         # web from anyone
iptables -A INPUT -p icmp -j ACCEPT                                   # ping (optional)
iptables -P INPUT DROP                                                # everything else
```

Order: essentials first, specific allows next, policy last. When working
remotely, the SSH rule must exist **before** the policy change.

DROP or REJECT for the rest? `DROP` gives attackers less information and
makes scans slow; `REJECT` makes legitimate mistakes fail fast. Either is
acceptable; graders in this course only check that the traffic doesn't get
through.

### OUTPUT and FORWARD

Restricting outbound traffic (`OUTPUT` policy DROP) is stronger still — a
compromised server can't call home — but needs rules for DNS, package
updates and so on. Most teams start with INPUT. `FORWARD` matters on
routers and on hosts running containers.

### Persistence

Rules live in kernel memory. To keep them:

- `sudo iptables-save > /etc/iptables/rules.v4` writes them in a restorable
  format; `sudo iptables-restore < /etc/iptables/rules.v4` loads them.
- Ubuntu/Debian: the `iptables-persistent` package restores
  `/etc/iptables/rules.v4` at boot (`netfilter-persistent save`).
- Rocky/RHEL: the `iptables-services` package uses `/etc/sysconfig/iptables`,
  though `firewalld` is the default there.

### nftables, briefly

The native nftables syntax for the same idea:

```text
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    iif lo accept
    ct state established,related accept
    tcp dport 22 ip saddr 10.10.2.10 accept
    tcp dport 80 accept
  }
}
```

New setups increasingly use `nft` (or `firewalld`) directly; knowing
iptables makes both easy to read.

## Try it

Build the app01-style policy on this machine, then test it from inside
(loopback and replies) and inspect the counters.

```bash
sudo iptables -F INPUT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -s 10.10.2.10 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -L INPUT -n --line-numbers
```

```text
Chain INPUT (policy DROP)
num  target     prot opt source               destination
1    ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0
2    ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
3    ACCEPT     6    --  10.10.2.10           0.0.0.0/0            tcp dpt:22
4    ACCEPT     6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80
```

Both connections below succeed — even the one to our own external address,
which doesn't come from `10.10.2.10`. Why? Traffic from a machine to *any*
of its own addresses travels over the loopback interface `lo`, which rule 1
accepts:

```bash
nc -zv -w 2 127.0.0.1 22
nc -zv -w 2 "$(hostname -I | awk '{print $1}')" 22
sudo iptables -L INPUT -v -n | sed -n '3p'
```

```text
Connection to 127.0.0.1 22 port [tcp/ssh] succeeded!
Connection to 172.17.0.2 22 port [tcp/ssh] succeeded!
   14   822 ACCEPT     0    --  lo     *       0.0.0.0/0            0.0.0.0/0
```

That's the lesson: **a firewall can only be tested from other machines.**
The lab grader probes each server from the other hosts for exactly this
reason.

Save the rules in restorable form, then reset everything:

```bash
sudo iptables-save | grep -E '^(\*|:INPUT|-A INPUT|COMMIT)'
sudo iptables-save > /tmp/rules.v4
sudo iptables -P INPUT ACCEPT
sudo iptables -F INPUT
sudo iptables-restore < /tmp/rules.v4
sudo iptables -S INPUT | head -2
sudo iptables -P INPUT ACCEPT; sudo iptables -F INPUT
```

```text
*filter
:INPUT DROP [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 10.10.2.10/32 -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
COMMIT
-P INPUT DROP
-A INPUT -i lo -j ACCEPT
```

## Common mistakes

- **No ESTABLISHED,RELATED rule** with a DROP policy: the server can no
  longer reach anything, because replies are dropped.
- **No loopback rule**: local services (and Docker's DNS in the labs) break
  in confusing ways.
- **Changing the policy first** while logged in over SSH.
- **Testing only from the machine itself.** Its own traffic goes over `lo`;
  rules about *sources* must be tested from those sources.

## Recap

- Default deny inbound: allow `lo`, `ESTABLISHED,RELATED`, then specific
  services with `-s` source limits, then `-P INPUT DROP`.
- Add rules before changing the policy when working remotely.
- `iptables-save`/`iptables-restore` (plus iptables-persistent or
  iptables-services) make rules survive reboots; nftables is the modern
  native syntax.

## Next

Lab: `make lab ID=iptables`. Then: scheduling jobs with cron.
