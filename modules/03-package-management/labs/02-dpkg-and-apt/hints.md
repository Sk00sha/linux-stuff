# Hints — Install the vendor's notes tool on Ubuntu

## t1

### Level 1

`dpkg` installs a `.deb` file directly. Installing needs root.

### Level 2

`sudo dpkg -i FILE.deb`. It will complain about a dependency — that's expected, and t2 deals with it.

### Level 3

`sudo dpkg -i /home/bob/packages/bob-notes_1.0-1_all.deb`

## t2

### Level 1

`dpkg` doesn't fetch dependencies. The high-level tool can repair a half-finished install.

### Level 2

`apt` has a "fix broken" mode, `-f`. `dpkg -l bob-notes` shows the status before and after.

### Level 3

`sudo apt -f install` (or `sudo apt-get -f install -y`), then run `bob-notes`.

## t3

### Level 1

One `dpkg` option lists the files a package installed; save its output.

### Level 2

`dpkg -L PACKAGE` lists the files. Use `>` to write to a file.

### Level 3

`dpkg -L tree > /home/bob/tree-files.txt`

## t4

### Level 1

You need the reverse lookup: from a file to its package.

### Level 2

`dpkg -S /path` prints `package: /path`. Only the part before the colon goes into the file.

### Level 3

`dpkg -S /usr/bin/whatis` prints `man-db: /usr/bin/whatis`, so `echo man-db > /home/bob/whatis-owner.txt` (or `dpkg -S /usr/bin/whatis | cut -d: -f1 > /home/bob/whatis-owner.txt`).

## t5

### Level 1

Removing is done with the high-level tool. Read what it says it will remove before confirming.

### Level 2

`sudo apt remove PACKAGE`. Check `vim` is not in the removal list.

### Level 3

`sudo apt remove nano`, then `dpkg -l nano vim`.
