# Backlog

One item per file — or per folder, when it carries a screenshot — in the
folder that says where it stands. Moving something along is moving its
file.

Committed, unlike the rest of `.abydos`: what is left to do belongs to
whoever is working on the project rather than to one machine.

The workflow, and what an item and the spec are shaped like, is in
[AGENTS.md](AGENTS.md). This file is the map.

## The folders

**`open/`** — Written down so it is not forgotten. Not yet agreed, not yet anybody's.

**`ready/`** — Decided. Anybody — or any agent — can pick this up and start.

**`in-progress/`** — Being worked on right now, by a person or in a worktree of its own.

**`waiting/`** — Stuck on something that is not work, and says what it is waiting for.

**`completed/`** — Done, keeping the number it was given.

**`history/`** — The commit log in the backlog's shape, from before the backlog. Not added to.

## spec/

What the project does today, one file per capability. The backlog says
what to do and then forgets; the spec is the account that stays. An item
that changes behaviour carries a delta, and folding that delta in is a
step of the work rather than a tidy-up afterwards.

## Numbers

One sequence across the whole backlog. A number is given once, when the
item is written, and never changes again — finishing an item moves its
file and takes its number with it.
