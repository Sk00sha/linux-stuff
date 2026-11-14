# Lab: Logs, reports and a noisy script

Bob's "behind schedule" to-do list.

- **Runtime:** Docker — machine `ubuntu`, logged in as `bob`
- **Estimated time:** 30 minutes
- **Start:** `make lab ID=shell-2` · **Check:** `make check ID=shell-2`

## Tasks

| ID | Task |
|---|---|
| t1 | Archive the directory `/home/bob/reports` into the gzip-compressed tar file `/home/bob/reports.tar.gz`. Paths inside the archive must start with `reports/`. |
| t2 | Find every file whose name ends in `.log` **and** that is larger than 1 MiB anywhere under `/var/app`, and write their full paths, one per line, into `/home/bob/biglogs.txt`. |
| t3 | Save every line of `/var/app/app.log` that contains the word `error` in any letter case into `/home/bob/errors.txt`. |
| t4 | Run `/opt/mercury/start.sh` so that its standard output goes to `/home/bob/start.out` and its standard error goes to `/home/bob/start.err`. |

## Notes

- `/var/app` contains decoys: big files that aren't `.log`, and `.log` files
  just under 1 MiB. `ls -lh` and `du -h` help you double-check.
- Some directories under `/var/app` are not readable by bob. Errors from
  `find` about them are fine to hide.
- The order of lines in `biglogs.txt` doesn't matter.
