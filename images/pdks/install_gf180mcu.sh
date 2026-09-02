#!/bin/bash

set -ex

export PATH=`realpath $TOOLS/magic/*/bin`:$PATH
source /images/pdks/prepare_open_pdks.sh

prepare_open_pdks gf180mcu
trap 'rm -rf "$OPEN_PDKS_SOURCE"' EXIT

# Use limited parallelism to reduce RAM usage
BUILD_JOBS=${MAX_BUILD_JOBS:-2}
echo "Building gf180mcu PDK with $BUILD_JOBS parallel jobs"
volare build \
    --pdk=gf180mcu \
    --use-repo-at "open_pdks=$OPEN_PDKS_SOURCE" \
    -j "${BUILD_JOBS}" \
    "$OPEN_PDKS_REPO_COMMIT"
volare enable --pdk=gf180mcu $OPEN_PDKS_REPO_COMMIT

rm -rf $PDK_ROOT/gf180mcuA
rm -rf $PDK_ROOT/gf180mcuB
rm -rf $PDK_ROOT/gf180mcuC
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/gf180mcuA
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/gf180mcuB
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/gf180mcuC

# Filter testing or unused DRC/LVS folders
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/gf180mcuD/libs.tech/klayout/drc/testing
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/gf180mcuD/libs.tech/klayout/lvs/testing
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/gf180mcuD/libs.tech/klayout/tech/drc
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/gf180mcuD/libs.tech/klayout/tech/lvs

# Cleanup: Remove volare cache and build artifacts
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/.build
rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_REPO_COMMIT/.source
