#!/usr/bin/env bash
# Grader for 06-security-and-permissions/cronjob (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=06-security-and-permissions/cronjob
H=devbox

require_lab "$H" "$LAB"

BOB=$(run_on "$H" "crontab -l -u bob 2>/dev/null | grep -v '^[[:space:]]*#' | grep '/opt/scripts/cleanup.sh'")
ROOT=$(run_on "$H" "crontab -l -u root 2>/dev/null | grep -v '^[[:space:]]*#'")

check_t1() {
  [ -n "$BOB" ] || { fail t1 "bob's crontab has no active line running /opt/scripts/cleanup.sh"; return; }
  [ "$(printf '%s\n' "$BOB" | wc -l)" -eq 1 ] || { fail t1 "bob's crontab runs cleanup.sh more than once"; return; }
  local m h dom mon dow
  read -r m h dom mon dow _ <<<"$BOB"
  case "$m $h $dom $mon $dow" in
    "0 21 * * *"|"00 21 * * *") pass t1 ;;
    @daily*) fail t1 "@daily runs at midnight, not 21:00" ;;
    *) fail t1 "the schedule '$m $h $dom $mon $dow' does not mean every day at 21:00" ;;
  esac
}

check_t2() {
  [ -n "$BOB" ] || { fail t2 "no cleanup job in bob's crontab yet"; return; }
  if printf '%s' "$BOB" | grep -Eq '>>[[:space:]]*/home/bob/cleanup\.log[[:space:]]+2>&1|&>>[[:space:]]*/home/bob/cleanup\.log'; then
    pass t2
  elif printf '%s' "$BOB" | grep -q '> */home/bob/cleanup.log' && ! printf '%s' "$BOB" | grep -q '>>'; then
    fail t2 "the job overwrites cleanup.log (>) instead of appending (>>)"
  else
    fail t2 "the job does not append stdout and stderr to /home/bob/cleanup.log (expected '>> /home/bob/cleanup.log 2>&1')"
  fi
}

check_t3() {
  if printf '%s\n' "$ROOT" | grep -q '/opt/scripts/cleanup.sh'; then
    fail t3 "root's crontab still runs /opt/scripts/cleanup.sh"; return
  fi
  printf '%s\n' "$ROOT" | grep -q 'apt-get -qq clean' || { fail t3 "the legitimate apt-get clean job disappeared from root's crontab"; return; }
  pass t3
}

run_tasks t1 t2 t3
