# Solution — Get to know bob-vm

Run on `bob-vm` as `bob`; `sudo` is used where root is required.

## t1 — record the kernel release

```bash solution user=bob
uname -r > /home/bob/kernel.txt
```

## t2 and t3 — load `dummy` now and at every boot

`modprobe` loads the module into the running kernel only. At boot,
`systemd-modules-load.service` reads `/etc/modules-load.d/*.conf` and loads
each name listed there. `sudo tee` is used because a redirection
(`sudo echo dummy > file`) would be performed by bob's shell, without root.

```bash solution user=bob
sudo modprobe dummy
echo dummy | sudo tee /etc/modules-load.d/dummy.conf
lsmod | grep dummy
```

## t4 — boot to multi-user (text) mode

`set-default` repoints the `/etc/systemd/system/default.target` symlink. It
does not change the running system; `isolate` would.

```bash solution user=bob
sudo systemctl set-default multi-user.target
systemctl get-default
```

## t5 — a shortcut to the system log

The target comes first. On Rocky the log is `/var/log/messages`; the
`/etc/course-vm` marker records which one this VM uses.

```bash solution user=bob
LOG=$(sed -n 's/^syslog=//p' /etc/course-vm)
ln -sfn "${LOG:-/var/log/syslog}" /home/bob/latest-log
ls -l /home/bob/latest-log
```

## t6 — classify the files

```bash norun
ls -l /home/bob/filetypes /dev/null
```

```text
-rw-r--r-- 1 bob bob   18 ... disk-image          <- regular file
lrwxrwxrwx 1 bob bob   13 ... config.txt -> /etc/hostname   <- symbolic link
prw-r--r-- 1 bob bob    0 ... data.log             <- named pipe
brw-r--r-- 1 bob bob 7, 200 ... terminal           <- block device
crw-rw-rw- 1 root root 1, 3 ... /dev/null          <- character device
```

The names were deliberately misleading: `disk-image` is plain text,
`data.log` is a FIFO and `terminal` is a block device node.

```bash solution user=bob
cat > /home/bob/types.txt <<'TYPES'
/home/bob/filetypes/disk-image:regular file
/home/bob/filetypes/config.txt:symbolic link
/home/bob/filetypes/data.log:named pipe
/home/bob/filetypes/terminal:block device
/dev/null:character device
TYPES
```
