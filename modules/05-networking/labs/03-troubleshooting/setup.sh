#!/usr/bin/env bash
# Prepare lab 05-networking/troubleshooting: three faults across two machines.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
# shellcheck source=../common.sh
. "$(dirname "$0")/../common.sh"
LAB=05-networking/troubleshooting

require_services client web01
ensure_user client bob
ensure_user web01 bob
say "injecting faults"
reset_client_network
# fault 1: stale hosts entry with a typo in the address (.8 instead of .80)
run_on client "echo '10.10.1.8   web01   # old web server, migrated 2025' >> /etc/hosts"
# faults 2 and 3: wrong port, loopback-only bind address
on web01 <<'SCRIPT'
set -e
mkdir -p /etc/webapp
cat > /etc/webapp/webapp.conf <<'CONF'
# webapp configuration (read by webctl)
LISTEN_ADDR=127.0.0.1
LISTEN_PORT=8080
MESSAGE="Mercury demo: web01 OK"
CONF
webctl stop >/dev/null 2>&1 || true
pkill -f 'ThreadingHTTPServer' 2>/dev/null || true
rm -f /run/webapp.pid
webctl start
SCRIPT
mark_lab client "$LAB"
mark_lab web01 "$LAB"
say "done"
