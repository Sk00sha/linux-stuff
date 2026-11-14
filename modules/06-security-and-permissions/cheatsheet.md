# Cheatsheet — Security and File Permissions

## Accounts

| Command | Does |
|---|---|
| `id [u]`, `groups`, `who`, `w`, `last` | identity and logins |
| `su - USER` / `sudo CMD` / `sudo -i` / `sudo -l` | switch user / run as root / root shell / my rules |
| `useradd -m -u UID -g G -G G1,G2 -s SHELL -c TEXT -d DIR NAME` | create user |
| `usermod -aG G USER`, `-s`, `-L/-U`, `-e 1` | add group, shell, lock/unlock, expire |
| `passwd [USER]`, `passwd -l/-u/-S USER`, `chage -l USER` | passwords |
| `userdel -r USER`, `groupadd [-g GID] G`, `groupdel G`, `gpasswd -d U G` | remove, groups |

`/etc/passwd` name:x:UID:GID:comment:home:shell · `/etc/shadow` hashes (`!` = locked) · `/etc/group` name:x:GID:members

## sudo

`visudo` · `visudo -f /etc/sudoers.d/NAME` (mode 440, no dots in name) · `visudo -c`

`%devops ALL=(root) NOPASSWD: /usr/bin/systemctl`

## Permissions

| Command | Does |
|---|---|
| `chmod 640 f` / `chmod u+x,go-w f` / `chmod -R u=rwX,go=rX d` | octal / symbolic / dirs-only x |
| `chown user:group f` / `chgrp g f` / `-R` | owners |
| `umask` (0022 → 644/755, 0002 → 664/775) | defaults |
| `chmod 4755` / `2770` / `1777` (`u+s`, `g+s`, `+t`) | setuid / setgid / sticky |

r=4 w=2 x=1 · dir: r=list, w=create/delete, x=enter

## SSH

| Command | Does |
|---|---|
| `ssh-keygen -t ed25519` | key pair |
| `ssh-copy-id user@host` | install public key |
| `ssh user@host [cmd]` / `ssh -o BatchMode=yes` | log in / fail instead of prompting |
| `scp [-r] [-p] SRC user@host:DEST` | copy |
| `~/.ssh` 700, `authorized_keys` 600, private key 600 | perms |
| `~/.ssh/config`: `Host x` `HostName` `User` `IdentityFile` | shortcuts |

## iptables

| Command | Does |
|---|---|
| `iptables -L -n -v --line-numbers` / `-S` | list |
| `-A`/`-I CHAIN N`/`-D CHAIN N`/`-F`/`-P CHAIN DROP` | append/insert/delete/flush/policy |
| `-p tcp --dport 22 -s 10.0.0.5 -j ACCEPT` | match + target |
| `-i lo -j ACCEPT` · `-m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT` | essentials |
| `iptables-save > rules.v4` / `iptables-restore < rules.v4` | persist |

## cron

`m h dom mon dow cmd` · `*/15` `1-5` `a,b` `@daily` `@reboot` · `crontab -e/-l/-r`, `crontab -u USER -l`
· `/etc/cron.d/*` has a user field · redirect `>> log 2>&1` · logs: `/var/log/syslog` (CRON) or `/var/log/cron`
