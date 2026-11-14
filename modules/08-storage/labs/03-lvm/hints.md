# Hints — A growable media volume with LVM

## t1

### Level 1

Disks must be initialised for LVM before they can join a volume group.

### Level 2

`sudo pvcreate DISK...` and check with `sudo pvs`.

### Level 3

`sudo pvcreate $(course-disk disk-b) $(course-disk disk-c)`

## t2

### Level 1

A volume group is a named pool made from one or more PVs.

### Level 2

`sudo vgcreate NAME PV1 PV2`, then `sudo vgs`.

### Level 3

`sudo vgcreate caleston_vg $(course-disk disk-b) $(course-disk disk-c)`

## t3

### Level 1

Carve a volume with a size and a name, then treat it like a partition: filesystem, mount point, mount.

### Level 2

`lvcreate -L SIZE -n NAME VG`; the device is `/dev/caleston_vg/data`.

### Level 3

`sudo lvcreate -L 1G -n data caleston_vg && sudo mkfs.ext4 /dev/caleston_vg/data && sudo mkdir -p /mnt/media && sudo mount /dev/caleston_vg/data /mnt/media`

## t4

### Level 1

Growing has two parts: the volume and the filesystem inside it. One option does both.

### Level 2

`lvextend -L +SIZE -r` — mind the plus sign.

### Level 3

`sudo lvextend -L +500M -r /dev/caleston_vg/data`, then `df -h /mnt/media`.
