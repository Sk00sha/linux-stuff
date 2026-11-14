# Lab (optional): Share reports over NFS

- **Runtime:** VM only — needs the second VM: `NFS=1 make vm-up` (Vagrant)
- Machines: `bob-vm` (192.168.56.10, client) and `nfs-server` (192.168.56.20)
- **Estimated time:** 25 minutes
- **Start:** `make lab ID=nfs` · **Check:** `make check ID=nfs`

## Tasks

| ID | Task |
|---|---|
| t1 | On `nfs-server`, export `/srv/share` read-write to bob-vm (`192.168.56.10`). |
| t2 | On `bob-vm`, mount `nfs-server:/srv/share` at `/mnt/share`. |
| t3 | Make the mount persistent on bob-vm with an `/etc/fstab` entry that waits for the network (`_netdev`). |
| t4 | As `bob` on bob-vm, create the file `/mnt/share/hello-from-bob.txt`; it must appear on nfs-server owned by bob. |

## Notes

- Reach the server with `ssh bob@nfs-server` from bob-vm (password
  `caleston123`), or from your host with `cd runtime/vm && vagrant ssh nfs-server`.
- `/srv/share` on the server is owned by bob. Because bob has the same UID on
  both VMs, NFS maps the file ownership correctly.
