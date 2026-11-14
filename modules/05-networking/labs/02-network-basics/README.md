# Lab: Route the client to the backend

DNS now gives the right address for the database, but connections to
`10.10.2.20` still go nowhere.

- **Runtime:** Docker — `client`, `router`, `db01`; you are `bob` on `client`
- **Estimated time:** 20 minutes
- **Start:** `make lab ID=network-basics` · **Check:** `make check ID=network-basics`

## Tasks

| ID | Task |
|---|---|
| t1 | Write the client's IPv4 address on `eth0`, in CIDR notation (`address/prefix`), into `/home/bob/client-ip.txt`. |
| t2 | The client has no route to the backend network `10.10.2.0/24`. Add one that sends this traffic through the machine called `router`. |
| t3 | Verify that `client` can now `ping` db01 at `10.10.2.20`. |
| t4 | db01 runs a service on TCP port 5432 that greets every connection with a one-line banner. Save that banner into `/home/bob/db-banner.txt`. |

## Notes

- The router's addresses are not given: find the one on *your* subnet
  (`getent hosts router` is a good start).
- `client` is allowed to change its own routes, but you need `sudo`.
- Routes added with `ip route` disappear when the container restarts — that's
  expected here. In the real world you'd persist them with netplan or
  NetworkManager.
