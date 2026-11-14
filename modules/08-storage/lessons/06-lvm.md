---
id: 08-storage/06-lvm
title: LVM — Logical Volume Manager
minutes: 11
objectives:
  - Explain physical volumes, volume groups and logical volumes
  - Build a volume group from several disks and carve logical volumes
  - Grow a logical volume and its filesystem online
  - Inspect LVM with pvs, vgs and lvs
prerequisites: [08-storage/03-file-systems]
tryit: vm
---

# LVM — Logical Volume Manager

## Why this matters

Media uploads will keep growing. With plain partitions, growing means
downtime and careful repartitioning. With **LVM**, Bob pools the two new
disks and can grow the media volume with one command, while it is mounted
and in use.

## Concepts

### Three layers

```text
  LV  /dev/caleston_vg/data (1G)    LV  /dev/caleston_vg/backup (...)     <- like partitions; get filesystems
   └───────────────┬─────────────────────┘
  VG  caleston_vg  (3G pool, split into 4 MiB "extents")                  <- a pool of space
   ┌───────────────┴───────────────┐
  PV  /dev/sdc (1G)              PV  /dev/sdd (2G)                        <- disks or partitions given to LVM
```

- **Physical volume (PV)** — a disk or partition initialised for LVM
  (`pvcreate`).
- **Volume group (VG)** — a pool made of one or more PVs (`vgcreate`).
  Its space is counted in **extents** (4 MiB by default).
- **Logical volume (LV)** — a block device carved out of a VG (`lvcreate`).
  You put a filesystem on it and mount it like a partition. An LV can span
  several PVs and can grow as long as the VG has free extents; add a disk to
  the VG (`vgextend`) to get more.

LVs appear as `/dev/VG/LV` and `/dev/mapper/VG-LV` (the same device).

### Commands

| Step | Command |
|---|---|
| initialise disks | `sudo pvcreate /dev/sdc /dev/sdd` |
| create the pool | `sudo vgcreate caleston_vg /dev/sdc /dev/sdd` |
| create a volume | `sudo lvcreate -L 1G -n data caleston_vg` (or `-l 100%FREE`) |
| filesystem + mount | `sudo mkfs.ext4 /dev/caleston_vg/data` … `mount` as usual |
| grow volume **and** filesystem | `sudo lvextend -L +500M -r /dev/caleston_vg/data` |
| add a disk to the pool | `sudo pvcreate /dev/sde && sudo vgextend caleston_vg /dev/sde` |
| summaries | `pvs`, `vgs`, `lvs` (detailed: `pvdisplay`, `vgdisplay`, `lvdisplay`) |
| remove | `lvremove`, `vgremove`, `pvremove` (in that order) |

`-r` (`--resizefs`) is the key option when growing: it resizes the
filesystem inside the LV in the same step (calling `resize2fs` for ext4 or
`xfs_growfs` for XFS), while mounted. Without it the LV is bigger but the
filesystem — and `df` — still shows the old size. `lvresize` can both grow
and shrink; shrinking ext4 must be done unmounted and XFS can't shrink at
all.

## Try it

On the course VM. This demo uses two small **loop devices** (files acting as
disks), so the practice disks stay blank for the lab.

```bash novmcheck
truncate -s 300M /tmp/pv1.img /tmp/pv2.img
L1=$(sudo losetup -f --show /tmp/pv1.img); L2=$(sudo losetup -f --show /tmp/pv2.img)
sudo pvcreate -q "$L1" "$L2"
sudo vgcreate -q demo_vg "$L1" "$L2"
sudo vgs demo_vg
```

```text
  VG      #PV #LV #SN Attr   VSize   VFree
  demo_vg   2   0   0 wz--n- 592.00m 592.00m
```

A 400 MiB LV must span both 300 MiB PVs:

```bash novmcheck
sudo lvcreate -q -L 400M -n demo demo_vg
sudo lvs -o lv_name,lv_size,devices demo_vg
sudo mkfs.ext4 -q /dev/demo_vg/demo
sudo mkdir -p /mnt/demo && sudo mount /dev/demo_vg/demo /mnt/demo
df -h /mnt/demo
```

```text
  LV   LSize   Devices
  demo 400.00m /dev/loop0(0)
  demo 400.00m /dev/loop1(0)
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/demo_vg-demo 365M   24K  338M   1% /mnt/demo
```

Grow it by 100 MiB while mounted — volume and filesystem in one step:

```bash novmcheck
sudo lvextend -q -L +100M -r /dev/demo_vg/demo
df -h /mnt/demo
```

```text
  Size of logical volume demo_vg/demo changed from 400.00 MiB (100 extents) to 500.00 MiB (125 extents).
  Logical volume demo_vg/demo successfully resized.
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/mapper/demo_vg-demo is mounted on /mnt/demo; on-line resizing required
The filesystem on /dev/mapper/demo_vg-demo is now 512000 (1k) blocks long.
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/demo_vg-demo 461M   24K  430M   1% /mnt/demo
```

Tear everything down, top layer first:

```bash novmcheck
sudo umount /mnt/demo
sudo lvremove -q -y demo_vg/demo && sudo vgremove -q demo_vg
sudo pvremove -q "$L1" "$L2" && sudo losetup -d "$L1" "$L2"
rm /tmp/pv1.img /tmp/pv2.img
```

## Common mistakes

- **`lvextend` without `-r`**: the LV grows, the filesystem doesn't; run
  `resize2fs` (ext4) or `xfs_growfs` (XFS) afterwards.
- **`-L 500M` when you meant `-L +500M`**: the first sets the size *to* 500M
  (it may even refuse because that's a shrink).
- **Removing layers bottom-up**: unmount, then `lvremove`, `vgremove`,
  `pvremove`.
- **`pvcreate` on a disk with data** — it's destructive, like `mkfs`.

## Recap

- PVs (disks) → VG (pool of extents) → LVs (volumes with filesystems).
- `pvcreate`, `vgcreate`, `lvcreate -L/-l -n`, `vgextend`, `lvextend -r`.
- `pvs`, `vgs`, `lvs` show the state; LVs are `/dev/VG/LV`.

## Next

The labs: `make lab ID=partitions`, `filesystems`, `lvm` and the optional
`nfs`. Then a final story beat before the demo.
