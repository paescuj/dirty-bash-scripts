#!/usr/bin/env bash
#
# Update all installed Node.js versions, managed by fnm, to their latest version.

fnm list | sed -En 's/^\* v([[:digit:]]*).*/\1/p' | uniq | while read -r major; do
	fnm install "$major"

	mapfile -t versions < <(fnm list | sed -En "s/^\* v(${major}\.[[:digit:]]*\.[[:digit:]]*).*/\1/p")

	for ((i = 0; i < $((${#versions[@]} - 1)); i++)); do
		fnm uninstall "${versions[$i]}"
	done
done
