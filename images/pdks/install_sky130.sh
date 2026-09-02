#!/bin/bash

set -ex

export PATH=`realpath $TOOLS/magic/*/bin`:$PATH
source /images/pdks/prepare_open_pdks.sh

prepare_open_pdks sky130
trap 'rm -rf "$OPEN_PDKS_SOURCE"' EXIT

# Ensure PDK_ROOT directory exists
mkdir -p "$PDK_ROOT"

# Use limited parallelism to reduce RAM usage
BUILD_JOBS=${MAX_BUILD_JOBS:-2}
echo "Building sky130 PDK with $BUILD_JOBS parallel jobs"
volare build \
    --pdk=sky130 \
    --use-repo-at "open_pdks=$OPEN_PDKS_SOURCE" \
    -j "${BUILD_JOBS}" \
    "$OPEN_PDKS_REPO_COMMIT"
volare enable --pdk=sky130 $OPEN_PDKS_REPO_COMMIT

rm -rf $PDK_ROOT/sky130B
rm -rf $PDK_ROOT/volare/sky130/versions/$OPEN_PDKS_REPO_COMMIT/sky130B

# Cleanup: Remove volare cache and build artifacts
rm -rf $PDK_ROOT/volare/sky130/versions/$OPEN_PDKS_REPO_COMMIT/.build
rm -rf $PDK_ROOT/volare/sky130/versions/$OPEN_PDKS_REPO_COMMIT/.source
