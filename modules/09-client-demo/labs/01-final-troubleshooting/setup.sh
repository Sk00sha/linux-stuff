#!/usr/bin/env bash
# Prepare the finale: install a healthy Mercury stack on demo-web, then inject
# eight faults. SEED (default 1, or "random") picks the variant of each fault
# and the injection order, so every seed is reproducible.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=09-client-demo/final-troubleshooting
H=demo-web
F=/course/modules/09-client-demo/labs/01-final-troubleshooting/files

SEED=${SEED:-1}
[ "$SEED" = random ] && SEED=$(( (RANDOM % 9000) + 1000 ))
case "$SEED" in ''|*[!0-9]*) die "SEED must be a number or 'random'";; esac

require_services demo-web demo-db
standard_bob "$H"
say "waiting for the database"
for _ in $(seq 30); do
  docker exec lbc-demo-db pg_isready -q -U mercury -d mercury 2>/dev/null && break; sleep 1
done

say "installing a healthy Mercury stack on $H"
on "$H" <<SCRIPT
set -e
for i in \$(seq 30); do systemctl is-system-running 2>/dev/null | grep -qE 'running|degraded' && break; sleep 1; done
iptables -F OUTPUT; iptables -P OUTPUT ACCEPT
dpkg-query -W -f='\${Status}' python3-psycopg 2>/dev/null | grep -q 'install ok installed' ||
  DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-download python3-psycopg >/dev/null
id mercury >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin mercury
install -m 755 $F/mercury-web /usr/local/bin/mercury-web
install -m 755 $F/mercury-rotate /usr/local/bin/mercury-rotate
rm -f /usr/local/bin/mercury-webapp
install -d -m 755 /etc/mercury
install -m 640 -o root -g mercury $F/app.conf /etc/mercury/app.conf
install -d -m 750 -o mercury -g mercury /var/log/mercury
find /var/lib/mercury -mindepth 1 -delete 2>/dev/null || true
chown mercury:mercury /var/lib/mercury; chmod 755 /var/lib/mercury
install -m 644 $F/mercury-web.service /etc/systemd/system/mercury-web.service
rm -rf /etc/systemd/system/mercury-web.service.d
install -m 644 $F/mercury-logrotate.cron /etc/cron.d/mercury-logrotate
rm -f /etc/cron.d/mercury-logrotate.disabled
[ -f /etc/hosts.course-orig ] || cp /etc/hosts /etc/hosts.course-orig
{ cat /etc/hosts.course-orig; echo "10.10.9.20  db01.caleston.local db01"; } > /tmp/hosts.new
cat /tmp/hosts.new > /etc/hosts
systemctl daemon-reload
systemctl enable --now cron >/dev/null 2>&1
systemctl enable mercury-web >/dev/null 2>&1
systemctl restart mercury-web
SCRIPT

# sanity: the healthy stack must work before we break it
ok=""
for _ in $(seq 15); do
  if run_on "$H" "curl -s -m 5 http://localhost/" 2>/dev/null | grep -q 'Mercury is live'; then ok=1; break; fi
  sleep 1
done
[ -n "$ok" ] || die "the healthy baseline does not work — please report this as a course bug"

say "injecting faults (seed $SEED)"
v() { echo $(( ((SEED * 2654435761 + $1 * 40503) >> 9) % 2 )); }   # variant 0/1 per fault, from a hash of the seed
F1=$(v 1) F2=$(v 2) F3=$(v 3) F4=$(v 5) F5=$(v 7) F6=$(v 11) F8=$(v 13)

declare -A FAULT
FAULT[1]="systemctl disable --now mercury-web >/dev/null 2>&1
sed -i 's#^ExecStart=.*#ExecStart=$([ "$F1" = 0 ] && echo /usr/local/bin/mercury-webapp || echo /usr/bin/mercury-web)#' /etc/systemd/system/mercury-web.service"
FAULT[2]="chown root:root /etc/mercury/app.conf; chmod $([ "$F2" = 0 ] && echo 600 || echo 640) /etc/mercury/app.conf"
FAULT[3]="grep -v caleston.local /etc/hosts > /tmp/hosts.new
echo '$([ "$F3" = 0 ] && echo "10.10.9.21  db01.caleston.local db01" || echo "10.10.9.20  db01.caleston.lcoal db01")' >> /tmp/hosts.new
cat /tmp/hosts.new > /etc/hosts"
FAULT[4]="$([ "$F4" = 0 ] && echo "iptables -A OUTPUT -p tcp --dport 5432 -j DROP" || echo "iptables -I OUTPUT 1 -d 10.10.9.20/32 -p tcp --dport 5432 -j REJECT")"
FAULT[5]="mkdir -p /var/lib/mercury/$([ "$F5" = 0 ] && echo .cache || echo tmp)
dd if=/dev/zero of=/var/lib/mercury/$([ "$F5" = 0 ] && echo .cache/core.dump || echo tmp/upload-0001.part) bs=64k 2>/dev/null || true
chown -R mercury:mercury /var/lib/mercury"
FAULT[6]="$([ "$F6" = 0 ] && echo "rm -f /etc/cron.d/mercury-logrotate" || echo "sed -i 's/^15 2/#15 2/' /etc/cron.d/mercury-logrotate")"
FAULT[7]="dpkg -r python3-psycopg >/dev/null 2>&1"
FAULT[8]="sed -i '/^\\[Service\\]/a Environment=PATH=$([ "$F8" = 0 ] && echo /opt/mercury/bin || echo /usr/local/sbin:/usr/local/bin:/opt/mercury/bin)' /etc/systemd/system/mercury-web.service"

# seed-dependent order (cosmetic, but it changes what the journal shows first)
order=$(for i in 1 2 3 4 5 6 7 8; do echo "$(( (i * 7919 + SEED * 104729) % 1000 )) $i"; done | sort -n | awk '{print $2}')
for i in $order; do
  run_on "$H" "${FAULT[$i]}"
done
run_on "$H" "systemctl daemon-reload; rm -f /var/log/mercury/access.log; journalctl --rotate >/dev/null 2>&1; journalctl --vacuum-time=1s >/dev/null 2>&1 || true"
run_on "$H" "echo $SEED > /etc/course-lab-seed"
mark_lab demo-web "$LAB"
say "done. The demo is in 68 minutes. Good luck."
