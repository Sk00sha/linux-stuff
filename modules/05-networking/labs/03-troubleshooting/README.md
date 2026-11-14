# Lab: The web server that nobody can reach

"web01 is up, I can see the process!" says the developer. Yet the demo page
won't load from anywhere. Work through the layers and fix it.

- **Runtime:** Docker — `client` and `web01`; you start as `bob` on `client`
- **Estimated time:** 25 minutes
- **Start:** `make lab ID=troubleshooting` · **Check:** `make check ID=troubleshooting`

## Tasks

| ID | Task |
|---|---|
| t1 | From `client`, the name `web01` must resolve to web01's real address. Find and fix what makes it resolve wrongly. |
| t2 | The web app on `web01` must listen on TCP port 80. |
| t3 | The web app must accept connections from other machines, not only from web01 itself. |
| t4 | End to end: running `curl http://web01/` on `client` must return the page `Mercury demo: web01 OK`. |

## Notes

- Get onto `web01` with `ssh bob@10.10.1.80` from the client (password
  `caleston123`), or from your host with `bin/course shell troubleshooting --service web01`.
- The web app is managed with `sudo webctl start|stop|restart|status` and
  configured in `/etc/webapp/webapp.conf`.
- Climb the ladder: name → route → port. `getent`, `ping`, `ss -tlnp`, `nc -zv`
  and `curl -v` are your tools.
