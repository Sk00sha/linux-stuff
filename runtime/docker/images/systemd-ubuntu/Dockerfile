# systemd-enabled Ubuntu image (module 07 fallback and module 09 demo-web).
# Needs: privileged, cgroupns host, /sys/fs/cgroup mounted rw, tmpfs /run.
# Works reliably on Linux hosts; on macOS/Windows prefer the VM runtime.
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC container=docker
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
 && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/01keep-debs
COPY packages-ubuntu.txt /tmp/packages.txt
RUN apt-get update \
 && xargs -a /tmp/packages.txt apt-get install -y --no-install-recommends \
 && apt-get install -y --no-install-recommends systemd systemd-sysv dbus python3-psycopg \
      postgresql-client logrotate \
 && (mandb -q || true) \
 && find /etc/systemd/system /lib/systemd/system \
      \( -path '*.wants/*' -name '*getty*' -o -name 'systemd-firstboot*' -o -name 'systemd-udevd*' \) \
      -exec rm -f {} + \
 && systemctl mask systemd-udevd.service systemd-udevd-kernel.socket systemd-udevd-control.socket \
      getty.target console-getty.service systemd-firstboot.service systemd-resolved.service \
      systemd-networkd.service sys-kernel-config.mount 2>/dev/null || true \
 && systemctl enable ssh cron
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -u 1000 -s /bin/bash -c "Bob (new hire)" bob \
 && echo 'bob:caleston123' | chpasswd \
 && usermod -aG sudo bob \
 && echo 'bob ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-bob \
 && chmod 440 /etc/sudoers.d/90-bob \
 && install -o bob -g bob -m 644 /dev/null /home/bob/.sudo_as_admin_successful
COPY course-listen /usr/local/bin/
LABEL course=linux-basics
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
