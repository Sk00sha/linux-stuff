#!/usr/bin/env bash
# Grader for 01-shell-1/bash-prompt (read-only). Every check starts a fresh
# interactive shell as bob, so only persistent settings pass.
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=01-shell-1/bash-prompt
H=ubuntu

require_lab "$H" "$LAB"

# Run a command in a new interactive bash as bob and print only what the
# command wrote between the markers (startup files may print banners).
ibash() {
  run_as "$H" bob "TERM=dumb bash -ic $(printf '%q' "echo '<<<'; $1; echo '>>>'") 2>/dev/null" |
    sed -n '/^<<<$/,/^>>>$/p' | sed '1d;$d'
}

check_t1() {
  local ps1
  # shellcheck disable=SC2016  # expanded by the inner interactive shell
  ps1=$(ibash 'printf "%s|\n" "$PS1"')
  ps1=${ps1%|}
  case "$ps1" in
    '[\u@\h \W]$ '|'[\u@\h \W]\$ ') pass t1 ;;
    *) fail t1 "a new interactive shell has PS1='$ps1', expected '[\\u@\\h \\W]\$ ' (note the trailing space)" ;;
  esac
}

check_t2() {
  local p
  # shellcheck disable=SC2016  # expanded by the inner interactive shell
  p=$(ibash 'echo "$PATH"')
  case ":$p:" in
    *:/opt/tools/bin:*) ;;
    *) fail t2 "/opt/tools/bin is not in PATH of a new interactive shell (PATH=$p)"; return ;;
  esac
  case ":$p:" in
    *:/usr/bin:*) ;;
    *) fail t2 "PATH no longer contains /usr/bin (PATH=$p) — append to PATH instead of replacing it"; return ;;
  esac
  if ! ibash 'mercury-status' | grep -q 'mercury:'; then
    fail t2 "mercury-status does not run by name in a new interactive shell"; return
  fi
  pass t2
}

check_t3() {
  local t
  t=$(ibash 'type ll')
  if printf '%s' "$t" | grep -Eq "aliased to .ls( +[^ ]+)* +-[a-zA-Z]*l"; then
    pass t3
  else
    fail t3 "in a new interactive shell 'type ll' says: ${t:-ll: not found}"
  fi
}

run_tasks t1 t2 t3
