#!/usr/bin/env bash
#
# Checks whether a newer remote version of a Docker image is available.

is_latest_docker_image() {
	declare repository="$1" image="${1#*/}" tag="$2"

	local_digest=$(
		docker images --digests --format json |
			jq --raw-output --arg repository "$image" --arg tag "$tag" 'select(.Repository==$repository and .Tag==$tag).Digest'
	)

	token=$(
		curl --silent "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repository}:pull" |
			jq --raw-output '.token'
	)

	remote_digest=$(
		curl --silent --output /dev/null --head \
			--write-out '%header{docker-content-digest}' \
			--header "Authorization: Bearer $token" \
			--header 'Accept: application/vnd.docker.distribution.manifest.list.v2+json' \
			"https://registry-1.docker.io/v2/${repository}/manifests/${tag}"
	)

	if [[ $local_digest == "$remote_digest" ]]; then
		echo "Already on latest ${image}:${tag} image"
		return 0
	else
		echo "Newer ${image}:${tag} image available"
		return 1
	fi
}

if ! is_latest_docker_image 'library/ubuntu' 'latest'; then
	# Do something if there's a newer version of the image...
	run_other_task
fi
