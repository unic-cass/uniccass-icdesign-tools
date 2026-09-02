#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

docker_user="${DOCKER_USER:-isaiassh}"
docker_image="${DOCKER_IMAGE:-unic-cass-tools}"
docker_tag="${DOCKER_TAG:-1.1.0}"

export BUILD_IMAGE_TAG="${BUILD_IMAGE_TAG:-${docker_user}/${docker_image}:${docker_tag}}"
exec "$script_dir/build-stage.sh" unic-cass-tools-nix
