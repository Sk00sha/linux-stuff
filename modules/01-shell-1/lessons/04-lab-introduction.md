---
id: 01-shell-1/04-lab-introduction
title: How the Labs Work
minutes: 5
objectives:
  - Start a lab and open a shell on the lab machine
  - Check your work, ask for hints and reset a lab
prerequisites: [01-shell-1/03-command-line-help]
tryit: none
---

# How the Labs Work

## Why this matters

Reading about commands is not the same as using them. Every module in this
course ends with hands-on labs where you solve Bob's problems on real Linux
machines — containers on your computer for most modules, a virtual machine
for the ones that need a real kernel. An automatic grader tells you what is
done and what is still missing.

## Concepts

### Two places, two prompts

During a lab you work in **two** terminals (or switch between them):

1. **Your own computer** (the *host*), in the course repository. Here you run
   `make` / `course` commands to start, check and reset labs. Prompts in the
   course material for the host look like `you@laptop:~/linux-basics-course$`.
2. **The lab machine**, for example `bob@ubuntu:~$`. This is where you do the
   actual tasks.

`course start` opens a shell on the lab machine for you. When you `exit` that
shell, you are back on your host and can run `course check`.

### The lab lifecycle

| Step | Command (either form works) | What happens |
|---|---|---|
| start | `make lab ID=working-with-the-shell` or `bin/course start working-with-the-shell` | starts only the machines this lab needs, runs the lab's `setup.sh`, opens a shell as `bob` |
| check | `make check ID=…` or `bin/course check …` | runs the grader; prints `PASS`/`FAIL` per task with a reason |
| hint | `make hint ID=… TASK=t2` or `bin/course hint … t2` | shows the next of three hint levels for a task |
| reset | `make reset ID=…` or `bin/course reset …` | puts the lab back to its starting state |
| shell | `bin/course shell …` | opens another shell on the lab machine |
| solution | `bin/course solution …` | shows the full worked solution (try first!) |

Lab IDs can be shortened to any unique part: `working-with-the-shell`,
`01-shell-1/working-with-the-shell` and `with-the-shell` all work.

### Reading grader output

The grader never changes anything; it only looks. A failure message tells
you what it **observed**, not what to type:

```text
PASS t1
FAIL t2: /home/bob/asia/india/mumbai/city-guide.txt does not exist on ubuntu (or is not a regular file)
PASS t3
---
2 passed, 1 failed
```

Run the check as often as you like — it is a good way to confirm each task
as you finish it.

### Hints come in three levels

1. a **nudge** — what to think about;
2. the **command** you probably need;
3. something very close to the answer.

Try to stop at the lowest level that gets you moving again.

### Quizzes and progress

Each lesson has a short quiz: `make quiz ID=01-introduction-to-shell` or
`bin/course quiz 01-introduction-to-shell`. `make progress` shows what you
have completed. Progress is stored in
`~/.local/share/linux-basics-course/progress.json` on your host.

## Try it

These commands run on your **host**, inside the course repository.

See the course outline:

```bash norun
bin/course list 01-shell-1
```

```text
Linux Basics — Hands-On  v1.0.0

01-shell-1  Working with Shell I  [runtime: docker] 0/12 done
    story   Story: Day one, no mouse                             01-shell-1/00-story
    lesson  Introduction to the Shell                            01-shell-1/01-introduction-to-shell
    quiz    Quiz: introduction to shell                          01-shell-1/01-introduction-to-shell
    ...
```

Start the first lab without opening a shell, then open one separately:

```bash norun
bin/course start working-with-the-shell --no-shell
bin/course shell working-with-the-shell
```

Inside the lab machine, look around, then type `exit` and grade your work
from the host:

```bash norun
bin/course check working-with-the-shell
bin/course hint working-with-the-shell t1
```

## Common mistakes

- **Running lab tasks on your host instead of the lab machine.** Look at the
  prompt: lab machines show `bob@ubuntu` (or similar).
- **Running `course check` inside the lab machine.** The grader runs on the
  host; exit the lab shell first or use a second terminal.
- **Forgetting to reset after experimenting.** If you made a mess, `course
  reset` gives you a clean starting point.

## Recap

- `course start` prepares the lab machines and opens a shell; `course check`
  grades from the host.
- Hints come in three levels; the full solution is available but try first.
- `course reset` restores a lab's starting state at any time.

## Next

Start your first lab: `make lab ID=working-with-the-shell`. After that, the
Bash lesson shows how to make the shell your own.
