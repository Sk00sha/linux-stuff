# Lab: Partition the first new disk

- **Runtime:** VM only — `bob-vm`, logged in as `bob` (with `sudo`)
- **Estimated time:** 20 minutes
- **Start:** `make lab ID=partitions` · **Check:** `make check ID=partitions`

## Tasks

| ID | Task |
|---|---|
| t1 | Create a **GPT** partition table on practice disk `disk-a`. Find its device with `course-disk disk-a`. |
| t2 | Create exactly one partition of **500 MiB** on disk-a. |
| t3 | The partition's type must be "Linux filesystem" (gdisk code `8300`). |
| t4 | Write the partition's device path (for example `/dev/sdb1`) into `/home/bob/partition.txt`. |

## Notes

- `course-disk disk-a` prints the device (e.g. `/dev/sdb` on VirtualBox,
  `/dev/vdb` on QEMU, `/dev/loop0` on Multipass). **Only** touch that disk.
- Use `gdisk` interactively — it's the point of the lab. `sgdisk` and
  `parted` are fine too.
- The setup refuses to run outside the course VM (it checks for
  `/etc/course-vm`).
