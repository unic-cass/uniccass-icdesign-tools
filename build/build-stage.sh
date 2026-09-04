#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage: build/build-stage.sh <docker-stage>

Build one stage from the repository Dockerfile. The output defaults to
the image namespace, name, and release version declared in manifest.json.

Environment overrides:
  DOCKER_USER         Image namespace
  DOCKER_IMAGE        Image name
  DOCKER_TAG          Base image tag
  BUILD_IMAGE_TAG     Complete output image reference
  ENABLE_GUI          Override the manifest Docker build argument
  MAX_BUILD_JOBS      Override the manifest compilation parallelism
  NO_CACHE            Use --no-cache when set to a truthy value
  CHECK_ONLY          Run Dockerfile build checks without building
  BUILDKIT_PROGRESS   BuildKit progress mode (default: plain)

Any environment variable matching a manifest build argument overrides that
argument for the current build.
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

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required to read manifest.json but was not found in PATH." >&2
    exit 127
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "$script_dir/.." && pwd)"
manifest_path="$repository_root/manifest.json"
dockerfile_path="$repository_root/Dockerfile"

if [ ! -f "$manifest_path" ]; then
    echo "Build manifest not found: $manifest_path" >&2
    exit 2
fi

if ! jq -e '
    .schemaVersion == 1
    and (.release.version | type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
    and (.image.registry | type == "string")
    and (.image.namespace | type == "string" and length > 0)
    and (.image.name | type == "string" and length > 0)
    and (.build.target | type == "string" and length > 0)
    and (.build.arguments | type == "object")
    and ([.build.arguments[] | type == "string"] | all)
    and ([.build.arguments | keys[] | test("^[A-Z][A-Z0-9_]*$")] | all)
' "$manifest_path" >/dev/null; then
    echo "manifest.json is invalid or contains inconsistent release metadata." >&2
    exit 2
fi

mapfile -t dockerfile_arguments < <(
    awk '
        /^FROM[[:space:]]/ { exit }
        /^ARG[[:space:]]/ {
            name = $2
            sub(/=.*/, "", name)
            print name
        }
    ' "$dockerfile_path" | LC_ALL=C sort -u
)
mapfile -t manifest_arguments < <(
    jq -r '.build.arguments | keys[]' "$manifest_path" | LC_ALL=C sort -u
)
diff_output="$(
    LC_ALL=C comm -3 \
        <(printf '%s\n' "${dockerfile_arguments[@]}") \
        <(printf '%s\n' "${manifest_arguments[@]}")
)"
if [ -n "$diff_output" ]; then
    echo "Dockerfile global ARG declarations and manifest build arguments differ:" >&2
    printf '%s\n' "$diff_output" >&2
    exit 2
fi

manifest_registry="$(jq -r '.image.registry' "$manifest_path")"
docker_user="${DOCKER_USER:-$(jq -r '.image.namespace' "$manifest_path")}"
docker_image="${DOCKER_IMAGE:-$(jq -r '.image.name' "$manifest_path")}"
docker_tag="${DOCKER_TAG:-$(jq -r '.release.version' "$manifest_path")}"
progress_mode="${BUILDKIT_PROGRESS:-plain}"

if [ -z "$manifest_registry" ] || [ "$manifest_registry" = "docker.io" ]; then
    image_repository="${docker_user}/${docker_image}"
else
    image_repository="${manifest_registry}/${docker_user}/${docker_image}"
fi
output_image="${BUILD_IMAGE_TAG:-${image_repository}:${docker_tag}-${docker_stage}}"

build_command=(
    docker build
    --progress "$progress_mode"
    --tag "$output_image"
    --target "$docker_stage"
)

while IFS= read -r argument_name; do
    argument_value="$(jq -r --arg name "$argument_name" '.build.arguments[$name]' "$manifest_path")"
    if [[ -v "$argument_name" ]]; then
        environment_value="${!argument_name}"
        if [[ "$argument_name" == "ENABLE_GUI" || -n "$environment_value" ]]; then
            argument_value="$environment_value"
        fi
    fi
    if [[ "$argument_value" == *$'\n'* || "$argument_value" == *$'\t'* ]]; then
        echo "Build argument $argument_name cannot contain tabs or newlines." >&2
        exit 2
    fi
    build_command+=(--build-arg "${argument_name}=${argument_value}")
done < <(jq -r '.build.arguments | keys[]' "$manifest_path")

case "${NO_CACHE:-}" in
    ""|0|false|FALSE|no|NO)
        ;;
    *)
        build_command+=(--no-cache)
        ;;
esac

case "${CHECK_ONLY:-}" in
""|0|false|FALSE|no|NO)
    check_only=false
    ;;
*)
    check_only=true
    build_command+=(--check)
    ;;
esac

build_command+=(--file "$dockerfile_path" "$repository_root")

export DOCKER_BUILDKIT=1
if "$check_only"; then
    printf 'Checking Docker target %s with manifest.json\n' "$docker_stage"
else
    printf 'Building Docker target %s as %s\n' "$docker_stage" "$output_image"
fi
"${build_command[@]}"
if ! "$check_only"; then
    docker image inspect "$output_image" --format 'Built {{.RepoTags}} ({{.Size}} bytes)'
fi
