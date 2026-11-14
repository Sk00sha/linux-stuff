# Cheatsheet — Storage in Linux

Disk → partition → (LVM) → filesystem → mount point. **Identify the device twice before writing.**

## Look

| Command | Shows |
|---|---|
| `lsblk` / `lsblk -f` / `lsblk -o NAME,SIZE,SERIAL,TRAN` | tree / filesystems / details |
| `sudo fdisk -l [DISK]` / `sudo sgdisk -p DISK` | partition tables |
| `sudo blkid [DEV]` | UUID, LABEL, TYPE |
| `findmnt` / `df -h` / `df -i` | mounts / space / inodes |
| `course-disk disk-a` | practice disk device on the course VM |

## Partition

`sudo gdisk DISK` → `o` new GPT, `n` new, `+500M`, type `8300`, `p`, `w` ·
`sgdisk -o DISK; sgdisk -n 1:0:+500M -t 1:8300 DISK` · `parted -s DISK mklabel gpt mkpart data ext4 1MiB 501MiB` ·
`sudo partprobe DISK` · MBR ≤ 2 TiB/4 primaries; GPT for new disks

## Filesystems

| Command | Does |
|---|---|
| `sudo mkfs.ext4 [-L label] PART` / `mkfs.xfs PART` | create (erases!) |
| `sudo mount PART DIR` / `sudo umount DIR` | attach / detach |
| `UUID=... /mnt/data ext4 defaults 0 2` | fstab line |
| `sudo findmnt --verify` / `sudo mount -a` | test fstab |
| `resize2fs DEV` / `xfs_growfs MOUNT` | grow filesystem |

## LVM

`pvcreate D1 D2` → `vgcreate VG D1 D2` → `lvcreate -L 1G -n LV VG` → `mkfs.ext4 /dev/VG/LV`
· grow: `lvextend -L +500M -r /dev/VG/LV` · more disks: `vgextend VG D3` · `pvs vgs lvs`
· remove: `umount`, `lvremove`, `vgremove`, `pvremove`

## NFS

Server `/etc/exports`: `/srv/share 192.168.56.10(rw,sync,no_subtree_check)` → `sudo exportfs -arv`
· Client: `showmount -e SERVER`, `sudo mount -t nfs SERVER:/srv/share /mnt/share`
· fstab: `SERVER:/srv/share /mnt/share nfs defaults,_netdev,nofail 0 0` · port 2049/tcp

DAS = local blocks · NAS = files over network (NFS/SMB) · SAN = blocks over network (iSCSI/FC)
