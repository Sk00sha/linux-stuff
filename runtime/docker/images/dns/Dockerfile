# Small DNS server for module 05 (dnsmasq serving the company.local zone).
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends dnsmasq dnsutils iproute2 \
 && rm -rf /var/lib/apt/lists/*
COPY images/dns/dnsmasq.conf /etc/dnsmasq.conf
LABEL course=linux-basics
EXPOSE 53/udp 53/tcp
CMD ["dnsmasq", "--keep-in-foreground", "--log-queries", "--log-facility=-"]
