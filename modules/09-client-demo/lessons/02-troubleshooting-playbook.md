---
id: 09-client-demo/02-troubleshooting-playbook
title: A Troubleshooting Playbook
minutes: 15
objectives:
  - Apply a repeatable method to an unknown failure
  - Use logs to turn symptoms into specific causes
  - Verify each fix before moving on
prerequisites: [09-client-demo/01-client-demo-in-jeopardy]
tryit: systemd
---

# A Troubleshooting Playbook

## Why this matters

Under pressure, people skip steps. A short, written method keeps you honest
and fast. This one ties together every module of the course.

## Concepts

### The loop

1. **Observe the symptom precisely.** "Site down" → `curl -v` says
   *connection refused*: nothing listens on port 80.
2. **Form one hypothesis**, from the evidence: "the web service isn't
   running".
3. **Test it** with a read-only command: `systemctl status mercury-web`.
4. **Fix one thing**, the smallest change that addresses it.
5. **Verify** with the same test — and the end-to-end test.
6. **Repeat** until the end-to-end test passes. Write down what you
   changed.

### Where to look, by layer

| Question | Command | Module |
|---|---|---|
| Is the service running? Enabled? | `systemctl status NAME`, `systemctl is-enabled NAME` | 07 |
| Why did it stop? | `journalctl -u NAME -n 50 --no-pager` | 07 |
| What exactly does it run, with which environment? | `systemctl cat NAME`, `systemctl show NAME -p Environment` | 07, 01 |
| Can it read its files? | `ls -l FILE`, `sudo -u USER cat FILE` | 06 |
| Does the name resolve? | `getent hosts NAME`, `cat /etc/hosts` | 05 |
| Can it reach the port? | `nc -zv HOST PORT`, `sudo iptables -L -n -v` | 05, 06 |
| Is there space? | `df -h`, `du -sh DIR/* .[!.]*` | 04, 08 |
| Is the software installed? | `dpkg -l NAME`, `apt-get install NAME` | 03 |
| Are scheduled jobs in place? | `ls /etc/cron.d`, `crontab -l` | 06 |

### Reading error messages

Most of the hour is reading. Common messages and what they usually mean:

| Message | Likely cause |
|---|---|
| `status=203/EXEC` (in status and journal) | wrong `ExecStart=` path, or not executable |
| `env: 'python3': No such file or directory` | broken `PATH` in the environment |
| `ModuleNotFoundError: No module named …` | a package is missing |
| `Permission denied` | file mode/owner, or the wrong `User=` |
| `Name or service not known` / `could not translate host name` | DNS or `/etc/hosts` |
| `Connection timed out` | routing or a firewall **DROP** |
| `Connection refused` | nothing listening, or a firewall **REJECT** |
| `No space left on device` | full filesystem (`df -h`) — or out of inodes (`df -i`) |

### Two habits that save demos

- **Change one thing at a time**, then retest. Two simultaneous changes hide
  which one mattered.
- **`sudo -u SERVICEUSER COMMAND`** reproduces the service's point of view:
  `sudo -u mercury cat /etc/mercury/app.conf` fails exactly like the service
  does.

## Try it

Practise reading a failing unit in a systemd environment. This creates a
deliberately broken service and diagnoses it:

```bash
printf '[Service]\nExecStart=/usr/local/bin/does-not-exist\n' | sudo tee /etc/systemd/system/broken-demo.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl start broken-demo || true
systemctl is-failed broken-demo
```

```text
failed
```

The status line and journal point straight at the cause:

```bash
systemctl status broken-demo --no-pager | grep -E 'Active|Process'
sleep 1; sudo journalctl -u broken-demo --no-pager -o cat | grep -m1 '203/EXEC'
```

```text
     Active: failed (Result: exit-code) since Sat 2026-11-14 21:03:52 UTC; 60ms ago
    Process: 143 ExecStart=/usr/local/bin/does-not-exist (code=exited, status=203/EXEC)
broken-demo.service: Main process exited, code=exited, status=203/EXEC
```

See a file through a service user's eyes:

```bash mayfail
echo "secret=1" | sudo tee /root/demo.conf >/dev/null
sudo -u nobody cat /root/demo.conf
sudo rm /root/demo.conf /etc/systemd/system/broken-demo.service
sudo systemctl daemon-reload; sudo systemctl reset-failed
```

```text
cat: /root/demo.conf: Permission denied
```

## Common mistakes

- **Restarting repeatedly without reading the logs.** The journal usually
  names the problem in the first error line.
- **Fixing with sledgehammers**: `chmod 777`, `iptables -F` on a production
  host, disabling the firewall. Fix the specific rule or permission.
- **Forgetting `daemon-reload`** after editing the unit, then believing the
  fix didn't work.

## Recap

- Observe → hypothesise → test → fix one thing → verify → repeat.
- Logs and error messages map almost one-to-one to causes.
- Reproduce as the service user with `sudo -u`.

## Next

The finale: `make lab ID=final-troubleshooting`. Good luck, Bob.
