#!/usr/bin/env bash
# Prepare lab 01-shell-1/working-with-the-shell on the ubuntu container.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=01-shell-1/working-with-the-shell
H=ubuntu

require_services "$H"
ensure_user "$H" bob
say "preparing /home/bob on $H"
on "$H" <<'SCRIPT'
set -e
cd /home/bob
rm -rf asia projects projetcs old-contractor-tmp notes whatis.txt
mkdir -p notes projetcs/mercury/src old-contractor-tmp/cache/2019
cat > notes/city-guide.txt <<'TXT'
Mumbai office — city guide for visitors
=======================================
Office: 14th floor, Lower Parel. Reception opens at 09:00.
Nearest station: Lower Parel (Western line).
Lunch: the canteen on 3 serves vegetarian thalis until 14:30.
TXT
echo "Project Mercury — client demo build" > projetcs/README.md
printf '#!/bin/bash\necho "mercury starting"\n' > projetcs/mercury/src/start.sh
for i in 1 2 3; do echo "stale cache $i" > "old-contractor-tmp/cache/2019/blob$i.tmp"; done
echo "do not keep" > old-contractor-tmp/notes.txt
chown -R bob:bob /home/bob
SCRIPT
mark_lab "$H" "$LAB"
say "done"
