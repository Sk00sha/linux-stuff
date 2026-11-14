# Solution — Configure Bob's shell to the team standard

Everything goes into `~/.bashrc`, which Bash reads at the start of every
interactive shell (and which Ubuntu's `~/.profile` also sources for login
shells). Appending to the end of the file ensures nothing later in it
overrides our settings.

```bash solution target=ubuntu user=bob
cat >> ~/.bashrc <<'BASHRC'

# --- Caleston team standard ---
PS1='[\u@\h \W]$ '
export PATH="$PATH:/opt/tools/bin"
alias ll='ls -la'
BASHRC
```

Why each line looks the way it does:

- `PS1='[\u@\h \W]$ '` — single quotes keep the backslash sequences intact;
  Bash expands `\u` (user), `\h` (host) and `\W` (current directory name)
  every time it prints the prompt. Note the space after `$`.
- `export PATH="$PATH:/opt/tools/bin"` — `$PATH` is expanded *when the shell
  starts*, so the existing directories are kept and ours is added last.
- `alias ll='ls -la'` — no spaces around `=`.

Apply to the current shell and verify in a new one:

```bash
source ~/.bashrc
bash -ic 'echo "$PS1"; type ll; mercury-status'
```
