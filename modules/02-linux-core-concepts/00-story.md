---
id: 02-linux-core-concepts/00-story
title: "Story: The servers Bob inherits"
---

# Story: The servers Bob inherits

Bob's tidy home directory earned him a thumbs-up emoji from Priya, which at
Caleston counts as high praise. On Wednesday he is invited to his first
platform team meeting.

The meeting room whiteboard shows a diagram of the Mercury environment: a
web tier, an application server, a database, and an arrow labelled
"client demo — 3 weeks". Priya points at a box labelled **bob-vm**.

"This one's yours now," she says. "It was built by someone who left last
year. Before you change anything, I'd like you to understand what's running
on it — which kernel, what hardware it thinks it has, how it boots, and
where things live on disk."

Marco adds a warning from experience: "Last time someone 'cleaned up' a
server they didn't understand, they deleted half of `/var` and the database
went with it."

The action items on the whiteboard are written next to Bob's name:

1. Record the kernel version for the asset inventory.
2. Load the `dummy` network driver the monitoring team needs, and make sure
   it comes back after a reboot.
3. Make the server boot into a text-only, multi-user mode — no graphical
   desktop on a server.
4. Leave a convenient shortcut to the system log in his home directory.
5. Figure out what kind of file each of a handful of strange entries really
   is.

This module needs a real kernel, so it runs on the course **virtual
machine** rather than in a container. If you haven't yet, run `make vm-up`
(see the README) — it takes a few minutes the first time.
