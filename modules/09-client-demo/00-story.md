---
id: 09-client-demo/00-story
title: "Story: Client demonstration in jeopardy!"
---

# Story: Client demonstration in jeopardy

Friday, 08:52. The client's delegation arrives at 10:00. The demo
environment was rebuilt overnight by the deployment pipeline, and Bob opens
the demo URL with a cup of coffee in his other hand.

```text
curl: (7) Failed to connect to demo-web port 80: Connection refused
```

He puts the coffee down.

Priya is already on the phone with the client's project manager, smiling
in the way people smile when they're buying time. Marco is stuck in traffic.
The pipeline's log says "SUCCESS" in large green letters, which is not
helpful.

Bob takes a breath and remembers what he learned over the last three weeks:
**observe before you change anything, then climb the ladder.** Is the
service running? What do its logs say? Can it read its configuration? Can
it find the database by name? Can it reach the database's port? Is there
space to write? Is everything it needs installed?

Somewhere in the rebuild, several things went wrong at once. The pipeline
broke the service definition, tightened a permission too far, typed a host
name wrong, left a firewall rule from a test, filled a disk, lost a cron job
and a package, and mangled an environment variable. Each one alone would
take the site down. Together they look like one big mystery.

They aren't. They're eight small problems, and Bob knows how to find each
one.

You have until 10:00.
