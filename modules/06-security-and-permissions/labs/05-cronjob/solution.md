# Solution — Schedule the nightly clean-up

## t1 + t2 — bob's crontab

Interactively: `crontab -e` and add the line. Non-interactively, feed the
existing crontab plus the new line back into `crontab -` (the `|| true`
handles "no crontab for bob" on the first run).

```bash solution target=devbox user=bob
(crontab -l 2>/dev/null || true; echo '0 21 * * * /opt/scripts/cleanup.sh >> /home/bob/cleanup.log 2>&1') | crontab -
crontab -l
```

- `0 21 * * *` — minute 0 of hour 21, every day of every month, any weekday.
- `>> file 2>&1` — append stdout, then send stderr to the same place.

## t3 — fix root's crontab

Filter out only the bad line and install the result as root's crontab.

```bash solution target=devbox user=bob
sudo crontab -l -u root | grep -v '/opt/scripts/cleanup.sh' | sudo crontab -u root -
sudo crontab -l -u root
```

Why it matters: the script deletes files. Running it every minute as root
means any mistake in it (or any attacker who can edit it) acts with full
privileges, sixty times an hour.
