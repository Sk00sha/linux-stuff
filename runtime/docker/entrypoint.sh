#!/usr/bin/env bash
# Shared entrypoint for Linux Basics course containers (non-systemd images).
# Starts sshd and cron, applies optional static routes and listeners, then
# runs the container command (default: sleep forever).
set -u

log() { echo "[entrypoint] $*"; }

# SSH server
if command -v sshd >/dev/null 2>&1 || [ -x /usr/sbin/sshd ]; then
  mkdir -p /run/sshd
  ssh-keygen -A >/dev/null 2>&1
  /usr/sbin/sshd && log "sshd started"
fi

# Cron daemon (Debian: cron, Red Hat: crond)
if command -v cron >/dev/null 2>&1; then
  cron && log "cron started"
elif command -v crond >/dev/null 2>&1; then
  crond && log "crond started"
fi

# Optional static routes: COURSE_ROUTES="10.10.1.0/24 via 10.10.2.254;..."
if [ -n "${COURSE_ROUTES:-}" ]; then
  IFS=';' read -r -a routes <<<"$COURSE_ROUTES"
  for r in "${routes[@]}"; do
    # shellcheck disable=SC2086
    ip route replace $r && log "route added: $r"
  done
fi

# Optional TCP listeners: COURSE_LISTEN="80 5432"
if [ -n "${COURSE_LISTEN:-}" ]; then
  for p in $COURSE_LISTEN; do
    nohup /usr/local/bin/course-listen "$p" >/var/log/course-listen-"$p".log 2>&1 &
    log "listener started on port $p"
  done
fi

# Optional mini web app (module 05 troubleshooting lab)
if [ "${COURSE_WEBAPP:-0}" = "1" ] && [ -x /usr/local/bin/webctl ]; then
  /usr/local/bin/webctl start
fi

hostname > /etc/course-host 2>/dev/null || true

if [ "$#" -eq 0 ]; then
  exec sleep infinity
fi
exec "$@"
