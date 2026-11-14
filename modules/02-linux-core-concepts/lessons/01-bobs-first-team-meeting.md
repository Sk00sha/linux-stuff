---
id: 02-linux-core-concepts/01-bobs-first-team-meeting
title: "Bob's First Team Meeting: Kernel and User Space"
minutes: 8
objectives:
  - Describe the main layers of a Linux system
  - Explain why this module needs a virtual machine
prerequisites: [01-shell-1/05-bash-shell]
quiz: false
tryit: vm
---

# Bob's First Team Meeting: Kernel and User Space

## Why this matters

Before Bob changes anything on bob-vm he needs a mental map of what a Linux
system is made of. That map tells you where to look when something breaks:
is it a hardware problem, a kernel problem, or a problem with a program?

## Concepts

A running Linux system has three broad layers:

```text
+---------------------------------------------------------+
|  Applications and services                              |
|  (bash, sshd, nginx, postgres, your scripts)            |  user space
+---------------------------------------------------------+
|  System libraries (glibc), system calls interface       |
+=========================================================+
|  Linux kernel: processes, memory, filesystems,          |  kernel space
|  networking, device drivers                             |
+---------------------------------------------------------+
|  Hardware: CPU, RAM, disks, network cards               |
+---------------------------------------------------------+
```

- The **kernel** is the core program loaded at boot. It is the only software
  that talks to the hardware directly. It decides which process runs on
  which CPU, hands out memory, and provides drivers for devices.
- **User space** is everything else: every program you run, including the
  shell. A program cannot touch the disk or the network card itself — it
  asks the kernel through a **system call**.
- A **Linux distribution** (Ubuntu, Rocky Linux, Debian, Fedora…) bundles a
  kernel with a curated set of user-space programs, an installer and a
  package manager.

### Why a VM for this module?

Containers, which the course uses for most labs, are just isolated groups of
processes that **share the host's kernel**. Inside a container you cannot
load kernel modules, change how the machine boots, or partition real disks —
those actions would affect (or be refused by) the host. A virtual machine has
its own kernel and its own virtual hardware, so you can experiment safely.

## Try it

Run these on the course VM (`make vm-ssh`). Your numbers will differ.

```bash
uname -s
uname -r
cat /etc/os-release | head -2
```

```text
Linux
6.8.0-45-generic
PRETTY_NAME="Ubuntu 24.04.1 LTS"
NAME="Ubuntu"
```

The very first process the kernel starts is PID 1. On modern systems it is
systemd:

```bash
ps -p 1 -o pid,comm
```

```text
    PID COMMAND
      1 systemd
```

Every program you run is a user-space process with its own PID:

```bash
echo "this shell is PID $$"
ps -o pid,ppid,comm
```

```text
this shell is PID 1843
    PID    PPID COMMAND
   1843    1842 bash
   1859    1843 ps
```

## Common mistakes

- **Thinking "Linux" means a whole operating system.** Strictly, Linux is the
  kernel; the distribution provides everything around it.
- **Expecting kernel features inside containers.** `modprobe` or changing the
  boot target inside a Docker container either fails or affects the host.

## Recap

- Hardware is managed only by the kernel; programs run in user space and use
  system calls to ask the kernel for anything.
- A distribution = kernel + user-space tools + package manager.
- Containers share the host kernel; this module uses a VM to get its own.

## Next

Let's look at the kernel itself: what kind of kernel Linux is and how to tell
which version you're running.
