#!/usr/bin/env bash
# Grader for 06-security-and-permissions/account-management (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=06-security-and-permissions/account-management
H=devbox

require_lab "$H" "$LAB"

check_t1() {
  local pw
  pw=$(run_on "$H" "getent passwd bob")
  [ -n "$pw" ] || { fail t1 "there is no user bob"; return; }
  IFS=: read -r _ _ uid _ _ home shell <<<"$pw"
  [ "$uid" = 2000 ] || { fail t1 "bob has UID $uid"; return; }
  [ "$shell" = /bin/bash ] || { fail t1 "bob's shell is $shell"; return; }
  [ "$home" = /home/bob ] || { fail t1 "bob's home is $home"; return; }
  require t1 assert_dir "$H" /home/bob || return
  run_on "$H" "[ \"\$(stat -c %u /home/bob)\" = 2000 ]" || { fail t1 "/home/bob is not owned by bob"; return; }
  pass t1
}

check_t2() {
  run_on "$H" "getent group devops >/dev/null" || { fail t2 "group devops does not exist"; return; }
  run_on "$H" "id -nG bob 2>/dev/null | tr ' ' '\n' | grep -qx devops" || { fail t2 "bob is not a member of devops"; return; }
  pass t2
}

check_t3() {
  local f=/etc/sudoers.d/devops rules
  require t3 assert_file "$H" "$f" || return
  run_on "$H" "visudo -cqf $f" || { fail t3 "$f has a syntax error (visudo -cf $f)"; return; }
  require t3 assert_mode "$H" "$f" 440 || return
  require t3 assert_contains "$H" "$f" '^[[:space:]]*%devops[[:space:]]' || return
  rules=$(run_on "$H" "sudo -l -U bob 2>/dev/null | sed -n '/may run the following/,\$p' | tail -n +2")
  printf '%s' "$rules" | grep -Eq 'NOPASSWD: */usr/bin/systemctl *$' ||
    { fail t3 "sudo -l -U bob does not show 'NOPASSWD: /usr/bin/systemctl' (it shows: $(echo "$rules" | tr -s ' ' | tr '\n' ';'))"; return; }
  if printf '%s' "$rules" | grep -Eq '(\) |: )ALL *$|, *ALL'; then
    fail t3 "bob may run ALL commands via sudo; only /usr/bin/systemctl should be allowed"; return
  fi
  pass t3
}

check_t4() {
  local s
  s=$(run_on "$H" "passwd -S intruder | awk '{print \$2}'")
  [ "$s" = L ] && pass t4 || fail t4 "passwd -S intruder reports status '$s' (L means locked)"
}

check_t5() {
  run_on "$H" "id -nG intruder | tr ' ' '\n' | grep -qx sudo" && fail t5 "intruder is still in the sudo group" || pass t5
}

run_tasks t1 t2 t3 t4 t5
