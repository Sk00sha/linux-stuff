---
id: 02-linux-core-concepts/04-linux-boot-sequence
title: The Linux Boot Sequence
minutes: 11
objectives:
  - Name the four stages of booting a Linux machine
  - Explain what GRUB2, the kernel, the initramfs and systemd each do
  - Inspect how the current system booted
prerequisites: [02-linux-core-concepts/03-working-with-hardware]
tryit: vm
---

# The Linux Boot Sequence

## Why this matters

When a server doesn't come back after a reboot, the first question is
*where* in the boot it stopped. Knowing the stages lets you read the clues on
the console — and Bob's task of changing how bob-vm boots depends on the
last stage, systemd.

## Concepts

Booting happens in four stages:

```text
[1] Firmware        [2] Boot loader      [3] Kernel            [4] init (PID 1)
 BIOS or UEFI   ->   GRUB2           ->   vmlinuz +        ->   systemd
 POST, find          menu, load           initramfs             mounts filesystems,
 boot device         kernel & initrd      drivers, mount /      starts services,
                                                                reaches a target
```

### 1. Firmware: BIOS or UEFI

When power comes on, the firmware runs the **POST** (power-on self test) to
check CPU, memory and devices, then looks for something bootable in the
configured order.

- Legacy **BIOS** reads the first sector of the disk (the MBR) and runs the
  tiny boot code there.
- Modern **UEFI** firmware reads a FAT-formatted **EFI System Partition**
  (usually mounted at `/boot/efi`) and runs a boot loader file from it, such
  as `shimx64.efi` or `grubx64.efi`. UEFI also supports **Secure Boot**.

You can tell which you have: `/sys/firmware/efi` exists only on UEFI boots.

### 2. Boot loader: GRUB2

**GRUB2** (the GRand Unified Bootloader, version 2) shows the boot menu,
lets you pick a kernel (useful when a new one misbehaves) and loads two files
into memory:

- the **kernel** image, `/boot/vmlinuz-<version>`;
- the **initramfs** (initial RAM filesystem), `/boot/initrd.img-<version>`
  on Ubuntu or `/boot/initramfs-<version>.img` on Rocky.

GRUB's configuration is generated, not hand-edited: you change
`/etc/default/grub` and run `sudo update-grub` (Ubuntu) or
`sudo grub2-mkconfig -o /boot/grub2/grub.cfg` (Rocky).

### 3. Kernel and initramfs

The kernel decompresses itself, initialises the CPU and memory, and starts
detecting hardware. It may not yet have the drivers needed to read the root
filesystem (for example LVM, RAID or an unusual disk controller). The
initramfs is a small temporary root filesystem containing exactly those
drivers and tools. It prepares the real root filesystem, mounts it, then
hands over control. The options the kernel was started with are in
`/proc/cmdline`.

### 4. init: systemd as PID 1

The kernel starts the first user-space process, `/sbin/init`, which on
nearly every modern distribution is **systemd**. It has PID 1 and is the
ancestor of every other process. systemd mounts the remaining filesystems
(from `/etc/fstab`), starts services in parallel according to their
dependencies, and works towards a **target** — a named system state such as
`multi-user.target` (text mode, networking, services) or
`graphical.target` (the same plus a desktop). Targets are the next lesson.

Older systems used **SysV init** (`/etc/init.d` scripts run one by one) or
Upstart; you will still see `/etc/init.d` and the word "runlevel" in
documentation.

## Try it

Run on the course VM.

Which firmware type booted this machine, and with which kernel options?

```bash
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
cat /proc/cmdline
```

```text
BIOS
BOOT_IMAGE=/vmlinuz-6.8.0-45-generic root=/dev/mapper/ubuntu--vg-ubuntu--lv ro
```

The kernel and initramfs files GRUB loads:

```bash novmcheck
ls -l /boot | grep -E 'vmlinuz|initrd'
```

```text
lrwxrwxrwx 1 root root       28 Nov 14 09:01 initrd.img -> initrd.img-6.8.0-45-generic
-rw-r--r-- 1 root root 69437103 Nov 14 09:01 initrd.img-6.8.0-45-generic
lrwxrwxrwx 1 root root       25 Nov 14 09:01 vmlinuz -> vmlinuz-6.8.0-45-generic
-rw------- 1 root root 14928264 Aug 30 12:30 vmlinuz-6.8.0-45-generic
```

PID 1, and how long each stage of the last boot took:

```bash novmcheck
ps -p 1 -o comm=
systemd-analyze
systemd-analyze blame | head -3
```

```text
systemd
Startup finished in 3.102s (kernel) + 9.844s (userspace) = 12.946s
graphical.target reached after 9.711s in userspace.
5.204s cloud-init.service
1.122s snapd.seeded.service
 812ms dev-mapper-ubuntu\x2d\x2dvg\x2dubuntu\x2d\x2dlv.device
```

Kernel messages from the current boot are kept in the journal:

```bash novmcheck
journalctl -k -b --no-pager | head -2
```

```text
Nov 14 09:11:58 bob-vm kernel: Linux version 6.8.0-45-generic (buildd@lcy02-amd64-075) ...
Nov 14 09:11:58 bob-vm kernel: Command line: BOOT_IMAGE=/vmlinuz-6.8.0-45-generic root=...
```

## Common mistakes

- **Editing `/boot/grub/grub.cfg` directly.** It is regenerated on the next
  kernel update; edit `/etc/default/grub` and regenerate.
- **Deleting "old" kernels from `/boot` by hand.** Remove them with the
  package manager so GRUB's menu stays consistent — and keep at least one
  known-good kernel.
- **Confusing initramfs problems with disk failure.** "Unable to mount root
  fs" right after a kernel update often means the initramfs lacks a driver,
  not that the disk is broken. Boot the previous kernel from the GRUB menu.

## Recap

- Firmware (BIOS/UEFI) → boot loader (GRUB2) → kernel + initramfs → init
  (systemd, PID 1).
- GRUB loads `vmlinuz` and the initramfs; the initramfs mounts the real root
  filesystem.
- systemd starts services and brings the system to a target.

## Next

Targets — and their ancestors, runlevels — decide what state the system
boots into.
