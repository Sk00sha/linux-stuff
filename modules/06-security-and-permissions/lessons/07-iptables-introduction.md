---
id: 06-security-and-permissions/07-iptables-introduction
title: IPTABLES Introduction
minutes: 20
objectives:
  - Describe tables, chains, rules and targets
  - Explain how rule order and the default policy decide a packet's fate
  - List, add, insert and delete rules
prerequisites: [05-networking/04-troubleshooting]
tryit: ubuntu
---

# IPTABLES Introduction

## Why this matters

During the incident, app01 accepted connections from anywhere to every
port it had open. A host firewall lets each server decide which traffic it
accepts — the network layer of least privilege. On Linux, the classic tool
is `iptables`.

## Concepts

### Netfilter, iptables and nftables

The kernel's packet-filtering framework is **netfilter**. `iptables` is the
long-standing command for configuring it. Modern distributions use a newer
kernel backend, **nftables**, and ship an `iptables` command that translates
the familiar syntax onto it (`iptables -V` shows `(nf_tables)`). The rules
and concepts below apply either way; `nft` is the native nftables tool, and
`firewalld` (Rocky) and `ufw` (Ubuntu) are friendlier front ends on top.

### Tables and chains

Rules are organised into **tables** by purpose; this module uses the
default **filter** table, which decides whether packets are allowed. (Others:
`nat` for address translation, `mangle`, `raw`.)

Each table contains **chains** — ordered lists of rules applied at a
particular point:

```text
                       ┌─────────┐
 packet arrives ──────>│  INPUT  │──> local process (sshd, web server)
       │               └─────────┘
       │               ┌─────────┐
       └──────────────>│ FORWARD │──> out another interface (routers only)
                       └─────────┘
 local process ───────>┌─────────┐
                       │ OUTPUT  │──> leaves the machine
                       └─────────┘
```

- **INPUT** — packets addressed to this machine.
- **OUTPUT** — packets this machine sends.
- **FORWARD** — packets passing through (when it routes).

### Rules, matches and targets

A rule is a set of **matches** plus a **target**:

```bash
iptables -A INPUT -p tcp --dport 22 -s 10.10.2.10 -j ACCEPT
#        │        │      │          │              └─ target
#        │        └──────┴──────────┴─ matches: protocol, destination port, source
#        └─ append to the INPUT chain
```

| Match | Meaning |
|---|---|
| `-p tcp` / `-p udp` / `-p icmp` | protocol |
| `--dport 80` / `--sport 5432` | destination / source port (needs `-p`) |
| `-s 10.10.2.10` / `-s 10.10.2.0/24` | source address or network |
| `-d ADDRESS` | destination address |
| `-i eth0` / `-o eth0` | incoming / outgoing interface (`-i lo` = loopback) |
| `-m conntrack --ctstate ESTABLISHED,RELATED` | packets of connections already allowed |

| Target | Effect |
|---|---|
| `ACCEPT` | let the packet through |
| `DROP` | silently discard (sender sees a timeout) |
| `REJECT` | discard and tell the sender (sender sees "refused") |
| `LOG` | log it and continue to the next rule |

### Order and policy

Rules in a chain are checked **top to bottom; the first matching rule with
ACCEPT/DROP/REJECT wins**. If none matches, the chain's **policy** applies
(`ACCEPT` by default). So:

- specific exceptions go **above** general rules;
- `-A` appends at the bottom, `-I CHAIN N` inserts at position N (default 1).

### Commands

| Command | Does |
|---|---|
| `sudo iptables -L -n -v --line-numbers` | list rules (numeric, with counters and positions) |
| `sudo iptables -S` | list rules as the commands that create them |
| `sudo iptables -A INPUT …` | append a rule |
| `sudo iptables -I INPUT 1 …` | insert at the top |
| `sudo iptables -D INPUT 3` | delete rule number 3 (or repeat the rule spec) |
| `sudo iptables -P INPUT DROP` | set the chain policy |
| `sudo iptables -F INPUT` | flush (delete) all rules in a chain |

Rules take effect immediately and vanish at reboot unless saved (next
lesson).

## Try it

The lab containers are allowed to manage their own firewall.

Which backend, and what's there now?

```bash
sudo iptables -V
sudo iptables -L -n --line-numbers
```

```text
iptables v1.8.10 (nf_tables)
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination
```

Block SSH, and see "refused" vs "timeout" from the client's point of view
(here the client and server are the same machine, via its own IP):

```bash mayfail
IP=$(hostname -I | awk '{print $1}')
nc -zv -w 2 "$IP" 22
sudo iptables -A INPUT -p tcp --dport 22 -j DROP
nc -zv -w 2 "$IP" 22
sudo iptables -D INPUT -p tcp --dport 22 -j DROP
sudo iptables -A INPUT -p tcp --dport 22 -j REJECT
nc -zv -w 2 "$IP" 22
sudo iptables -F INPUT
```

```text
Connection to 172.17.0.2 22 port [tcp/ssh] succeeded!
nc: connect to 172.17.0.2 port 22 (tcp) timed out: Operation now in progress
nc: connect to 172.17.0.2 port 22 (tcp) failed: Connection refused
```

Order matters — an ACCEPT inserted above a DROP wins:

```bash
sudo iptables -A INPUT -p tcp --dport 8080 -j DROP
sudo iptables -I INPUT 1 -p tcp --dport 8080 -s 127.0.0.1 -j ACCEPT
sudo iptables -L INPUT -n --line-numbers
sudo iptables -S INPUT
sudo iptables -F INPUT
```

```text
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     6    --  127.0.0.1            0.0.0.0/0            tcp dpt:8080
2    DROP       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:8080
-P INPUT ACCEPT
-A INPUT -s 127.0.0.1/32 -p tcp -m tcp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8080 -j DROP
```

## Common mistakes

- **Setting `-P INPUT DROP` over SSH before allowing SSH.** You lock
  yourself out instantly. Add the ACCEPT rules first, then change the
  policy.
- **Appending an ACCEPT after a DROP that already matches.** It will never be
  reached; use `-I` or reorder.
- **`--dport` without `-p tcp`.** iptables refuses: ports only exist for
  TCP/UDP.
- **Forgetting the rules are not persistent.** A reboot wipes them.

## Recap

- netfilter in the kernel, configured by `iptables` (nftables backend today).
- filter table chains: INPUT, OUTPUT, FORWARD; rules = matches + target
  (ACCEPT, DROP, REJECT); first match wins, then the policy.
- `-L -n --line-numbers`, `-S`, `-A`, `-I`, `-D`, `-P`, `-F`.

## Next

Building a real policy: default deny, established connections, and saving
the rules.
