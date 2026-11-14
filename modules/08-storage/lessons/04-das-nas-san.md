---
id: 08-storage/04-das-nas-san
title: DAS, NAS and SAN
minutes: 10
objectives:
  - Distinguish direct-attached, network-attached and storage-area-network storage
  - Explain block storage versus file storage
prerequisites: [08-storage/03-file-systems]
tryit: none
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

### In the cloud

Clouds use the same ideas under other names: **block volumes** (AWS EBS,
Azure Managed Disks, GCP Persistent Disk) are SAN-like; **file shares** (EFS,
Azure Files, Filestore) are NAS; **object storage** (S3 and friends) is a
third model, accessed over HTTP rather than mounted.

## Try it

Nothing to run — just look at a VM's storage through this lens:

```bash norun
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL
findmnt -t nfs,nfs4,cifs
```

`TRAN` (transport) shows `sata`, `nvme`, `usb` or `iscsi`; the second
command lists any file-storage mounts.

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
