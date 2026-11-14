#!/usr/bin/env bash
# Shared code for module 08 labs. STORAGE_FUNCS is prepended to scripts that
# run *inside the course VM*; nothing here ever touches the host's disks.
# shellcheck disable=SC2016,SC2034  # used by the labs that source this file
STORAGE_FUNCS='
disk() { course-disk "$1"; }
# first partition of a disk (handles sdb1, vdb1, nvme1n1p1, loop0p1)
part1() { lsblk -nrpo NAME,TYPE "$1" | awk '"'"'$2=="part"{print $1; exit}'"'"'; }
# unmount and forget everything living on a disk, then wipe it
wipe_disk() {
  local d=$1 p
  for p in $(lsblk -nrpo NAME "$d" | tail -n +2); do
    umount -q "$p" 2>/dev/null || true
    u=$(blkid -s UUID -o value "$p" 2>/dev/null || true)
    [ -n "$u" ] && sed -i "/$u/d" /etc/fstab
    wipefs -qa "$p" 2>/dev/null || true
  done
  wipefs -qa "$d" 2>/dev/null || true
  sgdisk --zap-all "$d" >/dev/null 2>&1 || true
  partprobe "$d" 2>/dev/null || true
  udevadm settle 2>/dev/null || true
}
'
