#!/usr/bin/env bash
# Grader for 08-storage/partitions (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=08-storage/partitions
H=${LAB_HOST:-bob-vm}

require_lab "$H" "$LAB"
D=$(run_on "$H" "course-disk disk-a")
PARTS=$(run_on "$H" "lsblk -nrpbo NAME,TYPE,SIZE,PARTTYPE $D | awk '\$2==\"part\"'")

check_t1() {
  local t
  t=$(run_on "$H" "blkid -p -s PTTYPE -o value $D 2>/dev/null || lsblk -dno PTTYPE $D")
  [ "$t" = gpt ] && pass t1 || fail t1 "$D has partition table type '${t:-none}'"
}

check_t2() {
  local n size mib
  n=$(printf '%s\n' "$PARTS" | grep -c . || true)
  [ "$n" -eq 1 ] || { fail t2 "$D has $n partitions, expected exactly 1"; return; }
  size=$(printf '%s' "$PARTS" | awk '{print $3}')
  mib=$((size / 1048576))
  [ "$mib" -ge 495 ] && [ "$mib" -le 505 ] && pass t2 || fail t2 "the partition is $mib MiB, expected 500 MiB"
}

check_t3() {
  local t
  t=$(printf '%s' "$PARTS" | awk '{print tolower($4)}' | head -1)
  [ "$t" = 0fc63daf-8483-4772-8e79-3d69d8477de4 ] && pass t3 ||
    fail t3 "partition type GUID is '${t:-unknown}', which is not Linux filesystem (8300)"
}

check_t4() {
  local want got
  require t4 assert_file "$H" /home/bob/partition.txt || return
  want=$(printf '%s' "$PARTS" | awk '{print $1}' | head -1)
  got=$(run_on "$H" "tr -d '[:space:]' < /home/bob/partition.txt")
  [ -n "$want" ] && [ "$(run_on "$H" "readlink -f '$got'")" = "$want" ] && pass t4 ||
    fail t4 "partition.txt contains '$got', the partition is '${want:-missing}'"
}

run_tasks t1 t2 t3 t4
