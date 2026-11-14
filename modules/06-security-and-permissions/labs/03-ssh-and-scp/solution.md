# Solution — Keys, not passwords

On `devbox` as `bob`.

## t1 — generate a key pair

ed25519 keys are short, fast and secure. `-N ''` sets an empty passphrase
for the lab; use a real passphrase (and `ssh-agent`) for your own keys.

```bash solution target=devbox user=bob
ssh-keygen -t ed25519 -C "bob@devbox" -f ~/.ssh/id_ed25519 -N '' -q
ls -l ~/.ssh
```

## t2 — install the public key on app01

`ssh-copy-id` appends `~/.ssh/id_ed25519.pub` to `~/.ssh/authorized_keys`
on app01 and sets safe permissions. Interactively you simply type the
password when asked; `sshpass` provides it here so the automated test can
run unattended. `accept-new` records app01's host key on first contact.

```bash solution target=devbox user=bob
sshpass -p caleston123 ssh-copy-id -o StrictHostKeyChecking=accept-new bob@app01
ssh -o BatchMode=yes bob@app01 'hostname; ls -l ~/.ssh/authorized_keys'
```

## t3 + t4 — copy the archive, keeping its timestamp

`-p` preserves modification time and mode. The key is used automatically,
so no password is asked.

```bash solution target=devbox user=bob
scp -p /home/bob/caleston-code.tar.gz bob@app01:/opt/
ssh bob@app01 'ls -l /opt/caleston-code.tar.gz; tar -tzf /opt/caleston-code.tar.gz | head -3'
```
