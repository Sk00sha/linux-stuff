# Lab: Organise the Asia office notes

Priya's first ticket for Bob:

> The Asia office keeps its notes in a messy home directory. Please set up a
> proper folder for the Mumbai team, tidy up what the last contractor left
> behind, and save a quick reference for `ls` while you're at it.

- **Runtime:** Docker — machine `ubuntu`, you are logged in as `bob`
- **Estimated time:** 20 minutes
- **Start:** `make lab ID=working-with-the-shell`
- **Check:** `make check ID=working-with-the-shell`

## Tasks

| ID | Task |
|---|---|
| t1 | Create the directory tree `/home/bob/asia/india/mumbai`. It should be owned by `bob` (so don't use `sudo`). |
| t2 | Copy `/home/bob/notes/city-guide.txt` into `/home/bob/asia/india/mumbai/`, keeping its name. The original must stay where it is. |
| t3 | The previous contractor misspelled a directory as `/home/bob/projetcs`. Rename it to `/home/bob/projects` without losing its contents. |
| t4 | Delete the directory `/home/bob/old-contractor-tmp` and everything inside it. |
| t5 | Save the one-line description of the `ls` command, exactly as printed by `whatis`, into `/home/bob/whatis.txt`. |

## Notes

- Only the commands from lessons 1–3 of this module are needed.
- For t5 you will need one new trick: `command > file` saves a command's
  output into a file instead of printing it. Module 04 covers this properly.
- Made a mess? `make reset ID=working-with-the-shell` restores the start state.
