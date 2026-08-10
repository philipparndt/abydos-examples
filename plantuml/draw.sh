#!/usr/bin/env bash
# Draw every diagram here into build/, the way the editor draws them.
#
# The editor does this on its own, in the pane beside the source. This is for
# checking the files from a terminal, and for the first time — seeing the image
# come down and a picture come back is worth doing once, deliberately, rather
# than discovering it in a preview that appears to be thinking.
set -euo pipefail

cd "$(dirname "$0")"

# One source of truth for the image: the file the project checked in.
image=$(sed -n 's/.*"plantuml"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .abydos/tools.json)
if [ -z "$image" ]; then
	echo "no plantuml image named in .abydos/tools.json" >&2
	exit 1
fi

# The order the editor looks in. Apple's `container` first: it needs no daemon
# running before it will answer, which is the difference between a feature that
# works after a restart and one that says "cannot connect".
runtime=""
for candidate in container docker nerdctl podman; do
	if command -v "$candidate" >/dev/null 2>&1; then
		runtime=$candidate
		break
	fi
done

if [ -z "$runtime" ]; then
	echo "no container runtime here — install docker, or Apple's container" >&2
	echo "(or install plantuml, and the editor will use that instead)" >&2
	exit 1
fi

# A deadline, for the same reason the preview has one: a runtime that is
# installed but whose service is not running takes the command and then waits
# for a daemon that is never coming, and something that waits for ever tells
# nobody why. Generous, because the first draw has to fetch the image.
#
# perl rather than `timeout`, which is not on a Mac: an alarm survives exec, so
# the process that replaces perl is the one it goes off on.
deadline=${DEADLINE:-180}
draw() { perl -e 'alarm shift; exec @ARGV or exit 127' "$deadline" "$@"; }

mkdir -p build
for file in *.puml; do
	out="build/${file%.puml}.png"
	status=0
	# --rm -i, and no mount: the diagram goes in on stdin and the picture comes
	# back on stdout, so the container never sees the project.
	draw "$runtime" run --rm -i "$image" -pipe -tpng -charset UTF-8 <"$file" >"$out" || status=$?

	# 142 is the alarm going off — the case worth a sentence of its own, since
	# nothing was wrong with the diagram and nothing said so.
	if [ "$status" -eq 142 ]; then
		echo "$file: $runtime did not answer within ${deadline}s" >&2
		echo "is it running? \`$runtime run --rm -i $image -version\` answers faster" >&2
		exit 1
	elif [ "$status" -ne 0 ]; then
		echo "$file: $runtime exited $status" >&2
		exit 1
	fi
	# PlantUML answers a diagram it cannot parse with a picture of the error,
	# so a file that fails still writes something. Nothing at all is the case
	# worth failing on.
	if [ ! -s "$out" ]; then
		echo "$file drew nothing — is $runtime running?" >&2
		exit 1
	fi
	echo "  $out"
done

echo "==> drawn by $runtime run --rm -i $image"
