# Lab: Lock down the Mercury project tree

The intruder could change Mercury's code because the project tree was wide
open. Fix ownership and permissions.

- **Runtime:** Docker — machine `devbox`, logged in as `bob` (with `sudo`)
- **Estimated time:** 25 minutes
- **Start:** `make lab ID=permissions-and-ownership` · **Check:** `make check ID=permissions-and-ownership`

## Tasks

| ID | Path | Requirement |
|---|---|---|
| t1 | `/srv/mercury/app` (recursive) | owner `bob`, group `devops` |
| t2 | `/srv/mercury/app/config/db.conf` | `rw-r-----` (640) |
| t3 | `/srv/mercury/app/bin/deploy.sh` | `rwxr-x---` (750) |
| t4 | `/srv/mercury/app` (the directory itself) | `rwxrws---` (2770: setgid) |
| t5 | `/srv/shared` | `rwxrwxrwt` (1777: sticky) |
| t6 | everything below `/srv/mercury` | not writable by others |

## Notes

- Everything is currently owned by root, so you'll need `sudo`.
- Order matters a little: a recursive `chmod` after t2–t4 can undo them.
- `stat -c '%A %a %U:%G %n' PATH` shows everything the grader checks.
- `find /srv/mercury -perm -o+w` lists what t6 complains about.
