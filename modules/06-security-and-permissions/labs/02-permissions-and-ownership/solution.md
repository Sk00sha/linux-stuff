# Solution — Lock down the Mercury project tree

On `devbox` as `bob`, with `sudo` because everything belongs to root.

Start broad, then set the specific modes, so the recursive commands don't
undo the precise ones:

1. Remove "write for others" everywhere (t6). `o-w` changes only that bit.
2. Give the tree to bob and the devops group (t1).
3. Set the precise modes (t2–t4) and the sticky bit (t5).

```bash solution target=devbox user=bob
sudo chmod -R o-w /srv/mercury
sudo chown -R bob:devops /srv/mercury/app
sudo chmod 640 /srv/mercury/app/config/db.conf
sudo chmod 750 /srv/mercury/app/bin/deploy.sh
sudo chmod 2770 /srv/mercury/app
sudo chmod 1777 /srv/shared
stat -c '%A %a %U:%G %n' /srv/mercury/app /srv/mercury/app/config/db.conf /srv/mercury/app/bin/deploy.sh /srv/shared
```

Why each mode:

- **640** on `db.conf`: it holds a password — bob edits it, the `devops`
  group (and a service running in that group) reads it, nobody else.
- **750** on `deploy.sh`: team members may run it; others can't even read it.
- **2770** on `app/`: only owner and group can enter; the setgid bit makes
  files created inside belong to `devops` instead of the creator's private
  group, so the whole team keeps access.
- **1777** on `/srv/shared`: anyone can create files, but only the owner of a
  file (or root) can delete or rename it.

A more careful real-world version of t6 would set sane defaults for the
whole tree, e.g. `sudo chmod -R u=rwX,g=rX,o=rX /srv/mercury/docs`, where
`X` adds execute only to directories.
