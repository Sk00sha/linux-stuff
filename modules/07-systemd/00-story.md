---
id: 07-systemd/00-story
title: "Story: Working overtime"
---

# Story: Working overtime

Tuesday of the final week. It's 19:40 and Bob is still at his desk, because
Project Mercury's reporting worker crashed again at 18:55 — and stayed
crashed until someone noticed at 19:30.

The worker is started by hand. Every time. Someone logs in, types
`nohup /usr/bin/project-mercury.sh &`, and logs out. When the server
reboots, nobody remembers. When the process dies, nobody notices. It runs
as root, because that's what the person who started it happened to be.

Marco pulls up a chair. "This is what systemd is for," he says. "You
describe the service once, in a small text file: what to run, as which user,
what it needs to start after, and what to do when it dies. systemd starts it
at boot, restarts it when it crashes, and keeps its logs in one place."

Priya's requirements arrive in the ticket a few minutes later:

- runs as a dedicated, unprivileged user `mercury`;
- starts automatically at boot, but only after the network and the
  database are up;
- if it crashes, it comes back by itself after ten seconds;
- logs go to the journal so anyone can read them with one command.

"Do this right," says Priya, "and nobody works overtime for this worker ever
again."

This module uses the course VM (a real systemd as PID 1). If you don't have
the VM, the labs fall back to a systemd container — on a Linux host only.
