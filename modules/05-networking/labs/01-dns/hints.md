# Hints — Teach the client to find the database

## t1

### Level 1

The local, highest-priority source of names is a plain text file in `/etc`.

### Level 2

Each line of `/etc/hosts` is `IP name [aliases...]`. Edit with `sudo vi /etc/hosts`.

### Level 3

`echo "10.10.2.20 db01" | sudo tee -a /etc/hosts`, then `getent hosts db01`.

## t2

### Level 1

The resolver reads the DNS server's address from `/etc/resolv.conf`.

### Level 2

Replace the existing `nameserver` line with one pointing at the company DNS server — don't keep the old one.

### Level 3

Edit `/etc/resolv.conf` so it contains `nameserver 10.10.1.53` (and no other nameserver). Test with `getent hosts db.company.local`.

## t3

### Level 1

Short names are completed with domains from a list in the same file as t2.

### Level 2

Add a `search` line to `/etc/resolv.conf`.

### Level 3

Add `search company.local` to `/etc/resolv.conf`, then `getent hosts www`.

## t4

### Level 1

MX records name the mail server for a domain. Query DNS for that record type.

### Level 2

`dig DOMAIN MX` (add `+short` for a compact answer). The answer is a priority followed by a host name.

### Level 3

`dig company.local MX +short` prints `10 mail.company.local.` — write `mail.company.local` into `/home/bob/mx.txt`.
