# Lab: A growable media volume with LVM

- **Runtime:** VM only — `bob-vm`, logged in as `bob` (with `sudo`)
- **Estimated time:** 25 minutes
- **Start:** `make lab ID=lvm` · **Check:** `make check ID=lvm`

## Tasks

| ID | Task |
|---|---|
| t1 | Make practice disks `disk-b` and `disk-c` LVM physical volumes (use the whole disks). |
| t2 | Create the volume group `caleston_vg` from both physical volumes. |
| t3 | Create a **1 GiB** logical volume named `data` in `caleston_vg`, format it **ext4** and mount it at `/mnt/media`. |
| t4 | Media is growing: extend `data` by **500 MiB**, together with its filesystem, while it stays mounted. |

## Notes

- `course-disk disk-b` and `course-disk disk-c` print the device names.
- After t4 the grader expects the LV to be about 1.5 GiB (1024 + 500 MiB)
  **and** `df -h /mnt/media` to show the larger size.
- A persistent fstab entry isn't required here (you practised that in the
  filesystems lab), but it's good practice.
