# Solution — Firewall app01 and db01

In real life you'd `ssh bob@app01` from devbox and run these with `sudo`.
The automated test runs them as root on each server directly.

The order is the important part: essentials (loopback, replies) first, then
the specific services, then the DROP policy last — so the SSH session you're
working in is never cut off.

## app01 — t1, t2, t3

```bash solution target=app01 user=root
iptables -F INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -s 10.10.2.10 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -P INPUT DROP
iptables -L INPUT -n --line-numbers
```

- **lo**: local processes (and Docker's DNS at 127.0.0.11) use loopback.
- **ESTABLISHED,RELATED**: without it, app01's connection to db01 would get
  its SYN out, but the SYN-ACK coming back would be dropped by INPUT.
- **22 from devbox only**, **80 from anywhere**, then **policy DROP** blocks
  8080 and everything else.

## db01 — t4, t5

```bash solution target=db01 user=root
iptables -F INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -s 10.10.2.10 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -s 10.10.2.30 -j ACCEPT
iptables -P INPUT DROP
iptables -S INPUT
```

## Verify from devbox

```bash solution target=devbox user=bob
nc -zv -w 2 10.10.2.30 22 && nc -zv -w 2 10.10.2.30 80
nc -zv -w 2 10.10.2.30 8080 || echo "8080 blocked, as intended"
nc -zv -w 2 10.10.2.20 5432 || echo "5432 blocked from devbox, as intended"
```

## Making it permanent (not needed in the lab)

```bash norun
sudo iptables-save | sudo tee /etc/iptables/rules.v4
sudo apt install iptables-persistent      # restores rules.v4 at boot
```
