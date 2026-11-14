# Hints — Logs, reports and a noisy script

## t1

### Level 1

`tar` creates the archive and can compress it with gzip at the same time. Think about which directory you run it from — that decides the paths stored inside.

### Level 2

`tar -czf ARCHIVE DIR` — create, gzip, file. Run it from `/home/bob` so the stored paths begin with `reports/`.

### Level 3

`cd /home/bob && tar -czf reports.tar.gz reports`, then `tar -tzf reports.tar.gz | head`.

## t2

### Level 1

You need two conditions at once: the name pattern and the size. One command can test both, and redirect its output to a file.

### Level 2

`find DIR -name '*.log' -size +1M`. Some directories are only readable by root: use `sudo`, and `2>/dev/null` to hide noise.

### Level 3

`sudo find /var/app -type f -name '*.log' -size +1M > /home/bob/biglogs.txt` — the redirection is done by bob's shell, which is fine because the file is in bob's home.

## t3

### Level 1

Search inside the file for a word, ignoring case, and save the matching lines.

### Level 2

`grep` has an option to ignore case. Note the task says "contains", so `terrorist` counts too.

### Level 3

`grep -i error /var/app/app.log > /home/bob/errors.txt`

## t4

### Level 1

The script writes to two streams. Redirect each one to its own file.

### Level 2

`>` redirects stdout (stream 1) and `2>` redirects stderr (stream 2), both in the same command.

### Level 3

`/opt/mercury/start.sh > /home/bob/start.out 2> /home/bob/start.err`
