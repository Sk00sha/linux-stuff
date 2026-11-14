#!/usr/bin/env bash
# Prepare lab 07-systemd/systemd-services (VM, or the systemd container).
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=07-systemd/systemd-services
H=${LAB_HOST:-bob-vm}

if [ "$COURSE_RUNTIME" = vm ]; then require_vm "$H"; else require_services "$H"; fi
standard_bob "$H"
say "preparing the mercury worker and a stand-in postgresql.service on $H"
on "$H" <<'SCRIPT'
set -e
for i in $(seq 30); do systemctl is-system-running 2>/dev/null | grep -qE 'running|degraded' && break; sleep 1; done
systemctl disable --now project-mercury.service >/dev/null 2>&1 || true
rm -rf /etc/systemd/system/project-mercury.service /etc/systemd/system/project-mercury.service.d
id mercury >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin mercury
cat > /usr/bin/project-mercury.sh <<'SH'
#!/bin/bash
# Project Mercury reporting worker (course stand-in).
echo "mercury worker starting as $(whoami), pid $$"
n=0
while true; do
  n=$((n + 1))
  echo "mercury: processed batch $n"
  sleep 5
done
SH
chmod 755 /usr/bin/project-mercury.sh
if [ ! -f /usr/lib/systemd/system/postgresql.service ]; then
  cat > /etc/systemd/system/postgresql.service <<'UNIT'
[Unit]
Description=PostgreSQL stand-in for the course labs
After=network.target

[Service]
Type=simple
ExecStart=/bin/sleep infinity

[Install]
WantedBy=multi-user.target
UNIT
fi
systemctl daemon-reload
systemctl enable --now postgresql.service >/dev/null 2>&1
pkill -f /usr/bin/project-mercury.sh 2>/dev/null || true
SCRIPT
mark_lab "$H" "$LAB"
say "done"
