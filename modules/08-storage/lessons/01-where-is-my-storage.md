---
id: 08-storage/01-where-is-my-storage
title: "Where Is My Storage? From Disk to Directory"
minutes: 5
objectives:
  - Describe the layers between a raw disk and a usable directory
prerequisites: [02-linux-core-concepts/08-filesystem-hierarchy]
tryit: vm
---

# Where Is My Storage? From Disk to Directory

## Why this matters

A brand-new disk is just a long row of empty blocks. Before a program can
write `report.csv` to it, several layers have to be set up. Knowing the
layers tells you which tool to reach for — and which mistakes are
destructive.

## Concepts

```text
 /mnt/data/report.csv           <- files and directories (what users see)
        │
 mount point /mnt/data          <- where the filesystem appears in the tree
        │
 filesystem (ext4, xfs)         <- organises blocks into files     mkfs, mount
        │
 [optional] LVM logical volume  <- flexible "virtual partitions"   pvcreate, vgcreate, lvcreate
        │
 partition /dev/sdb1            <- a slice of a disk               fdisk, gdisk, parted
        │
 block device /dev/sdb          <- the whole disk                  lsblk
```

Each lesson in this module covers one layer, from the bottom up.
Destructive steps — creating partition tables, `mkfs`, `pvcreate` — erase
what's there, so the golden rule is: **identify the device twice, then
act**.

## Try it

On the course VM, list block devices and the practice disks:

```bash novmcheck
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
course-disk --list
```

```text
NAME                      SIZE TYPE FSTYPE      MOUNTPOINTS
sda                        64G disk
├─sda1                      1M part
├─sda2                      2G part ext4        /boot
└─sda3                     62G part LVM2_member
  └─ubuntu--vg-ubuntu--lv  31G lvm  ext4        /
sdb                         1G disk
sdc                         1G disk
sdd                         2G disk
disk-a /dev/sdb
disk-b /dev/sdc
disk-c /dev/sdd
```

How full are the mounted filesystems?

```bash
df -h -x tmpfs
```

```text
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   31G   30G  1.1G  97% /
/dev/sda2                          2.0G  182M  1.7G  10% /boot
```

## Common mistakes

- **Assuming `/dev/sdb` is the new disk.** Check size, emptiness (`lsblk -f`
  shows no FSTYPE) and serial (`lsblk -o NAME,SERIAL`) first.

## Recap

- Disk → partition → (LVM) → filesystem → mount point → files.
- Identify the device twice before any destructive command.

## Next

The bottom layer: partitions.
