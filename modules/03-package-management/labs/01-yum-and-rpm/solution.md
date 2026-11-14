# Solution — Prepare the Rocky reporting server

## t1 — who owns /usr/bin/wget?

`rpm -qf` looks the file up in the database of installed packages. The
`--qf` (query format) option prints just the name instead of
`name-version-release.arch`.

```bash solution target=rocky user=bob
rpm -qf --qf '%{NAME}\n' /usr/bin/wget > /home/bob/wget-owner.txt
cat /home/bob/wget-owner.txt
```

## t2 — install httpd and tree

`dnf` resolves and installs dependencies (apr, httpd-tools, …).

```bash solution target=rocky user=bob
sudo dnf install -y httpd tree
```

## t3 — remove telnet

```bash solution target=rocky user=bob
sudo dnf remove -y telnet
```

## t4 — define the internal repository

`file:///opt/localrepo` is `file://` plus the absolute path. `gpgcheck=0`
is acceptable only because these practice packages are unsigned; real
repositories should be signed and use `gpgcheck=1` with a `gpgkey=`.

```bash solution target=rocky user=bob
sudo tee /etc/yum.repos.d/local.repo >/dev/null <<'REPO'
[local]
name=Caleston internal tools
baseurl=file:///opt/localrepo
enabled=1
gpgcheck=0
REPO
dnf repolist
```

## t5 — install bob-tool

```bash solution target=rocky user=bob
sudo dnf install -y bob-tool
bob-tool
```
