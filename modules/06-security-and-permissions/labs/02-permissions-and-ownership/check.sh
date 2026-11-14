#!/usr/bin/env bash
# Grader for 06-security-and-permissions/permissions-and-ownership (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=06-security-and-permissions/permissions-and-ownership
H=devbox
A=/srv/mercury/app

require_lab "$H" "$LAB"

check_t1() {
  local wrong
  wrong=$(run_on "$H" "find $A \\( ! -user bob -o ! -group devops \\) -printf '%p (%u:%g)\n' | head -3")
  [ -z "$wrong" ] && pass t1 || fail t1 "not owned by bob:devops: $(echo "$wrong" | tr '\n' ' ')"
}

check_t2() { require t2 assert_mode "$H" "$A/config/db.conf" 640 && pass t2; }
check_t3() { require t3 assert_mode "$H" "$A/bin/deploy.sh" 750 && pass t3; }
check_t4() { require t4 assert_mode "$H" "$A" 2770 && pass t4; }
check_t5() { require t5 assert_mode "$H" /srv/shared 1777 && pass t5; }

check_t6() {
  local ww
  ww=$(run_on "$H" "find /srv/mercury -perm -o+w | head -3")
  [ -z "$ww" ] && pass t6 || fail t6 "still writable by others: $(echo "$ww" | tr '\n' ' ')"
}

run_tasks t1 t2 t3 t4 t5 t6
