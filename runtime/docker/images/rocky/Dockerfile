# Learner image for the Red Hat family (module 03).
FROM rockylinux:9
# Base tools + everything module 03 needs, plus an offline repository so that
# "dnf install httpd tree" works without internet during the lab.
RUN dnf -y install dnf-plugins-core epel-release \
 && dnf -y install bash-completion man-db man-pages vim-enhanced nano less tree file \
      iproute iputils bind-utils nmap-ncat curl openssh-server openssh-clients sudo \
      cronie iptables-nft procps-ng psmisc lsof tar gzip bzip2 xz plocate python3 \
      wget telnet createrepo_c rpm-build \
 && mkdir -p /opt/offline-repo \
 && dnf -y download --resolve --alldeps --destdir /opt/offline-repo httpd tree telnet \
 && createrepo_c -q /opt/offline-repo \
 && printf '[course-offline]\nname=Course offline packages\nbaseurl=file:///opt/offline-repo\nenabled=1\ngpgcheck=0\npriority=1\n' \
      > /etc/yum.repos.d/course-offline.repo \
 && sed -i 's/^enabled=1/enabled=1\nskip_if_unavailable=True/' /etc/yum.repos.d/rocky*.repo /etc/yum.repos.d/epel*.repo \
 && rpm -e --nodeps tree \
 && dnf clean all
RUN useradd -m -u 1000 -s /bin/bash -c "Bob (new hire)" bob \
 && echo 'bob:caleston123' | chpasswd \
 && usermod -aG wheel bob \
 && echo 'bob ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-bob \
 && chmod 440 /etc/sudoers.d/90-bob \
 && (updatedb || true)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY course-listen webctl /usr/local/bin/
COPY umask.sh /etc/profile.d/umask.sh
RUN sed -i '1i [ "$(id -u)" -ge 1000 ] && umask 0002 || umask 0022' /etc/bash.bashrc 2>/dev/null || true
LABEL course=linux-basics
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
