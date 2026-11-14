#!/usr/bin/env bash
# Prepare lab 01-shell-1/bash-prompt.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=01-shell-1/bash-prompt
H=ubuntu

require_services "$H"
ensure_user "$H" bob
say "resetting bob's shell configuration on $H"
on "$H" <<'SCRIPT'
set -e
# default startup files, minus the stock ls aliases
grep -vE "^\s*alias (ll|la|l)=" /etc/skel/.bashrc > /home/bob/.bashrc
cp /etc/skel/.profile /home/bob/.profile
rm -f /home/bob/.bash_aliases
chown bob:bob /home/bob/.bashrc /home/bob/.profile
mkdir -p /opt/tools/bin
cat > /opt/tools/bin/mercury-status <<'TOOL'
#!/bin/bash
echo "mercury: all systems nominal (demo in $(( ( $(date -d 2026-12-05 +%s) - $(date +%s) ) / 86400 )) days)"
TOOL
chmod 755 /opt/tools/bin/mercury-status
SCRIPT
mark_lab "$H" "$LAB"
say "done"
