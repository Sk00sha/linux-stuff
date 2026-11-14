# Linux Basics — Hands-On

A free, self-contained course that takes you from "what is a shell?" to
troubleshooting a broken multi-server application. You learn alongside
**Bob**, a new hire at Caleston whose team must get **Project Mercury**
ready for a client demonstration in three weeks.

- **9 modules**, 48 lessons, 37 quizzes and **21 auto-graded labs**
- Labs run on **your own machine**: Docker containers for most modules, a
  small virtual machine where a real kernel is needed
- Every lab can be started, checked, hinted and reset from one command line
- About 19 hours of learner time (see [SYLLABUS.md](SYLLABUS.md))

```text
make lab ID=working-with-the-shell     # start a lab and get a shell
make check ID=working-with-the-shell   # grade it
make hint ID=working-with-the-shell TASK=t2
```

## Contents

1. [How it works](#how-it-works)
2. [Why Docker *and* a VM](#why-docker-and-a-vm)
3. [Prerequisites](#prerequisites)
4. [Quickstart](#quickstart)
5. [Setting up the VM](#setting-up-the-vm)
6. [Suggested learning path](#suggested-learning-path)
7. [Command reference](#command-reference)
8. [Repository layout](#repository-layout)
9. [Troubleshooting FAQ](#troubleshooting-faq)
10. [Known limitations](#known-limitations)
11. [Licence](#licence)

## How it works

Each module has a short **story** (what Bob is up against), **lessons**
(600–1,500 words with runnable "Try it" exercises, common mistakes and a
recap), a **quiz** per lesson, one or more **labs**, and a one-page
**cheatsheet**.

A lab is a small, broken or empty environment plus a list of tasks. You work
inside the lab machine as `bob`; when you're done, the grader (which only
*looks*, never fixes) tells you task by task what it observed:

```text
PASS t1
FAIL t2: port 8080 on app01 is reachable from devbox; expected it to be blocked
PASS t3
---
2 passed, 1 failed
```

Every task has three levels of hints (nudge → which command → nearly the
answer) and a worked solution that explains *why*, not just *what*.

The course is tested like software: for every lab, CI runs
`setup → check must fail → apply the solution → check must pass → reset →
check must fail`.

## Why Docker *and* a VM

**Docker for speed, a VM where you need a real kernel. On a Linux host,
Incus can do both.**

Containers start in a second and are perfect for most topics. But they share
the host's kernel, so some topics are fake — or dangerous — inside them:

| Topic | Plain Docker | Why |
|---|---|---|
| Shell, files, vi, redirection, find/grep, tar | ✅ | pure user space |
| RPM/DNF, DPKG/APT | ✅ | Rocky and Ubuntu images |
| Users, groups, permissions, sudoers | ✅ | |
| SSH/SCP between hosts | ✅ | several containers on a Compose network |
| DNS (`/etc/hosts`, `resolv.conf`, dnsmasq) | ✅ | Compose network + a dnsmasq container |
| Cron | ✅ | cron runs in the container |
| iptables | ⚠️ | needs `cap_add: NET_ADMIN`; works per container network namespace |
| systemd services | ⚠️ | needs a privileged systemd image — fragile on macOS/Windows |
| Kernel modules, `dmesg`, `/proc` hardware | ❌ | that's the host's kernel |
| Boot sequence, GRUB, targets | ❌ | containers don't boot |
| Partitions, mkfs, mount, LVM | ⚠️/❌ | only via privileged loop devices — dangerous on the host |
| NFS server | ⚠️ | kernel nfsd; privileged only |

So the course uses two **tracks**:

- **Track A — Docker Compose** (default, fast): modules 01, 03, 04, 05, 06
  and 09.
- **Track B — a lightweight VM** with three blank practice disks: modules
  02, 07 and 08. Module 07 can fall back to a systemd container on Linux
  hosts.

Each lab declares its runtime in `lab.yaml`; `make lab` picks the right
one.

## Prerequisites

| You need | For | Check |
|---|---|---|
| Python 3.8+ (standard library only) | the `course` CLI | `python3 --version` |
| GNU Make | the `make` shortcuts (optional: you can call `bin/course` directly) | `make --version` |
| Docker Engine 24+ or Docker Desktop, with Compose v2 | Track A | `docker compose version` |
| Vagrant + a provider, **or** Multipass, Incus or Lima | Track B | see [Setting up the VM](#setting-up-the-vm) |
| ~6 GB disk for images, ~4 GB RAM free | | |

Internet access is needed **once**, to build the images and the VM. Labs and
graders work offline.

## Quickstart

### Linux

```bash
git clone <this repository> linux-basics-course
cd linux-basics-course
make setup            # checks prerequisites, builds the images (10-20 min the first time)
make list             # the whole course
make read ID=01-introduction-to-shell
make quiz ID=01-introduction-to-shell
make lab ID=working-with-the-shell
```

On Linux every Docker lab works, including the systemd-based ones (module
07 fallback and the module 09 finale).

### macOS (Intel and Apple Silicon)

1. Install Docker Desktop (or Colima: `brew install colima docker docker-compose && colima start --cpu 2 --memory 4`).
2. `make setup` and start with module 01 exactly as on Linux.
3. For the VM modules use **Lima** or **Multipass** (simplest), or Vagrant
   with the Parallels, VMware or QEMU (`vagrant plugin install vagrant-qemu`)
   provider on Apple Silicon; VirtualBox works on Intel Macs.

The images are multi-architecture: on Apple Silicon they build natively for
arm64.

### Windows

1. Install **WSL 2** with Ubuntu, and **Docker Desktop** with the WSL 2
   backend enabled for that distribution.
2. Clone the repository **inside** WSL (e.g. `~/linux-basics-course`), not
   under `/mnt/c`, and run every command from the WSL terminal.
3. For the VM modules install Vagrant + VirtualBox (or the Hyper-V provider)
   on Windows, or Multipass. Run `vagrant` from PowerShell in
   `runtime\vm`, or install the Windows `vagrant.exe` path in WSL.

The systemd container (module 07 fallback, module 09 finale) generally works
under Docker Desktop's WSL 2 backend; if it doesn't on your machine, run
module 07 on the VM.

## Setting up the VM

The VM is called `bob-vm` (2 vCPU, 2 GB RAM) and gets three blank practice
disks: **disk-a** (1 GB), **disk-b** (1 GB) and **disk-c** (2 GB). Inside the
VM, `course-disk disk-a` prints the device name of each one (`/dev/sdb`,
`/dev/vdb`… depending on the hypervisor), so you never have to guess. Lab
setup scripts refuse to run anywhere that lacks the VM marker file
`/etc/course-vm`, so your own disks are never touched.

| Tool | Best for | Start | Notes |
|---|---|---|---|
| **Vagrant** | everyone (reference setup) | `make vm-up` | VirtualBox (x86), libvirt, QEMU / Parallels / VMware (Apple Silicon). Optional second VM for NFS: `NFS=1 make vm-up` |
| **Multipass** | simplest on macOS/Windows/Linux | `make vm-up VM_TOOL=multipass` | Ubuntu only; no blank disks, so provisioning creates loop-backed practice disks inside the VM |
| **Incus** | Linux hosts | see `runtime/vm/incus-profile.yaml` | real VMs *and* system containers with real systemd |
| **Lima** | macOS | see `runtime/vm/lima.yaml` | extra disks via `limactl disk create` |

`bin/course` finds a running `bob-vm` in that order (Vagrant, Incus,
Multipass, Lima); force one with `COURSE_VM_TOOL=multipass`.

```bash
make vm-up        # first time: download box + provision (~10 min)
make vm-ssh       # a shell on the VM as bob
make vm-down      # destroy it (your progress is stored on the host)
```

## Suggested learning path

1. **Week 1:** Modules 01, 03, 04 — Docker only, zero friction.
2. **Week 2:** Modules 05, 06 — multi-container networking and security.
3. **Week 3:** bring up the VM → Modules 02, 07, 08.
4. **Week 4:** Module 09, the finale, twice with different seeds
   (`SEED=1`, `SEED=2`); then try `SEED=random`.

Modules 02 and 07/08 can be done whenever your VM is ready; lessons list
their prerequisites in their front-matter.

## Command reference

`make` targets are thin wrappers around `bin/course`; use whichever you
prefer. Lab and quiz IDs can be abbreviated to any unique part
(`iptables`, `06-security-and-permissions/iptables`).

| make | bin/course | Does |
|---|---|---|
| `make setup` | | check prerequisites, build images |
| `make list` | `course list [MODULE]` | outline with your progress |
| `make read ID=…` | `course read ID` | read a lesson (marks it read) |
| `make quiz ID=…` | `course quiz ID` | interactive quiz |
| `make lab ID=…` | `course start LAB [--fresh] [--no-shell]` | start machines, run setup, open a shell |
| | `course shell LAB [--service S] [--user U]` | another shell on a lab machine |
| `make check ID=…` | `course check LAB` | grade |
| `make hint ID=… TASK=t2` | `course hint LAB t2 [--level N]` | next hint |
| `make reset ID=…` | `course reset LAB [--fresh]` | back to the starting state |
| | `course solution LAB` | the worked solution |
| `make progress` | `course progress` | what you've completed |
| `make down` | | remove all course containers, networks and volumes |
| `make vm-up` / `vm-down` / `vm-ssh` | | the VM |
| `make syllabus` | `course syllabus` | regenerate SYLLABUS.md |
| `make test` / `make test-labs MODULE=05` | | self-tests |

Progress is stored in `~/.local/share/linux-basics-course/progress.json`.

## Repository layout

```text
course.yaml            single source of truth: modules -> stories, lessons, quizzes, labs
bin/course             the CLI (Python 3, standard library only)
lib/                   runtime.sh, check-helpers.sh, setup-helpers.sh, miniyaml.py
runtime/docker/        compose.yaml, Dockerfiles (ubuntu, rocky, systemd-ubuntu, dns)
runtime/vm/            Vagrantfile, provision.sh, Multipass / Incus / Lima configs
modules/NN-name/       00-story.md, lessons/, quizzes/, labs/<lab>/, cheatsheet.md
tests/                 unit tests, lab end-to-end tests, Try-it runner
```

Each lab directory holds `lab.yaml` (tasks and runtime), `README.md`
(the assignment), `setup.sh` (prepare/reset), `check.sh` (read-only grader),
`hints.md` (three levels per task) and `solution.md` (commands plus why).

## Troubleshooting FAQ

**`make setup` fails building the rocky image.** It needs the Rocky Linux
mirrors at build time. Build the others with `make setup IMAGES="ubuntu dns
systemd"`; only the `yum-and-rpm` lab needs the Rocky image.

**"machine 'ubuntu' is not running".** Start the lab with `make lab ID=…`
(not `make check`) first. `docker ps --filter label=course=linux-basics`
lists course containers.

**"prepared for lab X, not Y".** Machines are shared between labs of a
module. Run `make reset ID=Y` (or `course start Y`).

**I broke a lab machine completely.** `course reset LAB --fresh` recreates
its containers and runs setup again. `make down` removes everything.

**Locked myself out with iptables.** From your host: `bin/course shell
iptables --service app01 --user root`, then `iptables -P INPUT ACCEPT;
iptables -F INPUT`.

**The systemd container doesn't start (module 07/09) on macOS or Windows.**
systemd in Docker needs cgroup support that some Docker Desktop versions
lack. Use the VM for module 07 (`course start systemd-services --runtime
vm`); the finale needs a Linux host or a Linux VM with Docker installed.

**`course check` says no course VM found.** Run `make vm-up`, or set
`COURSE_VM_TOOL` if you use Multipass, Incus or Lima.

**Port or subnet clash (10.10.x.0/24).** The lab networks use
10.10.1.0/24, 10.10.2.0/24 and 10.10.9.0/24. If your LAN or VPN uses them,
change the subnets in `runtime/docker/compose.yaml` and the IPs in the module
05/06/09 labs accordingly.

**Apple Silicon: the Vagrant box doesn't boot.** Use a provider that runs
arm64 (Parallels, VMware Fusion, or `vagrant-qemu`) — VirtualBox on Apple
Silicon is not supported by the box. Multipass and Lima are the easy route.

## Known limitations

- The **VM labs** (modules 02 and 08, and module 07 on the VM) are verified
  in CI only where nested virtualisation is available; module 07's systemd
  container fallback is tested on every run.
- The **Rocky Linux** lab image needs the Rocky mirrors at build time.
- The grader cannot tell *how* you made a change — e.g. that you used vi —
  only that the result is right. Practise the intended tool anyway.

## Licence

- Course content (lessons, stories, quizzes, lab instructions, hints,
  solutions, cheatsheets): **CC BY-SA 4.0** — see [LICENSE](LICENSE).
- Tooling (CLI, libraries, scripts, runtime, tests, CI): **MIT** — see
  [LICENSE-CODE](LICENSE-CODE).

All content is original. The curriculum's topic list follows common
"Linux basics" outlines, but no text, slides or lab wording was copied from
any other course. Contributions are welcome: see
[CONTRIBUTING.md](CONTRIBUTING.md).
