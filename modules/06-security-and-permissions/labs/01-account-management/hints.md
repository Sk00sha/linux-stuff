# Hints — Rebuild the accounts on devbox

## t1

### Level 1

One command creates the account with all the required properties. Check its options for UID, shell and home directory.

### Level 2

`useradd` with `-u`, `-s` and `-m` (create home). See `man useradd`.

### Level 3

`useradd -m -u 2000 -s /bin/bash bob`, then `id bob` and `ls -ld /home/bob`.

## t2

### Level 1

First create the group, then add bob to it without changing his other groups.

### Level 2

`groupadd NAME`; `usermod -aG GROUP USER` (the `-a` matters).

### Level 3

`groupadd devops && usermod -aG devops bob`, then `id bob`.

## t3

### Level 1

Sudo rules for a group start with `%`. Commands must be given with their full path.

### Level 2

`visudo -f /etc/sudoers.d/devops` and write one rule: who, where, as whom, NOPASSWD, command.

### Level 3

The rule is `%devops ALL=(root) NOPASSWD: /usr/bin/systemctl`. Check with `sudo -l -U bob`. Mode should be 440 (`chmod 440` if you created it another way).

## t4

### Level 1

Locking keeps the account and its files but makes the password unusable.

### Level 2

`passwd` (or `usermod`) has a lock option; `passwd -S` shows the status.

### Level 3

`passwd -l intruder`, then `passwd -S intruder` shows `L`.

## t5

### Level 1

Remove one user from one group, leaving everything else alone.

### Level 2

`gpasswd` can delete a member from a group (`-d`).

### Level 3

`gpasswd -d intruder sudo`, then `id intruder`.
