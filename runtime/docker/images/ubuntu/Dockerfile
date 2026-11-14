# Learner image for the Debian family (modules 01, 03, 04, 05, 06).
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
# Keep downloaded .deb files and package lists so that apt works offline
# during labs (graders and lab tasks never need the internet).
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
 && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/01keep-debs
COPY packages-ubuntu.txt /tmp/packages.txt
RUN apt-get update \
 && apt-get install -y --no-install-recommends unminimize \
 && (yes | unminimize) \
 && xargs -a /tmp/packages.txt apt-get install -y --no-install-recommends \
 && apt-get install -y --download-only figlet \
 && mandb -q || true
# Learner account. The stock "ubuntu" user is removed so bob gets UID 1000.
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -u 1000 -s /bin/bash -c "Bob (new hire)" bob \
 && echo 'bob:caleston123' | chpasswd \
 && usermod -aG sudo bob \
 && echo 'bob ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-bob \
 && chmod 440 /etc/sudoers.d/90-bob \
 && install -o bob -g bob -m 644 /dev/null /home/bob/.sudo_as_admin_successful \
 && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && updatedb || true
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY course-listen webctl /usr/local/bin/
COPY umask.sh /etc/profile.d/umask.sh
RUN sed -i '1i [ "$(id -u)" -ge 1000 ] && umask 0002 || umask 0022' /etc/bash.bashrc 2>/dev/null || true
LABEL course=linux-basics
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
