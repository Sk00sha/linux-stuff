#!/usr/bin/env bash
# Prepare lab 08-storage/partitions: disk-a completely blank. VM only.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
# shellcheck source=../common.sh
. "$(dirname "$0")/../common.sh"
LAB=08-storage/partitions
H=${LAB_HOST:-bob-vm}

require_vm "$H"
say "wiping practice disk disk-a on $H"
on "$H" <<SCRIPT
set -e
$STORAGE_FUNCS
D=\$(disk disk-a)
[ -b "\$D" ] || { echo "practice disk disk-a not found" >&2; exit 1; }
umount -q /mnt/data 2>/dev/null || true
sed -i '\#[[:space:]]/mnt/data[[:space:]]#d' /etc/fstab
wipe_disk "\$D"
rm -f /home/bob/partition.txt
SCRIPT
mark_lab "$H" "$LAB"
say "done"
