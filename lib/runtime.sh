#!/usr/bin/env bash
# lib/runtime.sh — how the host talks to lab machines.
# Sourced by check-helpers.sh and setup-helpers.sh; not run directly.
#
# Environment:
#   COURSE_ROOT     repository root (auto-detected)
#   COURSE_RUNTIME  docker | vm        (set by bin/course from lab.yaml)
#   COURSE_VM_TOOL  vagrant | multipass | incus | lima   (auto-detected if unset)
#   COURSE_TIMEOUT  seconds per remote command (default 60)

: "${COURSE_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
: "${COURSE_RUNTIME:=docker}"
: "${COURSE_TIMEOUT:=60}"
export COURSE_ROOT COURSE_RUNTIME

course_vm_tool() {
  if [ -n "${COURSE_VM_TOOL:-}" ]; then echo "$COURSE_VM_TOOL"; return; fi
  if command -v vagrant >/dev/null 2>&1 &&
     (cd "$COURSE_ROOT/runtime/vm" && vagrant status bob-vm 2>/dev/null | grep -q running); then
    echo vagrant
  elif command -v incus >/dev/null 2>&1 && incus info bob-vm >/dev/null 2>&1; then
    echo incus
  elif command -v multipass >/dev/null 2>&1 && multipass info bob-vm >/dev/null 2>&1; then
    echo multipass
  elif command -v limactl >/dev/null 2>&1 && limactl list -q 2>/dev/null | grep -qx bob-vm; then
    echo lima
  else
    echo none
  fi
}

# _remote <service> <user> : run the bash script read from stdin on <service> as <user>
_remote() {
  local svc=$1 user=$2
  if [ "$COURSE_RUNTIME" = docker ]; then
    # docker exec does not go through PAM, so set the umask a login would get
    if [ "$user" = root ]; then
      { echo 'umask 0022'; cat; } | timeout "$COURSE_TIMEOUT" docker exec -i "lbc-$svc" bash -s
    else
      { echo 'umask 0002'; cat; } | timeout "$COURSE_TIMEOUT" docker exec -i -u "$user" -w "/home/$user" \
        -e HOME="/home/$user" -e USER="$user" -e LOGNAME="$user" "lbc-$svc" bash -s
    fi
    return
  fi
  local tool sudo_cmd
  tool=$(course_vm_tool)
  if [ "$user" = root ]; then sudo_cmd="sudo bash -s"; else sudo_cmd="sudo -iu $user bash -s"; fi
  case "$tool" in
    vagrant)   (cd "$COURSE_ROOT/runtime/vm" && timeout "$COURSE_TIMEOUT" vagrant ssh "$svc" -c "$sudo_cmd" -- -q) ;;
    multipass) timeout "$COURSE_TIMEOUT" multipass exec "$svc" -- bash -c "$sudo_cmd" ;;
    lima)      timeout "$COURSE_TIMEOUT" limactl shell "$svc" bash -c "$sudo_cmd" ;;
    incus)     timeout "$COURSE_TIMEOUT" incus exec "$svc" -- bash -c "$sudo_cmd" ;;
    # Development/CI only: a systemd container named lbc-<svc> stands in for
    # the VM. Never use it for labs that touch kernel modules or disks.
    docker)    timeout "$COURSE_TIMEOUT" docker exec -i "lbc-$svc" bash -c "$sudo_cmd" ;;
    *) echo "No running course VM found (tried vagrant, incus, multipass, lima). Run 'make vm-up'." >&2; return 125 ;;
  esac
}

# run_on <service> <command string>   — run as root
run_on() { local svc=$1; shift; printf '%s\n' "$*" | _remote "$svc" root; }

# run_as <service> <user> <command string>
run_as() { local svc=$1 user=$2; shift 2; printf '%s\n' "$*" | _remote "$svc" "$user"; }

# service_running <service>
service_running() {
  if [ "$COURSE_RUNTIME" = docker ]; then
    [ "$(docker inspect -f '{{.State.Running}}' "lbc-$1" 2>/dev/null)" = true ]
  else
    run_on "$1" true >/dev/null 2>&1
  fi
}
