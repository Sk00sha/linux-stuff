# Lab: Install the vendor's notes tool on Ubuntu

The Ubuntu half of Mercury needs a vendor tool, a little documentation and
some clean-up.

- **Runtime:** Docker — machine `ubuntu`, logged in as `bob` (with `sudo`)
- **Estimated time:** 25 minutes
- **Start:** `make lab ID=dpkg-and-apt` · **Check:** `make check ID=dpkg-and-apt`

## Tasks

| ID | Task |
|---|---|
| t1 | Install the vendor package `/home/bob/packages/bob-notes_1.0-1_all.deb` using `dpkg`. |
| t2 | The install leaves `bob-notes` broken because of a missing dependency. Fix it with `apt` so that `bob-notes` is fully installed and the `bob-notes` command works. |
| t3 | Save the list of files installed by the `tree` package, as printed by `dpkg -L`, into `/home/bob/tree-files.txt`. |
| t4 | Write the name of the package that owns `/usr/bin/whatis` into `/home/bob/whatis-owner.txt` (just the name). |
| t5 | Remove the `nano` package, but keep `vim` installed. |

## Notes

- Everything works offline: the dependency is already in the local APT
  cache, so **don't** run `apt update` (it would try to reach the internet).
- Before t1, have a look at the package: `dpkg -I` shows its metadata.
