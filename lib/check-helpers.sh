#!/usr/bin/env bash
# lib/check-helpers.sh — helpers for lab graders (check.sh).
#
# Contract (see CONTRIBUTING.md):
#   * graders are read-only and idempotent;
#   * one function per task, check_t1, check_t2, ... printing
#       PASS t1            or   FAIL t1: <what was observed>
#   * run_tasks t1 t2 ... runs them and exits 0 only if all pass.
#
# Assertions are silent: they return 0/1 and leave a human-readable
# explanation in $REASON. Use `require <task> <assertion...> || return`
# inside a check function to fail the task with that explanation.

# shellcheck source=lib/runtime.sh
. "$(dirname "${BASH_SOURCE[0]}")/runtime.sh"

REASON=""
FAILED=0
PASSED=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  _G=$'\e[32m'; _R=$'\e[31m'; _N=$'\e[0m'
else
  _G=""; _R=""; _N=""
fi

pass() { PASSED=$((PASSED + 1)); echo "${_G}PASS${_N} $1"; }
fail() { FAILED=$((FAILED + 1)); echo "${_R}FAIL${_N} $1: $2"; }

# require <task> <assert_fn> [args...]  -> on failure prints FAIL and returns 1
require() {
  local task=$1; shift
  if "$@"; then return 0; fi
  fail "$task" "$REASON"
  return 1
}

_q() { printf '%q' "$1"; }

assert_file() { # svc path
  run_on "$1" "test -f $(_q "$2")" >/dev/null 2>&1 && return 0
  REASON="$2 does not exist on $1 (or is not a regular file)"; return 1
}

assert_dir() { # svc path
  run_on "$1" "test -d $(_q "$2")" >/dev/null 2>&1 && return 0
  REASON="directory $2 does not exist on $1"; return 1
}

assert_absent() { # svc path
  run_on "$1" "test ! -e $(_q "$2") && test ! -L $(_q "$2")" >/dev/null 2>&1 && return 0
  REASON="$2 still exists on $1"; return 1
}

assert_owner() { # svc path user:group
  local got
  got=$(run_on "$1" "stat -c %U:%G $(_q "$2")" 2>/dev/null)
  [ "$got" = "$3" ] && return 0
  REASON="$2 on $1 is owned by ${got:-<missing>}, expected $3"; return 1
}

assert_mode() { # svc path octal-mode (e.g. 750 or 1777)
  local got want
  got=$(run_on "$1" "stat -c %a $(_q "$2")" 2>/dev/null)
  want=$(echo "$3" | sed 's/^0*\([0-9]\)/\1/')
  [ "$got" = "$want" ] && return 0
  REASON="$2 on $1 has mode ${got:-<missing>}, expected $3"; return 1
}

assert_contains() { # svc path extended-regex
  run_on "$1" "grep -Eq -- $(_q "$3") $(_q "$2")" >/dev/null 2>&1 && return 0
  REASON="$2 on $1 does not contain a line matching /$3/"; return 1
}

assert_not_contains() { # svc path extended-regex
  run_on "$1" "! grep -Eq -- $(_q "$3") $(_q "$2")" >/dev/null 2>&1 && return 0
  REASON="$2 on $1 still contains a line matching /$3/"; return 1
}

assert_cmd_succeeds() { # svc command-string
  run_on "$1" "$2" >/dev/null 2>&1 && return 0
  REASON="'$2' failed on $1"; return 1
}

assert_cmd_output() { # svc command-string extended-regex
  local out
  out=$(run_on "$1" "$2" 2>&1)
  printf '%s\n' "$out" | grep -Eq -- "$3" && return 0
  REASON="'$2' on $1 printed '$(printf '%s' "$out" | head -c 200 | tr '\n' ' ')', expected /$3/"; return 1
}

assert_port_open() { # from-svc host port
  run_on "$1" "nc -z -w 2 $(_q "$2") $3" >/dev/null 2>&1 && return 0
  REASON="port $3 on $2 is not reachable from $1; expected it to be open"; return 1
}

assert_port_closed() { # from-svc host port
  run_on "$1" "! nc -z -w 2 $(_q "$2") $3" >/dev/null 2>&1 && return 0
  REASON="port $3 on $2 is reachable from $1; expected it to be blocked"; return 1
}

# require_lab <svc> <lab-id> : make sure setup.sh for this lab has been run
require_lab() {
  local got
  if ! service_running "$1"; then
    echo "${_R}FAIL${_N} setup: machine '$1' is not running. Start the lab with: course start $2"
    exit 2
  fi
  got=$(run_on "$1" "cat /etc/course-lab-id 2>/dev/null")
  if [ "$got" != "$2" ]; then
    echo "${_R}FAIL${_N} setup: '$1' is prepared for lab '${got:-none}', not '$2'. Run: course reset $2"
    exit 2
  fi
}

# run_tasks t1 t2 ... : call check_<task> for each and exit with the summary
run_tasks() {
  local t
  for t in "$@"; do
    "check_$t"
  done
  echo "---"
  echo "$PASSED passed, $FAILED failed"
  [ "$FAILED" -eq 0 ]
  exit $?
}
