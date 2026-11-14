---
id: 08-storage/04-das-nas-san
title: DAS, NAS and SAN
minutes: 9
objectives:
  - Distinguish direct-attached, network-attached and storage-area-network storage
  - Explain block storage versus file storage
prerequisites: [08-storage/03-file-systems]
tryit: vm
---

# DAS, NAS and SAN

## Why this matters

The reports team asked for "a shared drive". Before choosing NFS, Bob should
know the three ways servers get storage, because each one answers a
different question: speed, sharing, or flexibility.

## Concepts

### Block storage vs file storage

- **Block storage** gives the server raw blocks — something that looks like
  a disk. The server creates the partitions and filesystem and is the only
  one that can safely mount it read-write.
- **File storage** gives the server files and directories over the network.
  The storage system owns the filesystem; many clients can use it at once.

### The three architectures

| | DAS — Direct-Attached Storage | NAS — Network-Attached Storage | SAN — Storage Area Network |
|---|---|---|---|
| What | disks inside or cabled directly to one server | a file server on the LAN | a dedicated network delivering block devices |
| Gives you | blocks | **files** | **blocks** |
| Protocols | SATA, SAS, NVMe, USB | **NFS** (Linux/Unix), SMB/CIFS (Windows) | Fibre Channel, iSCSI, NVMe-oF |
| Shared by | one host | many hosts | one host per volume (unless a cluster filesystem) |
| Looks like on Linux | `/dev/sdb` | `nfs-server:/srv/share` mounted on a directory | `/dev/sdc` (just another disk) |
| Strengths | simple, fast, cheap | easy sharing, central backups | performance, central management, live migration |
| Weaknesses | not shareable; dies with the server | network-bound performance, locking subtleties | cost and complexity |

The new disks on bob-vm behave like DAS (they're virtual disks attached to
one VM). The NFS lab builds a tiny NAS. A SAN volume would appear on the
server as another block device and be handled exactly like the disks in the
partitions and LVM labs.

### Redundancy is a separate question

None of these architectures protect data on their own. Disks fail, so
storage is usually combined with **RAID** (several disks acting as one, with
mirroring or parity: RAID 1, 5, 6, 10), either in hardware, in the storage
array, or in Linux itself with `mdadm`. And RAID is not a backup: deleting a
file deletes it on every mirror at once. Backups — copies kept elsewhere,
ideally offline or immutable — are a separate layer again.

### Questions to ask before choosing

1. Does more than one server need the same data at the same time? → NAS.
2. Does a database need low-latency block storage? → DAS or SAN.
3. Must a volume move between servers or survive one server failing? → SAN
   (or cloud block volumes).
4. Who manages it — the server's admin, or a storage team?

### In the cloud

Clouds use the same ideas under other names: **block volumes** (AWS EBS,
Azure Managed Disks, GCP Persistent Disk) are SAN-like; **file shares** (EFS,
Azure Files, Filestore) are NAS; **object storage** (S3 and friends) is a
third model, accessed over HTTP rather than mounted.

## Try it

Look at the course VM's storage through this lens. Which disks are local
(DAS), and how are they attached? (`TRAN` shows `sata`, `nvme`, `usb`,
`iscsi`… and is empty for virtual disks on some hypervisors.)

```bash
lsblk -d -o NAME,SIZE,TYPE,TRAN,MODEL
```

```text
NAME  SIZE TYPE TRAN MODEL
sda    64G disk sata VBOX HARDDISK
sdb     1G disk sata VBOX HARDDISK
sdc     1G disk sata VBOX HARDDISK
sdd     2G disk sata VBOX HARDDISK
```

Is any file storage (NAS) mounted?

```bash
findmnt -t nfs,nfs4,cifs || echo "no network filesystems mounted"
```

```text
no network filesystems mounted
```

Every block device the kernel knows about, local or SAN, appears in the same
list:

```bash
cat /proc/partitions
```

```text
major minor  #blocks  name

   8        0   67108864 sda
   8        1       1024 sda1
   8        2    2097152 sda2
   8        3   65006592 sda3
   8       16    1048576 sdb
   8       32    1048576 sdc
   8       48    2097152 sdd
```

## Common mistakes

- **Mounting the same SAN/block volume read-write on two servers** with an
  ordinary filesystem like ext4 — both will corrupt it. Sharing needs NAS or
  a cluster filesystem.
- **Treating a NAS like a local disk** for latency-sensitive databases.

## Recap

- Block storage (DAS, SAN) gives a disk; file storage (NAS) gives a shared
  directory.
- NAS on Linux usually means NFS; SAN volumes look like local disks.
- Choose by need: speed (DAS), sharing (NAS), central flexible blocks (SAN).

## Next

Building a small NAS with NFS.
