#!/usr/bin/env bash
# lib/setup-helpers.sh — helpers for lab setup scripts (setup.sh).
#
# setup.sh must be idempotent: running it again resets the lab to its
# starting state (`course reset` simply re-runs it).

# shellcheck source=lib/runtime.sh
. "$(dirname "${BASH_SOURCE[0]}")/runtime.sh"
set -euo pipefail

say() { echo "[setup] $*"; }
die() { echo "[setup] ERROR: $*" >&2; exit 1; }

# require_services svc... : every machine must be up
require_services() {
  local s
  for s in "$@"; do
    service_running "$s" || die "machine '$s' is not running (start the lab with 'course start')"
  done
}

# require_vm svc : refuse to touch anything that is not the course VM
require_vm() {
  [ "$COURSE_RUNTIME" = vm ] || die "this lab needs the VM runtime (make vm-up)"
  run_on "$1" "test -f /etc/course-vm" >/dev/null 2>&1 ||
    die "'$1' does not look like the course VM (/etc/course-vm missing). Refusing to run."
}

# mark_lab svc lab-id : record which lab a machine is prepared for
mark_lab() { run_on "$1" "echo $(printf '%q' "$2") > /etc/course-lab-id"; }

# ensure_user svc user [extra useradd args...]
ensure_user() {
  local svc=$1 user=$2; shift 2
  run_on "$svc" "id $user >/dev/null 2>&1 || { useradd -m -s /bin/bash $* $user && echo '$user:caleston123' | chpasswd; }"
}

# remote script from stdin: on <svc> [user]
on() { _remote "$1" "${2:-root}"; }
