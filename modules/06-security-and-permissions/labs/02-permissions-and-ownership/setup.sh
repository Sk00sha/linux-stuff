#!/usr/bin/env bash
# Prepare lab 06-security-and-permissions/permissions-and-ownership.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=06-security-and-permissions/permissions-and-ownership
H=devbox

require_services "$H"
standard_bob "$H"
say "creating a badly-permissioned project tree on $H"
on "$H" <<'SCRIPT'
set -e
getent group devops >/dev/null || groupadd devops
usermod -aG devops bob
rm -rf /srv/mercury /srv/shared
mkdir -p /srv/mercury/app/{bin,config,src,logs} /srv/mercury/docs /srv/shared
echo 'host=db01 user=mercury password=m3rcury-demo' > /srv/mercury/app/config/db.conf
echo 'listen=0.0.0.0:80' > /srv/mercury/app/config/web.conf
printf '#!/bin/bash\necho "deploying mercury"\n' > /srv/mercury/app/bin/deploy.sh
for f in main.py db.py web.py; do echo "# $f" > /srv/mercury/app/src/$f; done
echo "Mercury design notes" > /srv/mercury/docs/README.md
touch /srv/mercury/app/logs/app.log
chown -R root:root /srv/mercury /srv/shared
chmod -R 777 /srv/mercury
chmod 777 /srv/shared
echo "priya's draft" > /srv/shared/priya-draft.txt
SCRIPT
mark_lab "$H" "$LAB"
say "done"
