#!/usr/bin/env bash
# Put this example's throwaway key where sops looks for one, and take it out
# again with --remove.
#
# Why a script and not a sentence in the README: sops finds an age key in
# exactly one place without being told — `~/Library/Application Support/sops/
# age/keys.txt` on this platform, which is `os.UserConfigDir()` and *not*
# `~/.config`, whatever the same tool does on Linux. A `SOPS_AGE_KEY_FILE`
# exported in a shell profile is not seen by an app started from the Finder,
# which is how apps are started, so pointing at the key from a profile works
# in a terminal and fails in the editor — the worst of the two answers.
#
# Appending is safe. The file is a list of identities and sops tries all of
# them, so a key already in there goes on working: measured, with the real key
# at that path and SOPS_AGE_KEY_FILE naming an unrelated one, the decrypt still
# succeeded. This adds a line; it replaces nothing.
set -euo pipefail

cd "$(dirname "$0")"

case "$(uname -s)" in
	Darwin) keys="$HOME/Library/Application Support/sops/age/keys.txt" ;;
	*) keys="${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt" ;;
esac

begin="# >>> abydos-examples/secrets — throwaway key, safe to delete"
end="# <<< abydos-examples/secrets"

if [ "${1:-}" = "--remove" ]; then
	if [ ! -f "$keys" ] || ! grep -qF "$begin" "$keys"; then
		echo "==> not installed; nothing to remove"
		exit 0
	fi
	# Everything outside the two markers, kept byte for byte.
	awk -v b="$begin" -v e="$end" '
		$0 == b { skip = 1 } skip != 1 { print } $0 == e { skip = 0 }
	' "$keys" > "$keys.abydos-tmp"
	mv "$keys.abydos-tmp" "$keys"
	echo "==> removed the example's key from $keys"
	exit 0
fi

if [ -f "$keys" ] && grep -qF "$begin" "$keys"; then
	echo "==> already installed in $keys"
	exit 0
fi

mkdir -p "$(dirname "$keys")"
{
	printf '%s\n' "$begin"
	grep -v '^#' age-key.txt
	printf '%s\n' "$end"
} >> "$keys"
chmod 600 "$keys"

echo "==> added the example's key to $keys"
echo "    ./install-key.sh --remove takes it out again"
