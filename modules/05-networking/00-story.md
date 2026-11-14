---
id: 05-networking/00-story
title: "Story: The network issue"
---

# Story: The network issue

Wednesday, week two. The first full rehearsal of the Mercury demo starts at
ten. At 10:02 the web page shows a single line:

```text
Error: could not connect to database server "db"
```

Priya looks at Bob. Bob looks at the screen. Marco looks at the ceiling.

"Database is up," says the DBA on the call. "I can see it listening on
5432."

"Then why can't the app reach it?" asks Priya.

Over the next hour Bob discovers that "the network" is not one thing but a
stack of layers, any of which can break independently. The client machine
can't turn the name `db` into an address because nobody told it where the
company's DNS server is. Once it has an address, it has no route to the
backend subnet where the database lives. And, in a separate incident the
same afternoon, the web server is up but listening on the wrong port and the
wrong interface.

Marco draws a ladder on the whiteboard:

```text
5. Port      is the service listening, and reachable?   ss, nc, curl
4. Name      does the name resolve to the right IP?     getent, dig
3. Route     is there a path to that IP?                ip route, traceroute
2. Address   do I have an IP on the right subnet?       ip addr
1. Link      is the interface up?                       ip link
```

"Start at the bottom," he says, "and climb until something fails. That's
where your problem is."

This module runs on a small simulated company network in Docker: a
`client`, a `router` joining two subnets, a `dns` server for the
`company.local` zone, a web server `web01` and a database `db01`.
