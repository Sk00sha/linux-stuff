#!/usr/bin/env bash
# Grader for 02-linux-core-concepts/kernel-modules-boot-filetypes (read-only).
set -uo pipefail
# shellcheck source=../../../../lib/check-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/check-helpers.sh"
LAB=02-linux-core-concepts/kernel-modules-boot-filetypes
H=${LAB_HOST:-bob-vm}

require_lab "$H" "$LAB"

check_t1() {
  local want got
  require t1 assert_file "$H" /home/bob/kernel.txt || return
  want=$(run_on "$H" "uname -r")
  got=$(run_on "$H" "tr -d '[:space:]' < /home/bob/kernel.txt")
  [ "$got" = "$want" ] && pass t1 || fail t1 "kernel.txt contains '$got' but the running kernel is '$want'"
}

check_t2() {
  if run_on "$H" "grep -q '^dummy ' /proc/modules 2>/dev/null"; then pass t2
  else fail t2 "lsmod does not list the dummy module"; fi
}

check_t3() {
  require t3 assert_file "$H" /etc/modules-load.d/dummy.conf || return
  require t3 assert_contains "$H" /etc/modules-load.d/dummy.conf '^[[:space:]]*dummy[[:space:]]*$' || return
  pass t3
}

check_t4() {
  local t
  t=$(run_on "$H" "systemctl get-default")
  [ "$t" = multi-user.target ] && pass t4 || fail t4 "systemctl get-default reports '$t'"
}

check_t5() {
  local log target
  log=$(run_on "$H" "sed -n 's/^syslog=//p' /etc/course-vm")
  log=${log:-/var/log/syslog}
  if ! run_on "$H" "test -L /home/bob/latest-log"; then
    fail t5 "/home/bob/latest-log is missing or is not a symbolic link"; return
  fi
  target=$(run_on "$H" "readlink -f /home/bob/latest-log")
  [ "$target" = "$log" ] && pass t5 || fail t5 "/home/bob/latest-log resolves to '$target', expected $log"
}

check_t6() {
  local line path want got bad=""
  require t6 assert_file "$H" /home/bob/types.txt || return
  declare -A expect=(
    [/home/bob/filetypes/disk-image]="regular file"
    [/home/bob/filetypes/config.txt]="symbolic link"
    [/home/bob/filetypes/data.log]="named pipe"
    [/home/bob/filetypes/terminal]="block device"
    [/dev/null]="character device"
  )
  local content
  content=$(run_on "$H" "cat /home/bob/types.txt")
  for path in "${!expect[@]}"; do
    want=${expect[$path]}
    line=$(printf '%s\n' "$content" | grep -F -- "$path:" | head -1)
    got=$(printf '%s' "${line#*:}" | tr '[:upper:]' '[:lower:]' | sed -E 's/^ *//; s/ *$//; s/special file$/device/;
      s/^fifo.*/named pipe/; s/^pipe$/named pipe/; s/^symlink$/symbolic link/; s/^(soft|sym) link$/symbolic link/;
      s/^regular$/regular file/; s/^file$/regular file/; s/special$/device/')
    if [ -z "$line" ]; then bad+=" $path: no line;"
    elif [ "$got" != "$want" ]; then bad+=" $path: '$got' is not right;"
    fi
  done
  [ -z "$bad" ] && pass t6 || fail t6 "types.txt problems:$bad"
}

run_tasks t1 t2 t3 t4 t5 t6
