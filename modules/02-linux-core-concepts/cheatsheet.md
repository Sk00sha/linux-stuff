# Cheatsheet — Linux Core Concepts

## Kernel

| Command | Does |
|---|---|
| `uname -r` / `uname -a` | kernel release / everything |
| `lsmod` | loaded modules |
| `modinfo NAME` | module details |
| `sudo modprobe NAME` / `sudo modprobe -r NAME` | load / unload (with dependencies) |
| `echo NAME \| sudo tee /etc/modules-load.d/NAME.conf` | load at every boot |

## Hardware

| Command | Does |
|---|---|
| `sudo dmesg -T` / `journalctl -k` | kernel messages |
| `udevadm info /dev/sdb` / `udevadm monitor` | device details / live events |
| `lscpu`, `lsmem`, `free -m` | CPU, memory |
| `lsblk`, `lspci -k`, `lsusb`, `sudo lshw -short` | disks, PCI, USB, everything |
| `/proc/cpuinfo`, `/proc/meminfo`, `/proc/cmdline`, `/sys/class/net` | kernel's live views |

## Boot and targets

| Command | Does |
|---|---|
| `systemd-analyze` / `systemd-analyze blame` | boot time / slowest units |
| `systemctl get-default` | default target |
| `sudo systemctl set-default multi-user.target` | boot to text mode next time |
| `sudo systemctl isolate rescue.target` | switch now (careful over SSH) |
| `/etc/default/grub` + `sudo update-grub` (`grub2-mkconfig -o /boot/grub2/grub.cfg`) | GRUB settings |

Runlevels: 0 poweroff · 1 rescue · 3 multi-user · 5 graphical · 6 reboot

## File types (`ls -l` first character)

`-` file · `d` directory · `l` symlink · `c` char device · `b` block device · `p` named pipe · `s` socket

| Command | Does |
|---|---|
| `file PATH` / `stat -c '%F' PATH` | identify type |
| `ln TARGET NAME` / `ln -s TARGET NAME` | hard link / symlink |
| `readlink -f NAME` | resolve a symlink |
| `mkfifo NAME` | create a named pipe |

## Hierarchy

`/etc` config · `/var` logs & data · `/usr` packaged software · `/opt` add-ons ·
`/home` users · `/tmp` temporary · `/boot` kernel · `/dev` devices ·
`/proc` `/sys` `/run` virtual · `/mnt` `/media` mount points · `/srv` served data
