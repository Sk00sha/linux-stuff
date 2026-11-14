#!/usr/bin/env bash
# Prepare lab 04-shell-2/shell-2.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=04-shell-2/shell-2
H=ubuntu

require_services "$H"
ensure_user "$H" bob
say "creating reports, logs and the start script on $H"
on "$H" <<'SCRIPT'
set -e
rm -rf /var/app /home/bob/reports /home/bob/reports.tar.gz /home/bob/biglogs.txt \
       /home/bob/errors.txt /home/bob/start.out /home/bob/start.err /opt/mercury
# reports
mkdir -p /home/bob/reports/archive
for d in $(seq -w 1 12); do
  seq 1 500 | awk -v d="$d" '{print "2026-11-" d "," $1 "," ($1*7)%101}' > /home/bob/reports/sales-2026-11-$d.csv
done
echo "summary for October" > /home/bob/reports/archive/october-summary.txt
chown -R bob:bob /home/bob/reports

# logs: sizes in KiB; names chosen to include decoys
mk() { mkdir -p "$(dirname "$1")"; head -c "$(( $2 * 1024 ))" /dev/urandom | base64 -w 120 | head -c "$(( $2 * 1024 ))" > "$1"; }
mk /var/app/web/access.log 3072
mk /var/app/web/error.log 200
mk /var/app/batch/2026/11/reports.log 1536
mk /var/app/batch/2026/11/reports.log.1 2048     # big, but not *.log
mk /var/app/cache/debug.log 1000                  # just under 1 MiB
mk /var/app/cache/blob.bin 4096                   # big, not a log
mk /var/app/archive/old-logs/payments.log 1100
mk /var/app/restricted/audit.log 2048             # not readable by bob
chmod 700 /var/app/restricted
cat > /var/app/app.log <<'LOG'
2026-11-14 08:00:01 INFO  mercury starting, version 2.4.1
2026-11-14 08:00:02 INFO  connecting to db01:5432
2026-11-14 08:00:07 ERROR connection to db01:5432 timed out
2026-11-14 08:00:07 WARN  retrying in 5s
2026-11-14 08:00:12 Error authentication failed for user mercury
2026-11-14 08:00:13 INFO  falling back to read-only mode
2026-11-14 08:01:00 INFO  request /api/orders 200
2026-11-14 08:01:04 error: disk quota exceeded writing /var/lib/mercury/cache
2026-11-14 08:01:05 INFO  cache disabled
2026-11-14 08:02:30 INFO  terrorist-filter module loaded
2026-11-14 08:03:00 INFO  request /api/health 200
LOG
chmod 644 /var/app/app.log

# a script that writes to both streams
mkdir -p /opt/mercury
cat > /opt/mercury/start.sh <<'SH'
#!/bin/bash
echo "mercury: loading configuration"
echo "mercury: WARNING config value cache_size missing, using default" >&2
echo "mercury: starting 4 workers"
echo "mercury: ERROR worker 3 failed to bind port 9003" >&2
echo "mercury: ready"
SH
chmod 755 /opt/mercury/start.sh
SCRIPT
mark_lab "$H" "$LAB"
say "done"
