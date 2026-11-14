---
id: 08-storage/07-project-status-meeting
title: "Project Status Meeting"
minutes: 5
objectives:
  - Review what has been built so far and what the demo depends on
prerequisites: [08-storage/06-lvm]
tryit: none
---

# Project Status Meeting

## Why this matters

Thursday, 16:00 — the last status meeting before the client demonstration.
Every layer Bob has worked on is now part of the system the client will see,
which means every layer is something that can break tomorrow.

## Concepts

Priya goes around the table, and Bob realises he can answer every question:

| Area | Status | Module |
|---|---|---|
| Shell and file layout | Bob's home and the project tree are organised | 01, 04 |
| Kernel, boot, targets | bob-vm boots to multi-user, monitoring module loads at boot | 02 |
| Packages | web server, tools and internal repo on Rocky; vendor tool on Ubuntu | 03 |
| Networking | DNS for `company.local`, routing to the backend, web01 fixed | 05 |
| Security | accounts rebuilt, permissions fixed, SSH keys, firewalls, nightly clean-up | 06 |
| Services | Mercury worker managed by systemd, restarts on failure | 07 |
| Storage | `/mnt/data` on its own disk, media on LVM, shared reports over NFS | 08 |

"One more thing," says Priya. "Tomorrow morning the demo environment is
rebuilt from scratch by the deployment pipeline. If anything goes wrong in
that rebuild, Bob, you're on call."

Marco grins. "Remember the ladder. And read the logs before you touch
anything."

## Try it

No commands this time. Instead, make sure you can say, without looking,
which command you'd use first for each symptom:

```text
"The site is down."                         -> ?
"The app can't reach the database by name."  -> ?
"The service didn't come back after reboot." -> ?
"Disk full."                                 -> ?
"Permission denied reading the config."      -> ?
```

(Suggested answers: `curl -v` from a client; `getent hosts`;
`systemctl is-enabled` + `journalctl -b -u`; `df -h` then `du -sh`;
`ls -l` + `id`.)

## Common mistakes

- **Changing things before observing them.** Look first; every change you
  make while confused adds a new problem.

## Recap

- Every module's skills are now part of one system.
- The finale tests them together, under time pressure.

## Next

Module 09: the client demonstration.
