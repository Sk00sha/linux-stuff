# Hints — Keys, not passwords

## t1

### Level 1

One command generates a key pair. Accept the default file location.

### Level 2

`ssh-keygen -t ed25519`. A passphrase is recommended in real life; for the lab you may leave it empty.

### Level 3

`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''`

## t2

### Level 1

The public key has to end up in a specific file in bob's home on app01. There's a tool that does it for you.

### Level 2

`ssh-copy-id bob@app01` asks for the password once and installs the key.

### Level 3

`ssh-copy-id bob@app01` (password `caleston123`), then `ssh -o BatchMode=yes bob@app01 hostname`.

## t3

### Level 1

Copy over SSH. The syntax for a remote location is `user@host:path`.

### Level 2

`scp FILE bob@app01:/opt/`

### Level 3

`scp /home/bob/caleston-code.tar.gz bob@app01:/opt/`

## t4

### Level 1

scp has an option to preserve modification times and modes.

### Level 2

`scp -p ...` — run the copy again with it.

### Level 3

`scp -p /home/bob/caleston-code.tar.gz bob@app01:/opt/`, then compare `ls -l --time-style=full-iso` on both sides.
