#!/usr/bin/env bash
# Grader for 01-shell-1/working-with-the-shell (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=01-shell-1/working-with-the-shell
H=ubuntu
M=/home/bob/asia/india/mumbai

require_lab "$H" "$LAB"

check_t1() {
  require t1 assert_dir "$H" "$M" || return
  require t1 assert_owner "$H" "$M" bob:bob || return
  pass t1
}

check_t2() {
  require t2 assert_file "$H" "$M/city-guide.txt" || return
  require t2 assert_file "$H" /home/bob/notes/city-guide.txt || return
  if ! run_on "$H" "cmp -s $M/city-guide.txt /home/bob/notes/city-guide.txt"; then
    fail t2 "$M/city-guide.txt differs from the original in /home/bob/notes"; return
  fi
  pass t2
}

check_t3() {
  require t3 assert_absent "$H" /home/bob/projetcs || return
  require t3 assert_dir "$H" /home/bob/projects || return
  require t3 assert_file "$H" /home/bob/projects/mercury/src/start.sh || return
  require t3 assert_file "$H" /home/bob/projects/README.md || return
  pass t3
}

check_t4() {
  require t4 assert_absent "$H" /home/bob/old-contractor-tmp || return
  pass t4
}

check_t5() {
  require t5 assert_file "$H" /home/bob/whatis.txt || return
  if ! run_on "$H" 'diff -q <(whatis ls) /home/bob/whatis.txt' >/dev/null 2>&1; then
    fail t5 "/home/bob/whatis.txt does not contain exactly the output of 'whatis ls' (found: '$(run_on "$H" 'head -c 120 /home/bob/whatis.txt')')"
    return
  fi
  pass t5
}

run_tasks t1 t2 t3 t4 t5
