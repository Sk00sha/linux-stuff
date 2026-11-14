# Hints — Lock down the Mercury project tree

## t1

### Level 1

Change owner and group of a whole directory tree in one command. Giving files away needs root.

### Level 2

`chown` takes `USER:GROUP` and has a recursive option.

### Level 3

`sudo chown -R bob:devops /srv/mercury/app`

## t2

### Level 1

Work out the octal digits: owner rw, group r, others nothing.

### Level 2

r=4, w=2, x=1 per class: 6, 4, 0.

### Level 3

`sudo chmod 640 /srv/mercury/app/config/db.conf`

## t3

### Level 1

Owner rwx, group r-x, others nothing.

### Level 2

7, 5, 0.

### Level 3

`sudo chmod 750 /srv/mercury/app/bin/deploy.sh`

## t4

### Level 1

The setgid bit is the "2" in a four-digit mode. It applies to the directory itself, not recursively.

### Level 2

`chmod 2770 DIR` or `chmod 770 DIR && chmod g+s DIR`.

### Level 3

`sudo chmod 2770 /srv/mercury/app`, then `ls -ld /srv/mercury/app` shows `drwxrws---`.

## t5

### Level 1

The sticky bit is the "1" in a four-digit mode — like `/tmp`.

### Level 2

`chmod 1777 DIR` or `chmod +t DIR`.

### Level 3

`sudo chmod 1777 /srv/shared`, then `ls -ld /srv/shared` shows `drwxrwxrwt`.

## t6

### Level 1

Find everything still writable by others, then remove just that bit — without touching the modes you set in t2–t4.

### Level 2

`find /srv/mercury -perm -o+w` lists offenders; `chmod -R o-w` removes only the others-write bit.

### Level 3

`sudo chmod -R o-w /srv/mercury` (do it before or after t2–t4; it only removes `w` for others). Then `find /srv/mercury -perm -o+w` prints nothing.
