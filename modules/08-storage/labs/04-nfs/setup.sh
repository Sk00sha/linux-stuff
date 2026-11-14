#!/usr/bin/env bash
# Prepare lab 08-storage/nfs (two VMs).
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=08-storage/nfs

require_vm bob-vm
require_vm nfs-server
say "resetting the NFS server"
on nfs-server <<'SCRIPT'
set -e
sed -i '\#^/srv/share[[:space:]]#d' /etc/exports
mkdir -p /srv/share
rm -f /srv/share/hello-from-bob.txt
echo "Shared from nfs-server — reports land here." > /srv/share/README.txt
chown -R bob:bob /srv/share
exportfs -ra
systemctl enable --now nfs-server >/dev/null 2>&1 || systemctl enable --now nfs-kernel-server >/dev/null 2>&1
SCRIPT
say "resetting the client"
on bob-vm <<'SCRIPT'
set -e
umount -q -f /mnt/share 2>/dev/null || true
sed -i '\#[[:space:]]/mnt/share[[:space:]]#d' /etc/fstab
systemctl daemon-reload
rm -rf /mnt/share
SCRIPT
mark_lab bob-vm "$LAB"
mark_lab nfs-server "$LAB"
say "done"
