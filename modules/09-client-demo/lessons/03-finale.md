---
id: 09-client-demo/03-finale
title: "Finale"
minutes: 5
objectives:
  - Reflect on the course and choose what to learn next
prerequisites: [09-client-demo/02-troubleshooting-playbook]
quiz: false
tryit: none
---

# Finale

## Why this matters

09:47. The last `course check` comes back green. `curl http://demo-web/`
answers:

```text
Caleston demo: Caleston Mercury is live!
```

At 10:03 the client's delegation sits down, Priya clicks through the demo,
and nobody in the room except Bob, Priya and Marco (who arrived at 09:58,
out of breath) knows how close it came. The client signs the following
week.

On Monday there's a card on Bob's desk. "Three weeks ago you'd never seen a
shell prompt," Priya wrote. "This morning you fixed eight faults in an
hour. Welcome to the team — properly this time."

## Concepts

What Bob — and you — can now do:

| Skill | Module |
|---|---|
| Move around, manage files, find help, configure Bash | 01 |
| Understand the kernel, hardware, boot, targets, file types and layout | 02 |
| Install and remove software on both distribution families | 03 |
| Archive, search, redirect and edit like a pro | 04 |
| Diagnose names, routes and ports | 05 |
| Manage accounts, permissions, SSH, firewalls and scheduled jobs | 06 |
| Run software as reliable services | 07 |
| Partition, format, mount, pool and share storage | 08 |
| Troubleshoot a whole stack methodically | 09 |

### Where to go next

- **Shell scripting** — turning the commands you know into reusable
  scripts: variables, conditions, loops, functions, exit codes.
- **Automation** — Ansible to apply the same configuration to many servers.
- **Containers** — Docker and Kubernetes; you've already seen what a
  container shares with its host and what it doesn't.
- **Certifications** — LFCS (Linux Foundation) and RHCSA (Red Hat) test
  exactly these skills, hands-on.
- **The finale again** — `SEED=random make lab ID=final-troubleshooting`
  gives you a different variation every time.

## Try it

Run the finale with another seed and time yourself:

```bash norun
SEED=random make lab ID=final-troubleshooting
```

## Common mistakes

- **Stopping here.** Linux skills fade without practice. Run a small server
  of your own — a home lab, a Raspberry Pi, a cheap VM — and break it on
  purpose.

## Recap

- You've covered the full set of everyday Linux administration skills.
- The troubleshooting loop works on any system, not just this one.
- Keep practising: scripting and automation are the natural next steps.

## Next

Thank you for following Bob's story. `make progress` shows how far you've
come.
