# Hints — Firewall app01 and db01

## t1

### Level 1

A rule can match on protocol, destination port and source address at the same time.

### Level 2

On app01: `sudo iptables -A INPUT -p tcp --dport 22 -s SOURCE -j ACCEPT`. Something else must stop SSH from other hosts (see t3).

### Level 3

`sudo iptables -A INPUT -p tcp --dport 22 -s 10.10.2.10 -j ACCEPT` — then the DROP policy from t3 blocks everyone else.

## t2

### Level 1

"From anywhere" means: no source restriction.

### Level 2

`-p tcp --dport 80 -j ACCEPT` on app01's INPUT chain.

### Level 3

`sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT`

## t3

### Level 1

Default deny: the chain policy decides what happens to everything no rule accepted. But app01's own outgoing connections get replies on INPUT too — and local processes talk over loopback.

### Level 2

You need `-i lo -j ACCEPT`, a `conntrack --ctstate ESTABLISHED,RELATED` rule, and `-P INPUT DROP` last.

### Level 3

```text
sudo iptables -I INPUT 1 -i lo -j ACCEPT
sudo iptables -I INPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -P INPUT DROP
```

## t4

### Level 1

Same pattern as t1, on the other server and another port.

### Level 2

On db01: allow 5432 from app01's IP only, then default-deny (t5).

### Level 3

`sudo iptables -A INPUT -p tcp --dport 5432 -s 10.10.2.30 -j ACCEPT`

## t5

### Level 1

You're probably logged in to db01 over SSH from devbox. Which rule must exist *before* you change the policy?

### Level 2

Loopback, established/related, SSH from devbox, then `-P INPUT DROP`.

### Level 3

```text
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -s 10.10.2.10 -j ACCEPT
sudo iptables -P INPUT DROP
```
