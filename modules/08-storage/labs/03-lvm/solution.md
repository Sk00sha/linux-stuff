# Solution — A growable media volume with LVM

On `bob-vm` as `bob`.

```bash solution user=bob
B=$(course-disk disk-b); C=$(course-disk disk-c)
sudo pvcreate "$B" "$C"
sudo vgcreate caleston_vg "$B" "$C"
sudo lvcreate -L 1G -n data caleston_vg
sudo mkfs.ext4 -q /dev/caleston_vg/data
sudo mkdir -p /mnt/media
sudo mount /dev/caleston_vg/data /mnt/media
df -h /mnt/media
sudo lvextend -L +500M -r /dev/caleston_vg/data
df -h /mnt/media
sudo pvs; sudo vgs; sudo lvs
```

- `pvcreate` labels both whole disks as PVs (t1); `vgcreate` pools them into
  3 GiB of extents (t2).
- `lvcreate -L 1G -n data` takes 1 GiB from the pool; it's formatted and
  mounted like any partition (t3).
- `lvextend -L +500M -r` adds 500 MiB **and** runs `resize2fs` on the mounted
  ext4 filesystem (t4). Without `-r` the LV would grow but `df` would still
  show the old size.

Optional, to make it persistent:

```bash norun
echo "/dev/caleston_vg/data /mnt/media ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

(LV paths are stable, so using them in fstab is fine; UUIDs work too.)
