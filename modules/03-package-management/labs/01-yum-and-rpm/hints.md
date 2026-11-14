# Hints — Prepare the Rocky reporting server

## t1

### Level 1

The RPM database knows which package every installed file belongs to.

### Level 2

`rpm -qf FILE` answers "which package owns this file?". Add `--qf '%{NAME}\n'` to print only the name.

### Level 3

`rpm -qf --qf '%{NAME}\n' /usr/bin/wget > /home/bob/wget-owner.txt`

## t2

### Level 1

Use the high-level tool so dependencies are installed too. It needs root.

### Level 2

`sudo dnf install -y PACKAGE...` (`yum` works too).

### Level 3

`sudo dnf install -y httpd tree`

## t3

### Level 1

Removal is the opposite of t2.

### Level 2

`sudo dnf remove PACKAGE` (or `sudo rpm -e PACKAGE`).

### Level 3

`sudo dnf remove -y telnet`, then `rpm -q telnet`.

## t4

### Level 1

Repository definitions are small INI files in `/etc/yum.repos.d/`. Look at `course-offline.repo` for an example.

### Level 2

You need a `[local]` section header and the keys `name`, `baseurl`, `enabled` and `gpgcheck`. Writing to `/etc` needs root (`sudo vi` or `sudo tee`).

### Level 3

```text
[local]
name=Caleston internal tools
baseurl=file:///opt/localrepo
enabled=1
gpgcheck=0
```

Then `dnf repolist` should list `local`.

## t5

### Level 1

Once the repository is defined, the package installs like any other.

### Level 2

`dnf search bob-tool` or `dnf --disablerepo='*' --enablerepo=local list available` confirms dnf can see it.

### Level 3

`sudo dnf install -y bob-tool`, then run `bob-tool`.
