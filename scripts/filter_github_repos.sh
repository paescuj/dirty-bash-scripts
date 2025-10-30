#!/usr/bin/env bash
#
# Filter a list of GitHub repos.

input_file="$1"
output_file="$2"

while read -r line; do
	repo=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${line}")

	pushed_at=$(echo "$repo" | jq -r '.pushed_at')

	if [[ $pushed_at != 2025* ]]; then
		echo "Filtered ${line} since inactive (no push in 2025)"
		continue
	fi

	fork=$(echo "$repo" | jq -r '.fork')

	if [[ $fork == true ]]; then
		source=$(echo "$repo" | jq -r '.source.full_name')
		if grep -q "$source" "$1"; then
			echo "Filtered ${line} since fork of ${source}"
		else
			echo "Filtered ${line} since fork of ${source} (not in our list)"
		fi
		continue
	fi

	echo "$line" >>"$output_file"
done <"$input_file"
