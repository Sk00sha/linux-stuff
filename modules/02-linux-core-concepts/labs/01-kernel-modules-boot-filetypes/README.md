# Lab: Get to know bob-vm

The action items from Bob's first team meeting.

- **Runtime:** VM — machine `bob-vm`, logged in as `bob` (who has `sudo`)
- **Estimated time:** 30 minutes
- **Before you start:** `make vm-up` (once; it takes a few minutes)
- **Start:** `make lab ID=kernel-modules-boot-filetypes`
- **Check:** `make check ID=kernel-modules-boot-filetypes`

## Tasks

| ID | Task |
|---|---|
| t1 | Write the release of the running kernel, exactly as printed by `uname -r`, into `/home/bob/kernel.txt`. |
| t2 | Load the kernel module `dummy` now. |
| t3 | Make the `dummy` module load automatically at every boot, using the file `/etc/modules-load.d/dummy.conf`. |
| t4 | Make `multi-user.target` the default boot target. (Don't `isolate` — just change the default.) |
| t5 | Create a symbolic link `/home/bob/latest-log` pointing to the system log: `/var/log/syslog` on Ubuntu, `/var/log/messages` on Rocky. |
| t6 | `/home/bob/filetypes/README` lists five paths. For each, write a line `path:type` into `/home/bob/types.txt`, using the full path and one of: `regular file`, `directory`, `symbolic link`, `character device`, `block device`, `named pipe`, `socket`. |

Example line for t6: `/etc/hostname:regular file`

## Notes

- Tasks t2–t4 need `sudo`.
- For t6, don't guess from the names — they were chosen to mislead. Use
  `ls -l`, `file` or `stat`.
- Optional extra: `sudo reboot`, log back in, and confirm with `lsmod` and
  `systemctl get-default` that t3 and t4 really survive a reboot.
