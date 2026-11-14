---
id: 06-security-and-permissions/06-ssh-and-scp
title: SSH and SCP
minutes: 14
objectives:
  - Log in to remote machines with ssh
  - Create a key pair and set up key-based authentication
  - Get the permissions of ~/.ssh right
  - Copy files with scp and simplify connections with ~/.ssh/config
prerequisites: [06-security-and-permissions/05-file-permissions-and-ownership]
tryit: ubuntu
---

# SSH and SCP

## Why this matters

The intruder got in by guessing a password over SSH. Caleston's new rule:
engineers log in with **keys**, and password logins will be switched off.
Bob also needs to ship the Mercury code archive from devbox to the
application server without exposing it on the network.

## Concepts

### SSH in one paragraph

SSH (Secure Shell) gives you an encrypted connection to a remote machine's
shell. The server runs `sshd` (port 22); you run the `ssh` client:

```bash
ssh bob@app01               # log in as bob on app01
ssh -p 2222 bob@app01       # non-standard port
ssh bob@app01 'uptime'      # run one command and return
```

The first time you connect, ssh shows the server's **host key fingerprint**
and asks you to confirm. It records it in `~/.ssh/known_hosts`; if the key
ever changes, ssh warns loudly — that can mean a reinstalled server, or an
attacker in the middle.

### Key-based authentication

A **key pair** is two files:

- the **private key** (`~/.ssh/id_ed25519`) stays on your machine and is
  secret;
- the **public key** (`~/.ssh/id_ed25519.pub`) is copied to every server you
  want to log in to, into `~/.ssh/authorized_keys` of the target account.

When you connect, the server challenges you to prove you have the private
key; nothing secret crosses the network, and there's no password to guess.

```bash
ssh-keygen -t ed25519 -C "bob@devbox"        # create a key pair (optionally with a passphrase)
ssh-copy-id bob@app01                        # append the public key on app01 (asks for the password once)
ssh bob@app01                                # no password prompt any more
```

`ed25519` is the modern default; `rsa -b 4096` is the compatible
alternative. A **passphrase** encrypts the private key on disk; `ssh-agent`
remembers it for your session.

### Permissions matter

`sshd` refuses keys if the files could have been tampered with by others:

| Path | Mode |
|---|---|
| `~/.ssh/` | `700` |
| `~/.ssh/authorized_keys` | `600` (644 also accepted) |
| `~/.ssh/id_ed25519` (private) | `600` |
| your home directory | not writable by group/others |

The client also refuses to use a private key that others can read.

### Copying files: `scp`

`scp` copies over SSH using the same authentication:

```bash
scp file.tar.gz bob@app01:/opt/            # local -> remote
scp bob@app01:/var/log/app.log .           # remote -> local
scp -r -p project/ bob@app01:/srv/         # -r recursive, -p keep times and modes
```

`rsync -av` (over SSH) is more efficient for large or repeated copies, and
`sftp` gives an interactive session.

### `~/.ssh/config`

Save typing with per-host settings:

```text
Host app01
    HostName 10.10.2.30
    User bob
    IdentityFile ~/.ssh/id_ed25519
```

Then `ssh app01` and `scp x app01:/tmp/` just work.

### Server side, briefly

`/etc/ssh/sshd_config` controls the server. Hardening usually includes
`PasswordAuthentication no` and `PermitRootLogin no`, followed by a reload
of sshd — but only **after** confirming key logins work, or you'll lock
yourself out.

## Try it

These examples use SSH to the same machine (`localhost`), which is enough to
see every step.

Create a key pair without a passphrase (fine for a demo; use one for real
keys) and look at the files:

```bash
ssh-keygen -t ed25519 -N '' -C 'bob@demo' -f ~/.ssh/id_ed25519 -q
ls -l ~/.ssh
cut -c1-40 ~/.ssh/id_ed25519.pub
```

```text
total 8
-rw------- 1 bob bob 399 Nov 14 20:45 id_ed25519
-rw-r--r-- 1 bob bob  90 Nov 14 20:45 id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMD+
```

Install the public key for bob on "the server" (here localhost). Interactively
you'd type the password once; `sshpass` supplies it for this demo:

```bash keepoutput
sshpass -p caleston123 ssh-copy-id -o StrictHostKeyChecking=accept-new bob@localhost 2>&1 | grep -E 'Number|check'
ls -ld ~/.ssh ~/.ssh/authorized_keys
```

```text
Number of key(s) added: 1
and check to make sure that only the key(s) you wanted were added.
drwx------ 2 bob bob 4096 Nov 14 20:45 /home/bob/.ssh
-rw------- 1 bob bob   90 Nov 14 20:45 /home/bob/.ssh/authorized_keys
```

Log in with the key — `BatchMode` forbids password prompts, so this only
works because the key is accepted:

```bash
ssh -o BatchMode=yes bob@localhost 'echo "logged in to $(hostname) as $(whoami) using a key"'
```

```text
logged in to ubuntu as bob using a key
```

Break the permissions and watch sshd refuse the key:

```bash mayfail keepoutput
chmod 777 ~/.ssh
ssh -o BatchMode=yes bob@localhost true && echo accepted || echo "key refused"
chmod 700 ~/.ssh
ssh -o BatchMode=yes bob@localhost true && echo accepted
```

```text
bob@localhost: Permission denied (publickey,password).
key refused
accepted
```

Copy a file with scp, keeping its timestamps, and use an ssh config entry:

```bash
printf 'Host me\n    HostName localhost\n    User bob\n' > ~/.ssh/config
echo "release notes" > ~/notes.txt
scp -q -p ~/notes.txt me:/tmp/notes-copy.txt
ssh me 'cat /tmp/notes-copy.txt'
rm -rf ~/.ssh ~/notes.txt /tmp/notes-copy.txt
```

```text
release notes
```

## Common mistakes

- **Copying the private key** to servers. Only the `.pub` file goes into
  `authorized_keys`.
- **Group- or world-writable `~/.ssh`** (or home directory): the key is
  silently refused. Check `/var/log/auth.log` (Ubuntu) or `/var/log/secure`
  (Rocky) on the server.
- **Disabling password logins before testing the key** — keep a second
  session open while changing `sshd_config`.
- **Ignoring the "REMOTE HOST IDENTIFICATION HAS CHANGED" warning.** Find out
  why before removing the line from `known_hosts` (`ssh-keygen -R HOST`).

## Recap

- `ssh user@host` logs in; host keys are remembered in `known_hosts`.
- `ssh-keygen` + `ssh-copy-id` set up key login; `~/.ssh` must be 700 and
  `authorized_keys` 600.
- `scp [-r] [-p] SRC user@host:DEST` copies over SSH; `~/.ssh/config` stores
  per-host settings.

## Next

Lab: `make lab ID=ssh-and-scp`. Then firewalls: controlling *who can connect
at all*.
