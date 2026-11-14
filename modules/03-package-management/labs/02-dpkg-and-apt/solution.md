# Solution — Install the vendor's notes tool on Ubuntu

## t1 + t2 — install the .deb and repair the dependency

`dpkg -i` unpacks the package but cannot configure it because `figlet` is
missing; it exits with an error and leaves bob-notes in the `iU` state.
`apt -f install` sees the unmet dependency, installs `figlet` (from the local
cache here) and finishes configuring bob-notes.

```bash solution target=ubuntu user=bob
sudo dpkg -i /home/bob/packages/bob-notes_1.0-1_all.deb || true
dpkg -l bob-notes | tail -1
sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y
dpkg -l bob-notes figlet | tail -2
bob-notes
```

(The `|| true` is only there so the automated test continues after the
expected error; interactively you just read the message and move on.)

A cleaner alternative for next time: `sudo apt install ./bob-notes_1.0-1_all.deb`
resolves the dependency in one step.

## t3 — files of the tree package

```bash solution target=ubuntu user=bob
dpkg -L tree > /home/bob/tree-files.txt
```

## t4 — owner of /usr/bin/whatis

`dpkg -S` searches the database of installed files and prints
`package: path`; `cut` keeps the part before the colon.

```bash solution target=ubuntu user=bob
dpkg -S /usr/bin/whatis | cut -d: -f1 > /home/bob/whatis-owner.txt
cat /home/bob/whatis-owner.txt
```

## t5 — remove nano, keep vim

`apt remove` lists what it will remove; only `nano` goes, because nothing
else depends on it. (`purge` would also remove its configuration.)

```bash solution target=ubuntu user=bob
sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y nano
dpkg -l nano vim | tail -2
```
