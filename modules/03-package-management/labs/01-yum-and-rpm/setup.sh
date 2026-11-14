#!/usr/bin/env bash
# Prepare lab 03-package-management/yum-and-rpm on the rocky container.
# shellcheck source=../../../../lib/setup-helpers.sh
. "${COURSE_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}/lib/setup-helpers.sh"
LAB=03-package-management/yum-and-rpm
H=rocky

require_services "$H"
ensure_user "$H" bob
say "resetting packages and building /opt/localrepo on $H (offline)"
on "$H" <<'SCRIPT'
set -e
DNF="dnf -y -q --disablerepo=* --enablerepo=course-offline"
rpm -q bob-tool >/dev/null 2>&1 && rpm -e bob-tool
for p in httpd tree; do rpm -q "$p" >/dev/null 2>&1 && $DNF remove "$p" >/dev/null; done
rpm -q telnet >/dev/null 2>&1 || $DNF install telnet >/dev/null
rm -f /etc/yum.repos.d/local.repo /home/bob/wget-owner.txt

# Build bob-tool-1.0 as a noarch RPM and publish it in /opt/localrepo.
top=$(mktemp -d)
mkdir -p "$top"/{SPECS,SOURCES,BUILD,RPMS,SRPMS}
cat > "$top/SPECS/bob-tool.spec" <<'SPEC'
Name:           bob-tool
Version:        1.0
Release:        1
Summary:        Caleston internal helper for the Mercury reporting server
License:        MIT
BuildArch:      noarch

%description
Prints the status of the Mercury reporting backend.

%install
mkdir -p %{buildroot}/usr/bin
cat > %{buildroot}/usr/bin/bob-tool <<'EOS'
#!/bin/sh
echo "bob-tool 1.0: reporting backend looks healthy"
EOS
chmod 755 %{buildroot}/usr/bin/bob-tool

%files
/usr/bin/bob-tool
SPEC
rpmbuild --quiet --define "_topdir $top" -bb "$top/SPECS/bob-tool.spec" >/dev/null 2>&1
rm -rf /opt/localrepo
mkdir -p /opt/localrepo
cp "$top"/RPMS/noarch/bob-tool-1.0-1.noarch.rpm /opt/localrepo/
createrepo_c -q /opt/localrepo
rm -rf "$top"
dnf clean all -q >/dev/null 2>&1 || true
SCRIPT
mark_lab "$H" "$LAB"
say "done"
