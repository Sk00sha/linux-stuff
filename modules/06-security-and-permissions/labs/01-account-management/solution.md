# Solution — Rebuild the accounts on devbox

Everything runs as root on `devbox`.

## t1 — bob with UID 2000

`-m` creates `/home/bob` from `/etc/skel`; `-u` fixes the UID so files
copied between servers keep the right owner. A private group `bob` is
created automatically.

```bash solution target=devbox user=root
useradd -m -u 2000 -s /bin/bash -c "Bob (platform)" bob
echo 'bob:caleston123' | chpasswd
id bob
```

## t2 — the devops group

`-aG` **appends** a secondary group; `-G` alone would replace them all.

```bash solution target=devbox user=root
groupadd devops
usermod -aG devops bob
id -nG bob
```

## t3 — a narrow sudo rule

`%` marks a group, `(root)` the target user, `NOPASSWD:` skips the password
prompt, and the command needs its full path. Writing through a temporary
file and checking it with `visudo -cf` gives the same safety as editing with
`visudo -f`.

```bash solution target=devbox user=root
echo '%devops ALL=(root) NOPASSWD: /usr/bin/systemctl' > /tmp/devops.sudoers
visudo -cf /tmp/devops.sudoers
install -m 440 -o root -g root /tmp/devops.sudoers /etc/sudoers.d/devops
sudo -l -U bob
```

## t4 and t5 — neutralise intruder

Locking keeps the account (and its evidence) but makes the password
unusable; removing it from `sudo` takes away root access. For a real
incident you would also expire the account (`usermod -e 1 intruder`) so SSH
keys stop working, and kill its processes.

```bash solution target=devbox user=root
passwd -l intruder
gpasswd -d intruder sudo
passwd -S intruder
id intruder
```
