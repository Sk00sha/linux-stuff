#!/usr/bin/env bash
# Grader for 03-package-management/yum-and-rpm (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=03-package-management/yum-and-rpm
H=rocky

require_lab "$H" "$LAB"

installed() { run_on "$H" "rpm -q $1 >/dev/null 2>&1"; }

check_t1() {
  local want got
  require t1 assert_file "$H" /home/bob/wget-owner.txt || return
  want=$(run_on "$H" "rpm -qf --qf '%{NAME}' /usr/bin/wget")
  got=$(run_on "$H" "tr -d '[:space:]' < /home/bob/wget-owner.txt")
  [ "$got" = "$want" ] && pass t1 || fail t1 "wget-owner.txt contains '$got'; rpm disagrees"
}

check_t2() {
  local p missing=""
  for p in httpd tree; do installed "$p" || missing+=" $p"; done
  [ -z "$missing" ] && pass t2 || fail t2 "not installed:$missing"
}

check_t3() {
  installed telnet && fail t3 "rpm -q telnet says it is still installed" || pass t3
}

check_t4() {
  local f=/etc/yum.repos.d/local.repo
  require t4 assert_file "$H" "$f" || return
  require t4 assert_contains "$H" "$f" '^\[local\][[:space:]]*$' || return
  require t4 assert_contains "$H" "$f" '^baseurl[[:space:]]*=[[:space:]]*file:///opt/localrepo/?[[:space:]]*$' || return
  if run_on "$H" "grep -Eq '^enabled[[:space:]]*=[[:space:]]*0' $f"; then
    fail t4 "$f sets enabled=0"; return
  fi
  if ! run_on "$H" "dnf -q --disablerepo='*' --enablerepo=local repoinfo local 2>/dev/null | grep -q enabled"; then
    fail t4 "dnf cannot read the 'local' repository (check baseurl and gpgcheck)"; return
  fi
  pass t4
}

check_t5() {
  installed bob-tool || { fail t5 "bob-tool is not installed"; return; }
  local repo
  repo=$(run_on "$H" "dnf -q list installed bob-tool 2>/dev/null | awk '/bob-tool/{print \$3}'")
  case "$repo" in
    @local|local) pass t5 ;;
    *) fail t5 "bob-tool was installed from '${repo:-unknown}', not from the local repository" ;;
  esac
}

run_tasks t1 t2 t3 t4 t5
