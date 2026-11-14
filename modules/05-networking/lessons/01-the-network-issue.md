---
id: 05-networking/01-the-network-issue
title: "The Network Issue: Meet the Lab Network"
minutes: 5
objectives:
  - Describe the module's lab network
  - Name the layers you will check when troubleshooting
prerequisites: [04-shell-2/04-io-redirection]
tryit: none
---

# The Network Issue: Meet the Lab Network

## Why this matters

Before Bob can fix the rehearsal, he needs a map of the network. Every
network problem is easier when you can point at a diagram and say "the
packet gets this far".

## Concepts

The lab network built by Docker Compose for this module:

```text
           frontend 10.10.1.0/24                  backend 10.10.2.0/24
  +---------+   +---------+   +--------+       +--------+
  | client  |   |  dns    |   | web01  |       |  db01  |
  | .1.10   |   | .1.53   |   | .1.80  |       | .2.20  |
  +----+----+   +----+----+   +---+----+       +---+----+
       |             |            |                |
  =====+=============+============+====+     +=====+=========
                                       |     |
                                  +----+-----+----+
                                  |    router     |
                                  | .1.254 .2.254 |
                                  +---------------+
```

- **client** — where Bob works. It has `NET_ADMIN` rights so it can change
  its own routes.
- **router** — has a leg in each subnet and forwards packets between them.
- **dns** — runs `dnsmasq` and answers for the `company.local` zone.
- **web01** — a small web application.
- **db01** — the database server (something listening on port 5432).

The troubleshooting ladder from the story — link, address, route, name,
port — gives the order of the next three lessons in reverse: names (DNS),
then addresses and routes, then a full troubleshooting method.

## Try it

From your host, start any module 05 lab and open a shell on the client, for
example:

```bash norun
bin/course start dns
```

Then look around from the client:

```bash norun
hostname
ip -br addr
cat /etc/resolv.conf
```

## Common mistakes

- **Testing from the wrong machine.** "It works on db01" says nothing about
  whether the client can reach it. Always test from where the failure is.

## Recap

- Two subnets joined by a router; DNS, web and database servers on them.
- Troubleshoot bottom-up: link, address, route, name, port.

## Next

Names first: how does `db` become `10.10.2.20`?
