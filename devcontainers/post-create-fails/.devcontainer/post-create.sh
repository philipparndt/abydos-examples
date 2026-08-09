#!/bin/sh
# Fails on purpose, and fails the way real ones fail: some way in, after it has
# already printed enough to look like it was working.
#
# The interesting thing about this script is the last two lines it writes. A
# lifecycle command that fails has to be reported as *this command, this
# output* — "the container could not be created" is the message that sends
# somebody to read a log nobody kept.
set -e

echo "post-create: step 1 of 3 — this works"
sleep 1
echo "post-create: step 2 of 3 — this works too"
sleep 1

echo "post-create: step 3 of 3 — fetching a dependency that is not there"
echo "error: no such package: a-package-that-does-not-exist" >&2
exit 3
