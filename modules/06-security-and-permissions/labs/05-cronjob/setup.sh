#!/usr/bin/env bash
# Prepare lab 06-security-and-permissions/cronjob.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=06-security-and-permissions/cronjob
H=devbox

require_services "$H"
standard_bob "$H"
say "preparing crontabs on $H"
on "$H" <<'SCRIPT'
set -e
mkdir -p /opt/scripts
cat > /opt/scripts/cleanup.sh <<'SH'
#!/bin/bash
# Remove temporary files older than a day from the shared directories.
echo "$(date '+%F %T') cleanup starting"
find /tmp /srv/shared -maxdepth 2 -name '*.tmp' -mtime +1 -print -delete 2>&1
echo "$(date '+%F %T') cleanup done"
SH
chmod 755 /opt/scripts/cleanup.sh
crontab -r -u bob 2>/dev/null || true
rm -f /home/bob/cleanup.log
printf '%s\n' \
  '# root crontab (devbox)' \
  'MAILTO=""' \
  '30 4 * * * /usr/bin/apt-get -qq clean' \
  '* * * * * /opt/scripts/cleanup.sh' | crontab -u root -
pgrep -x cron >/dev/null || cron
SCRIPT
mark_lab "$H" "$LAB"
say "done"
