# Hints — Share reports over NFS

## t1

### Level 1

The server's list of shares is one text file; a command publishes it.

### Level 2

Add a line to `/etc/exports` on nfs-server: `DIR CLIENT(OPTIONS)`, then `exportfs -arv`.

### Level 3

`echo '/srv/share 192.168.56.10(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports && sudo exportfs -arv`

## t2

### Level 1

An NFS share mounts like a disk, with `server:/path` as the device.

### Level 2

`showmount -e nfs-server` lists exports; `sudo mount -t nfs SERVER:/DIR MOUNTPOINT`.

### Level 3

`sudo mkdir -p /mnt/share && sudo mount -t nfs nfs-server:/srv/share /mnt/share`

## t3

### Level 1

Same fstab format as for disks; the device is `server:/path`, the type `nfs`.

### Level 2

Options should include `_netdev` (and `nofail` is wise).

### Level 3

`echo 'nfs-server:/srv/share /mnt/share nfs defaults,_netdev,nofail 0 0' | sudo tee -a /etc/fstab`

## t4

### Level 1

Write to the share as bob, then look at it from the server.

### Level 2

`echo hi > /mnt/share/hello-from-bob.txt` as bob; on nfs-server `ls -l /srv/share`.

### Level 3

If you get "Permission denied", check that the export is `rw` and that `/srv/share` is owned by bob on the server.
