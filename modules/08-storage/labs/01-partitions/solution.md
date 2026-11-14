# Solution — Partition the first new disk

On `bob-vm` as `bob`. Interactive version first:

```text
$ lsblk $(course-disk disk-a)                 # 1G, no partitions: the right disk
$ sudo gdisk $(course-disk disk-a)
Command (? for help): o   -> y               # new GPT
Command (? for help): n                       # new partition
Partition number (1-128, default 1):          <Enter>
First sector ...:                             <Enter>
Last sector ...: +500M
Hex code or GUID (... Enter = 8300):          <Enter>
Command (? for help): p                       # check
Command (? for help): w   -> y               # write
```

The same with `sgdisk`, which is what the automated test uses:

```bash solution user=bob
D=$(course-disk disk-a)
sudo sgdisk -o "$D"
sudo sgdisk -n 1:0:+500M -t 1:8300 "$D"
sudo partprobe "$D"; sudo udevadm settle
lsblk -nrpo NAME,TYPE "$D" | awk '$2=="part"{print $1}' > /home/bob/partition.txt
cat /home/bob/partition.txt
sudo sgdisk -p "$D" | tail -2
```

- `-o` writes a new, empty GPT (t1).
- `-n 1:0:+500M` creates partition 1 starting at the first free (aligned)
  sector and 500 MiB long (t2); `-t 1:8300` sets its type (t3).
- `partprobe` + `udevadm settle` make sure the kernel and udev have created
  the new partition device before we look for it (t4).
