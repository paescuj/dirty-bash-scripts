#!/usr/bin/env bash
#
# Find duplicate lines in a file and print the count.

file_name="$1"

declare -A lines

while read -r line; do
	# Optionally, process the line, e.g. extract only a part of it
	# line="${line#*/}"

	((lines[$line]++))
done <"$file_name"

for line in "${!lines[@]}"; do
	if [[ ${lines[$line]} -gt 1 ]]; then
		echo "${lines[$line]} $line"
	fi
done
