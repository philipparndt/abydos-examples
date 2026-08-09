#!/bin/sh
# What a real postCreateCommand does: fetch the things the image deliberately
# did not carry, and take long enough doing it that somebody wonders whether
# anything is happening.
#
# It prints as it goes, because a lifecycle command with nothing on screen is
# indistinguishable from a hung editor. Whatever runs this is expected to put
# these lines somewhere they can be read.
set -e

echo "post-create: installing the tools the image does not carry"
apk add --no-cache git make jq >/dev/null

echo "post-create: warming a cache, slowly, so there is something to watch"
i=1
while [ "$i" -le 10 ]; do
	printf 'post-create: step %s of 10\n' "$i"
	sleep 1
	i=$((i + 1))
done

echo "post-create: done — jq is $(jq --version)"
