#!/usr/bin/env bash
# Prepare lab 04-shell-2/vi-editor.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=04-shell-2/vi-editor
H=ubuntu

require_services "$H"
ensure_user "$H" bob
say "writing /home/bob/mercury.conf and a stale swap file on $H"
on "$H" <<'SCRIPT'
set -e
cd /home/bob
rm -f mercury.conf .mercury.conf.sw? 
cat > mercury.conf <<'CONF'
# Mercury application configuration
# environment: development build for internal testing

[server]
host = 0.0.0.0
port = 8080
workers = 4

[database]
host = db01.company.local
port = 5432
name = mercury_development
debug_password = hunter2

[logging]
level = info
path = /var/log/mercury/development.log
CONF
# A realistic stale swap file: open the file in vim on a pseudo-terminal,
# make an (unsaved) change, then kill vim so it cannot clean up.
su - bob -c "cd /home/bob && (TERM=xterm script -qc \"vim -c 'normal Ox' mercury.conf\" /dev/null >/dev/null 2>&1 &)
  sleep 1.5; pkill -KILL -u bob -x vim; sleep 0.3; pkill -u bob -x script" </dev/null >/dev/null 2>&1 || true
if ! ls -a | grep -q '^\.mercury\.conf\.sw.$'; then
  printf 'b0VIM 9.1\0stale swap from a crashed session' > .mercury.conf.swp
fi
chown bob:bob mercury.conf .mercury.conf.sw? 2>/dev/null || true
SCRIPT
mark_lab "$H" "$LAB"
say "done"
