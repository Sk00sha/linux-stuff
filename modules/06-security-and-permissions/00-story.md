---
id: 06-security-and-permissions/00-story
title: "Story: Security incident"
---

# Story: Security incident

Friday, week two, 07:40. Bob's phone buzzes with a message from Priya:
"Don't log in to devbox. Meeting room 3, now."

The security team found a shell session on the development box that nobody
can account for. An account called `intruder` — created three weeks ago,
with a password, and a home directory full of scripts. The access logs show
it logged in with SSH from outside the office. On the same machine, project
files were world-writable, the shared directory let anyone delete anyone
else's files, and the firewall on the application server allowed
connections from everywhere to everything.

"Nobody's getting fired," says Priya, looking pointedly at no one. "But
this is a dev box that sits next to the servers we're demoing to a client in
a week. We're going to lock it down properly, and Bob's going to help,
because he'll learn more this week than in a year of reading."

Marco writes the plan:

1. Accounts: who exists, who can become root, and lock the intruder out.
2. Permissions: fix ownership and modes on the project tree.
3. SSH: keys instead of passwords for the team; copy the code safely.
4. Firewall: the app server and the database only accept what they need.
5. Housekeeping: a nightly clean-up job, scheduled properly.

This module covers Linux accounts and groups, the files that control access,
user management, file permissions, SSH and SCP, the iptables firewall and
cron. The labs run on three containers on the backend network: `devbox`,
`app01` and `db01`.
