# Hints — Get to know bob-vm

## t1

### Level 1

One command prints the kernel release; you only need to save its output.

### Level 2

`uname -r` prints the release. `>` redirects output into a file.

### Level 3

`uname -r > /home/bob/kernel.txt`

## t2

### Level 1

Kernel modules are loaded with a tool that also resolves dependencies. It needs root.

### Level 2

`modprobe` loads modules; verify with `lsmod`.

### Level 3

`sudo modprobe dummy` then `lsmod | grep dummy`

## t3

### Level 1

`modprobe` only affects the running kernel. systemd reads a directory of `.conf` files at boot to decide which modules to load.

### Level 2

Files in `/etc/modules-load.d/` contain one module name per line. You need root to write there.

### Level 3

`echo dummy | sudo tee /etc/modules-load.d/dummy.conf` (`sudo echo dummy > file` would fail: the redirection runs as bob).

## t4

### Level 1

The boot target is a systemd setting. There's a `systemctl` subcommand to read it and one to change it.

### Level 2

`systemctl get-default` shows it; `systemctl set-default TARGET` changes it.

### Level 3

`sudo systemctl set-default multi-user.target`

## t5

### Level 1

A symbolic link is created with `ln` and an option. Which log file exists on this distribution? `ls /var/log`.

### Level 2

`ln -s TARGET LINKNAME` — the target comes first.

### Level 3

`ln -s /var/log/syslog /home/bob/latest-log` (Rocky: `/var/log/messages`), then `ls -l /home/bob/latest-log`.

## t6

### Level 1

Don't trust the names. Look at the first character of `ls -l` for each path.

### Level 2

`ls -l PATH`, `file PATH` and `stat -c '%F' PATH` all reveal the type. Note `ls -l` on a symlink shows the link itself.

### Level 3

`stat -c '%n:%F' $(tail -n +2 /home/bob/filetypes/README)` prints nearly the right lines; "block special file" means block device, "fifo" means named pipe.
