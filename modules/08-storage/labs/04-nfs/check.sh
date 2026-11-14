#!/usr/bin/env bash
# Grader for 08-storage/nfs (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=08-storage/nfs

require_lab bob-vm "$LAB"
require_lab nfs-server "$LAB"

check_t1() {
  local e
  e=$(run_on nfs-server "exportfs -v | tr -s ' \t' ' ' | paste -sd' ' | grep -o '/srv/share [^/]*'")
  [ -n "$e" ] || { fail t1 "nfs-server does not export /srv/share (exportfs -v)"; return; }
  printf '%s' "$e" | grep -Eq '(192\.168\.56\.10|192\.168\.56\.0/24|bob-vm|\*)\(' || { fail t1 "/srv/share is not exported to bob-vm: $e"; return; }
  printf '%s' "$e" | grep -q '(rw' || { fail t1 "/srv/share is exported read-only: $e"; return; }
  pass t1
}

check_t2() {
  local src
  src=$(run_on bob-vm "findmnt -no SOURCE,FSTYPE /mnt/share 2>/dev/null")
  printf '%s' "$src" | grep -Eq '^(nfs-server|192\.168\.56\.20):/srv/share +nfs4?$' && pass t2 ||
    fail t2 "/mnt/share on bob-vm is '${src:-not mounted}'"
}

check_t3() {
  local line
  line=$(run_on bob-vm "grep -v '^[[:space:]]*#' /etc/fstab | awk '\$2==\"/mnt/share\"'")
  [ -n "$line" ] || { fail t3 "bob-vm's /etc/fstab has no entry for /mnt/share"; return; }
  printf '%s' "$line" | grep -Eq '^(nfs-server|192\.168\.56\.20):/srv/share[[:space:]]+/mnt/share[[:space:]]+nfs4?[[:space:]]' ||
    { fail t3 "the /mnt/share fstab entry doesn't mount nfs-server:/srv/share as nfs: $line"; return; }
  printf '%s' "$line" | awk '{print $4}' | grep -q '_netdev' || { fail t3 "the /mnt/share entry lacks the _netdev option"; return; }
  pass t3
}

check_t4() {
  local o
  o=$(run_on nfs-server "stat -c %U /srv/share/hello-from-bob.txt 2>/dev/null")
  [ "$o" = bob ] && pass t4 || fail t4 "/srv/share/hello-from-bob.txt on nfs-server is ${o:+owned by $o}${o:-missing}"
}

run_tasks t1 t2 t3 t4
