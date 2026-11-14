# Hints — Route the client to the backend

## t1

### Level 1

The `ip` command shows addresses. CIDR notation is the address followed by `/` and the prefix length.

### Level 2

`ip addr show eth0` (or `ip -br addr`) lists `inet ADDRESS/PREFIX`.

### Level 3

`ip -4 -br addr show eth0` shows `10.10.1.10/24`; write that into `/home/bob/client-ip.txt`.

## t2

### Level 1

A route says "to reach network X, hand packets to gateway Y". The gateway must be on your own subnet.

### Level 2

Find the router's frontend address with `getent hosts router`, then use `sudo ip route add NETWORK via GATEWAY`.

### Level 3

`sudo ip route add 10.10.2.0/24 via 10.10.1.254`, then `ip route get 10.10.2.20`.

## t3

### Level 1

Once the route exists, ICMP echo should work in both directions (db01 already knows the way back).

### Level 2

`ping -c 3 10.10.2.20`. If it fails, check `ip route` again.

### Level 3

`ping -c 3 10.10.2.20` should show `0% packet loss`.

## t4

### Level 1

You need a tool that opens a raw TCP connection and prints whatever the server sends.

### Level 2

`nc HOST PORT` (netcat) connects and prints the server's data. Redirect its output to the file.

### Level 3

`nc -w 2 10.10.2.20 5432 > /home/bob/db-banner.txt`, then `cat /home/bob/db-banner.txt`.
