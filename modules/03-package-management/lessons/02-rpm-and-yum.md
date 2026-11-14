---
id: 03-package-management/02-rpm-and-yum
title: RPM and YUM/DNF
minutes: 11
objectives:
  - Install, upgrade, query and remove packages with rpm
  - Use dnf/yum to install from repositories with dependency resolution
  - Find which package provides a file
  - Read and write .repo files
prerequisites: [03-package-management/01-package-management-introduction]
tryit: rocky
---

# RPM and YUM/DNF

## Why this matters

Mercury's reporting backend runs on Rocky Linux. Bob has to install the web
server, remove a flagged package and hook up Caleston's internal repository.
All of that is done with two tools: `rpm` for individual package files and
the local database, and `dnf` (the successor of `yum`) for repositories.

## Concepts

### `rpm`: the low-level tool

`rpm` installs and inspects `.rpm` files and queries the database of
installed packages. It does **not** download anything or resolve
dependencies: if a dependency is missing, it stops with an error.

| Command | Meaning |
|---|---|
| `rpm -ivh pkg.rpm` | **i**nstall, **v**erbose, with **h**ash progress marks |
| `rpm -Uvh pkg.rpm` | **U**pgrade (installs if not present) |
| `rpm -e NAME` | **e**rase (remove) an installed package — by name, not file |
| `rpm -q NAME` | **q**uery: is it installed, which version? |
| `rpm -qa` | query **a**ll installed packages |
| `rpm -qi NAME` | **i**nformation: description, size, vendor |
| `rpm -ql NAME` | **l**ist the files it installed |
| `rpm -qf /path/file` | which package owns this **f**ile? |
| `rpm -qR NAME` | what it **R**equires |
| `rpm -V NAME` | **V**erify installed files against the database |

`rpm -qa | grep httpd` is a common idiom for "is anything Apache-related
installed?".

### `dnf` and `yum`: the high-level tools

`yum` (Yellowdog Updater, Modified) was the RHEL package manager for years.
Since RHEL 8 / Rocky 8 the real tool is **`dnf`**, and `yum` is a
compatibility alias for it — the commands below work with either name.

| Command | Meaning |
|---|---|
| `dnf install NAME…` | install packages and all their dependencies |
| `dnf remove NAME` | remove a package (and dependencies nothing else needs) |
| `dnf update` / `dnf update NAME` | update everything / one package |
| `dnf search WORD` | search names and summaries |
| `dnf info NAME` | details of an installed or available package |
| `dnf provides /usr/bin/wget` | which (available) package contains a file |
| `dnf list installed` | installed packages |
| `dnf repolist` / `dnf repolist all` | enabled / all repositories |
| `dnf install ./local.rpm` | install a local file *and* resolve its dependencies |

Add `-y` to answer "yes" automatically (useful in scripts).

`rpm -qf` only knows about **installed** files; `dnf provides` also searches
packages you haven't installed yet.

### Repository files

Repositories are configured in `/etc/yum.repos.d/*.repo` (the directory kept
its old name). Each file is in INI format:

```ini
[local]
name=Caleston internal tools
baseurl=file:///opt/localrepo
enabled=1
gpgcheck=0
```

- `[local]` is the repository id used by `dnf --enablerepo=local …`.
- `baseurl` can be `https://…`, `http://…` or `file:///…` for a local directory.
- `gpgcheck=1` (with `gpgkey=`) verifies package signatures — always use it
  for real repositories; the course disables it only for its unsigned
  practice packages.

A repository is just a directory of `.rpm` files plus a `repodata/` index,
which `createrepo_c DIRECTORY` generates.

## Try it

Run on the Rocky lab machine (`bin/course shell yum-and-rpm`).

Query the database:

```bash
rpm -q bash
rpm -qf /usr/bin/ls
rpm -ql tar | head -3
```

```text
bash-5.1.8-9.el9.x86_64
coreutils-8.32-36.el9.x86_64
/usr/bin/gtar
/usr/bin/tar
/usr/share/doc/tar
```

List repositories and search them:

```bash
dnf repolist
dnf search tree 2>/dev/null | grep -i '^tree'
```

```text
repo id                 repo name
appstream               Rocky Linux 9 - AppStream
baseos                  Rocky Linux 9 - BaseOS
course-offline          Course offline packages
extras                  Rocky Linux 9 - Extras
tree.x86_64 : File system tree viewer
```

Install and remove something, watching dependency resolution:

```bash
sudo dnf install -y tree
rpm -q tree
sudo dnf remove -y tree
rpm -q tree
```

```text
...
Installed:
  tree-1.8.0-10.el9.x86_64

Complete!
tree-1.8.0-10.el9.x86_64
...
Removed:
  tree-1.8.0-10.el9.x86_64

Complete!
package tree is not installed
```

Find the package that would provide a command you don't have:

```bash
dnf provides /usr/bin/htpasswd 2>/dev/null | head -2
```

```text
httpd-tools-2.4.62-1.el9.x86_64 : Tools for use with the Apache HTTP Server
Repo        : course-offline
```

## Common mistakes

- **`rpm -e pkg.rpm`.** Removal takes the package *name* (`rpm -e tree`),
  not the file name.
- **Using `rpm -ivh` for files with dependencies.** It fails with "Failed
  dependencies". Use `dnf install ./file.rpm` instead.
- **Typos in `.repo` files.** `baseurl=file://opt/localrepo` (two slashes)
  means a host called "opt". Local paths need three: `file:///opt/localrepo`.
- **Forgetting `sudo`.** Queries work as a normal user; installs and removals
  need root.

## Recap

- `rpm` handles single packages and the database: `-ivh`, `-Uvh`, `-e`, `-q`,
  `-qa`, `-ql`, `-qf`.
- `dnf` (alias `yum`) adds repositories and dependency resolution: `install`,
  `remove`, `update`, `search`, `provides`, `repolist`.
- Repositories live in `/etc/yum.repos.d/*.repo` with `baseurl`, `enabled`
  and `gpgcheck`.

## Next

The Debian family's equivalents: `dpkg` and `apt`.
