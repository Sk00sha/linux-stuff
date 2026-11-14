# Hints — Partition the first new disk

## t1

### Level 1

Find the disk first. A new partition table erases the disk, so be sure it's the right one.

### Level 2

`course-disk disk-a` and `lsblk` identify it. In `gdisk`, the `o` command creates a new empty GPT.

### Level 3

`sudo gdisk $(course-disk disk-a)`, then `o`, `y`. Don't quit yet — continue with t2 and finish with `w`.

## t2

### Level 1

Inside gdisk, create a new partition and give its size relative to the start.

### Level 2

`n`, accept the default number and first sector, last sector `+500M`.

### Level 3

`n` Enter Enter `+500M` Enter (type: see t3), then `p` to print and `w` to write.

## t3

### Level 1

gdisk asks for a hex code when you create the partition.

### Level 2

8300 is "Linux filesystem" — it's also the default.

### Level 3

Press Enter (or type `8300`) at the "Hex code or GUID" prompt. Fix an existing partition with `t`.

## t4

### Level 1

The kernel names partitions after the disk plus a number.

### Level 2

`lsblk -p $(course-disk disk-a)` shows the full path of the partition.

### Level 3

`lsblk -nrpo NAME,TYPE $(course-disk disk-a) | awk '$2=="part"{print $1}' > /home/bob/partition.txt`
