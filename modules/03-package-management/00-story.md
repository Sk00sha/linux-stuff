---
id: 03-package-management/00-story
title: "Story: Two families, one app"
---

# Story: Two families, one app

Mercury, the application Caleston will demo, has an awkward history. Its
web front end was written by a team that loves Ubuntu; its reporting backend
was written by a team that only trusts Rocky Linux. Both halves must be
ready for the demo, and both need software installed.

On Thursday morning Priya drops two tickets into Bob's queue.

The first is for the Rocky box: install the Apache web server and a couple
of utilities, remove a package that a security scan flagged, and set up the
company's internal package repository so that the team's own tool, `bob-tool`
(named, to Bob's mild embarrassment, after the last engineer called Bob), can
be installed like any other package.

The second is for the Ubuntu box: a vendor sent a `.deb` file for their
notes tool. "It never installs cleanly," the ticket says. "Something about
dependencies." While he's there, Bob should remove the `nano` editor from
the image — the team standard is `vim` — and document which files one of the
packages put on the system.

"Whatever you do," says Marco, "don't download random binaries from the
internet and copy them into `/usr/bin`. That's what package managers are
for. They know what's installed, what depends on what, and how to remove it
cleanly."

This module explains what packages are, how the Red Hat and Debian families
manage them, and why there are two layers of tools in each family. Both labs
work **offline**: the repositories the labs need are baked into the course
images.
