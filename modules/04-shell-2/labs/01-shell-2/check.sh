#!/usr/bin/env bash
# Grader for 04-shell-2/shell-2 (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=04-shell-2/shell-2
H=ubuntu

require_lab "$H" "$LAB"

check_t1() {
  local A=/home/bob/reports.tar.gz missing
  require t1 assert_file "$H" "$A" || return
  if ! run_on "$H" "file -b $A | grep -q '^gzip'"; then
    fail t1 "$A is not gzip-compressed ($(run_on "$H" "file -b $A"))"; return
  fi
  missing=$(run_on "$H" "cd /home/bob && comm -23 <(find reports -type f | sort) <(tar -tzf $A | sort)")
  if [ -n "$missing" ]; then
    fail t1 "archive is missing $(printf '%s' "$missing" | wc -l) file(s), e.g. $(printf '%s' "$missing" | head -1) — paths must start with reports/"
    return
  fi
  pass t1
}

check_t2() {
  local want got
  require t2 assert_file "$H" /home/bob/biglogs.txt || return
  want=$(run_on "$H" "find /var/app -type f -name '*.log' -size +1M | sort")
  got=$(run_on "$H" "sed 's#/\$##; /^\$/d' /home/bob/biglogs.txt | sort -u")
  if [ "$want" = "$got" ]; then pass t2; return; fi
  local extra missing
  missing=$(comm -23 <(printf '%s\n' "$want") <(printf '%s\n' "$got") | wc -l)
  extra=$(comm -13 <(printf '%s\n' "$want") <(printf '%s\n' "$got") | wc -l)
  fail t2 "biglogs.txt has $extra unexpected and $missing missing path(s) (are you searching all of /var/app, as root if needed?)"
}

check_t3() {
  require t3 assert_file "$H" /home/bob/errors.txt || return
  if run_on "$H" "diff -q <(grep -i error /var/app/app.log) /home/bob/errors.txt" >/dev/null 2>&1; then
    pass t3; return
  fi
  local n
  n=$(run_on "$H" "wc -l < /home/bob/errors.txt")
  fail t3 "errors.txt has $n line(s) but does not match the case-insensitive error lines of app.log"
}

check_t4() {
  local out err
  require t4 assert_file "$H" /home/bob/start.out || return
  require t4 assert_file "$H" /home/bob/start.err || return
  out=$(run_on "$H" "cat /home/bob/start.out")
  err=$(run_on "$H" "cat /home/bob/start.err")
  if ! printf '%s' "$out" | grep -q 'mercury: ready' || printf '%s' "$out" | grep -q 'ERROR'; then
    fail t4 "start.out should contain only the normal output of the script"; return
  fi
  if ! printf '%s' "$err" | grep -q 'ERROR worker 3' || printf '%s' "$err" | grep -q 'ready'; then
    fail t4 "start.err should contain only the error output of the script"; return
  fi
  pass t4
}

run_tasks t1 t2 t3 t4
