#!/usr/bin/env bash
# Prepare lab 06-security-and-permissions/iptables: open firewalls everywhere.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=06-security-and-permissions/iptables

require_services devbox app01 db01
for h in devbox app01 db01; do
  standard_bob "$h"
  say "flushing the firewall on $h"
  run_on "$h" "iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT; iptables -F; iptables -X 2>/dev/null || true"
  mark_lab "$h" "$LAB"
done
# make sure the services the grader probes are listening
run_on app01 "pgrep -f 'course-listen 80\$' >/dev/null || (nohup course-listen 80 >/dev/null 2>&1 &); pgrep -f 'course-listen 8080' >/dev/null || (nohup course-listen 8080 >/dev/null 2>&1 &)"
run_on db01 "pgrep -f 'course-listen 5432' >/dev/null || (nohup course-listen 5432 >/dev/null 2>&1 &)"
say "done"
