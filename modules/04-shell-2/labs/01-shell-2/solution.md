# Solution — Logs, reports and a noisy script

## t1 — archive the reports

Running `tar` from `/home/bob` stores relative paths (`reports/…`), so the
archive can be extracted anywhere. `-c` create, `-z` gzip, `-f` file name.

```bash solution target=ubuntu user=bob
cd /home/bob
tar -czf reports.tar.gz reports
tar -tzf reports.tar.gz | head -3
```

## t2 — big log files

Both tests must match (find ANDs them): name ends in `.log` and size larger
than 1 MiB. `reports.log.1` doesn't match the name, `debug.log` is just under
the limit, and `restricted/` is only readable by root, hence `sudo`.
`2>/dev/null` would hide permission errors if you ran it without sudo.

```bash solution target=ubuntu user=bob
sudo find /var/app -type f -name '*.log' -size +1M > /home/bob/biglogs.txt
cat /home/bob/biglogs.txt
```

## t3 — error lines, any case

`-i` ignores case, so `ERROR`, `Error`, `error` — and `terrorist` — all
match, exactly as the task asks ("contains the word error in any letter
case"). Use `-w` if you only want whole words.

```bash solution target=ubuntu user=bob
grep -i error /var/app/app.log > /home/bob/errors.txt
```

## t4 — separate the streams

`>` sends stream 1 (stdout) to one file and `2>` sends stream 2 (stderr) to
another.

```bash solution target=ubuntu user=bob
/opt/mercury/start.sh > /home/bob/start.out 2> /home/bob/start.err
cat /home/bob/start.out
cat /home/bob/start.err
```
