# Lab: Fix the Mercury config with vi

The demo configuration must be production-ready, and the only editor on the
server is `vi`.

- **Runtime:** Docker — machine `ubuntu`, logged in as `bob`
- **Estimated time:** 20 minutes
- **Start:** `make lab ID=vi-editor` · **Check:** `make check ID=vi-editor`

## Tasks

Edit `/home/bob/mercury.conf` with `vi`:

| ID | Task |
|---|---|
| t1 | Change the line `port = 8080` to `port = 80`. |
| t2 | Change every occurrence of `development` to `production` in the file. |
| t3 | Delete the line that starts with `debug_password`. |
| t4 | Add the line `demo_client = halvorsen` as the last line of the file. All other lines must stay unchanged. |
| t5 | A crashed session left a stale swap file for `mercury.conf`. Make sure no swap file remains when you are done. |

## Notes

- When you open the file, vim will warn about the existing swap file
  (`.mercury.conf.swp`). Read the message: there is nothing worth recovering
  in it. Choose **(D)elete it** if offered, or **(E)dit anyway** and delete the
  `.swp` file afterwards.
- The grader checks the file's content and the absence of swap files. It can't
  tell which editor you used — but the point of this lab is to practise vi.
- Stuck in vi? Esc, then `:q!` and start again. `course reset vi-editor`
  restores the original file.
