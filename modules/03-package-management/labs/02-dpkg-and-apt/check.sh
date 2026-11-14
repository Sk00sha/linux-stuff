#!/usr/bin/env bash
# Grader for 03-package-management/dpkg-and-apt (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=03-package-management/dpkg-and-apt
H=ubuntu

require_lab "$H" "$LAB"

status() { run_on "$H" "dpkg-query -W -f='\${Status}' $1 2>/dev/null"; }

check_t1() {
  local s
  s=$(status bob-notes)
  if [ -z "$s" ] || [ "$s" = "unknown ok not-installed" ]; then
    fail t1 "dpkg knows nothing about bob-notes yet"; return
  fi
  pass t1
}

check_t2() {
  local s
  s=$(status bob-notes)
  [ "$s" = "install ok installed" ] || { fail t2 "bob-notes status is '${s:-not installed}', expected 'install ok installed'"; return; }
  [ "$(status figlet)" = "install ok installed" ] || { fail t2 "dependency figlet is not installed"; return; }
  run_on "$H" "apt-get check >/dev/null 2>&1" || { fail t2 "apt-get check still reports broken packages"; return; }
  run_as "$H" bob "bob-notes" 2>/dev/null | grep -q 'client demo' || { fail t2 "running bob-notes as bob does not work"; return; }
  pass t2
}

check_t3() {
  require t3 assert_file "$H" /home/bob/tree-files.txt || return
  if run_on "$H" "diff -q <(dpkg -L tree) /home/bob/tree-files.txt" >/dev/null 2>&1; then
    pass t3
  else
    fail t3 "/home/bob/tree-files.txt is not identical to the output of 'dpkg -L tree'"
  fi
}

check_t4() {
  local got
  require t4 assert_file "$H" /home/bob/whatis-owner.txt || return
  got=$(run_on "$H" "tr -d '[:space:]' < /home/bob/whatis-owner.txt")
  [ "$got" = man-db ] && pass t4 || fail t4 "whatis-owner.txt contains '$got'; that is not the package owning /usr/bin/whatis"
}

check_t5() {
  local s
  s=$(status nano)
  case "$s" in
    "install ok installed") fail t5 "nano is still installed"; return ;;
  esac
  [ "$(status vim)" = "install ok installed" ] || { fail t5 "vim is no longer installed"; return; }
  pass t5
}

run_tasks t1 t2 t3 t4 t5
