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

printf '\nMade in %s\n' "$out"
