# Lab: Schedule the nightly clean-up

The clean-up script must run every evening as bob — not as root, and not
every minute.

- **Runtime:** Docker — machine `devbox`, logged in as `bob` (with `sudo`)
- **Estimated time:** 15 minutes
- **Start:** `make lab ID=cronjob` · **Check:** `make check ID=cronjob`

## Tasks

| ID | Task |
|---|---|
| t1 | In bob's own crontab, schedule `/opt/scripts/cleanup.sh` to run every day at 21:00. |
| t2 | Make the job append both its output and its errors to `/home/bob/cleanup.log`. |
| t3 | Someone scheduled the clean-up in **root's** crontab, every minute. Remove that entry — and only that one — from root's crontab. |

## Notes

- `crontab -e` edits your own crontab; `sudo crontab -e` (or
  `sudo crontab -u root -e`) edits root's.
- Root's crontab contains another, legitimate job. Keep it.
- `crontab -l` and `sudo crontab -l` show the results.
