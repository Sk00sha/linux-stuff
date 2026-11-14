# Lab: Prepare the Rocky reporting server

The Red Hat half of Mercury needs a web server, a clean-up and access to
Caleston's internal repository.

- **Runtime:** Docker — machine `rocky`, logged in as `bob` (with `sudo`)
- **Estimated time:** 30 minutes
- **Start:** `make lab ID=yum-and-rpm` · **Check:** `make check ID=yum-and-rpm`

## Tasks

| ID | Task |
|---|---|
| t1 | Write the name of the package that owns `/usr/bin/wget` into `/home/bob/wget-owner.txt` (just the name, e.g. `bash`). |
| t2 | Install the `httpd` and `tree` packages. |
| t3 | A security scan flagged `telnet`. Remove the `telnet` package. |
| t4 | Create `/etc/yum.repos.d/local.repo` defining an enabled repository with the id `local`, whose `baseurl` is `file:///opt/localrepo`, with `gpgcheck=0`. |
| t5 | Install the package `bob-tool` from the new local repository. |

## Notes

- The lab works offline: `httpd` and `tree` come from a repository baked
  into the image (`course-offline`), and `/opt/localrepo` was built by the
  lab setup with `createrepo_c`. The internet repositories may time out —
  that's fine.
- `ls /opt/localrepo` shows what the internal repository contains.
- The `rocky` image must be built once with `make setup` (it needs access to
  the Rocky Linux mirrors at build time).
