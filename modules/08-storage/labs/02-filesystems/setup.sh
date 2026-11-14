#!/usr/bin/env bash
# Prepare lab 08-storage/filesystems: disk-a has one 500 MiB partition, no filesystem.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
# shellcheck source=../common.sh
. "$(dirname "$0")/../common.sh"
LAB=08-storage/filesystems
H=${LAB_HOST:-bob-vm}

require_vm "$H"
say "preparing disk-a on $H"
on "$H" <<SCRIPT
set -e
$STORAGE_FUNCS
D=\$(disk disk-a)
umount -q /mnt/data 2>/dev/null || true
sed -i '\#[[:space:]]/mnt/data[[:space:]]#d' /etc/fstab
wipe_disk "\$D"
sgdisk -o "\$D" >/dev/null
sgdisk -n 1:0:+500M -t 1:8300 "\$D" >/dev/null
partprobe "\$D"; udevadm settle
P=\$(part1 "\$D")
wipefs -qa "\$P"
rm -rf /mnt/data
systemctl daemon-reload
echo "disk-a partition: \$P"
SCRIPT
mark_lab "$H" "$LAB"
say "done"
