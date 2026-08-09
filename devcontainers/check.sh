#!/bin/sh
# Brings up every devcontainer example that is meant to come up, asks it the one
# question it exists to answer, and removes it again.
#
# An example whose container cannot be built is worse than no example, which is
# the whole reason this script is here: the refusals below are checked by
# Abydos' own tests, but "does this image still exist, does this Dockerfile
# still build, is the toolchain still in there" is a question only docker can
# answer, and only by being asked.
#
# It is not Abydos. It runs the same shape of command Abydos runs — the checkout
# bind-mounted at the workspace folder, the entrypoint replaced so the container
# stays up, the user and the environment the file asked for — so that a change
# breaking one breaks the other. What it cannot show is the refusals, because
# those are sentences Abydos writes; see the README beside this file.
#
# Docker only, as Abydos is: a container kept for a whole editing session is the
# one that most needs removing again.
set -e

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
failed=0

# Every container this starts is named abydos-probe-… and removed in the same
# function, however the probe goes.
probe() {
	project=$1
	image=$2
	folder=$3
	user=$4
	command=$5

	name="abydos-probe-$(basename "$project")"
	printf '\n==> %s (%s)\n' "$project" "$image"
	docker rm -f "$name" >/dev/null 2>&1 || true

	docker run -d --name "$name" \
		--entrypoint /bin/sh \
		-v "$root/$project:$folder" \
		-w "$folder" \
		"$image" \
		-c "trap 'exit 0' TERM INT; while true; do sleep 86400 & wait \$!; done" >/dev/null

	if docker exec -w "$folder" ${user:+-u "$user"} "$name" /bin/sh -c "$command"; then
		:
	else
		echo "!!! $project did not answer"
		failed=1
	fi
	docker rm -f "$name" >/dev/null
}

# The plainest thing that works, twice: one image and nothing else, and the same
# image with ports and environment on top.
probe go-service golang:1.24-alpine /workspaces/go-service "" \
	'go build -o /tmp/go-service . && echo "built with $(go version)"'

probe smart-home-microservice golang:1.24-alpine /workspaces/smart-home-microservice "" \
	'go build -o /tmp/smart-home . && echo "built with $(go version)"'

# Built here rather than pulled. The three checks are one per build field:
# context, args, target.
echo
echo "==> devcontainers/dockerfile-build (built from .devcontainer/Dockerfile)"
docker build -q \
	-t abydos-devcontainer:dockerfile-build \
	-f "$here/dockerfile-build/.devcontainer/Dockerfile" \
	--build-arg ALPINE=3.21 \
	--build-arg EXTRA=jq \
	--target development \
	"$here/dockerfile-build" >/dev/null
probe devcontainers/dockerfile-build abydos-devcontainer:dockerfile-build \
	/workspaces/dockerfile-build "" \
	'abydos-hello && jq --version && ! test -e /etc/abydos-wrong-stage && echo "the development stage, not the one after it"'

# A shell that is not root.
probe devcontainers/non-root-user mcr.microsoft.com/devcontainers/base:alpine-3.21 \
	/workspaces/non-root-user vscode \
	'echo "the shell is $(whoami), uid $(id -u)"'

# The substitutions cannot be checked here — they are resolved by Abydos before
# the container exists — but the image and the workspace folder can be.
probe devcontainers/substitutions alpine:3.21 /src "" \
	'test -f README.md && echo "the checkout is at $(pwd)"'

# The lifecycle command, run the way Abydos runs it: inside the container that
# is already up, at the workspace folder. The package it installs is one the
# image deliberately does not carry, so finding it afterwards is the command
# having really run.
probe devcontainers/post-create alpine:3.21 /workspaces/post-create "" \
	'sh .devcontainer/post-create.sh >/dev/null && jq --version && echo "jq is here, and the image has none"'

# Its harder half, which is meant to fail: exit 3, and the reason on standard
# error rather than on standard output, which is what Abydos quotes.
printf '\n==> devcontainers/post-create-fails (alpine:3.21, expected to fail)\n'
fails_name=abydos-probe-post-create-fails
docker rm -f "$fails_name" >/dev/null 2>&1 || true
docker run -d --name "$fails_name" \
	--entrypoint /bin/sh \
	-v "$here/post-create-fails:/workspaces/post-create-fails" \
	-w /workspaces/post-create-fails \
	alpine:3.21 \
	-c "trap 'exit 0' TERM INT; while true; do sleep 86400 & wait \$!; done" >/dev/null
fails_said=$(docker exec -w /workspaces/post-create-fails "$fails_name" \
	/bin/sh -c 'sh .devcontainer/post-create.sh 2>&1 >/dev/null' || true)
docker exec -w /workspaces/post-create-fails "$fails_name" \
	/bin/sh -c 'sh .devcontainer/post-create.sh >/dev/null 2>&1' && fails_status=0 || fails_status=$?
docker rm -f "$fails_name" >/dev/null
if [ "$fails_status" -eq 3 ]; then
	echo "exited 3, saying: $(echo "$fails_said" | tail -n 1)"
else
	echo "!!! devcontainers/post-create-fails exited $fails_status, and 3 is what it is for"
	failed=1
fi

# Two containers for one project, which Abydos offers as two menu entries and
# can have up at the same time. Both, because the point is that they are two.
probe devcontainers/two-containers alpine:3.21 /workspaces/two-containers "" \
	'! command -v go >/dev/null && echo "the small one, with no toolchain in it"'
probe devcontainers/two-containers golang:1.24-alpine /workspaces/two-containers "" \
	'echo "the other one, with $(go version)"'

echo
echo "==> refused on purpose, so there is nothing to bring up"
echo "    multi-tier                     dockerComposeFile"
echo "    devcontainers/features         features"

# The compose file is refused by Abydos and still has to be a real one.
if docker compose -f "$root/multi-tier/.devcontainer/docker-compose.yml" config -q; then
	echo "    multi-tier/.devcontainer/docker-compose.yml is valid compose"
else
	echo "!!! multi-tier/.devcontainer/docker-compose.yml is not valid compose"
	failed=1
fi

echo
if [ "$failed" -eq 0 ]; then
	echo "==> every devcontainer that should come up came up"
else
	echo "==> something did not come up"
fi
exit "$failed"
