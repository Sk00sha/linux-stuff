---
id: 08-storage/03-file-systems
title: File Systems in Linux
minutes: 11
objectives:
  - Compare ext2, ext3, ext4 and XFS
  - Create a filesystem with mkfs and mount it
  - Read and write /etc/fstab using UUIDs
  - Check space with df and identify filesystems with blkid
prerequisites: [08-storage/02-disk-partitions]
tryit: vm
---

# File Systems in Linux

## Why this matters

`/mnt/data` must hold Mercury's application data and still be there after
a reboot. That takes three steps: create a filesystem, mount it, and record
the mount in `/etc/fstab` — by UUID, so it can't end up on the wrong disk.

## Concepts

### Filesystem types

| Type | Notes |
|---|---|
| ext2 | old, no journal; fast but slow to recover after a crash |
| ext3 | ext2 + a **journal** (crash recovery in seconds) |
| ext4 | the common Linux default: journal, extents, large files and volumes, can grow and shrink |
| XFS | default on RHEL/Rocky; excellent for large files and parallel I/O; can grow, **cannot shrink** |
| btrfs, ZFS | copy-on-write, snapshots, checksums — more features, more to learn |
| vfat / exFAT | USB sticks and the EFI system partition |

A **journal** records what the filesystem is about to change before doing
it, so after a power cut it replays or discards those changes instead of
scanning the whole disk.

### Creating and mounting

```bash
sudo mkfs.ext4 /dev/sdb1            # or: sudo mkfs -t ext4 /dev/sdb1 ; mkfs.xfs for XFS
sudo mkdir -p /mnt/data             # the mount point is an ordinary directory
sudo mount /dev/sdb1 /mnt/data      # attach the filesystem there
sudo umount /mnt/data               # detach (note: umount, not unmount)
```

`mkfs` **erases** whatever was on the partition. `mount` with no arguments,
`findmnt` and `lsblk -f` show what's mounted where.

### UUIDs and labels

Device names can change between boots (add a disk and `sdc` may become
`sdb`). Each filesystem gets a **UUID** when it's created; `blkid` and
`lsblk -f` show it. Mount by UUID and the right filesystem is always found.

### `/etc/fstab`

Each line describes a filesystem to mount at boot — six fields:

```text
# <device>                                 <mount point> <type> <options> <dump> <pass>
UUID=2c4b8e2c-5d1f-4b8e-9a51-6c1d2e3f4a5b  /mnt/data     ext4   defaults  0      2
```

| Field | Meaning |
|---|---|
| device | `UUID=…` (best), `LABEL=…`, or `/dev/…` |
| mount point | an existing directory |
| type | `ext4`, `xfs`, `nfs`, `swap`… |
| options | `defaults` (rw, auto…), plus e.g. `noatime`, `ro`, `nofail` (don't block boot if missing) |
| dump | legacy backup flag, `0` |
| pass | fsck order at boot: `1` for `/`, `2` for others, `0` to skip |

A broken fstab line can stop a server from booting, so always test:

```bash
sudo findmnt --verify          # syntax and sanity check
sudo umount /mnt/data && sudo mount -a   # mount everything in fstab that isn't mounted
```

On systemd systems run `sudo systemctl daemon-reload` after editing fstab
so its generated mount units are refreshed.

### How full is it? `df`

`df -h` shows size, used and available space per mounted filesystem;
`df -i` shows inode usage (a disk can be "full" of tiny files while
blocks remain). `du` (module 04) shows what is using the space.

## Try it

On the course VM, using a **scratch file** as a pretend disk so the
practice disks stay blank for the labs. `-F` lets mkfs work on a file.

```bash novmcheck
truncate -s 64M /tmp/scratch.img
mkfs.ext4 -q -F -L scratch /tmp/scratch.img
blkid /tmp/scratch.img
```

```text
/tmp/scratch.img: LABEL="scratch" UUID="5a0f3c1e-7d2b-4e6a-9c38-0b1d2e4f6a7c" BLOCK_SIZE="1024" TYPE="ext4"
```

Mount it through a loop device, use it, check space:

```bash novmcheck
sudo mkdir -p /mnt/scratch
sudo mount -o loop /tmp/scratch.img /mnt/scratch
findmnt /mnt/scratch
sudo cp /etc/services /mnt/scratch/
df -h /mnt/scratch
```

```text
TARGET       SOURCE     FSTYPE OPTIONS
/mnt/scratch /dev/loop0 ext4   rw,relatime
Filesystem      Size  Used Avail Use% Mounted on
/dev/loop0       55M   32K   51M   1% /mnt/scratch
```

Add it to a **test** fstab and verify it — `--tab-file` lets us check a file
without touching the real `/etc/fstab`:

```bash novmcheck
UUID=$(blkid -s UUID -o value /tmp/scratch.img)
echo "UUID=$UUID /mnt/scratch ext4 defaults,nofail 0 2" > /tmp/fstab.test
sudo findmnt --verify --tab-file /tmp/fstab.test
```

```text
Success, no errors or warnings detected
```

Clean up:

```bash novmcheck
sudo umount /mnt/scratch
rm /tmp/scratch.img /tmp/fstab.test
```

## Common mistakes

- **`mkfs` on the whole disk instead of the partition** (`/dev/sdb` vs
  `/dev/sdb1`) — or on the wrong disk entirely.
- **`/dev/sdb1` in fstab.** Use `UUID=`.
- **A typo in fstab and a reboot.** Run `findmnt --verify` and `mount -a`
  first; consider `nofail` for non-essential disks.
- **"target is busy" on umount** — a shell is `cd`'d into it or a process
  has files open (`lsof +D /mnt/data`).

## Recap

- ext4 (Ubuntu default) and XFS (Rocky default) are journaling filesystems;
  `mkfs.TYPE` creates them and erases what was there.
- `mount DEV DIR` / `umount DIR`; `findmnt`, `lsblk -f`, `blkid`, `df -h`.
- Persistent mounts go in `/etc/fstab`, by UUID; test with
  `findmnt --verify` and `mount -a`.

## Next

A short tour of storage you don't plug into the server: DAS, NAS and SAN.
