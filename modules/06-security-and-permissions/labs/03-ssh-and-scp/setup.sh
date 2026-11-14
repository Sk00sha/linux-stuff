#!/usr/bin/env bash
# Prepare lab 06-security-and-permissions/ssh-and-scp.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=06-security-and-permissions/ssh-and-scp

require_services devbox app01
standard_bob devbox
standard_bob app01
say "removing keys and preparing the code archive"
on devbox <<'SCRIPT'
set -e
rm -rf /home/bob/.ssh /home/bob/caleston-code /home/bob/caleston-code.tar.gz
mkdir -p /home/bob/caleston-code/src
for f in api.py worker.py models.py; do echo "# Mercury $f" > /home/bob/caleston-code/src/$f; done
echo "Mercury release 2.4.1" > /home/bob/caleston-code/RELEASE
tar -C /home/bob -czf /home/bob/caleston-code.tar.gz caleston-code
touch -d '2026-11-01 09:30' /home/bob/caleston-code.tar.gz
rm -rf /home/bob/caleston-code
chown -R bob:bob /home/bob
SCRIPT
on app01 <<'SCRIPT'
set -e
rm -rf /home/bob/.ssh /opt/caleston-code.tar.gz
chgrp bob /opt && chmod 775 /opt
grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config || echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
SCRIPT
mark_lab devbox "$LAB"
mark_lab app01 "$LAB"
say "done"
