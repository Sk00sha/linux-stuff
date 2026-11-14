#!/usr/bin/env bash
# Provision a course VM (bob-vm or nfs-server). Idempotent.
# Used by Vagrant, and by the Multipass / Incus instructions in the README.
set -euo pipefail
ROLE=${COURSE_ROLE:-bob-vm}

if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -q
  apt-get install -y -q bash-completion man-db manpages vim nano less tree file iproute2 \
    iputils-ping dnsutils netcat-openbsd curl openssh-server sudo cron iptables procps \
    psmisc lsof tar gzip bzip2 xz-utils plocate python3 lvm2 nfs-common gdisk parted \
    xfsprogs pciutils usbutils lshw dosfstools
  [ "$ROLE" = nfs-server ] && apt-get install -y -q nfs-kernel-server
  SYSLOG=/var/log/syslog
  # Ubuntu 24.04 no longer ships rsyslog in minimal images; module 02 uses /var/log/syslog
  dpkg -s rsyslog >/dev/null 2>&1 || apt-get install -y -q rsyslog
  SUDO_GROUP=sudo
else
  dnf -y install bash-completion man-db man-pages vim-enhanced nano less tree file iproute \
    iputils bind-utils nmap-ncat curl openssh-server sudo cronie iptables-nft procps-ng \
    psmisc lsof tar gzip bzip2 xz plocate python3 lvm2 nfs-utils gdisk parted xfsprogs \
    pciutils usbutils lshw dosfstools rsyslog
  SYSLOG=/var/log/messages
  SUDO_GROUP=wheel
fi
systemctl enable --now rsyslog >/dev/null 2>&1 || true

if ! id bob >/dev/null 2>&1; then
  useradd -m -s /bin/bash -c "Bob (new hire)" bob
  echo 'bob:caleston123' | chpasswd
fi
usermod -aG "$SUDO_GROUP" bob
echo 'bob ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-bob
chmod 440 /etc/sudoers.d/90-bob

# Marker that lab setup scripts check before touching disks or the kernel.
cat > /etc/course-vm <<MARK
role=$ROLE
syslog=$SYSLOG
MARK

cat > /etc/hosts.course <<'HOSTS'
192.168.56.10 bob-vm
192.168.56.20 nfs-server
HOSTS
grep -q nfs-server /etc/hosts || cat /etc/hosts.course >> /etc/hosts

if [ "$ROLE" = bob-vm ]; then
  # Map the three blank data disks to stable names in /etc/course-disks.
  # 1) Prefer serial numbers set by the hypervisor (disk-a, disk-b, disk-c).
  # 2) Otherwise pick unpartitioned, unmounted disks by size (1G, 1G, 2G).
  # 3) Otherwise (e.g. Multipass) create loop-backed disks inside the VM.
  if [ ! -s /etc/course-disks ]; then
    : > /etc/course-disks.tmp
    for name in disk-a disk-b disk-c; do
      dev=$(ls /dev/disk/by-id/ 2>/dev/null | grep -E "${name}|${name/-/}|${name/-/--}" | grep -v -- '-part' | head -1 || true)
      [ -n "$dev" ] && echo "$name=/dev/disk/by-id/$dev" >> /etc/course-disks.tmp
    done
    if [ "$(wc -l < /etc/course-disks.tmp)" -lt 3 ]; then
      : > /etc/course-disks.tmp
      root_disk=$(lsblk -no PKNAME "$(findmnt -no SOURCE /)" 2>/dev/null | head -1 || true)
      mapfile -t blanks < <(lsblk -dbno NAME,SIZE,TYPE | awk '$3=="disk"{print $1, $2}' |
        while read -r n s; do
          [ "$n" = "$root_disk" ] && continue
          [ -n "$(lsblk -no NAME "/dev/$n" | sed 1d)" ] && continue
          blkid "/dev/$n" >/dev/null 2>&1 && continue
          echo "$s $n"
        done | sort -n | awk '{print $2}')
      if [ "${#blanks[@]}" -ge 3 ]; then
        i=0
        for name in disk-a disk-b disk-c; do
          echo "$name=/dev/${blanks[$i]}" >> /etc/course-disks.tmp; i=$((i + 1))
        done
      fi
    fi
    if [ "$(wc -l < /etc/course-disks.tmp)" -lt 3 ]; then
      echo "No blank data disks found: creating loop-backed disks under /var/lib/course-disks"
      mkdir -p /var/lib/course-disks
      : > /etc/course-disks.tmp
      for spec in disk-a:1 disk-b:1 disk-c:2; do
        n=${spec%%:*}; g=${spec##*:}
        [ -f "/var/lib/course-disks/$n.img" ] || truncate -s "${g}G" "/var/lib/course-disks/$n.img"
        echo "$n=loop:/var/lib/course-disks/$n.img" >> /etc/course-disks.tmp
      done
      cat > /etc/systemd/system/course-loop-disks.service <<'UNIT'
[Unit]
Description=Attach the course's loop-backed practice disks
DefaultDependencies=no
Before=local-fs-pre.target lvm2-activation-early.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/course-disk --attach-loops
[Install]
WantedBy=local-fs-pre.target
UNIT
      systemctl daemon-reload
      systemctl enable course-loop-disks.service
    fi
    mv /etc/course-disks.tmp /etc/course-disks
  fi

  cat > /usr/local/sbin/course-disk <<'HELPER'
#!/usr/bin/env bash
# course-disk NAME  -> print the block device for practice disk NAME (disk-a|disk-b|disk-c)
# course-disk --list | --attach-loops
set -eu
attach() {
  while IFS='=' read -r n target; do
    case "$target" in
      loop:*) f=${target#loop:}
              losetup -j "$f" | grep -q . || losetup -fP "$f" ;;
    esac
  done < /etc/course-disks
}
resolve() {
  local target
  target=$(grep "^$1=" /etc/course-disks | cut -d= -f2-)
  [ -n "$target" ] || { echo "unknown disk $1" >&2; exit 1; }
  case "$target" in
    loop:*) losetup -j "${target#loop:}" | head -1 | cut -d: -f1 ;;
    *) readlink -f "$target" ;;
  esac
}
case "${1:-}" in
  --attach-loops) attach ;;
  --list) for n in disk-a disk-b disk-c; do echo "$n $(resolve $n)"; done ;;
  disk-?) resolve "$1" ;;
  *) echo "usage: course-disk disk-a|disk-b|disk-c|--list" >&2; exit 2 ;;
esac
HELPER
  chmod 755 /usr/local/sbin/course-disk
  ln -sf /usr/local/sbin/course-disk /usr/local/bin/course-disk
  /usr/local/sbin/course-disk --attach-loops
  echo "Practice disks:"; /usr/local/sbin/course-disk --list
fi

if [ "$ROLE" = nfs-server ]; then
  mkdir -p /srv/share
  echo "Shared from nfs-server" > /srv/share/README.txt
  systemctl enable --now nfs-server
fi

echo "Provisioning of $ROLE complete."
