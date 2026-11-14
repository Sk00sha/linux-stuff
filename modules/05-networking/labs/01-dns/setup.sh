#!/usr/bin/env bash
# Prepare lab 05-networking/dns.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
# shellcheck source=../common.sh
. "$(dirname "$0")/../common.sh"
LAB=05-networking/dns

require_services client dns
ensure_user client bob
say "resetting name resolution on client"
reset_client_network
mark_lab client "$LAB"
say "done"
