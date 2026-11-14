#!/usr/bin/env bash
# Grader for 06-security-and-permissions/ssh-and-scp (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=06-security-and-permissions/ssh-and-scp

require_lab devbox "$LAB"
require_lab app01 "$LAB"

check_t1() {
  local k
  k=$(run_on devbox "ls /home/bob/.ssh/id_ed25519 /home/bob/.ssh/id_rsa 2>/dev/null | head -1")
  [ -n "$k" ] || { fail t1 "no private key at ~/.ssh/id_ed25519 or ~/.ssh/id_rsa"; return; }
  require t1 assert_file devbox "$k.pub" || return
  require t1 assert_mode devbox "$k" 600 || return
  require t1 assert_owner devbox "$k" bob:bob || return
  pass t1
}

check_t2() {
  if run_as devbox bob "ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new bob@app01 true" >/dev/null 2>&1; then
    pass t2
  else
    local perms
    perms=$(run_on app01 "stat -c '%a %n' /home/bob/.ssh /home/bob/.ssh/authorized_keys 2>/dev/null | tr '\n' ' '")
    fail t2 "ssh from devbox to app01 as bob still needs a password (on app01: ${perms:-no ~/.ssh})"
  fi
}

check_t3() {
  local a b
  require t3 assert_file app01 /opt/caleston-code.tar.gz || return
  a=$(run_on devbox "sha256sum < /home/bob/caleston-code.tar.gz")
  b=$(run_on app01 "sha256sum < /opt/caleston-code.tar.gz")
  [ "$a" = "$b" ] && pass t3 || fail t3 "/opt/caleston-code.tar.gz on app01 differs from the original"
}

check_t4() {
  local a b
  require t4 assert_file app01 /opt/caleston-code.tar.gz || return
  a=$(run_on devbox "stat -c %Y /home/bob/caleston-code.tar.gz")
  b=$(run_on app01 "stat -c %Y /opt/caleston-code.tar.gz")
  [ "$a" = "$b" ] && pass t4 || fail t4 "the copy's modification time is $(run_on app01 "stat -c %y /opt/caleston-code.tar.gz | cut -d. -f1"), the original's is $(run_on devbox "stat -c %y /home/bob/caleston-code.tar.gz | cut -d. -f1")"
}

run_tasks t1 t2 t3 t4
