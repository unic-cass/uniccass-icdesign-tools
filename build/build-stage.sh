#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage: build/build-stage.sh <docker-stage>

Build one stage from the repository Dockerfile. The output defaults to
isaiassh/unic-cass-tools:1.1.0-<docker-stage>.

Environment overrides:
  DOCKER_USER         Image namespace (default: isaiassh)
  DOCKER_IMAGE        Image name (default: unic-cass-tools)
  DOCKER_TAG          Base image tag (default: 1.1.0)
  BUILD_IMAGE_TAG     Complete output image reference
  ENABLE_GUI          Value for the Docker build argument
  MAX_BUILD_JOBS      Compilation parallelism (default: 2)
  NO_CACHE            Use --no-cache when set to a truthy value
  BUILDKIT_PROGRESS   BuildKit progress mode (default: plain)
EOF
}

if [ "$#" -ne 1 ]; then
    usage >&2
    exit 2
fi

docker_stage="$1"
if [[ ! "$docker_stage" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]]; then
    echo "Invalid Docker stage: $docker_stage" >&2
    exit 2
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required but was not found in PATH." >&2
    exit 127
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "$script_dir/.." && pwd)"

docker_user="${DOCKER_USER:-isaiassh}"
docker_image="${DOCKER_IMAGE:-unic-cass-tools}"
docker_tag="${DOCKER_TAG:-1.1.0}"
enable_gui="${ENABLE_GUI:-}"
max_build_jobs="${MAX_BUILD_JOBS:-2}"
progress_mode="${BUILDKIT_PROGRESS:-plain}"
output_image="${BUILD_IMAGE_TAG:-${docker_user}/${docker_image}:${docker_tag}-${docker_stage}}"

build_command=(
    docker build
    --progress "$progress_mode"
    --tag "$output_image"
    --target "$docker_stage"
    --build-arg "ENABLE_GUI=$enable_gui"
    --build-arg "MAX_BUILD_JOBS=$max_build_jobs"
)

case "${NO_CACHE:-}" in
    ""|0|false|FALSE|no|NO)
        ;;
    *)
        build_command+=(--no-cache)
        ;;
esac

build_command+=(--file "$repository_root/Dockerfile" "$repository_root")

export DOCKER_BUILDKIT=1
printf 'Building Docker target %s as %s\n' "$docker_stage" "$output_image"
"${build_command[@]}"
docker image inspect "$output_image" --format 'Built {{.RepoTags}} ({{.Size}} bytes)'
