---
id: 09-client-demo/01-client-demo-in-jeopardy
title: "Client Demonstration in Jeopardy"
minutes: 5
objectives:
  - Understand the demo environment's architecture before troubleshooting it
prerequisites: [08-storage/07-project-status-meeting]
quiz: false
tryit: none
---

# Client Demonstration in Jeopardy

## Why this matters

You can't fix a system you can't picture. Two minutes spent drawing the
demo environment saves twenty minutes of random poking.

## Concepts

```text
 browser / curl
      │ HTTP :80
      ▼
 ┌─────────────── demo-web (10.10.9.10) ───────────────┐
 │ systemd ── mercury-web.service (User=mercury)       │
 │            /usr/local/bin/mercury-web (Python)      │
 │              reads   /etc/mercury/app.conf          │
 │              writes  /var/lib/mercury/ (heartbeat)  │
 │              logs    journal + /var/log/mercury/    │
 │              needs   python3-psycopg (DB driver)    │
 │ cron ── /etc/cron.d/mercury-logrotate (nightly)     │
 │ /etc/hosts: db01.caleston.local -> 10.10.9.20       │
 │ iptables (OUTPUT)                                   │
 └───────────────────────┬─────────────────────────────┘
                         │ PostgreSQL :5432
                         ▼
 ┌──────────── demo-db (10.10.9.20) ────────────┐
 │ PostgreSQL, database "mercury"                │
 │ table greetings: "Caleston Mercury is live!"  │
 └───────────────────────────────────────────────┘
```

A healthy request: `curl http://demo-web/` → mercury-web writes a heartbeat
file, connects to `db01.caleston.local:5432`, reads the greeting and answers
`Caleston demo: Caleston Mercury is live!`.

The database is fine — the DBA checked. Everything that's broken is on
**demo-web**.

## Try it

From your host, start the finale and open a shell on demo-web:

```bash norun
make lab ID=final-troubleshooting           # SEED=1 by default
SEED=2 make lab ID=final-troubleshooting    # a different variation
SEED=random make lab ID=final-troubleshooting
```

## Common mistakes

- **Fixing the first thing you see and declaring victory.** There are
  several faults; keep testing end to end.

## Recap

- One web server, one database; all faults are on demo-web.
- Request path: service → config → disk → name → network → database.
- Several faults at once: keep testing end to end after every fix.

## Next

A troubleshooting playbook for the next hour.
