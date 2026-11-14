#!/usr/bin/env bash
# Grader for 05-networking/dns (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=05-networking/dns
H=client

require_lab "$H" "$LAB"

resolve() { run_as "$H" bob "getent hosts $1 | awk '{print \$1; exit}'"; }

check_t1() {
  require t1 assert_contains "$H" /etc/hosts '^[[:space:]]*10\.10\.2\.20[[:space:]].*\bdb01\b' || return
  local ip
  ip=$(resolve db01)
  [ "$ip" = 10.10.2.20 ] && pass t1 || fail t1 "getent hosts db01 returns '${ip:-nothing}'"
}

check_t2() {
  local ns ip
  ns=$(run_on "$H" "awk '/^[[:space:]]*nameserver/{print \$2}' /etc/resolv.conf | tr '\n' ' '")
  [ "$ns" = "10.10.1.53 " ] || { fail t2 "/etc/resolv.conf nameservers are '${ns:-none}', expected only 10.10.1.53"; return; }
  ip=$(resolve db.company.local)
  [ "$ip" = 10.10.2.20 ] || { fail t2 "db.company.local resolves to '${ip:-nothing}'"; return; }
  pass t2
}

check_t3() {
  local a b
  require t3 assert_contains "$H" /etc/resolv.conf '^[[:space:]]*(search|domain)[[:space:]].*company\.local' || return
  a=$(resolve www); b=$(resolve mail)
  [ "$a" = 10.10.1.80 ] && [ "$b" = 10.10.1.25 ] && pass t3 ||
    fail t3 "short names don't resolve yet (www -> '${a:-nothing}', mail -> '${b:-nothing}')"
}

check_t4() {
  local got
  require t4 assert_file "$H" /home/bob/mx.txt || return
  got=$(run_on "$H" "tr -d '[:space:]' < /home/bob/mx.txt")
  case "$got" in
    mail.company.local|mail.company.local.) pass t4 ;;
    *) fail t4 "mx.txt contains '$got', which is not the mail server named in the MX record" ;;
  esac
}

run_tasks t1 t2 t3 t4
