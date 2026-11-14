#!/usr/bin/env bash
# Grader for 06-security-and-permissions/iptables (read-only: only probes).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=06-security-and-permissions/iptables
DEVBOX=10.10.2.10 APP01=10.10.2.30 DB01=10.10.2.20

for h in devbox app01 db01; do require_lab "$h" "$LAB"; done

# probe FROM-host TO-ip PORT : prints open/closed
probe() { run_on "$1" "nc -z -w 2 $2 $3 >/dev/null 2>&1" && echo open || echo closed; }

check_t1() {
  [ "$(probe devbox $APP01 22)" = open ] || { fail t1 "SSH to app01 from devbox is blocked; it must stay open"; return; }
  [ "$(probe db01 $APP01 22)" = closed ] || { fail t1 "SSH to app01 from db01 is reachable; only devbox may connect"; return; }
  pass t1
}

check_t2() {
  local h
  for h in devbox db01; do
    [ "$(probe $h $APP01 80)" = open ] || { fail t2 "HTTP (80) on app01 is not reachable from $h"; return; }
  done
  pass t2
}

check_t3() {
  local h
  for h in devbox db01; do
    [ "$(probe $h $APP01 8080)" = closed ] || { fail t3 "port 8080 on app01 is reachable from $h; expected it to be blocked"; return; }
  done
  run_on app01 "iptables -S INPUT | grep -q '^-P INPUT DROP' || iptables -S INPUT | grep -qE '^-A INPUT .*-j (DROP|REJECT)\$'" ||
    { fail t3 "app01's INPUT chain neither has a DROP policy nor a final catch-all DROP/REJECT rule"; return; }
  [ "$(probe app01 $DB01 5432)" = open ] ||
    { fail t3 "app01 can no longer connect to db01:5432 — replies to app01's own connections are being dropped (or db01 blocks app01)"; return; }
  pass t3
}

check_t4() {
  [ "$(probe app01 $DB01 5432)" = open ] || { fail t4 "db01:5432 is not reachable from app01"; return; }
  [ "$(probe devbox $DB01 5432)" = closed ] || { fail t4 "db01:5432 is reachable from devbox; only app01 may connect"; return; }
  pass t4
}

check_t5() {
  [ "$(probe devbox $DB01 22)" = open ] || { fail t5 "SSH to db01 from devbox is blocked; it must stay open"; return; }
  [ "$(probe app01 $DB01 22)" = closed ] || { fail t5 "SSH to db01 from app01 is reachable; only devbox may connect"; return; }
  run_on db01 "iptables -S INPUT | grep -q '^-P INPUT DROP' || iptables -S INPUT | grep -qE '^-A INPUT .*-j (DROP|REJECT)\$'" ||
    { fail t5 "db01's INPUT chain neither has a DROP policy nor a final catch-all DROP/REJECT rule"; return; }
  pass t5
}

run_tasks t1 t2 t3 t4 t5
