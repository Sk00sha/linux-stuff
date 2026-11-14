---
id: 04-shell-2/05-vi-editor
title: The VI Editor
minutes: 20
objectives:
  - Switch between vi's normal, insert and command-line modes
  - Move, insert, delete, copy, paste and undo
  - Search and substitute text
  - Save, quit, and quit without saving
prerequisites: [04-shell-2/04-io-redirection]
tryit: ubuntu
---

# The VI Editor

## Why this matters

`vi` (today almost always **Vim**, "Vi IMproved") is installed on virtually
every Unix-like system, including minimal servers and rescue environments
where nothing else is. Bob doesn't need to become a Vim wizard, but he must
be able to open a config file, change a value, save and get out — without
panicking.

## Concepts

### Modes

vi is a **modal** editor: the same key does different things depending on
the mode.

```text
             i, a, o, I, A, O
   NORMAL  ------------------>  INSERT
   (move,  <------------------  (type text)
   delete,        Esc
   copy)
     |  ^
   : |  | Enter / Esc
     v  |
   COMMAND-LINE  (:w  :q  :%s/old/new/g)
```

- **Normal mode** (where you start): keys are commands.
- **Insert mode**: keys type text. `-- INSERT --` shows at the bottom.
- **Command-line mode**: started with `:` (or `/` for search); type a
  command and press Enter.

When in doubt, press **Esc** (twice does no harm) to get back to normal mode.

### Entering insert mode

| Key | Inserts |
|---|---|
| `i` / `a` | before / after the cursor |
| `I` / `A` | at the start / end of the line |
| `o` / `O` | on a new line below / above |

### Moving (normal mode)

| Key | Moves |
|---|---|
| `h j k l` (or arrow keys) | left, down, up, right |
| `w` / `b` | next / previous word |
| `0` / `$` | start / end of line |
| `gg` / `G` / `42G` | first line / last line / line 42 |

### Editing (normal mode)

| Key | Action |
|---|---|
| `x` | delete the character under the cursor |
| `dd` / `3dd` | delete (cut) the line / three lines |
| `dw` | delete to the end of the word |
| `yy` / `3yy` | yank (copy) the line / three lines |
| `p` / `P` | paste after / before |
| `u` / `Ctrl+R` | undo / redo |
| `r` + char | replace one character |
| `.` | repeat the last change |

### Search and substitute

- `/word` searches forward, `?word` backwards; `n` / `N` jump to the next /
  previous match.
- `:%s/old/new/g` replaces every `old` with `new` in the whole file (`%`).
  Add `c` (`:%s/old/new/gc`) to confirm each one.
- `:set number` shows line numbers.

### Saving and quitting

| Command | Effect |
|---|---|
| `:w` | write (save) |
| `:q` | quit (refuses if there are unsaved changes) |
| `:wq` or `:x` or `ZZ` | save and quit |
| `:q!` | quit and **discard** changes |
| `:w newname` | save as another file |

### Swap files

While a file is open, Vim keeps unsaved changes in a hidden **swap file**
next to it, e.g. `.app.conf.swp`. If Vim or your SSH session crashes, it is
left behind, and the next time you open the file Vim warns you. Recover with
`vim -r file`, or delete the stale `.swp` after checking you don't need it.

### Learning more

Run `vimtutor` for a 30-minute interactive tutorial — the best investment
you can make in vi.

## Try it

vi is interactive, so practise by opening a scratch file. Run this, then
follow the steps below:

```bash norun
cp /etc/os-release ~/practice.txt
vi ~/practice.txt
```

1. Type `/VERSION` and Enter to jump to the first match, `n` for the next.
2. Press `dd` to delete that line, then `u` to undo.
3. Press `G` to go to the end, `o` to open a new line, type
   `# edited by bob`, then Esc.
4. Type `:wq` and Enter.

The same editing commands can also be run non-interactively, which is how
we can show you real output here. `vim -es` runs Ex commands from the
command line and exits:

```bash
printf 'port=8080\nhost=localhost\nmode=debug\n' > ~/app.conf
vim -es -c '%s/8080/9090/g' -c 'wq' ~/app.conf
cat ~/app.conf
```

```text
port=9090
host=localhost
mode=debug
```

Delete line 3, then use `:normal` to replay normal-mode keys: `G` (go to
the last line), `o` (open a new line below) and the text to type:

```bash
vim -es -c '3d' -c 'normal Gomode=production' -c 'wq' ~/app.conf
cat ~/app.conf
```

```text
port=9090
host=localhost
mode=production
```

A crashed editing session leaves a swap file behind. Here we fake one to see
what it looks like:

```bash
touch ~/.app.conf.swp
ls -a ~ | grep swp
rm ~/.app.conf.swp ~/app.conf
```

```text
.app.conf.swp
```

## Common mistakes

- **Typing text in normal mode.** Random commands run (`d`, `x`, `G`…).
  Press Esc, then `u` until the damage is undone, or `:q!` to bail out.
- **"E37: No write since last change".** You used `:q` with unsaved changes.
  `:wq` to save, `:q!` to discard.
- **Editing a root-owned file without sudo.** You'll get "E45: 'readonly'
  option is set". Quit and use `sudo vi FILE` (or `sudoedit FILE`).
- **Leaving swap files behind.** If Vim warns about one, decide: recover
  (`R`) or delete it once you're sure.

Note: the lab grader can check the *result* of your edits, but it can't tell
whether you used vi. Use vi anyway — the practice is the point.

## Recap

- Normal mode for commands, `i`/`a`/`o` for insert mode, Esc to return, `:`
  for commands.
- `dd` `yy` `p` `u` `x`, `/search` `n`, `:%s/old/new/g`.
- `:wq` saves and quits, `:q!` discards; stale `.swp` files mean an
  interrupted session.

## Next

Labs time: `make lab ID=shell-2`, then `make lab ID=vi-editor`.
