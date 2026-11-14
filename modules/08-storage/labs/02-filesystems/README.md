# Lab: A persistent data filesystem

- **Runtime:** VM only — `bob-vm`, logged in as `bob` (with `sudo`)
- **Estimated time:** 20 minutes
- **Start:** `make lab ID=filesystems` · **Check:** `make check ID=filesystems`

## Tasks

| ID | Task |
|---|---|
| t1 | Create an **ext4** filesystem on the 500 MiB partition of `disk-a`. |
| t2 | Mount it at `/mnt/data`. |
| t3 | Add an `/etc/fstab` entry that mounts it at `/mnt/data` at boot, identifying it **by UUID**. |
| t4 | The entry must be valid and reboot-safe: the grader unmounts `/mnt/data` and runs `mount -a` to prove it comes back. |

## Notes

- If you skipped the partitions lab, the setup created the partition for
  you. `lsblk -f $(course-disk disk-a)` shows it.
- Make a copy of fstab before editing: `sudo cp /etc/fstab /etc/fstab.bak`.
- Bonus: `sudo reboot`, log back in, and check `findmnt /mnt/data`.
