# Cheatsheet — Working with Shell II

## Archive and compress

| Command | Does |
|---|---|
| `du -sh DIR` / `du -sh * \| sort -h` | size / biggest items |
| `tar -czf a.tar.gz DIR` / `-cjf` / `-cJf` | create gzip / bzip2 / xz archive |
| `tar -tzf a.tar.gz` / `tar -xzf a.tar.gz -C /dest` | list / extract elsewhere |
| `gzip f` / `gunzip f.gz` / `gzip -k f` | compress / decompress / keep original |
| `bzip2`, `bunzip2`, `xz`, `unxz` | other compressors |
| `zcat`, `zless`, `zgrep` | read .gz files directly |

## Find and grep

| Command | Does |
|---|---|
| `locate NAME` / `sudo updatedb` | database search / refresh database |
| `find DIR -name '*.log' -type f -size +1M -mtime -7` | name, type, size, age |
| `find DIR -user bob -perm -o+w` | owner, permissions |
| `find ... -exec CMD {} \;` / `-delete` | act on each match |
| `grep -i -v -w -n -c -l -r PAT FILES` | case, invert, word, numbers, count, names, recurse |
| `grep -A2 -B2 -C2 PAT` / `grep -E 'a\|b'` | context / extended regex |

## Redirection

| Syntax | Does |
|---|---|
| `> f` / `>> f` | stdout overwrite / append |
| `2> f` / `> f 2>&1` / `&> f` | stderr / both / both |
| `< f` | stdin from file |
| `2>/dev/null` | discard errors |
| `a \| b` / `a \| tee f` / `\| sudo tee f` | pipe / save and show / write as root |

## vi

| Keys | Does |
|---|---|
| `i a o I A O` / Esc | insert modes / back to normal |
| `h j k l w b 0 $ gg G 42G` | move |
| `x dd 3dd dw yy p P u Ctrl+R .` | edit, undo, redo, repeat |
| `/pat` `n` `N` / `:%s/old/new/g` | search / substitute |
| `:w` `:q` `:wq` `:q!` `ZZ` | save / quit |
| `:set number`, `vim -r file`, `vimtutor` | line numbers, recover, tutorial |
