#!/usr/bin/env bash
# End-to-end lab tests. For every selected lab:
#   setup -> check must FAIL -> apply solution.md -> check must PASS
#         -> reset -> check must FAIL again
#
# Usage:
#   tests/test_labs.sh                 # every docker lab
#   tests/test_labs.sh 05              # labs of modules whose id starts with 05
#   tests/test_labs.sh --lab iptables  # one lab
#   RUNTIME=vm tests/test_labs.sh 08   # VM labs (needs `make vm-up`)
#   KEEP=1 ...                         # leave containers running afterwards
set -uo pipefail
cd "$(dirname "$0")/.."
COURSE=./bin/course
RUNTIME=${RUNTIME:-docker}
export NO_COLOR=1
COURSE_PROGRESS_FILE=$(mktemp)
export COURSE_PROGRESS_FILE
LOGDIR=${LOGDIR:-$(mktemp -d)}

if [ "${1:-}" = --lab ]; then
  labs=("$2")
else
  mapfile -t labs < <($COURSE labs "${1:-}" --runtime "$RUNTIME")
fi
[ "${#labs[@]}" -gt 0 ] || { echo "no labs selected"; exit 1; }

ok=0; bad=0; failed=()
step() { printf '  %-34s' "$1"; }
result() { if [ "$1" = ok ]; then echo "ok"; else echo "FAILED ($2)"; fi; }

for lab in "${labs[@]}"; do
  log="$LOGDIR/$(echo "$lab" | tr '/' '_').log"
  echo "== $lab  (log: $log)"
  rt=(--runtime "$RUNTIME")
  status=ok
  {
    step "setup"
    if $COURSE start "$lab" "${rt[@]}" --no-shell --fresh >>"$log" 2>&1; then result ok; else result bad "setup failed"; status=bad; fi

    if [ $status = ok ]; then
      step "check fails before solving"
      if $COURSE check "$lab" "${rt[@]}" >>"$log" 2>&1; then result bad "check passed on a fresh lab"; status=bad; else result ok; fi
    fi

    if [ $status = ok ]; then
      step "apply solution.md"
      script=$(mktemp)
      $COURSE solution-script "$lab" "${rt[@]}" >"$script"
      if COURSE_RUNTIME=$($COURSE info "$lab" runtime "${rt[@]}") bash "$script" >>"$log" 2>&1; then result ok; else result bad "solution script failed"; status=bad; fi
      rm -f "$script"
    fi

    if [ $status = ok ]; then
      step "check passes after solution"
      if $COURSE check "$lab" "${rt[@]}" >>"$log" 2>&1; then result ok; else result bad "check failed"; status=bad; fi
    fi

    if [ $status = ok ]; then
      step "reset + check fails again"
      $COURSE reset "$lab" "${rt[@]}" >>"$log" 2>&1
      if $COURSE check "$lab" "${rt[@]}" >>"$log" 2>&1; then result bad "check passed after reset"; status=bad; else result ok; fi
    fi
  }
  if [ $status = ok ]; then ok=$((ok + 1)); else bad=$((bad + 1)); failed+=("$lab"); tail -25 "$log" | sed 's/^/    | /'; fi
done

if [ -z "${KEEP:-}" ] && [ "$RUNTIME" = docker ]; then
  docker compose -f runtime/docker/compose.yaml --profile '*' down -v --remove-orphans >/dev/null 2>&1
fi
rm -f "$COURSE_PROGRESS_FILE"
echo
echo "labs passed: $ok, failed: $bad ${failed[*]:+(${failed[*]})}"
[ "$bad" -eq 0 ]
