#!/usr/bin/env bash
# Grader for 08-storage/filesystems. Read-only, except that t4 (as the task
# states) unmounts /mnt/data and remounts it with mount -a.
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=08-storage/filesystems
H=${LAB_HOST:-bob-vm}

require_lab "$H" "$LAB"
D=$(run_on "$H" "course-disk disk-a")
P=$(run_on "$H" "lsblk -nrpo NAME,TYPE $D | awk '\$2==\"part\"{print \$1; exit}'")
UUID=$(run_on "$H" "blkid -s UUID -o value $P 2>/dev/null")

check_t1() {
  local t
  t=$(run_on "$H" "blkid -s TYPE -o value $P 2>/dev/null")
  [ "$t" = ext4 ] && pass t1 || fail t1 "$P has filesystem type '${t:-none}'"
}

check_t2() {
  local src
  src=$(run_on "$H" "findmnt -no SOURCE /mnt/data 2>/dev/null")
  [ -n "$src" ] || { fail t2 "nothing is mounted at /mnt/data"; return; }
  [ "$(run_on "$H" "readlink -f $src")" = "$P" ] && pass t2 || fail t2 "/mnt/data is mounted from $src, not $P"
}

check_t3() {
  local line
  [ -n "$UUID" ] || { fail t3 "$P has no filesystem UUID yet"; return; }
  line=$(run_on "$H" "grep -v '^[[:space:]]*#' /etc/fstab | awk '\$2==\"/mnt/data\"'")
  [ -n "$line" ] || { fail t3 "/etc/fstab has no entry for /mnt/data"; return; }
  printf '%s' "$line" | awk '{print $1}' | grep -qx "UUID=\"\\{0,1\\}$UUID\"\\{0,1\\}" ||
    { fail t3 "the /mnt/data entry uses '$(printf '%s' "$line" | awk '{print $1}')' instead of UUID=$UUID"; return; }
  [ "$(printf '%s' "$line" | awk '{print $3}')" = ext4 ] || { fail t3 "the /mnt/data entry's type field is not ext4"; return; }
  pass t3
}

check_t4() {
  local out
  out=$(run_on "$H" "findmnt --verify --tab-file /etc/fstab 2>&1 | grep -A3 '/mnt/data' | grep -iE 'error|\\[E\\]'")
  [ -z "$out" ] || { fail t4 "findmnt --verify reports a problem with the /mnt/data entry: $out"; return; }
  run_on "$H" "systemctl daemon-reload; umount /mnt/data 2>/dev/null; mount -a 2>&1; findmnt /mnt/data >/dev/null" >/dev/null 2>&1 ||
    { fail t4 "after 'umount /mnt/data; mount -a', /mnt/data was not mounted again"; return; }
  pass t4
}

run_tasks t1 t2 t3 t4
