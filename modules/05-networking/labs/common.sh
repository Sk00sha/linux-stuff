#!/usr/bin/env bash
# Shared setup for module 05 labs: put the client's name resolution and
# routing back to the state Docker created. Sourced by each lab's setup.sh.

reset_client_network() {
  on client <<'SCRIPT'
set -e
# first run: remember Docker's original files
[ -f /etc/hosts.course-orig ] || cp /etc/hosts /etc/hosts.course-orig
[ -f /etc/resolv.conf.course-orig ] || cp /etc/resolv.conf /etc/resolv.conf.course-orig
# bind-mounted by Docker: overwrite in place instead of replacing
cat /etc/hosts.course-orig > /etc/hosts
cat /etc/resolv.conf.course-orig > /etc/resolv.conf
ip route del 10.10.2.0/24 2>/dev/null || true
ip route replace default via 10.10.1.1 dev eth0
rm -f /home/bob/mx.txt /home/bob/client-ip.txt /home/bob/db-banner.txt
SCRIPT
}
