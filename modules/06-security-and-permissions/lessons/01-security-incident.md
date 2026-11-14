---
id: 06-security-and-permissions/01-security-incident
title: "Security Incident: Layers of Defence"
minutes: 5
objectives:
  - Describe the layers of Linux security covered in this module
prerequisites: [05-networking/04-troubleshooting]
tryit: none
---

# Security Incident: Layers of Defence

## Why this matters

No single setting makes a server secure. The incident on devbox succeeded
because several small weaknesses lined up. Security on Linux is built from
layers, each limiting the damage if another fails.

## Concepts

| Layer | Question it answers | Lessons |
|---|---|---|
| Accounts | Who can log in at all? Who can become root? | Linux Accounts, Access Control Files, User Management |
| Permissions | Once logged in, what can each user read, write, run? | File Permissions and Ownership |
| Authentication | How do users prove who they are remotely? | SSH and SCP |
| Network | Which machines can even connect to which ports? | IPTABLES Introduction, Securing the Environment |
| Operations | Are routine tasks (clean-ups, rotations) automated and auditable? | Cronjobs |

The guiding principle across all of them is **least privilege**: every
user, process and machine gets exactly the access it needs, and nothing
more. The intruder account didn't need to exist; the files didn't need to be
world-writable; the database didn't need to accept connections from the
whole network.

## Try it

From your host, start the first lab of this module to see the lab machines:

```bash norun
bin/course start account-management
```

On devbox, have a first look at who is around:

```bash norun
who
tail -5 /etc/passwd
```

## Common mistakes

- **Fixing only the symptom.** Deleting the intruder's scripts without
  locking the account, or locking the account without closing the network
  path, leaves the door open.

## Recap

- Security comes in layers: accounts, permissions, authentication, network,
  operations.
- Apply least privilege at every layer.

## Next

Start at the top: what is a Linux account?
