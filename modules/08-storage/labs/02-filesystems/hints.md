# Hints — A persistent data filesystem

## t1

### Level 1

Find the partition (not the whole disk), then make a filesystem on it.

### Level 2

`lsblk -p $(course-disk disk-a)` shows the partition; `mkfs.ext4` formats it.

### Level 3

`sudo mkfs.ext4 $(lsblk -nrpo NAME,TYPE $(course-disk disk-a) | awk '$2=="part"{print $1}')`

## t2

### Level 1

A mount point is just a directory. It doesn't exist yet.

### Level 2

`sudo mkdir -p /mnt/data`, then `sudo mount DEVICE /mnt/data`.

### Level 3

`sudo mkdir -p /mnt/data && sudo mount /dev/sdb1 /mnt/data` (use your partition), then `findmnt /mnt/data`.

## t3

### Level 1

fstab lines have six fields. The first should identify the filesystem by something that never changes.

### Level 2

`sudo blkid PARTITION` prints the UUID. The line is `UUID=... /mnt/data ext4 defaults 0 2`.

### Level 3

`echo "UUID=$(sudo blkid -s UUID -o value /dev/sdb1) /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab`

## t4

### Level 1

Test the entry the same way the grader does, before you trust a reboot to it.

### Level 2

`sudo findmnt --verify`, then unmount and `mount -a`.

### Level 3

`sudo findmnt --verify && sudo systemctl daemon-reload && sudo umount /mnt/data && sudo mount -a && findmnt /mnt/data`
