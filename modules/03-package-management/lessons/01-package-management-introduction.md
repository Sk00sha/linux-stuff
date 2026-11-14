---
id: 03-package-management/01-package-management-introduction
title: Package Management Introduction
minutes: 10
objectives:
  - Explain what a software package contains
  - Describe dependencies and repositories
  - Match distributions to their package formats and managers
prerequisites: [01-shell-1/05-bash-shell]
tryit: ubuntu
---

# Package Management Introduction

## Why this matters

Installing software on a Linux server is rarely "download and run". A
program needs libraries, configuration files, documentation and often a
service definition, and all of it must be removable again and upgradable
when security fixes arrive. **Package managers** do that bookkeeping for
you. Bob will use them on both of Mercury's servers.

## Concepts

### What is a package?

A **package** is an archive containing:

- the **files** to install (binaries in `/usr/bin`, libraries, man pages,
  default configuration in `/etc`);
- **metadata**: name, version, architecture, description, and the list of
  other packages it **depends** on;
- optional **scripts** to run before/after installation or removal (for
  example to create a system user or restart a service);
- a **checksum and signature**, so you can verify it came from the
  distribution unchanged.

The package manager records every installed package and every file it owns
in a local database. That's how it can answer "which package put this file
here?" and remove a package without leaving debris.

### Dependencies

Software reuses other software. `curl` needs an HTTP library, which needs a
TLS library, which needs a crypto library… If you install packages by hand
you must find and install each dependency yourself, in the right version —
the infamous **dependency hell**. Higher-level package managers resolve the
whole tree automatically.

### Repositories

A **repository** is a server (or a directory) holding packages plus an index
of their metadata. Your system has a list of repositories it trusts; the
package manager downloads the indexes, finds what you asked for and its
dependencies, verifies signatures and installs. Distributions run official
repositories; companies often add internal ones (as Caleston does in the
lab).

### Two families, two layers

| | Red Hat family (RHEL, Rocky, AlmaLinux, Fedora) | Debian family (Debian, Ubuntu, Mint) |
|---|---|---|
| Package file | `.rpm` | `.deb` |
| Low-level tool (single files, no dependency resolution) | `rpm` | `dpkg` |
| High-level tool (repositories, dependencies) | `dnf` (formerly `yum`) | `apt` / `apt-get` |
| Repository config | `/etc/yum.repos.d/*.repo` | `/etc/apt/sources.list.d/` |

Other ecosystems exist too — `zypper` on SUSE, `pacman` on Arch, `apk` on
Alpine — and distribution-independent formats like Snap and Flatpak, but the
two families above cover most servers you'll meet.

### Telling them apart

Not sure which family a machine belongs to? `/etc/os-release` says so in its
`ID` and `ID_LIKE` fields.

## Try it

These run on the Ubuntu lab machine.

Which family is this?

```bash
grep -E '^(ID|ID_LIKE)=' /etc/os-release
```

```text
ID=ubuntu
ID_LIKE=debian
```

Every installed package is in the local database. How many are there, and
what does one look like?

```bash
dpkg-query -W | wc -l
dpkg-query -W -f='${Package} ${Version}\n' tree
```

```text
203
tree 2.1.1-2ubuntu3.24.04.2
```

Which package owns a file, and what does that package depend on?

```bash
dpkg -S /usr/bin/curl
apt-cache depends curl | head -4
```

```text
curl: /usr/bin/curl
curl
  Depends: libc6
  Depends: libcurl4t64
  Depends: zlib1g
```

Where do packages come from? The configured repositories:

```bash
ls /etc/apt/sources.list.d/
grep -E '^(URIs|Suites):' /etc/apt/sources.list.d/ubuntu.sources | head -2
```

```text
ubuntu.sources
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
```

## Common mistakes

- **Installing software by copying binaries into `/usr/bin`.** The package
  manager doesn't know about it, can't update it and may overwrite it.
- **Mixing families.** You can't install a `.rpm` on Ubuntu or a `.deb` on
  Rocky (converters exist but are a last resort).
- **Adding random third-party repositories.** Every repository you add can
  install code that runs as root. Only add ones you trust.

## Recap

- A package bundles files, metadata (including dependencies) and scripts;
  the package manager tracks every file it installs.
- Repositories serve packages and indexes; high-level tools resolve
  dependencies from them.
- Red Hat family: `.rpm`, `rpm`, `dnf`/`yum`. Debian family: `.deb`, `dpkg`,
  `apt`.

## Next

The Red Hat family first: `rpm` and `yum`/`dnf`.
