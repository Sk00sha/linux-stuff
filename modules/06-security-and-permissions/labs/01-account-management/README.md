# Lab: Rebuild the accounts on devbox

After the incident, the security team wiped bob's old account. Rebuild it
to the company standard and neutralise the intruder.

- **Runtime:** Docker — machine `devbox`; you are logged in as **root**
- **Estimated time:** 25 minutes
- **Start:** `make lab ID=account-management` · **Check:** `make check ID=account-management`

## Tasks

| ID | Task |
|---|---|
| t1 | Create the user `bob` with UID `2000`, login shell `/bin/bash` and home directory `/home/bob` (created and owned by bob). |
| t2 | Create the group `devops` and make `bob` a member of it (as a secondary group). |
| t3 | In `/etc/sudoers.d/devops`, allow members of `devops` to run `/usr/bin/systemctl` as root without a password — and nothing else. |
| t4 | Lock the password of the account `intruder`. |
| t5 | Remove `intruder` from the `sudo` group. |

## Notes

- Use the account tools (`useradd`, `groupadd`, `usermod`, `passwd`,
  `gpasswd`), not a text editor on `/etc/passwd`.
- Edit sudo rules with `visudo -f /etc/sudoers.d/devops`.
- Don't delete `intruder`: the security team wants the account and its
  files kept as evidence.
