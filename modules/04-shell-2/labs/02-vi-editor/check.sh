#!/usr/bin/env bash
# Grader for 04-shell-2/vi-editor (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=04-shell-2/vi-editor
H=ubuntu
F=/home/bob/mercury.conf

require_lab "$H" "$LAB"

EXPECTED='# Mercury application configuration
# environment: production build for internal testing

[server]
host = 0.0.0.0
port = 80
workers = 4

[database]
host = db01.company.local
port = 5432
name = mercury_production

[logging]
level = info
path = /var/log/mercury/production.log
demo_client = halvorsen'

CONTENT=$(run_on "$H" "cat $F" 2>/dev/null)

check_t1() {
  if printf '%s\n' "$CONTENT" | grep -qx 'port = 80' && ! printf '%s\n' "$CONTENT" | grep -q '8080'; then
    pass t1
  else
    fail t1 "the [server] section does not contain the line 'port = 80' (or 8080 is still present)"
  fi
}

check_t2() {
  local n
  n=$(printf '%s\n' "$CONTENT" | grep -c development)
  if [ "$n" -gt 0 ]; then fail t2 "'development' still appears $n time(s)"; return; fi
  [ "$(printf '%s\n' "$CONTENT" | grep -c production)" -eq 3 ] && pass t2 ||
    fail t2 "expected 'production' in 3 places (comment, database name, log path)"
}

check_t3() {
  printf '%s\n' "$CONTENT" | grep -q '^debug_password' && fail t3 "the debug_password line is still there" || pass t3
}

check_t4() {
  local last
  last=$(printf '%s\n' "$CONTENT" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | tail -1)
  [ "$last" = "demo_client = halvorsen" ] || { fail t4 "the last line is '$last'"; return; }
  # everything else unchanged (ignoring trailing blank lines / trailing spaces)
  if [ "$(printf '%s\n' "$CONTENT" | sed 's/[[:space:]]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')" != "$EXPECTED" ]; then
    fail t4 "the file differs from the expected result in other lines too — compare it with the original task list"
    return
  fi
  pass t4
}

check_t5() {
  local swp
  swp=$(run_on "$H" "ls -a /home/bob | grep -E '^\\.mercury\\.conf\\.sw.\$'")
  [ -z "$swp" ] && pass t5 || fail t5 "swap file(s) still present in /home/bob: $(echo "$swp" | tr '\n' ' ')"
}

run_tasks t1 t2 t3 t4 t5
