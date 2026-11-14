#!/usr/bin/env bash
# Grader for 07-systemd/systemd-services. Read-only except t6, which (as the
# task says) kills the service's main process to test automatic restarts.
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=07-systemd/systemd-services
H=${LAB_HOST:-bob-vm}
U=project-mercury.service

require_lab "$H" "$LAB"

prop() { run_on "$H" "systemctl show $U -p $1 --value 2>/dev/null"; }

check_t1() {
  require t1 assert_file "$H" /etc/systemd/system/$U || return
  [ "$(prop LoadState)" = loaded ] || { fail t1 "systemd hasn't loaded the unit (LoadState=$(prop LoadState)) — did you run daemon-reload?"; return; }
  run_on "$H" "systemctl show $U -p ExecStart | grep -q 'path=/usr/bin/project-mercury.sh'" ||
    { fail t1 "ExecStart does not run /usr/bin/project-mercury.sh ($(prop ExecStart | cut -c1-80))"; return; }
  if run_on "$H" "systemctl show $U -p NeedDaemonReload --value | grep -q yes"; then
    fail t1 "the unit file changed on disk since it was loaded — run sudo systemctl daemon-reload"; return
  fi
  pass t1
}

check_t2() {
  local u
  u=$(prop User)
  [ "$u" = mercury ] && pass t2 || fail t2 "User= is '${u:-not set (root)}'"
}

check_t3() {
  local r s
  r=$(prop Restart); s=$(prop RestartUSec)
  [ "$r" = on-failure ] || [ "$r" = always ] || { fail t3 "Restart= is '$r'"; return; }
  [ "$s" = 10s ] && pass t3 || fail t3 "RestartSec is $s, expected 10s"
}

check_t4() {
  local a
  a=$(prop After)
  printf '%s' "$a" | tr ' ' '\n' | grep -qxE 'network(-online)?\.target' || { fail t4 "After= does not include network.target"; return; }
  printf '%s' "$a" | tr ' ' '\n' | grep -qx postgresql.service || { fail t4 "After= does not include postgresql.service"; return; }
  pass t4
}

check_t5() {
  local e a
  e=$(run_on "$H" "systemctl is-enabled $U 2>/dev/null"); a=$(run_on "$H" "systemctl is-active $U 2>/dev/null")
  [ "$e" = enabled ] || { fail t5 "is-enabled reports '$e'"; return; }
  [ "$a" = active ] || { fail t5 "is-active reports '$a'"; return; }
  run_on "$H" "ps -o user= -p \$(systemctl show $U -p MainPID --value) | grep -q mercury" ||
    { fail t5 "the running process is not owned by mercury"; return; }
  pass t5
}

check_t6() {
  local before after
  [ "$(run_on "$H" "systemctl is-active $U")" = active ] || { fail t6 "service is not running, nothing to test"; return; }
  before=$(prop MainPID)
  run_on "$H" "kill -9 $before"
  for _ in $(seq 1 20); do
    sleep 1
    after=$(prop MainPID)
    if [ "$(run_on "$H" "systemctl is-active $U")" = active ] && [ "$after" != 0 ] && [ "$after" != "$before" ]; then
      pass t6; return
    fi
  done
  fail t6 "after killing PID $before, the service was not restarted within 20 seconds"
}

run_tasks t1 t2 t3 t4 t5 t6
