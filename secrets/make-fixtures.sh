#!/usr/bin/env bash
# Write the three files this example cannot commit.
#
# Of the three states the status bar distinguishes for a file whose values it
# covers, only one can be checked in: a file git tracks. The other two are
# defined by git *not* having them — one it ignores, one it has never been told
# about — and a repository cannot carry a file it does not carry. So they are
# written here instead, and the fixture is the script rather than the files.
#
# `.env.staging` will show up in `git status` for as long as it exists, and
# that is the point of it. `--clean` takes all three away again.
set -euo pipefail

cd "$(dirname "$0")"

if [ "${1:-}" = "--clean" ]; then
	rm -f .env.staging .env.local secrets.yaml.dec
	echo "==> removed .env.staging, .env.local and secrets.yaml.dec"
	exit 0
fi

# Neither tracked nor ignored: the bar reads *Not in .gitignore*, and pressing
# it offers the one thing there is to do — a line in `.gitignore` — after which
# the notice goes by itself.
cat > .env.staging <<'EOF'
# Not in .gitignore, and git has never been told about it. Committing this file
# would commit the values under the covers, which is what the status bar says.
API_KEY=not-a-real-key-1111
DATABASE_PASSWORD=hunter2
EOF

# Ignored, so git can never see it: the values are covered and the bar says
# nothing further. This is the file a real project would have.
cat > .env.local <<'EOF'
# Matched by a line in .gitignore, so there is no notice beside the lock — the
# covers, and nothing else. This is the arrangement a real project wants.
API_KEY=not-a-real-key-2222
DATABASE_PASSWORD=hunter2
EOF

# A `.dec` file: concealed by its name, with no sops anywhere near it. The
# separator of a dec file may be a `:`, and the value of `signing_key:` is not
# the `|` — it is every indented line under it.
cat > secrets.yaml.dec <<'EOF'
# helmsec writes files like this one beside the chart. Abydos covers them by
# name, and has nothing to say about encrypting them: there is no chip here,
# only the lock.
database:
  password: hunter2
signing_key: |
  -----BEGIN PRIVATE KEY-----
  TheseAreNotTheBytesOfAnyKey0000000000000000000000
  NorAreThese11111111111111111111111111111111111111
  -----END PRIVATE KEY-----
export TOKEN="not-a-real-token-3333"
EOF

echo "==> wrote .env.staging (untracked), .env.local (ignored), secrets.yaml.dec (ignored)"
echo "    .env.staging stays in git status on purpose — committing it takes the fixture away"
