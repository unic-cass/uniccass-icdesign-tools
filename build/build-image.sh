#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "$script_dir/.." && pwd)"
manifest_path="$repository_root/manifest.json"

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required to read manifest.json but was not found in PATH." >&2
    exit 127
fi

manifest_registry="$(jq -er '.image.registry' "$manifest_path")"
docker_user="${DOCKER_USER:-$(jq -er '.image.namespace' "$manifest_path")}"
docker_image="${DOCKER_IMAGE:-$(jq -er '.image.name' "$manifest_path")}"
docker_tag="${DOCKER_TAG:-$(jq -er '.release.version' "$manifest_path")}"
docker_target="$(jq -er '.build.target' "$manifest_path")"

if [ -z "$manifest_registry" ] || [ "$manifest_registry" = "docker.io" ]; then
    image_repository="${docker_user}/${docker_image}"
else
    image_repository="${manifest_registry}/${docker_user}/${docker_image}"
fi

export BUILD_IMAGE_TAG="${BUILD_IMAGE_TAG:-${image_repository}:${docker_tag}}"
exec "$script_dir/build-stage.sh" "$docker_target"
