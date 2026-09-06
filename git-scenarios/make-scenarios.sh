#!/bin/bash
# Builds a set of repositories, each stuck in a state worth looking at.
#
# Generated rather than committed: a repository inside a repository is a
# submodule or a mess, and these are meant to be thrown away and made again.
# Everything lands in ./out, which is ignored.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
out="$here/out"
rm -rf "$out"
mkdir -p "$out"

# A commit whose author and date are the same every time, so the history reads
# the same on every machine.
export GIT_AUTHOR_NAME="Ada Lovelace" GIT_AUTHOR_EMAIL="ada@example.com"
export GIT_COMMITTER_NAME="Ada Lovelace" GIT_COMMITTER_EMAIL="ada@example.com"
export GIT_AUTHOR_DATE="2026-01-01T09:00:00+01:00"
export GIT_COMMITTER_DATE="2026-01-01T09:00:00+01:00"

new() {
	local name="$1"
	git init -q -b main "$out/$name"
	git -C "$out/$name" config user.name "$GIT_AUTHOR_NAME"
	git -C "$out/$name" config user.email "$GIT_AUTHOR_EMAIL"
	printf '%s\n' "$name" > "$out/$name/README.md"
	git -C "$out/$name" add .
	git -C "$out/$name" commit -qm "First commit"
	echo "$out/$name"
}

say() { printf '  %-22s %s\n' "$1" "$2"; }

# 1. A history to read: several commits, a tag, a merge.
repo="$(new history)"
for i in 1 2 3 4 5; do
	printf 'line %d\n' "$i" >> "$repo/notes.md"
	git -C "$repo" add notes.md
	git -C "$repo" commit -qm "Add note $i"
done
git -C "$repo" tag -a v0.1.0 -m "First release"
git -C "$repo" checkout -qb topic
printf 'from the topic branch\n' >> "$repo/notes.md"
git -C "$repo" commit -qam "Say where this came from"
git -C "$repo" checkout -q main
git -C "$repo" merge -q --no-ff topic -m "Merge topic"
say history "commits, a tag, a merge, a branch"

# 2. Work in progress: staged, unstaged and untracked at once.
repo="$(new uncommitted)"
printf 'staged change\n' >> "$repo/README.md"
git -C "$repo" add README.md
printf 'unstaged change\n' >> "$repo/README.md"
printf 'never added\n' > "$repo/scratch.txt"
mkdir -p "$repo/pkg"
printf 'package pkg\n' > "$repo/pkg/pkg.go"
say uncommitted "staged, unstaged and untracked together"

# 3. A conflict, ready to be resolved.
repo="$(new conflict)"
printf 'colour: blue\n' > "$repo/settings.yaml"
git -C "$repo" add settings.yaml
git -C "$repo" commit -qm "Add settings"
git -C "$repo" checkout -qb theirs
printf 'colour: green\n' > "$repo/settings.yaml"
git -C "$repo" commit -qam "Make it green"
git -C "$repo" checkout -q main
printf 'colour: red\n' > "$repo/settings.yaml"
git -C "$repo" commit -qam "Make it red"
git -C "$repo" merge theirs >/dev/null 2>&1 || true
say conflict "a merge stopped in the middle"

# 4. Ahead of a remote: something to push.
repo="$(new unpushed)"
git init -q --bare "$out/unpushed-remote.git"
git -C "$repo" remote add origin "$out/unpushed-remote.git"
git -C "$repo" push -q -u origin main
for i in 1 2 3; do
	printf 'change %d\n' "$i" >> "$repo/CHANGELOG.md"
	git -C "$repo" add CHANGELOG.md
	git -C "$repo" commit -qm "Change $i"
done
say unpushed "three commits the remote has not seen"

# 5. Behind a remote: something to pull.
repo="$(new behind)"
git init -q --bare "$out/behind-remote.git"
git -C "$repo" remote add origin "$out/behind-remote.git"
git -C "$repo" push -q -u origin main
git clone -q "$out/behind-remote.git" "$out/behind-other"
git -C "$out/behind-other" config user.name "$GIT_AUTHOR_NAME"
git -C "$out/behind-other" config user.email "$GIT_AUTHOR_EMAIL"
printf 'from somebody else\n' >> "$out/behind-other/README.md"
git -C "$out/behind-other" commit -qam "Somebody else's commit"
git -C "$out/behind-other" push -q
git -C "$repo" fetch -q
say behind "a commit waiting on the remote"

# 6. A detached head, which is the state people ask about.
repo="$(new detached)"
for i in 1 2 3; do
	printf 'step %d\n' "$i" >> "$repo/steps.md"
	git -C "$repo" add steps.md
	git -C "$repo" commit -qm "Step $i"
done
git -C "$repo" checkout -q HEAD~1
say detached "HEAD on a commit, not a branch"

# 7. Many branches, for the switcher and the graph.
repo="$(new branches)"
for name in feature/lights feature/blinds fix/timeout chore/deps release/1.2; do
	git -C "$repo" checkout -q -b "$name" main
	printf '%s\n' "$name" > "$repo/$(basename "$name").md"
	git -C "$repo" add .
	git -C "$repo" commit -qm "Work on $name"
done
git -C "$repo" checkout -q main
say branches "five branches to switch between"

# 8. A stash, which is easy to forget you have.
repo="$(new stashed)"
printf 'work in progress\n' >> "$repo/README.md"
git -C "$repo" stash -q -u
printf 'other work\n' > "$repo/other.txt"
git -C "$repo" stash -q -u
say stashed "two stashes"

# 9. A history big enough to page through.
repo="$(new large)"
for i in $(seq 1 300); do
	printf 'entry %d\n' "$i" >> "$repo/log.md"
	git -C "$repo" add log.md
	git -C "$repo" commit -qm "Entry $i"
done
say large "300 commits"

# 10. A file worth blaming: four people, months apart, one line still being
# written. Every author and date is fixed, so the blame column reads the same
# on every machine and can be compared against a screenshot.
repo="$(new blame)"
write_as() {
	local who="$1" mail="$2" when="$3" message="$4"
	GIT_AUTHOR_NAME="$who" GIT_AUTHOR_EMAIL="$mail" \
	GIT_COMMITTER_NAME="$who" GIT_COMMITTER_EMAIL="$mail" \
	GIT_AUTHOR_DATE="$when" GIT_COMMITTER_DATE="$when" \
		git -C "$repo" commit -qam "$message"
}

cat > "$repo/thermostat.py" <<'PYTHON'
class Thermostat:
    def __init__(self, target):
        self.target = target
PYTHON
git -C "$repo" add thermostat.py
GIT_AUTHOR_DATE="2024-03-04T10:12:00+01:00" GIT_COMMITTER_DATE="2024-03-04T10:12:00+01:00" \
	git -C "$repo" commit -qm "A thermostat that knows what it wants"

cat >> "$repo/thermostat.py" <<'PYTHON'

    def should_heat(self, current):
        return current < self.target
PYTHON
write_as "Grace Hopper" "grace@example.com" "2024-07-19T16:40:00+02:00" \
	"Heat when it is colder than asked for"

# The line somebody came back to fix, months later, in the middle of what
# somebody else wrote — which is the case blame exists for.
python3 - "$repo/thermostat.py" <<'PYTHON'
import sys
path = sys.argv[1]
text = open(path).read().replace(
    "        return current < self.target",
    "        # A degree of slack, or the relay chatters on the boundary.\n"
    "        return current < self.target - 0.5",
)
open(path, "w").write(text)
PYTHON
write_as "Katherine Johnson" "katherine@example.com" "2025-11-02T08:05:00+01:00" \
	"Stop the relay chattering on the boundary"

cat >> "$repo/thermostat.py" <<'PYTHON'

    def summary(self):
        return f"target {self.target}"
PYTHON
write_as "Radia Perlman" "radia@example.com" "2026-06-15T13:20:00+02:00" \
	"Say what the thermostat is set to"

# And one line nobody has committed, which blame marks as such.
printf '\n# TODO: read the target from the config\n' >> "$repo/thermostat.py"
say blame "four authors over two years, one uncommitted line"

# 11. A superproject: many working copies that look like one.
#
# Twelve by default, because these are meant to be made in a second and thrown
# away. `SUBMODULES=200 ./make-scenarios.sh` builds the size the submodules
# work was measured against — a `git status` that walks every submodule inside
# one process against one that asks each of them separately.
#
# `protocol.file.allow` because git refuses a file:// submodule since
# CVE-2022-39253, and every one of these is a directory beside it.
count="${SUBMODULES:-12}"
mkdir -p "$out/modules"
for i in $(seq 1 "$count"); do
	name="$(printf 'mod-%03d' "$i")"
	git init -q -b main "$out/modules/$name"
	git -C "$out/modules/$name" config user.name "$GIT_AUTHOR_NAME"
	git -C "$out/modules/$name" config user.email "$GIT_AUTHOR_EMAIL"
	for f in a b c d e f g h; do
		printf '%s of %s\n' "$f" "$name" > "$out/modules/$name/$f.txt"
	done
	git -C "$out/modules/$name" add .
	git -C "$out/modules/$name" commit -qm "First commit"
done

repo="$(new superproject)"
for i in $(seq 1 "$count"); do
	name="$(printf 'mod-%03d' "$i")"
	git -C "$repo" -c protocol.file.allow=always \
		submodule add -q "$out/modules/$name" "lib/$name"
done
git -C "$repo" commit -qm "Add $count submodules"

# Four work trees with edits nobody committed. Only the submodules' own
# repositories know about these: the superproject, asked with
# --ignore-submodules=dirty, says nothing about them.
for i in 2 3 5 7; do
	[ "$i" -le "$count" ] || continue
	name="$(printf 'mod-%03d' "$i")"
	printf 'edited, and not committed\n' >> "$repo/lib/$name/a.txt"
done

# And one whose HEAD has moved past the commit the superproject recorded —
# which is the one thing only the superproject knows.
name="$(printf 'mod-%03d' 1)"
printf 'a commit the superproject has not recorded\n' >> "$repo/lib/$name/b.txt"
git -C "$repo/lib/$name" commit -qam "Move ahead of the gitlink"
say superproject "$count submodules, four dirty, one gitlink moved"

# 12. Pictures in a history, so a diff has something to draw rather than
# describe. Written by python3 rather than committed, because a generated
# repository should not need fixtures beside it, and ImageMagick is one more
# thing to have installed than git and python3 are.
repo="$(new pictures)"
png() {
	python3 - "$1" "$2" "$3" "$4" <<'PYTHON'
import struct, sys, zlib

path, width, height, colour = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
red, green, blue = (int(colour[i:i + 2], 16) for i in (0, 2, 4))

# A solid ground with a darker band across the middle third, so that two of
# these differ in a way somebody can see at a glance.
rows = bytearray()
for y in range(height):
    band = height // 3 <= y < 2 * height // 3
    pixel = bytes((red // 2, green // 2, blue // 2) if band else (red, green, blue))
    rows += b"\x00" + pixel * width


def chunk(kind, payload):
    body = kind + payload
    return struct.pack(">I", len(payload)) + body + struct.pack(">I", zlib.crc32(body))


open(path, "wb").write(
    b"\x89PNG\r\n\x1a\n"
    + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    + chunk(b"IDAT", zlib.compress(bytes(rows), 9))
    + chunk(b"IEND", b"")
)
PYTHON
}

png "$repo/logo.png" 160 120 2f6f4e
git -C "$repo" add logo.png
git -C "$repo" commit -qm "A logo"

# A second version at the same size: the diff is the picture, not the bytes.
png "$repo/logo.png" 160 120 7a3f8c
git -C "$repo" commit -qam "Repaint the logo"

# A third that is a different shape, and left uncommitted — so the changes
# pane has a picture to compare without anybody going into the history first.
png "$repo/logo.png" 240 120 b5651d
say pictures "a logo painted three times, the last one uncommitted"

printf '\nMade in %s\n' "$out"
