---
id: 02-linux-core-concepts/02-linux-kernel
title: The Linux Kernel
minutes: 11
objectives:
  - Explain what the kernel does and what a system call is
  - Describe Linux as a monolithic but modular kernel
  - Read kernel version strings with uname
  - List, load and unload kernel modules
prerequisites: [02-linux-core-concepts/01-bobs-first-team-meeting]
tryit: vm
---

# The Linux Kernel

## Why this matters

The asset inventory wants the exact kernel version of bob-vm, and the
monitoring team needs a kernel driver loaded. Both tasks need you to know
what the kernel is, how it is versioned and how pieces of it — **modules** —
are added and removed while the system runs.

## Concepts

### What the kernel does

The kernel has four big jobs:

1. **Process management** — creating processes and deciding which one runs
   on which CPU, and for how long.
2. **Memory management** — giving each process its own address space and
   keeping track of what is in RAM and what is in swap.
3. **Device drivers** — code that knows how to talk to a specific disk
   controller, network card or USB device.
4. **System calls and security** — the doorway user space uses to request
   anything from the kernel (`open`, `read`, `write`, `fork`, `execve`…),
   plus enforcing who is allowed to do what.

When `cat /etc/hostname` runs, `cat` does not read the disk itself. It calls
`open()` and `read()`; the kernel checks permissions, asks the filesystem
driver for the data and copies it back into `cat`'s memory.

### Kernel space and user space

The CPU runs kernel code in a privileged mode (**kernel space**) and normal
programs in a restricted mode (**user space**). A bug in a user program
crashes that program; a bug in kernel space can crash the whole machine.
This separation is why programs must go through system calls.

### Monolithic, but modular

Linux is a **monolithic** kernel: drivers, filesystems and networking all run
inside the same privileged kernel space, which makes it fast. To avoid
building everything in, most drivers are compiled as **loadable kernel
modules** (`.ko` files under `/lib/modules/$(uname -r)/`). Modules can be
loaded when hardware appears and unloaded when no longer needed, without a
reboot.

| Command | Purpose |
|---|---|
| `lsmod` | list loaded modules (reads `/proc/modules`) |
| `modinfo NAME` | describe a module: file, description, parameters |
| `sudo modprobe NAME` | load a module **and its dependencies** |
| `sudo modprobe -r NAME` | unload it (if nothing uses it) |
| `/etc/modules-load.d/*.conf` | modules to load at every boot (one name per line) |
| `/etc/modprobe.d/*.conf` | options and blacklists for modules |

`insmod`/`rmmod` also exist but do not resolve dependencies; prefer
`modprobe`.

### Kernel versions

`uname -r` prints the running kernel's release, for example
`6.8.0-45-generic`:

| Part | Meaning |
|---|---|
| `6` | major version |
| `8` | minor version (a new one roughly every 9–10 weeks) |
| `0` | patch level upstream |
| `-45` | the distribution's build/revision number |
| `-generic` | the distribution's kernel flavour |

`uname -a` prints everything: kernel name, hostname, release, build date and
architecture. The kernels installed on disk live in `/boot` (`vmlinuz-*`);
the *running* one is whatever `uname -r` says until you reboot.

## Try it

Run on the course VM. Your versions will differ.

```bash novmcheck
uname -r
uname -a
ls /boot | grep vmlinuz
```

```text
6.8.0-45-generic
Linux bob-vm 6.8.0-45-generic #45-Ubuntu SMP PREEMPT_DYNAMIC Fri Aug 30 12:02:04 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
vmlinuz
vmlinuz-6.8.0-45-generic
```

List loaded modules and inspect one:

```bash novmcheck
lsmod | head -5
modinfo -F description ext4
```

```text
Module                  Size  Used by
tls                   155648  0
intel_rapl_msr         20480  0
intel_rapl_common      40960  1 intel_rapl_msr
vboxguest              57344  2
Fourth Extended Filesystem
```

Load and unload a harmless module (`dummy` creates fake network interfaces):

```bash novmcheck
sudo modprobe dummy
lsmod | grep dummy
ip link show type dummy
sudo modprobe -r dummy
lsmod | grep -c dummy
```

```text
dummy                  12288  0
3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 5e:2a:f8:91:0c:3b brd ff:ff:ff:ff:ff:ff
0
```

See which modules are configured to load at boot:

```bash
ls /etc/modules-load.d/
grep -hv '^#' /etc/modules-load.d/*.conf || echo '(no modules listed)'
```

```text
modules.conf
(no modules listed)
```

## Common mistakes

- **Expecting `modprobe` to survive a reboot.** It only affects the running
  kernel. Add the module name to a file in `/etc/modules-load.d/`.
- **Writing the `.ko` file name or path in modules-load.d.** Write just the
  module name: `dummy`, not `dummy.ko`.
- **Assuming the newest kernel in `/boot` is running.** After a kernel update
  you must reboot; until then `uname -r` shows the old one.
- **Trying any of this in a container.** `modprobe` in Docker fails (or, if
  privileged, changes the *host's* kernel).

## Recap

- The kernel manages processes, memory and devices; programs reach it through
  system calls.
- Linux is monolithic but modular: `lsmod`, `modinfo`, `modprobe`,
  `modprobe -r`, and `/etc/modules-load.d/` for loading at boot.
- `uname -r` shows the running kernel release; `uname -a` shows everything.

## Next

Drivers exist to talk to hardware. Next, how to see what hardware Linux has
detected.
