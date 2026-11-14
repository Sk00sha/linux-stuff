#!/usr/bin/env bash
# Prepare lab 08-storage/lvm: disk-b and disk-c blank, no caleston_vg.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
# shellcheck source=../common.sh
. "$(dirname "$0")/../common.sh"
LAB=08-storage/lvm
H=${LAB_HOST:-bob-vm}

require_vm "$H"
say "removing caleston_vg and wiping disk-b, disk-c on $H"
on "$H" <<SCRIPT
set -e
$STORAGE_FUNCS
umount -q /mnt/media 2>/dev/null || true
sed -i '\#[[:space:]]/mnt/media[[:space:]]#d' /etc/fstab
if vgs caleston_vg >/dev/null 2>&1; then
  lvremove -qq -y caleston_vg >/dev/null 2>&1 || true
  vgremove -qq -y caleston_vg >/dev/null 2>&1 || true
fi
for n in disk-b disk-c; do
  D=\$(disk \$n)
  pvremove -qq -y -ff "\$D" >/dev/null 2>&1 || true
  wipe_disk "\$D"
done
rm -rf /mnt/media
systemctl daemon-reload
SCRIPT
mark_lab "$H" "$LAB"
say "done"
