# Solution — Fix the Mercury config with vi

## Interactively, in vi

```bash norun
vi /home/bob/mercury.conf
```

Vim shows "ATTENTION: Found a swap file by the name .mercury.conf.swp".
The editing session that created it is gone and there's nothing to recover:
press **D** (delete it) — or **E** (edit anyway) and remove it afterwards.

Then, in normal mode:

| Keys | Effect |
|---|---|
| `:%s/8080/80/` Enter | t1: change the port |
| `:%s/development/production/g` Enter | t2: all three occurrences |
| `/^debug_password` Enter `dd` | t3: delete the line |
| `G` `o` `demo_client = halvorsen` Esc | t4: append as last line |
| `:wq` Enter | save and quit |

Check the swap file is gone (t5): `ls -a /home/bob | grep swp` prints nothing.

## The same edits, scripted

The automated test applies the identical Ex commands with `vim -es`
(silent Ex mode). `-n` stops vim from creating a new swap file.

```bash solution target=ubuntu user=bob
cd /home/bob
rm -f .mercury.conf.sw?
vim -n -es -c '%s/8080/80/' -c '%s/development/production/g' \
  -c 'g/^debug_password/d' -c 'normal Godemo_client = halvorsen' -c 'wq' mercury.conf < /dev/null
cat mercury.conf
ls -a | grep swp || echo "no swap files"
```
