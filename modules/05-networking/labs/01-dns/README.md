# Lab: Teach the client to find the database

The rehearsal failed because the client couldn't resolve the database's
name. Fix name resolution on `client`.

- **Runtime:** Docker — machines `client`, `dns`, `router`, `web01`, `db01`; you are `bob` on `client`
- **Estimated time:** 20 minutes
- **Start:** `make lab ID=dns` · **Check:** `make check ID=dns`

## Tasks

| ID | Task |
|---|---|
| t1 | On `client`, add an `/etc/hosts` entry so that the name `db01` resolves to `10.10.2.20`. |
| t2 | Configure `client` to use the company DNS server at `10.10.1.53` as its **only** nameserver, so that `db.company.local` resolves. |
| t3 | Add `company.local` as a search domain on `client`, so that short names like `www` and `mail` resolve. |
| t4 | Look up the MX record of `company.local` and write the name of the mail server it points to into `/home/bob/mx.txt`. |

## Notes

- Both files are owned by root: use `sudo vi FILE` or `sudo nano FILE`.
- Docker bind-mounts `/etc/hosts` and `/etc/resolv.conf`: tools that replace
  the file (such as `sed -i`) fail with "Device or resource busy". Editors
  and `sudo tee` work.
- Verify like an application would: `getent hosts NAME`.
