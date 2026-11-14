# Solution — Organise the Asia office notes

All commands run on the lab machine as `bob`.

## t1 — create the tree

`-p` creates every missing parent and doesn't fail if some already exist.
Running as bob (no `sudo`) means bob owns the new directories.

```bash solution target=ubuntu user=bob
mkdir -p /home/bob/asia/india/mumbai
```

## t2 — copy the city guide

When the destination is an existing directory, `cp` places the copy inside
it with the same file name. The original is untouched.

```bash solution target=ubuntu user=bob
cp /home/bob/notes/city-guide.txt /home/bob/asia/india/mumbai/
```

## t3 — fix the misspelled directory

`mv` renames in place; the directory's contents come along because nothing
is copied — only the name changes.

```bash solution target=ubuntu user=bob
mv /home/bob/projetcs /home/bob/projects
```

## t4 — delete the leftovers

`-r` (recursive) is needed because the directory isn't empty. There is no
undo, so always check the path first (`ls -R /home/bob/old-contractor-tmp`).

```bash solution target=ubuntu user=bob
rm -r /home/bob/old-contractor-tmp
```

## t5 — save the whatis line

`>` redirects standard output into a file, creating or overwriting it.

```bash solution target=ubuntu user=bob
whatis ls > /home/bob/whatis.txt
cat /home/bob/whatis.txt
```

## Verify

```bash
ls -R /home/bob/asia
ls /home/bob
```
