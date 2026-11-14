# Cheatsheet — Package Management

## Red Hat family (Rocky, RHEL, Fedora)

| Command | Does |
|---|---|
| `rpm -ivh f.rpm` / `rpm -Uvh f.rpm` / `rpm -e NAME` | install / upgrade / erase |
| `rpm -q NAME` / `rpm -qa` / `rpm -qi NAME` | query one / all / info |
| `rpm -ql NAME` / `rpm -qf /path` / `rpm -qR NAME` | files / owner / requirements |
| `dnf install -y NAME` / `dnf install ./f.rpm` | install with dependencies |
| `dnf remove NAME` / `dnf update` | remove / update all |
| `dnf search WORD` / `dnf info NAME` / `dnf provides /path` | search / details / who provides a file |
| `dnf repolist` / `dnf list installed` | repositories / installed |
| `/etc/yum.repos.d/*.repo` | `[id]` `name=` `baseurl=file:///dir` `enabled=1` `gpgcheck=1` |
| `createrepo_c DIR` | turn a directory of rpms into a repository |

## Debian family (Ubuntu, Debian)

| Command | Does |
|---|---|
| `dpkg -i f.deb` / `dpkg -r NAME` / `dpkg -P NAME` | install / remove / purge |
| `dpkg -l [PAT]` / `dpkg -s NAME` | list (ii ok, rc config left) / status |
| `dpkg -L NAME` / `dpkg -S /path` / `dpkg -I f.deb` | files / owner / file info |
| `apt update` / `apt upgrade` | refresh indexes / upgrade all |
| `apt install NAME` / `apt install ./f.deb` | install with dependencies |
| `apt remove NAME` / `apt purge NAME` / `apt autoremove` | remove / with config / unused deps |
| `apt -f install` | fix broken installs |
| `apt search WORD` / `apt show NAME` | search / details |
| `/etc/apt/sources.list`, `/etc/apt/sources.list.d/` | repositories |

Scripts: use `apt-get` / `apt-cache`; at the keyboard: `apt`.
