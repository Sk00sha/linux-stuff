# Lab: Make Project Mercury a real service

No more overtime: turn the hand-started Mercury worker into a managed
systemd service.

- **Runtime:** VM (`bob-vm`). Without a VM, the lab falls back to the
  `systemd` container automatically — Linux hosts only.
- **Estimated time:** 30 minutes
- **Start:** `make lab ID=systemd-services` · **Check:** `make check ID=systemd-services`

## Tasks

| ID | Task |
|---|---|
| t1 | Create the unit `/etc/systemd/system/project-mercury.service` that runs `/usr/bin/project-mercury.sh`. |
| t2 | The service must run as the user `mercury`. |
| t3 | If it fails, systemd must restart it after 10 seconds. |
| t4 | It must start after the network (`network.target`) and after `postgresql.service`. |
| t5 | It must be enabled at boot and running now. |
| t6 | Prove it: the grader kills the main process and expects systemd to bring it back (this check takes about 15 seconds). |

## Notes

- The setup created the user `mercury`, the script `/usr/bin/project-mercury.sh`
  and a stand-in `postgresql.service` (there's no real database on this
  machine).
- Remember `sudo systemctl daemon-reload` after every edit of the unit file.
- `systemd-analyze verify /etc/systemd/system/project-mercury.service`
  catches typos; `journalctl -u project-mercury` shows its output.
