---
id: 08-storage/00-story
title: "Story: Where is my storage?"
---

# Story: Where is my storage?

Wednesday, two days before the demo, 08:15. The monitoring dashboard is
red. bob-vm's root filesystem is 97 % full: Mercury's media uploads and
reports have been landing on the same disk as the operating system.

"Good news," says Marco, holding a coffee in each hand. "Infrastructure
attached three new disks to bob-vm overnight. Bad news: they're completely
blank. No partitions, no filesystems, not mounted anywhere. Linux can see
them, but nothing can use them yet."

Priya writes the plan on the whiteboard:

1. The first new disk gets a partition and a filesystem for application
   data, mounted at `/mnt/data` — and it must survive a reboot.
2. The other two disks become one flexible pool with LVM, so the media
   volume can grow without anyone repartitioning anything at 2 a.m.
3. The reports team wants a shared folder that several servers can mount
   over the network. That's what the NFS server is for.

"And please," she adds, "triple-check device names before you format
anything. `mkfs` on the wrong disk is how careers end."

This module runs only on the course VM, which has three blank practice
disks. The lab setup scripts refuse to run anywhere else, so your own
computer's disks are never touched. The helper `course-disk disk-a` (and
`disk-b`, `disk-c`) prints the device name of each practice disk on your
VM.
