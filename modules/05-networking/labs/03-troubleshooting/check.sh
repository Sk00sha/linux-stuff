#!/usr/bin/env bash
# Grader for 05-networking/troubleshooting (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=05-networking/troubleshooting

require_lab client "$LAB"
require_lab web01 "$LAB"

check_t1() {
  local ip
  ip=$(run_as client bob "getent hosts web01 | awk '{print \$1; exit}'")
  [ "$ip" = 10.10.1.80 ] && pass t1 || fail t1 "on client, web01 resolves to '${ip:-nothing}'"
}

LISTEN=$(run_on web01 "ss -Htln" 2>/dev/null)

check_t2() {
  if printf '%s\n' "$LISTEN" | awk '{print $4}' | grep -Eq ':80$'; then pass t2
  else fail t2 "nothing on web01 listens on port 80 (listening: $(printf '%s\n' "$LISTEN" | awk '{print $4}' | tr '\n' ' '))"; fi
}

check_t3() {
  local addrs
  addrs=$(printf '%s\n' "$LISTEN" | awk '{print $4}' | grep -E ':(80|8080)$' | tr '\n' ' ')
  if [ -z "$addrs" ]; then fail t3 "the web app is not listening at all"; return; fi
  if printf '%s' "$addrs" | grep -Eq '(^| )127\.'; then
    fail t3 "the web app listens on $addrs — a loopback address only web01 itself can reach"; return
  fi
  require t3 assert_port_open client 10.10.1.80 "$(printf '%s' "$addrs" | grep -oE '[0-9]+ ' | head -1)" || return
  pass t3
}

check_t4() {
  local body
  body=$(run_as client bob "curl -s -m 3 http://web01/")
  [ "$body" = "Mercury demo: web01 OK" ] && pass t4 || fail t4 "curl http://web01/ on client returned '${body:-nothing}'"
}

run_tasks t1 t2 t3 t4
