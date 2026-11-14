# Lab: Configure Bob's shell to the team standard

Priya's second ticket:

> Team convention: prompts must look like `[user@host dir]$ `, the team tools
> in `/opt/tools/bin` must be on your PATH, and `ll` should give a long
> listing. Make sure it survives logging out and back in!

- **Runtime:** Docker — machine `ubuntu`, logged in as `bob`
- **Estimated time:** 15 minutes
- **Start:** `make lab ID=bash-prompt` · **Check:** `make check ID=bash-prompt`

## Tasks

| ID | Task |
|---|---|
| t1 | Make Bob's prompt `[\u@\h \W]$ ` — it displays as `[bob@ubuntu ~]$ ` — in every new interactive shell, by configuring `~/.bashrc`. |
| t2 | Add `/opt/tools/bin` to Bob's `PATH` persistently, keeping the existing directories, so that the team's `mercury-status` tool runs just by typing its name. |
| t3 | Create a persistent alias `ll` that runs `ls` with the `-l` option (for example `ls -la`). |

## Notes

- The setup has reset `~/.bashrc` to the distribution default **without** the
  usual `ll` alias.
- The grader starts a brand-new interactive shell (`bash -i`) for every check,
  so setting things only in your current session will not pass. That is the
  point: settings must be persistent.
- Edit `~/.bashrc` with `nano ~/.bashrc` (Ctrl+O saves, Ctrl+X exits) or with
  `vi` if you already know it, or append lines with `echo '...' >> ~/.bashrc`.
