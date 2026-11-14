---
id: 08-storage/02-disk-partitions
title: Disk Partitions
minutes: 10
objectives:
  - Explain block devices and partitions
  - Compare MBR and GPT partition tables
  - List partitions with lsblk and fdisk -l
  - Create a partition with gdisk (and know the parted equivalent)
prerequisites: [08-storage/01-where-is-my-storage]
tryit: vm
---

# Disk Partitions

## Why this matters

The first new disk must be sliced before it can hold a filesystem. Even when
a disk will hold only one filesystem, creating a partition table makes its
purpose obvious to every tool and every colleague who looks at it later.

## Concepts

### Block devices

Disks appear under `/dev` as **block devices** (file type `b`, module 02):

| Name | Typical device |
|---|---|
| `/dev/sda`, `/dev/sdb` | SATA/SAS/SCSI/USB disks (also VirtualBox disks) |
| `/dev/vda`, `/dev/vdb` | virtio disks in KVM/QEMU VMs |
| `/dev/nvme0n1` | NVMe SSDs (partitions: `nvme0n1p1`) |
| `/dev/loop0` | a file used as a disk |

Partitions get a number: `/dev/sdb1`, `/dev/vdb2`, `/dev/nvme0n1p1`. The
kernel lists all of them in `/proc/partitions`.

### Partition tables: MBR vs GPT

The **partition table** at the start of the disk records where each
partition begins and ends.

| | MBR (msdos, "DOS") | GPT (GUID Partition Table) |
|---|---|---|
| Age | 1983 | part of UEFI, 2000s |
| Max disk size | 2 TiB | 8 ZiB (effectively unlimited) |
| Partitions | 4 primary (or 3 + extended with logical partitions inside) | 128 by default |
| Redundancy | single copy | backup table at the end of the disk, CRC checks |
| Boot | BIOS | UEFI (BIOS too, with a small "BIOS boot" partition) |

Use **GPT** for new disks unless something old forces MBR. GPT partitions
also have a **type code** (`8300` Linux filesystem, `8e00` Linux LVM, `ef00`
EFI system, `8200` swap) and an optional name.

### Tools

| Tool | Notes |
|---|---|
| `lsblk` | tree of disks and partitions; `-f` adds filesystems, `-o NAME,SIZE,SERIAL` picks columns |
| `sudo fdisk -l [DISK]` | list partition tables; `fdisk DISK` edits (MBR and GPT) interactively |
| `sudo gdisk DISK` | interactive GPT editor; `sgdisk` is its scriptable twin |
| `sudo parted DISK` | edits both, scriptable: `parted -s DISK mklabel gpt mkpart data ext4 1MiB 501MiB` |

Interactive editors only change the disk when you **write** (`w`); until
then you can quit (`q`) safely. After writing, the kernel normally re-reads
the table; if a partition doesn't show up, run `sudo partprobe DISK`.

### A gdisk session

Creating one 500 MiB partition on a blank disk:

```text
$ sudo gdisk /dev/sdb
Command (? for help): o            <- new empty GPT (asks to confirm: Y)
Command (? for help): n            <- new partition
Partition number (1-128, default 1): <Enter>
First sector (...default = 2048) or {+-}size{KMGTP}: <Enter>
Last sector (...) or {+-}size{KMGTP}: +500M
Hex code or GUID (L to show codes, Enter = 8300): <Enter>
Command (? for help): p            <- print to check
Command (? for help): w            <- write and exit (confirm: Y)
```

The first partition starts at sector 2048 (1 MiB) so it is **aligned** to
the physical blocks of modern disks; all tools do this by default.

## Try it

On the course VM. Look before you touch:

```bash novmcheck
DISK=$(course-disk disk-a)
echo "$DISK"
lsblk -o NAME,SIZE,TYPE,SERIAL,FSTYPE "$DISK"
sudo fdisk -l "$DISK" | head -3
```

```text
/dev/sdb
NAME SIZE TYPE SERIAL FSTYPE
sdb    1G disk disk-a
Disk /dev/sdb: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
```

The scriptable equivalent of the gdisk session above, on the **second**
practice disk (the lab uses the first). `sgdisk -p` prints the result:

```bash novmcheck
DISK=$(course-disk disk-b)
sudo sgdisk --zap-all "$DISK" >/dev/null
sudo sgdisk -n 1:0:+500M -t 1:8300 -c 1:demo "$DISK"
sudo sgdisk -p "$DISK" | tail -3
lsblk -o NAME,SIZE,TYPE,PARTLABEL "$DISK"
```

```text
The operation has completed successfully.
Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         1026047   500.0 MiB   8300  demo
NAME   SIZE TYPE PARTLABEL
sdc      1G disk
└─sdc1 500M part demo
```

Wipe it again so disk-b is blank for the LVM lab:

```bash novmcheck
sudo sgdisk --zap-all "$(course-disk disk-b)" >/dev/null
lsblk "$(course-disk disk-b)"
```

```text
NAME SIZE RO TYPE MOUNTPOINTS
sdc    1G  0 disk
```

## Common mistakes

- **Partitioning the wrong disk.** Always confirm with `lsblk` (size, serial,
  no existing partitions) first. On the VM, use `course-disk`.
- **Repartitioning a disk that's in use** — unmount its filesystems first.
- **Expecting MBR to handle a 4 TB disk** — use GPT.
- **Forgetting `w`** in fdisk/gdisk: nothing was written.

## Recap

- Disks are block devices (`sdX`, `vdX`, `nvmeXnY`); partitions add a number.
- GPT beats MBR for new disks: big disks, 128 partitions, backup table.
- `lsblk`, `fdisk -l` to look; `gdisk`/`fdisk` interactively or
  `sgdisk`/`parted -s` in scripts to change.

## Next

A partition still can't store files. It needs a filesystem.
