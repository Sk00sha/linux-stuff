# Hints — Schedule the nightly clean-up

## t1

### Level 1

Five time fields: minute, hour, day of month, month, day of week. "Every day" means `*` in the last three.

### Level 2

Run `crontab -e` as bob and add one line: `MINUTE HOUR * * * COMMAND`.

### Level 3

`0 21 * * * /opt/scripts/cleanup.sh`

## t2

### Level 1

Cron throws output away (or mails it). Redirect it in the crontab line itself.

### Level 2

Append with `>>`, and send stderr where stdout goes with `2>&1` — in that order.

### Level 3

`0 21 * * * /opt/scripts/cleanup.sh >> /home/bob/cleanup.log 2>&1`

## t3

### Level 1

Root's crontab is edited the same way as yours, but as root.

### Level 2

`sudo crontab -l` shows it; `sudo crontab -e` edits it. Delete only the `* * * * *` line.

### Level 3

`sudo crontab -e`, remove `* * * * * /opt/scripts/cleanup.sh`, save. Or: `sudo crontab -l | grep -v cleanup.sh | sudo crontab -`.
