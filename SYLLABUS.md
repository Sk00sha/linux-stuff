# Syllabus — Linux Basics — Hands-On

Generated from `course.yaml` by `bin/course syllabus`. Do not edit by hand.

| Module | Runtime | Lessons | Quizzes | Labs | Est. time |
|---|---|---|---|---|---|
| 01 Working with Shell I | docker | 5 | 4 | 2 | 1h 47m |
| 02 Linux Core Concepts | vm | 8 | 6 | 1 | 2h 08m |
| 03 Package Management | docker | 4 | 4 | 2 | 1h 48m |
| 04 Working with Shell II | docker | 5 | 4 | 2 | 1h 59m |
| 05 Networking | docker | 4 | 3 | 3 | 2h 01m |
| 06 Security and File Permissions | docker | 9 | 8 | 5 | 4h 06m |
| 07 Service Management with systemd | vm | 3 | 2 | 1 | 1h 07m |
| 08 Storage in Linux | vm | 7 | 5 | 4 | 2h 47m |
| 09 The Client Demonstration | docker | 3 | 1 | 1 | 1h 24m |
| **Total** | | | | | **19h 07m** |

## 01-shell-1 — Working with Shell I

Runtime: **docker** · Estimated time: **1h 47m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: Day one, no mouse | 2 | [`00-story.md`](modules/01-shell-1/00-story.md) |
| 2 | lesson | Introduction to the Shell | 12 | [`lessons/01-introduction-to-shell.md`](modules/01-shell-1/lessons/01-introduction-to-shell.md) |
| 3 | quiz | Quiz: Introduction to the Shell | 3 | [`quizzes/01-introduction-to-shell.yaml`](modules/01-shell-1/quizzes/01-introduction-to-shell.yaml) |
| 4 | lesson | Basic Linux Commands | 13 | [`lessons/02-basic-linux-commands.md`](modules/01-shell-1/lessons/02-basic-linux-commands.md) |
| 5 | quiz | Quiz: Basic Linux Commands | 3 | [`quizzes/02-basic-linux-commands.yaml`](modules/01-shell-1/quizzes/02-basic-linux-commands.yaml) |
| 6 | lesson | Command-line Help | 14 | [`lessons/03-command-line-help.md`](modules/01-shell-1/lessons/03-command-line-help.md) |
| 7 | quiz | Quiz: Command-line Help | 3 | [`quizzes/03-command-line-help.yaml`](modules/01-shell-1/quizzes/03-command-line-help.yaml) |
| 8 | lesson | How the Labs Work | 5 | [`lessons/04-lab-introduction.md`](modules/01-shell-1/lessons/04-lab-introduction.md) |
| 9 | lab | Organise the Asia office notes | 20 | [`labs/01-working-with-the-shell`](modules/01-shell-1/labs/01-working-with-the-shell) |
| 10 | lesson | The Bash Shell | 14 | [`lessons/05-bash-shell.md`](modules/01-shell-1/lessons/05-bash-shell.md) |
| 11 | quiz | Quiz: The Bash Shell | 3 | [`quizzes/05-bash-shell.yaml`](modules/01-shell-1/quizzes/05-bash-shell.yaml) |
| 12 | lab | Configure Bob's shell to the team standard | 15 | [`labs/02-bash-prompt`](modules/01-shell-1/labs/02-bash-prompt) |

## 02-linux-core-concepts — Linux Core Concepts

Runtime: **vm** · Estimated time: **2h 08m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: The servers Bob inherits | 2 | [`00-story.md`](modules/02-linux-core-concepts/00-story.md) |
| 2 | lesson | Bob's First Team Meeting: Kernel and User Space | 8 | [`lessons/01-bobs-first-team-meeting.md`](modules/02-linux-core-concepts/lessons/01-bobs-first-team-meeting.md) |
| 3 | lesson | The Linux Kernel | 11 | [`lessons/02-linux-kernel.md`](modules/02-linux-core-concepts/lessons/02-linux-kernel.md) |
| 4 | quiz | Quiz: The Linux Kernel | 3 | [`quizzes/02-linux-kernel.yaml`](modules/02-linux-core-concepts/quizzes/02-linux-kernel.yaml) |
| 5 | lesson | Working with Hardware | 11 | [`lessons/03-working-with-hardware.md`](modules/02-linux-core-concepts/lessons/03-working-with-hardware.md) |
| 6 | quiz | Quiz: Working with Hardware | 3 | [`quizzes/03-working-with-hardware.yaml`](modules/02-linux-core-concepts/quizzes/03-working-with-hardware.yaml) |
| 7 | lesson | The Linux Boot Sequence | 11 | [`lessons/04-linux-boot-sequence.md`](modules/02-linux-core-concepts/lessons/04-linux-boot-sequence.md) |
| 8 | quiz | Quiz: The Linux Boot Sequence | 3 | [`quizzes/04-linux-boot-sequence.yaml`](modules/02-linux-core-concepts/quizzes/04-linux-boot-sequence.yaml) |
| 9 | lesson | Runlevels and systemd Targets | 9 | [`lessons/05-runlevels.md`](modules/02-linux-core-concepts/lessons/05-runlevels.md) |
| 10 | quiz | Quiz: Runlevels and systemd Targets | 3 | [`quizzes/05-runlevels.yaml`](modules/02-linux-core-concepts/quizzes/05-runlevels.yaml) |
| 11 | lesson | Article: From Runlevels to Targets | 5 | [`lessons/06-article-runlevels.md`](modules/02-linux-core-concepts/lessons/06-article-runlevels.md) |
| 12 | lesson | Linux File Types | 12 | [`lessons/07-file-types.md`](modules/02-linux-core-concepts/lessons/07-file-types.md) |
| 13 | quiz | Quiz: Linux File Types | 3 | [`quizzes/07-file-types.yaml`](modules/02-linux-core-concepts/quizzes/07-file-types.yaml) |
| 14 | lesson | The Filesystem Hierarchy | 11 | [`lessons/08-filesystem-hierarchy.md`](modules/02-linux-core-concepts/lessons/08-filesystem-hierarchy.md) |
| 15 | quiz | Quiz: The Filesystem Hierarchy | 3 | [`quizzes/08-filesystem-hierarchy.yaml`](modules/02-linux-core-concepts/quizzes/08-filesystem-hierarchy.yaml) |
| 16 | lab | Get to know bob-vm | 30 | [`labs/01-kernel-modules-boot-filetypes`](modules/02-linux-core-concepts/labs/01-kernel-modules-boot-filetypes) |

## 03-package-management — Package Management

Runtime: **docker** · Estimated time: **1h 48m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: Two families, one app | 2 | [`00-story.md`](modules/03-package-management/00-story.md) |
| 2 | lesson | Package Management Introduction | 10 | [`lessons/01-package-management-introduction.md`](modules/03-package-management/lessons/01-package-management-introduction.md) |
| 3 | quiz | Quiz: Package Management Introduction | 3 | [`quizzes/01-package-management-introduction.yaml`](modules/03-package-management/quizzes/01-package-management-introduction.yaml) |
| 4 | lesson | RPM and YUM/DNF | 11 | [`lessons/02-rpm-and-yum.md`](modules/03-package-management/lessons/02-rpm-and-yum.md) |
| 5 | quiz | Quiz: RPM and YUM/DNF | 3 | [`quizzes/02-rpm-and-yum.yaml`](modules/03-package-management/quizzes/02-rpm-and-yum.yaml) |
| 6 | lab | Prepare the Rocky reporting server | 30 | [`labs/01-yum-and-rpm`](modules/03-package-management/labs/01-yum-and-rpm) |
| 7 | lesson | DPKG and APT | 10 | [`lessons/03-dpkg-and-apt.md`](modules/03-package-management/lessons/03-dpkg-and-apt.md) |
| 8 | quiz | Quiz: DPKG and APT | 3 | [`quizzes/03-dpkg-and-apt.yaml`](modules/03-package-management/quizzes/03-dpkg-and-apt.yaml) |
| 9 | lesson | APT vs APT-GET | 8 | [`lessons/04-apt-vs-apt-get.md`](modules/03-package-management/lessons/04-apt-vs-apt-get.md) |
| 10 | quiz | Quiz: APT vs APT-GET | 3 | [`quizzes/04-apt-vs-apt-get.yaml`](modules/03-package-management/quizzes/04-apt-vs-apt-get.yaml) |
| 11 | lab | Install the vendor's notes tool on Ubuntu | 25 | [`labs/02-dpkg-and-apt`](modules/03-package-management/labs/02-dpkg-and-apt) |

## 04-shell-2 — Working with Shell II

Runtime: **docker** · Estimated time: **1h 59m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: Behind schedule | 2 | [`00-story.md`](modules/04-shell-2/00-story.md) |
| 2 | lesson | Behind Schedule: A Plan of Attack | 7 | [`lessons/01-behind-schedule.md`](modules/04-shell-2/lessons/01-behind-schedule.md) |
| 3 | lesson | File Compression and Archival | 12 | [`lessons/02-file-compression-and-archival.md`](modules/04-shell-2/lessons/02-file-compression-and-archival.md) |
| 4 | quiz | Quiz: File Compression and Archival | 3 | [`quizzes/02-file-compression-and-archival.yaml`](modules/04-shell-2/quizzes/02-file-compression-and-archival.yaml) |
| 5 | lesson | Searching for Files and Patterns | 13 | [`lessons/03-searching-for-files-and-patterns.md`](modules/04-shell-2/lessons/03-searching-for-files-and-patterns.md) |
| 6 | quiz | Quiz: Searching for Files and Patterns | 3 | [`quizzes/03-searching-for-files-and-patterns.yaml`](modules/04-shell-2/quizzes/03-searching-for-files-and-patterns.yaml) |
| 7 | lesson | IO Redirection | 12 | [`lessons/04-io-redirection.md`](modules/04-shell-2/lessons/04-io-redirection.md) |
| 8 | quiz | Quiz: IO Redirection | 3 | [`quizzes/04-io-redirection.yaml`](modules/04-shell-2/quizzes/04-io-redirection.yaml) |
| 9 | lab | Logs, reports and a noisy script | 30 | [`labs/01-shell-2`](modules/04-shell-2/labs/01-shell-2) |
| 10 | lesson | The VI Editor | 11 | [`lessons/05-vi-editor.md`](modules/04-shell-2/lessons/05-vi-editor.md) |
| 11 | quiz | Quiz: The VI Editor | 3 | [`quizzes/05-vi-editor.yaml`](modules/04-shell-2/quizzes/05-vi-editor.yaml) |
| 12 | lab | Fix the Mercury config with vi | 20 | [`labs/02-vi-editor`](modules/04-shell-2/labs/02-vi-editor) |

## 05-networking — Networking

Runtime: **docker** · Estimated time: **2h 01m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: The network issue | 2 | [`00-story.md`](modules/05-networking/00-story.md) |
| 2 | lesson | The Network Issue: Meet the Lab Network | 5 | [`lessons/01-the-network-issue.md`](modules/05-networking/lessons/01-the-network-issue.md) |
| 3 | lesson | DNS and Name Resolution | 12 | [`lessons/02-dns.md`](modules/05-networking/lessons/02-dns.md) |
| 4 | quiz | Quiz: DNS and Name Resolution | 3 | [`quizzes/02-dns.yaml`](modules/05-networking/quizzes/02-dns.yaml) |
| 5 | lab | Teach the client to find the database | 20 | [`labs/01-dns`](modules/05-networking/labs/01-dns) |
| 6 | lesson | Networking Basics | 13 | [`lessons/03-networking-basics.md`](modules/05-networking/lessons/03-networking-basics.md) |
| 7 | quiz | Quiz: Networking Basics | 3 | [`quizzes/03-networking-basics.yaml`](modules/05-networking/quizzes/03-networking-basics.yaml) |
| 8 | lab | Route the client to the backend | 20 | [`labs/02-network-basics`](modules/05-networking/labs/02-network-basics) |
| 9 | lesson | Network Troubleshooting | 15 | [`lessons/04-troubleshooting.md`](modules/05-networking/lessons/04-troubleshooting.md) |
| 10 | quiz | Quiz: Network Troubleshooting | 3 | [`quizzes/04-troubleshooting.yaml`](modules/05-networking/quizzes/04-troubleshooting.yaml) |
| 11 | lab | The web server that nobody can reach | 25 | [`labs/03-troubleshooting`](modules/05-networking/labs/03-troubleshooting) |

## 06-security-and-permissions — Security and File Permissions

Runtime: **docker** · Estimated time: **4h 06m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: Security incident | 2 | [`00-story.md`](modules/06-security-and-permissions/00-story.md) |
| 2 | lesson | Security Incident: Layers of Defence | 5 | [`lessons/01-security-incident.md`](modules/06-security-and-permissions/lessons/01-security-incident.md) |
| 3 | lesson | Linux Accounts | 10 | [`lessons/02-linux-accounts.md`](modules/06-security-and-permissions/lessons/02-linux-accounts.md) |
| 4 | quiz | Quiz: Linux Accounts | 3 | [`quizzes/02-linux-accounts.yaml`](modules/06-security-and-permissions/quizzes/02-linux-accounts.yaml) |
| 5 | lesson | Access Control Files | 11 | [`lessons/03-access-control-files.md`](modules/06-security-and-permissions/lessons/03-access-control-files.md) |
| 6 | quiz | Quiz: Access Control Files | 3 | [`quizzes/03-access-control-files.yaml`](modules/06-security-and-permissions/quizzes/03-access-control-files.yaml) |
| 7 | lesson | User Management | 12 | [`lessons/04-user-management.md`](modules/06-security-and-permissions/lessons/04-user-management.md) |
| 8 | quiz | Quiz: User Management | 3 | [`quizzes/04-user-management.yaml`](modules/06-security-and-permissions/quizzes/04-user-management.yaml) |
| 9 | lab | Rebuild the accounts on devbox | 25 | [`labs/01-account-management`](modules/06-security-and-permissions/labs/01-account-management) |
| 10 | lesson | File Permissions and Ownership | 14 | [`lessons/05-file-permissions-and-ownership.md`](modules/06-security-and-permissions/lessons/05-file-permissions-and-ownership.md) |
| 11 | quiz | Quiz: File Permissions and Ownership | 3 | [`quizzes/05-file-permissions-and-ownership.yaml`](modules/06-security-and-permissions/quizzes/05-file-permissions-and-ownership.yaml) |
| 12 | lab | Lock down the Mercury project tree | 25 | [`labs/02-permissions-and-ownership`](modules/06-security-and-permissions/labs/02-permissions-and-ownership) |
| 13 | lesson | SSH and SCP | 14 | [`lessons/06-ssh-and-scp.md`](modules/06-security-and-permissions/lessons/06-ssh-and-scp.md) |
| 14 | quiz | Quiz: SSH and SCP | 3 | [`quizzes/06-ssh-and-scp.yaml`](modules/06-security-and-permissions/quizzes/06-ssh-and-scp.yaml) |
| 15 | lab | Keys, not passwords | 20 | [`labs/03-ssh-and-scp`](modules/06-security-and-permissions/labs/03-ssh-and-scp) |
| 16 | lesson | IPTABLES Introduction | 11 | [`lessons/07-iptables-introduction.md`](modules/06-security-and-permissions/lessons/07-iptables-introduction.md) |
| 17 | quiz | Quiz: IPTABLES Introduction | 3 | [`quizzes/07-iptables-introduction.yaml`](modules/06-security-and-permissions/quizzes/07-iptables-introduction.yaml) |
| 18 | lesson | IPTABLES: Securing the Environment | 11 | [`lessons/08-iptables-securing-the-environment.md`](modules/06-security-and-permissions/lessons/08-iptables-securing-the-environment.md) |
| 19 | quiz | Quiz: IPTABLES — Securing the Environment | 3 | [`quizzes/08-iptables-securing-the-environment.yaml`](modules/06-security-and-permissions/quizzes/08-iptables-securing-the-environment.yaml) |
| 20 | lab | Firewall app01 and db01 | 35 | [`labs/04-iptables`](modules/06-security-and-permissions/labs/04-iptables) |
| 21 | lesson | Cron Jobs | 12 | [`lessons/09-cronjobs.md`](modules/06-security-and-permissions/lessons/09-cronjobs.md) |
| 22 | quiz | Quiz: Cron Jobs | 3 | [`quizzes/09-cronjobs.yaml`](modules/06-security-and-permissions/quizzes/09-cronjobs.yaml) |
| 23 | lab | Schedule the nightly clean-up | 15 | [`labs/05-cronjob`](modules/06-security-and-permissions/labs/05-cronjob) |

## 07-systemd — Service Management with systemd

Runtime: **vm** · Estimated time: **1h 07m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: Working overtime | 2 | [`00-story.md`](modules/07-systemd/00-story.md) |
| 2 | lesson | Working Overtime: Why Services Need a Manager | 6 | [`lessons/01-working-overtime.md`](modules/07-systemd/lessons/01-working-overtime.md) |
| 3 | lesson | Creating a systemd Service | 12 | [`lessons/02-creating-a-systemd-service.md`](modules/07-systemd/lessons/02-creating-a-systemd-service.md) |
| 4 | quiz | Quiz: Creating a systemd Service | 3 | [`quizzes/02-creating-a-systemd-service.yaml`](modules/07-systemd/quizzes/02-creating-a-systemd-service.yaml) |
| 5 | lesson | systemd Tools | 11 | [`lessons/03-systemd-tools.md`](modules/07-systemd/lessons/03-systemd-tools.md) |
| 6 | quiz | Quiz: systemd Tools | 3 | [`quizzes/03-systemd-tools.yaml`](modules/07-systemd/quizzes/03-systemd-tools.yaml) |
| 7 | lab | Make Project Mercury a real service | 30 | [`labs/01-systemd-services`](modules/07-systemd/labs/01-systemd-services) |

## 08-storage — Storage in Linux

Runtime: **vm** · Estimated time: **2h 47m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: Where is my storage? | 2 | [`00-story.md`](modules/08-storage/00-story.md) |
| 2 | lesson | Where Is My Storage? From Disk to Directory | 5 | [`lessons/01-where-is-my-storage.md`](modules/08-storage/lessons/01-where-is-my-storage.md) |
| 3 | lesson | Disk Partitions | 10 | [`lessons/02-disk-partitions.md`](modules/08-storage/lessons/02-disk-partitions.md) |
| 4 | quiz | Quiz: Disk Partitions | 3 | [`quizzes/02-disk-partitions.yaml`](modules/08-storage/quizzes/02-disk-partitions.yaml) |
| 5 | lab | Partition the first new disk | 20 | [`labs/01-partitions`](modules/08-storage/labs/01-partitions) |
| 6 | lesson | File Systems in Linux | 11 | [`lessons/03-file-systems.md`](modules/08-storage/lessons/03-file-systems.md) |
| 7 | quiz | Quiz: File Systems in Linux | 3 | [`quizzes/03-file-systems.yaml`](modules/08-storage/quizzes/03-file-systems.yaml) |
| 8 | lab | A persistent data filesystem | 20 | [`labs/02-filesystems`](modules/08-storage/labs/02-filesystems) |
| 9 | lesson | DAS, NAS and SAN | 9 | [`lessons/04-das-nas-san.md`](modules/08-storage/lessons/04-das-nas-san.md) |
| 10 | quiz | Quiz: DAS, NAS and SAN | 3 | [`quizzes/04-das-nas-san.yaml`](modules/08-storage/quizzes/04-das-nas-san.yaml) |
| 11 | lesson | The NFS Filesystem | 9 | [`lessons/05-nfs.md`](modules/08-storage/lessons/05-nfs.md) |
| 12 | quiz | Quiz: The NFS Filesystem | 3 | [`quizzes/05-nfs.yaml`](modules/08-storage/quizzes/05-nfs.yaml) |
| 13 | lesson | LVM — Logical Volume Manager | 11 | [`lessons/06-lvm.md`](modules/08-storage/lessons/06-lvm.md) |
| 14 | quiz | Quiz: LVM | 3 | [`quizzes/06-lvm.yaml`](modules/08-storage/quizzes/06-lvm.yaml) |
| 15 | lab | A growable media volume with LVM | 25 | [`labs/03-lvm`](modules/08-storage/labs/03-lvm) |
| 16 | lab | Optional: share reports over NFS | 25 | [`labs/04-nfs`](modules/08-storage/labs/04-nfs) |
| 17 | lesson | Project Status Meeting | 5 | [`lessons/07-project-status-meeting.md`](modules/08-storage/lessons/07-project-status-meeting.md) |

## 09-client-demo — The Client Demonstration

Runtime: **docker** · Estimated time: **1h 24m**

| # | Type | Title | Minutes | Path |
|---|---|---|---|---|
| 1 | story | Story: Client demonstration in jeopardy! | 2 | [`00-story.md`](modules/09-client-demo/00-story.md) |
| 2 | lesson | Client Demonstration in Jeopardy | 5 | [`lessons/01-client-demo-in-jeopardy.md`](modules/09-client-demo/lessons/01-client-demo-in-jeopardy.md) |
| 3 | lesson | A Troubleshooting Playbook | 9 | [`lessons/02-troubleshooting-playbook.md`](modules/09-client-demo/lessons/02-troubleshooting-playbook.md) |
| 4 | quiz | Quiz: A Troubleshooting Playbook | 3 | [`quizzes/02-troubleshooting-playbook.yaml`](modules/09-client-demo/quizzes/02-troubleshooting-playbook.yaml) |
| 5 | lab | Finale: save the client demonstration | 60 | [`labs/01-final-troubleshooting`](modules/09-client-demo/labs/01-final-troubleshooting) |
| 6 | lesson | Finale | 5 | [`lessons/03-finale.md`](modules/09-client-demo/lessons/03-finale.md) |
