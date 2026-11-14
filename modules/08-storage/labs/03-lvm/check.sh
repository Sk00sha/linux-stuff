#!/usr/bin/env bash
# Grader for 08-storage/lvm (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=08-storage/lvm
H=${LAB_HOST:-bob-vm}

require_lab "$H" "$LAB"
B=$(run_on "$H" "course-disk disk-b"); C=$(run_on "$H" "course-disk disk-c")

pv_vg() { run_on "$H" "pvs --noheadings -o vg_name $1 2>/dev/null | tr -d ' '"; }

check_t1() {
  local d
  for d in "$B" "$C"; do
    run_on "$H" "pvs $d >/dev/null 2>&1" || { fail t1 "$d is not an LVM physical volume"; return; }
  done
  pass t1
}

check_t2() {
  local n
  run_on "$H" "vgs caleston_vg >/dev/null 2>&1" || { fail t2 "volume group caleston_vg does not exist"; return; }
  [ "$(pv_vg "$B")" = caleston_vg ] && [ "$(pv_vg "$C")" = caleston_vg ] ||
    { fail t2 "caleston_vg does not contain both $B and $C"; return; }
  n=$(run_on "$H" "vgs --noheadings -o pv_count caleston_vg | tr -d ' '")
  [ "$n" = 2 ] && pass t2 || fail t2 "caleston_vg has $n physical volumes, expected 2"
}

check_t3() {
  local t src
  run_on "$H" "lvs caleston_vg/data >/dev/null 2>&1" || { fail t3 "logical volume caleston_vg/data does not exist"; return; }
  t=$(run_on "$H" "blkid -s TYPE -o value /dev/caleston_vg/data")
  [ "$t" = ext4 ] || { fail t3 "caleston_vg/data has filesystem type '${t:-none}'"; return; }
  src=$(run_on "$H" "findmnt -no SOURCE /mnt/media 2>/dev/null")
  [ "$(run_on "$H" "readlink -f '${src:-/nonexistent}'")" = "$(run_on "$H" "readlink -f /dev/caleston_vg/data")" ] ||
    { fail t3 "caleston_vg/data is not mounted at /mnt/media"; return; }
  pass t3
}

check_t4() {
  local lv fs
  lv=$(run_on "$H" "lvs --noheadings --units m --nosuffix -o lv_size caleston_vg/data 2>/dev/null | tr -d ' ' | cut -d. -f1")
  [ -n "$lv" ] || { fail t4 "no data volume yet"; return; }
  if [ "$lv" -lt 1500 ] || [ "$lv" -gt 1560 ]; then fail t4 "data is ${lv} MiB, expected about 1524 MiB (1 GiB + 500 MiB)"; return; fi
  fs=$(run_on "$H" "df -BM --output=size /mnt/media 2>/dev/null | tail -1 | tr -dc 0-9")
  [ "${fs:-0}" -ge 1350 ] && pass t4 || fail t4 "the LV grew but the filesystem on /mnt/media is still ${fs:-?} MiB — resize the filesystem too"
}

run_tasks t1 t2 t3 t4
