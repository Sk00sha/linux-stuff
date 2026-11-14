# Finale: save the client demonstration

> 08:52. The client arrives at 10:00. `curl http://demo-web/` says
> *Connection refused*. The deployment pipeline says SUCCESS.

- **Runtime:** Docker — `demo-web` (systemd, Linux hosts) and `demo-db` (PostgreSQL)
- You start as `bob` on `demo-web`, with `sudo`
- **Estimated time:** 60 minutes
- **Start:** `make lab ID=final-troubleshooting` (or `SEED=2 …`, `SEED=random …`)
- **Check:** `make check ID=final-troubleshooting`

## What you know

- The site should answer `Caleston demo: Caleston Mercury is live!` at
  `http://demo-web/` (from demo-web itself: `curl http://localhost/`).
- The service is called `mercury-web`. Its configuration lives in
  `/etc/mercury/`, its data in `/var/lib/mercury/`, its logs in the journal
  and `/var/log/mercury/`.
- The database `demo-db` is healthy — the DBA checked. **Everything broken
  is on demo-web.**
- Last night's rebuild broke **several** things. The check reports a health
  line per area, so you can see your progress — but it won't tell you what
  to type.

## Rules of engagement

- Fix causes, not symptoms: no `chmod 777`, no flushing every firewall rule,
  no running the app as root.
- The variation of each fault depends on `SEED`. `SEED=1` and `SEED=2` are
  different; the same seed always gives the same faults.
- Stuck? `make hint ID=final-troubleshooting TASK=t2` (tasks t1–t9).
