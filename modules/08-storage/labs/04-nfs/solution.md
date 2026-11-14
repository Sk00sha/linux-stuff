# Solution — Share reports over NFS

## t1 — export on nfs-server

`rw` for read-write, `sync` for safety, `no_subtree_check` as recommended.
No space between the client and the options.

```bash solution target=nfs-server user=bob
echo '/srv/share 192.168.56.10(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports
sudo exportfs -arv
```

## t2 + t3 — mount on bob-vm, now and at boot

```bash solution target=bob-vm user=bob
showmount -e nfs-server
sudo mkdir -p /mnt/share
sudo mount -t nfs nfs-server:/srv/share /mnt/share
echo 'nfs-server:/srv/share /mnt/share nfs defaults,_netdev,nofail 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
findmnt /mnt/share
```

`_netdev` makes systemd mount it only after the network is up; `nofail`
keeps bob-vm booting if nfs-server is down.

## t4 — write as bob

```bash solution target=bob-vm user=bob
echo "hello from $(hostname)" > /mnt/share/hello-from-bob.txt
ls -l /mnt/share
```

On nfs-server, `ls -l /srv/share` shows the file owned by `bob` — NFS
transmits the numeric UID, which is the same on both VMs.
