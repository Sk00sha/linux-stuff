#!/usr/bin/env bash
# Grader for the finale. Read-only. t1 is the end-to-end result; t2-t9 give
# partial credit per area so the learner can see progress.
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=09-client-demo/final-troubleshooting
H=demo-web
U=mercury-web.service

require_lab "$H" "$LAB"
echo "(seed $(run_on "$H" "cat /etc/course-lab-seed 2>/dev/null"))"

check_t1() {
  local out code body
  out=$(run_on "$H" "curl -s -m 8 -w '\n%{http_code}' http://localhost/ 2>/dev/null")
  code=$(printf '%s' "$out" | tail -1); body=$(printf '%s' "$out" | sed '$d')
  if [ "$code" = 200 ] && [ "$body" = "Caleston demo: Caleston Mercury is live!" ]; then pass t1
  elif [ "$code" = 000 ] || [ -z "$code" ]; then fail t1 "the site is down: nothing answers on port 80"
  else fail t1 "the site answers HTTP $code: $(printf '%s' "$body" | head -c 160)"; fi
}

check_t2() {
  local exe
  exe=$(run_on "$H" "systemctl show $U -p ExecStart --value | sed -n 's/.*path=\([^ ;]*\).*/\1/p'")
  [ "$exe" = /usr/local/bin/mercury-web ] || { fail t2 "the unit starts '${exe:-nothing}', which is not the Mercury web program"; return; }
  [ "$(run_on "$H" "systemctl is-enabled $U 2>/dev/null")" = enabled ] || { fail t2 "the web service will not start at boot"; return; }
  [ "$(run_on "$H" "systemctl is-active $U 2>/dev/null")" = active ] || { fail t2 "the web service is not running ($(run_on "$H" "systemctl is-active $U"))"; return; }
  run_on "$H" "systemctl show $U -p NeedDaemonReload --value | grep -q no" || { fail t2 "the unit file changed on disk; systemd hasn't reloaded it"; return; }
  pass t2
}

check_t3() {
  local envs
  envs=$(run_on "$H" "systemctl show $U -p Environment --value")
  if printf '%s' "$envs" | grep -q 'PATH='; then
    printf '%s' "$envs" | tr ' ' '\n' | grep '^PATH=' | grep -Eq '(^PATH=|:)/usr/bin(:|$)' ||
      { fail t3 "the service's PATH does not contain the directory python3 lives in"; return; }
  fi
  pass t3
}

check_t4() {
  local f=/etc/mercury/app.conf
  run_on "$H" "sudo -u mercury test -r $f" || { fail t4 "the service user cannot read $f"; return; }
  run_on "$H" "[ \$(( 0\$(stat -c %a $f) & 4 )) -eq 0 ]" || { fail t4 "$f (which contains a password) is readable by everyone"; return; }
  run_on "$H" "[ \$(( 0\$(stat -c %a $f) & 2 )) -eq 0 ]" || { fail t4 "$f is writable by everyone"; return; }
  pass t4
}

check_t5() {
  local ip
  ip=$(run_on "$H" "getent hosts db01.caleston.local | awk '{print \$1; exit}'")
  [ "$ip" = 10.10.9.20 ] && pass t5 || fail t5 "db01.caleston.local resolves to '${ip:-nothing}' on the application server"
}

check_t6() {
  run_on "$H" "nc -z -w 3 10.10.9.20 5432" >/dev/null 2>&1 && pass t6 || fail t6 "the application server cannot open a connection to 10.10.9.20:5432"
}

check_t7() {
  local free
  free=$(run_on "$H" "df -k --output=avail /var/lib/mercury | tail -1 | tr -dc 0-9")
  [ "${free:-0}" -ge 512 ] || { fail t7 "/var/lib/mercury has only ${free:-0} KiB free"; return; }
  run_on "$H" "sudo -u mercury touch /var/lib/mercury/.grader-probe && rm -f /var/lib/mercury/.grader-probe" ||
    { fail t7 "the service user cannot write to /var/lib/mercury"; return; }
  pass t7
}

check_t8() {
  local line
  line=$(run_on "$H" "cat /etc/cron.d/* 2>/dev/null | grep -v '^[[:space:]]*#' | grep 'mercury-rotate'")
  [ -n "$line" ] || { fail t8 "no active cron job runs /usr/local/bin/mercury-rotate"; return; }
  [ "$(printf '%s' "$line" | awk '{print ((NF >= 7 && $6 == "root") ? 1 : 0)}' | head -1)" = 1 ] ||
    { fail t8 "the cron.d line must have 5 time fields, the user root, then the command: '$line'"; return; }
  [ "$(run_on "$H" "systemctl is-active cron")" = active ] || { fail t8 "the cron daemon is not running"; return; }
  pass t8
}

check_t9() {
  run_on "$H" "dpkg-query -W -f='\${Status}' python3-psycopg 2>/dev/null | grep -q 'install ok installed'" ||
    { fail t9 "a package the application imports is not installed"; return; }
  pass t9
}

run_tasks t1 t2 t3 t4 t5 t6 t7 t8 t9
