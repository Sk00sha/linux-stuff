#!/usr/bin/env bash
# Prepare lab 02-linux-core-concepts/kernel-modules-boot-filetypes (VM only).
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=02-linux-core-concepts/kernel-modules-boot-filetypes
H=${LAB_HOST:-bob-vm}

require_vm "$H"
say "resetting kernel module, boot target and files on $H"
on "$H" <<'SCRIPT'
set -e
modprobe -r dummy 2>/dev/null || true
rm -f /etc/modules-load.d/dummy.conf
systemctl set-default graphical.target >/dev/null 2>&1
cd /home/bob
rm -rf kernel.txt types.txt latest-log filetypes
mkdir filetypes
echo "quarterly figures" > filetypes/disk-image      # regular file, misleading name
ln -s /etc/hostname filetypes/config.txt              # symbolic link
mkfifo filetypes/data.log                             # named pipe
mknod filetypes/terminal b 7 200                      # block device (loop minor 200)
cat > filetypes/README <<'TXT'
Classify each of these paths (write path:type lines into /home/bob/types.txt):
/home/bob/filetypes/disk-image
/home/bob/filetypes/config.txt
/home/bob/filetypes/data.log
/home/bob/filetypes/terminal
/dev/null
TXT
chown -R bob:bob /home/bob
SCRIPT
mark_lab "$H" "$LAB"
say "done"
