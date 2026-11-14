#!/usr/bin/env bash
# Prepare lab 05-networking/network-basics.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
# shellcheck source=../common.sh
. "$(dirname "$0")/../common.sh"
LAB=05-networking/network-basics

require_services client router db01
ensure_user client bob
say "resetting client routes (no default route, no backend route)"
reset_client_network
# Without a default route the backend can only be reached through the router.
run_on client "ip route del default 2>/dev/null || true"
run_on db01 "iptables -F INPUT; iptables -P INPUT ACCEPT; ip route replace 10.10.1.0/24 via 10.10.2.254"
mark_lab client "$LAB"
say "done"
