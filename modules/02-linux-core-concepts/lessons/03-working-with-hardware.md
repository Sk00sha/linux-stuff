---
id: 02-linux-core-concepts/03-working-with-hardware
title: Working with Hardware
minutes: 15
objectives:
  - Read kernel messages with dmesg
  - Inspect CPUs, memory, disks and PCI devices
  - Explain the roles of udev, /proc and /sys
prerequisites: [02-linux-core-concepts/02-linux-kernel]
tryit: vm
---

# Working with Hardware

## Why this matters

When Priya asks "how much RAM does bob-vm have, and which disks are
attached?", Bob shouldn't have to open a hypervisor console. Linux exposes
everything it knows about the hardware through commands and through two
virtual filesystems, `/proc` and `/sys`.

## Concepts

### How Linux discovers hardware

At boot (and whenever a device is plugged in), the kernel detects the
device, loads a driver for it and announces it in the **kernel ring buffer**.
Then the kernel sends an event ("uevent") to user space, where **udev**
(`systemd-udevd`) creates the device file under `/dev`, applies naming rules
and creates helpful symlinks such as `/dev/disk/by-id/…`.

```text
device appears -> kernel driver -> ring buffer message (dmesg)
                                -> uevent -> udev -> /dev/sdb, /dev/disk/by-id/...
```

### Kernel messages: `dmesg`

`dmesg` prints the ring buffer. Useful options: `-H` (human-friendly, with a
pager), `-T` (wall-clock timestamps), `-w` (follow new messages),
`--level=err,warn`. On many systems reading it requires `sudo`. The same
messages are also in the journal: `journalctl -k`.

### udev tools

- `udevadm info /dev/sda` — everything udev knows about a device (serial
  number, model, symlinks).
- `udevadm monitor` — watch events live; plug in a USB stick and see them.

### The "ls" family

| Command | Shows |
|---|---|
| `lscpu` | CPU model, cores, threads, virtualisation flags |
| `lsmem` / `free -m` | memory blocks / used and free RAM and swap in MiB |
| `lsblk` | block devices (disks, partitions, LVM) as a tree, with sizes and mount points |
| `lspci` | devices on the PCI bus (network cards, disk controllers, GPUs); `-k` shows drivers |
| `lsusb` | USB devices |
| `sudo lshw -short` | a summary of all hardware |

### `/proc` and `/sys`

Neither directory exists on disk — the kernel generates their contents on
the fly when you read them.

- `/proc` holds a directory per process (`/proc/1`, `/proc/1843`…) plus
  system-wide files: `/proc/cpuinfo`, `/proc/meminfo`, `/proc/partitions`,
  `/proc/modules`, `/proc/cmdline` (the options the kernel booted with).
- `/sys` (sysfs) is a structured view of devices, drivers and kernel
  settings: `/sys/class/net/` lists network interfaces,
  `/sys/block/` lists block devices.

## Try it

Run on the course VM. The numbers depend on your VM settings.

```bash
lscpu | grep -E '^(Architecture|CPU\(s\)|Model name)'
free -m
```

```text
Architecture:                         x86_64
CPU(s):                               2
Model name:                           Intel(R) Core(TM) i7-10710U CPU @ 1.10GHz
               total        used        free      shared  buff/cache   available
Mem:            1967         412        1201           1         510        1555
Swap:           2047           0        2047
```

Block devices — notice the three blank practice disks next to the system
disk:

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
```

```text
NAME                      SIZE TYPE MOUNTPOINTS
sda                        64G disk
├─sda1                      1M part
├─sda2                      2G part /boot
└─sda3                     62G part
  └─ubuntu--vg-ubuntu--lv  31G lvm  /
sdb                         1G disk
sdc                         1G disk
sdd                         2G disk
```

Kernel messages about disks, and udev's view of a disk:

```bash novmcheck
sudo dmesg -T | grep -i 'sd[b-d]' | head -3
udevadm info --query=symlink --name="$(course-disk disk-a)"
```

```text
[Thu Nov 14 09:12:03 2026] sd 1:0:0:0: [sdb] 2097152 512-byte logical blocks: (1.07 GB/1.00 GiB)
[Thu Nov 14 09:12:03 2026] sd 1:0:0:0: [sdb] Attached SCSI disk
[Thu Nov 14 09:12:03 2026] sd 2:0:0:0: [sdc] 2097152 512-byte logical blocks: (1.07 GB/1.00 GiB)
disk/by-id/ata-VBOX_HARDDISK_disk-a disk/by-path/pci-0000:00:0d.0-ata-2
```

Peek at the virtual filesystems:

```bash
grep MemTotal /proc/meminfo
cat /proc/cmdline
ls /sys/class/net
```

```text
MemTotal:        2014472 kB
BOOT_IMAGE=/vmlinuz-6.8.0-45-generic root=/dev/mapper/ubuntu--vg-ubuntu--lv ro
eth0  eth1  lo
```

## Common mistakes

- **"dmesg: read kernel buffer failed: Operation not permitted".** Use
  `sudo dmesg`; many distributions restrict it to root.
- **Trusting `/dev/sdb` names forever.** Disk names depend on detection
  order and can change between boots. Use `/dev/disk/by-id/` or UUIDs (module
  08) when it matters.
- **Editing files in `/proc` or `/sys` "to see what happens".** Some of them
  change kernel behaviour immediately.

## Recap

- The kernel detects devices and logs them (`dmesg`); udev creates the
  `/dev` entries and stable symlinks.
- `lscpu`, `free -m`, `lsblk`, `lspci`, `lsusb` and `lshw` summarise the
  hardware.
- `/proc` and `/sys` are generated by the kernel and expose processes,
  devices and settings as files.

## Next

How does a machine go from power button to login prompt? The boot sequence.
