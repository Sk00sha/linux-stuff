#!/usr/bin/env bash
# Grader for 05-networking/network-basics (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=05-networking/network-basics
H=client

require_lab "$H" "$LAB"

check_t1() {
  local want got
  require t1 assert_file "$H" /home/bob/client-ip.txt || return
  want=$(run_on "$H" "ip -4 -o addr show dev eth0 | awk '{print \$4}'")
  got=$(run_on "$H" "tr -d '[:space:]' < /home/bob/client-ip.txt")
  [ "$got" = "$want" ] && pass t1 || fail t1 "client-ip.txt contains '$got'; that is not eth0's address in CIDR form"
}

check_t2() {
  local r
  r=$(run_on "$H" "ip route get 10.10.2.20 2>&1 | head -1")
  case "$r" in
    *"via 10.10.1.254 "*) pass t2 ;;
    *) fail t2 "the kernel would send packets for 10.10.2.20 like this: '$r'" ;;
  esac
}

check_t3() {
  if run_as "$H" bob "ping -c 1 -W 2 10.10.2.20 >/dev/null 2>&1"; then pass t3
  else fail t3 "ping from client to 10.10.2.20 gets no reply"; fi
}

check_t4() {
  local want got
  require t4 assert_file "$H" /home/bob/db-banner.txt || return
  want="db01 service on port 5432"
  got=$(run_on "$H" "head -1 /home/bob/db-banner.txt | tr -d '\r'")
  [ "$got" = "$want" ] && pass t4 || fail t4 "db-banner.txt starts with '$got'; that is not what db01:5432 sends"
}

run_tasks t1 t2 t3 t4
