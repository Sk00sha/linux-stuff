---
id: 03-package-management/03-dpkg-and-apt
title: DPKG and APT
minutes: 10
objectives:
  - Install, list and remove .deb packages with dpkg
  - Use apt to install from repositories and fix broken dependencies
  - Find which package owns a file and which files a package owns
  - Understand sources.list and sources.list.d
prerequisites: [03-package-management/01-package-management-introduction]
tryit: ubuntu
---

# DPKG and APT

## Why this matters

The vendor's `.deb` for the Ubuntu box "never installs cleanly". That's a
classic sign of someone using the low-level tool, `dpkg`, without its
high-level partner, `apt`, which resolves dependencies. Bob needs to know
both — and how to recover when a half-installed package leaves the system
in a broken state.

## Concepts

### `dpkg`: the low-level tool

| Command | Meaning |
|---|---|
| `sudo dpkg -i file.deb` | install a package file (no dependency resolution) |
| `sudo dpkg -r NAME` | remove a package, keep its configuration files |
| `sudo dpkg -P NAME` | purge: remove it *and* its configuration |
| `dpkg -l [PATTERN]` | list installed packages with their status |
| `dpkg -L NAME` | list the files a package installed |
| `dpkg -S /path/file` | which package owns this file? |
| `dpkg -s NAME` | status and details of one package |
| `dpkg -I file.deb` | information about a `.deb` file before installing |

In `dpkg -l` output the first two letters are the status: `ii` = desired
**i**nstall, actually **i**nstalled (healthy); `rc` = **r**emoved but
**c**onfig files remain; `iU`/`iF` = unpacked or failed to configure — a
broken install.

If `dpkg -i` hits a missing dependency it unpacks the package but leaves it
**unconfigured** and complains. Nothing is rolled back — that's the "never
installs cleanly" problem.

### `apt`: the high-level tool

| Command | Meaning |
|---|---|
| `sudo apt update` | download fresh package indexes from the repositories |
| `sudo apt upgrade` | upgrade all installed packages |
| `sudo apt install NAME…` | install with dependencies |
| `sudo apt install ./file.deb` | install a local file *and* fetch its dependencies |
| `sudo apt remove NAME` / `sudo apt purge NAME` | remove / remove with config |
| `sudo apt autoremove` | remove dependencies no longer needed |
| `sudo apt -f install` | **f**ix broken: complete half-done installs by adding missing dependencies |
| `apt search WORD` / `apt show NAME` | search / details |
| `apt list --installed` | installed packages |

Always `apt update` before installing on a real system: the local indexes
may be days old. (The course images work offline, so the labs don't need
it.)

### Repositories: `sources.list`

Repositories are listed in `/etc/apt/sources.list` and in files under
`/etc/apt/sources.list.d/`. Ubuntu 24.04 uses the newer "deb822" format
(`*.sources` files):

```text
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

Older systems use one-line entries in the same spirit:
`deb http://archive.ubuntu.com/ubuntu noble main universe`. Third-party
repositories go in their own file in `sources.list.d/`, with their own
signing key.

Downloaded `.deb` files are cached in `/var/cache/apt/archives/`.

## Try it

Run on the Ubuntu lab machine.

Status, owner and file list:

```bash
dpkg -l tree | tail -1
dpkg -S /usr/bin/tree
dpkg -L tree | head -4
```

```text
ii  tree           2.1.1-2ubuntu3.24.04.2 amd64        displays an indented directory tree, in color
tree: /usr/bin/tree
/.
/usr
/usr/bin
/usr/bin/tree
```

Show details of an available package:

```bash
apt show figlet 2>/dev/null | grep -E '^(Package|Version|Depends|Description)'
```

```text
Package: figlet
Version: 2.2.5-3
Depends: libc6 (>= 2.14)
Description: Make large character ASCII banners out of ordinary text
```

Install, use and remove it (it's cached in the image, so no download):

```bash
sudo apt-get install -y -q figlet >/dev/null 2>&1
figlet -f small Mercury
sudo apt-get remove -y -q figlet >/dev/null 2>&1
dpkg -l figlet | tail -1
```

```text
 __  __
|  \/  |___ _ _ __ _  _ _ _ _  _
| |\/| / -_) '_/ _| || | '_| || |
|_|  |_\___|_| \__|\_,_|_|  \_, |
                            |__/
rc  figlet         2.2.5-3      amd64        Make large character ASCII banners out of ordinary text
```

Notice the `rc` status: removed, but its configuration files remain until
you `purge`.

## Common mistakes

- **Stopping after `dpkg -i` fails.** The package is half-installed; run
  `sudo apt -f install` (or use `sudo apt install ./file.deb` in the first
  place).
- **`dpkg -r file.deb`.** Removal takes the package name, not a file name.
- **Forgetting `apt update`** on real servers, then wondering why `apt`
  can't find a recently published version.
- **`apt remove` and expecting configuration to go.** Use `apt purge`.

## Recap

- `dpkg` handles `.deb` files and the database: `-i`, `-r`, `-P`, `-l`, `-L`,
  `-S`.
- `apt` resolves dependencies from repositories: `update`, `install`,
  `remove`, `purge`, `-f install`, `search`, `show`.
- Repositories are defined in `/etc/apt/sources.list` and
  `/etc/apt/sources.list.d/`.

## Next

`apt` and `apt-get` look almost identical. When should you use which?
