# Lab: Firewall app01 and db01

Turn Marco's sticky note into firewall rules:

```text
app01 (10.10.2.30): SSH only from devbox · HTTP from anyone · nothing else
db01  (10.10.2.20): PostgreSQL only from app01 · SSH only from devbox · nothing else
devbox (10.10.2.10): the admin machine — you work from here
```

- **Runtime:** Docker — `devbox`, `app01`, `db01`; you start as `bob` on `devbox`
- **Estimated time:** 35 minutes
- **Start:** `make lab ID=iptables` · **Check:** `make check ID=iptables`

## Tasks

| ID | Task |
|---|---|
| t1 | On `app01`, allow SSH (22/tcp) only from devbox (`10.10.2.10`). |
| t2 | On `app01`, allow HTTP (80/tcp) from anywhere. |
| t3 | On `app01`, drop all other inbound traffic — while app01 can still open connections to `db01:5432`. |
| t4 | On `db01`, allow PostgreSQL (5432/tcp) only from app01 (`10.10.2.30`). |
| t5 | On `db01`, allow SSH only from devbox and drop all other inbound traffic. |

## Notes

- Reach the servers with `ssh bob@app01` and `ssh bob@db01` (password
  `caleston123`), then use `sudo iptables …`. app01 also listens on 8080,
  which must end up blocked.
- You're configuring the firewall **over SSH**. Add your SSH rule before
  setting a DROP policy — or you'll lock yourself out (if you do,
  `bin/course shell iptables --service app01` from your host gets you back in).
- The grader probes each port from each machine with `nc`, so it tests what
  really gets through.
- Rules don't need to survive a container restart for this lab.
