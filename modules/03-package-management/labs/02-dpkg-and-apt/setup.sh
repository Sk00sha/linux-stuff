#!/usr/bin/env bash
# Prepare lab 03-package-management/dpkg-and-apt.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=03-package-management/dpkg-and-apt
H=ubuntu

require_services "$H"
ensure_user "$H" bob
say "resetting packages on $H (offline)"
on "$H" <<'SCRIPT'
set -e
export DEBIAN_FRONTEND=noninteractive
dpkg -P bob-notes >/dev/null 2>&1 || true
dpkg -P figlet >/dev/null 2>&1 || true
dpkg -s nano >/dev/null 2>&1 | grep -q 'install ok installed' || true
if ! dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -q 'install ok installed'; then
  apt-get install -y -q --no-download nano >/dev/null 2>&1
fi
dpkg-query -W -f='${Status}' vim 2>/dev/null | grep -q 'install ok installed' ||
  apt-get install -y -q --no-download vim >/dev/null 2>&1

# Build the vendor package: an architecture-independent script that needs figlet.
work=$(mktemp -d)
mkdir -p "$work/DEBIAN" "$work/usr/bin" "$work/usr/share/doc/bob-notes"
cat > "$work/DEBIAN/control" <<'CTL'
Package: bob-notes
Version: 1.0-1
Section: utils
Priority: optional
Architecture: all
Depends: figlet
Maintainer: Notes Vendor <support@notes-vendor.example>
Description: Team notes banner for the Mercury project
 Prints the Mercury banner and the current team notes.
CTL
cat > "$work/usr/bin/bob-notes" <<'BIN'
#!/bin/sh
figlet -f small "Mercury notes"
echo "* client demo: rehearse the database failover"
echo "* remember: dnf on Rocky, apt on Ubuntu"
BIN
chmod 755 "$work/usr/bin/bob-notes"
echo "bob-notes is free for internal use at Caleston." > "$work/usr/share/doc/bob-notes/copyright"
mkdir -p /home/bob/packages
dpkg-deb --root-owner-group -b "$work" /home/bob/packages/bob-notes_1.0-1_all.deb >/dev/null
rm -rf "$work"
rm -f /home/bob/tree-files.txt /home/bob/whatis-owner.txt
chown -R bob:bob /home/bob/packages
SCRIPT
mark_lab "$H" "$LAB"
say "done"
