# Lab: Keys, not passwords

Password logins are being switched off. Set up a key for bob, then ship the
code archive to the application server.

- **Runtime:** Docker — `devbox` and `app01`; you are `bob` on `devbox`
- **Estimated time:** 20 minutes
- **Start:** `make lab ID=ssh-and-scp` · **Check:** `make check ID=ssh-and-scp`

## Tasks

| ID | Task |
|---|---|
| t1 | Create an SSH key pair for bob on devbox (`ed25519` or `rsa`) in the default location under `~/.ssh`. |
| t2 | Set up key-based login so that bob on devbox can run `ssh bob@app01` without being asked for a password. |
| t3 | Copy `/home/bob/caleston-code.tar.gz` from devbox to `/opt/` on app01. |
| t4 | The copy on app01 must keep the original file's modification time. |

## Notes

- bob's password on app01 (needed once, for `ssh-copy-id`) is `caleston123`.
- The grader tests t2 with `ssh -o BatchMode=yes`, which fails instead of
  asking for a password.
- The setup gave bob write access to `/opt` on app01.
