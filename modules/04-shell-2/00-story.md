---
id: 04-shell-2/00-story
title: "Story: Behind schedule"
---

# Story: Behind schedule

Monday of week two. The Mercury demo is now twelve working days away, and
the stand-up meeting is tense.

"The reporting job crashed three times over the weekend," Priya says. "We
need the logs analysed, the old reports archived before the disk fills up,
and the config fixed. Today."

Bob gets the job. He opens `/var/app` and finds dozens of log files, some of
them hundreds of megabytes. The reports directory holds a month of CSV files
nobody has archived. The application's start-up script prints a wall of
output, half of it errors, all mixed together on the screen. And the
configuration file that needs changing lives on a server where the only
editor installed is `vi`.

Marco leans over. "Clicking through files won't scale," he says. "You need
four things: archive and compress, find files by their properties, search
inside files for patterns, and send command output exactly where you want
it. Oh — and you'll have to learn enough `vi` to survive."

He scribbles a line on a sticky note and hands it to Bob:

```text
find /var/app -name '*.log' -size +1M -exec ls -lh {} \; 2>/dev/null | tee biglogs.txt
```

"By the end of today you'll understand every part of that," he says.

This module covers archiving and compression, finding files and searching
text, input/output redirection, and the `vi` editor. The labs put Bob's
logs, reports and configuration in order.
