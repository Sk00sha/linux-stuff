# Solution — A persistent data filesystem

On `bob-vm` as `bob`.

```bash solution user=bob
D=$(course-disk disk-a)
P=$(lsblk -nrpo NAME,TYPE "$D" | awk '$2=="part"{print $1; exit}')
echo "partition: $P"
sudo mkfs.ext4 -q -L data "$P"
sudo mkdir -p /mnt/data
sudo mount "$P" /mnt/data
UUID=$(sudo blkid -s UUID -o value "$P")
sudo cp /etc/fstab /etc/fstab.bak
echo "UUID=$UUID /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab
sudo findmnt --verify
sudo systemctl daemon-reload
sudo umount /mnt/data && sudo mount -a && findmnt /mnt/data
```

- `mkfs.ext4` on the **partition**, never the whole disk; `-L data` adds a
  label as a bonus.
- The fstab entry uses `UUID=`, so it keeps working even if the disk shows
  up under another name after a reboot. `0 2`: no dump, fsck after `/`.
- `findmnt --verify` checks the file; `umount` + `mount -a` proves the
  entry works without risking a reboot. `daemon-reload` refreshes the
  mount units systemd generates from fstab.
