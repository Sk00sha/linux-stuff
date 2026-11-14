---
id: 08-storage/05-nfs
title: The NFS Filesystem
minutes: 8
objectives:
  - Export a directory from an NFS server with /etc/exports and exportfs
  - Mount an NFS share on a client by hand and via /etc/fstab
  - Understand the most important export options
prerequisites: [08-storage/04-das-nas-san]
tryit: vm
---

# The NFS Filesystem

## Why this matters

The reports team wants one folder that every Mercury server can read and
write. NFS (Network File System) is the standard way Linux and Unix machines
share directories over the network — and it is mounted just like a disk.

## Concepts

### Server side: exports

The NFS server (package `nfs-kernel-server` on Ubuntu, `nfs-utils` on Rocky)
publishes directories listed in **`/etc/exports`**:

```text
# directory     client(options)              client(options)...
/srv/share      192.168.56.10(rw,sync,no_subtree_check)
/srv/reports    192.168.56.0/24(ro,sync)     backup01(rw,sync)
```

Clients are host names, IP addresses, networks in CIDR form, or `*`.
**No space** between the client and its parentheses — `host (rw)` means
"`host` with defaults, and **everyone** with rw".

| Option | Meaning |
|---|---|
| `rw` / `ro` | read-write / read-only |
| `sync` / `async` | reply only after data is on disk (safe) / sooner (fast, risky) |
| `root_squash` (default) | a client's root is mapped to the unprivileged `nobody` user |
| `no_root_squash` | client root stays root on the share — avoid unless needed |
| `no_subtree_check` | recommended; avoids subtle problems with renamed files |

After editing, publish the changes and check them:

```bash
sudo exportfs -arv        # re-export all (-a), re-sync (-r), verbose (-v)
sudo exportfs -v          # what's exported right now
```

Permissions still apply: NFS identifies users by **UID/GID numbers**, so
`bob` should have the same UID on server and clients (module 06's identity
standard pays off here).

### Client side: mounting

The client needs `nfs-common` (Ubuntu) or `nfs-utils` (Rocky):

```bash
showmount -e nfs-server                       # what does the server export?
sudo mkdir -p /mnt/share
sudo mount -t nfs nfs-server:/srv/share /mnt/share
```

In `/etc/fstab`:

```text
nfs-server:/srv/share  /mnt/share  nfs  defaults,_netdev,nofail  0  0
```

`_netdev` tells systemd this mount needs the network, so it waits for it
at boot. `nofail` keeps the client booting if the server is down.

### Checking and troubleshooting

| Command | Where | Shows |
|---|---|---|
| `sudo exportfs -v` | server | active exports and their options |
| `showmount -e SERVER` | client | what the server offers (NFSv3 helper; may be blocked by firewalls) |
| `findmnt -t nfs,nfs4` | client | mounted NFS shares and negotiated options |
| `nfsstat -m` | client | per-mount statistics and version |
| `journalctl -u nfs-server` | server | server-side errors |

A mount that hangs usually means the server is unreachable (network,
firewall on 2049) rather than a permissions problem; "access denied by
server" means the client isn't in `/etc/exports` (or `exportfs -ra` wasn't
run); "Permission denied" on a file after mounting is ordinary Unix
permissions — check UIDs.

### Versions and ports

Modern clients use NFSv4 (single TCP port **2049**, firewall-friendly);
NFSv3 additionally needs rpcbind (port 111) and helper ports. If you
firewall an NFS server, allow 2049/tcp from the clients.

## Try it

On the course VMs (`NFS=1 vagrant up` creates `nfs-server`). These
commands only *look*; the lab does the configuration.

What does the server offer, and who is mounting it?

```bash novmcheck
showmount -e nfs-server
```

```text
Export list for nfs-server:
/srv/share 192.168.56.10
```

On the client, NFS mounts show up like any other filesystem:

```bash novmcheck
findmnt -t nfs,nfs4
df -h -t nfs4
```

```text
TARGET     SOURCE                 FSTYPE OPTIONS
/mnt/share nfs-server:/srv/share  nfs4   rw,relatime,vers=4.2,rsize=262144,wsize=262144,...
Filesystem             Size  Used Avail Use% Mounted on
nfs-server:/srv/share   31G  2.1G   27G   8% /mnt/share
```

Check an exports line for the classic space mistake before using it —
`exportfs` would accept both, with very different meanings:

```bash
printf '/srv/a 192.168.56.10(rw)\n/srv/b 192.168.56.10 (rw)\n' > /tmp/exports.test
grep -nE '[^ ] +\(' /tmp/exports.test || echo "no problems found"
rm /tmp/exports.test
```

```text
2:/srv/b 192.168.56.10 (rw)
```

## Common mistakes

- **A space before the parentheses** in `/etc/exports`, exporting rw to the
  whole world.
- **Forgetting `exportfs -ra`** after editing `/etc/exports`.
- **Different UIDs** for the same user on server and client: files appear
  owned by someone else, or "Permission denied".
- **No `_netdev`/`nofail`** in fstab: the client hangs at boot when the
  server is unreachable.
- **`no_root_squash` "to make it work"** — it lets any client's root own the
  share.

## Recap

- Server: `/etc/exports` lines `DIR client(options)`, then `exportfs -arv`.
- Client: `mount -t nfs server:/dir /mnt/x`; fstab with `_netdev,nofail`.
- NFS checks permissions by UID/GID; keep IDs consistent; NFSv4 uses port 2049.

## Next

Flexible local storage that can grow: LVM.
