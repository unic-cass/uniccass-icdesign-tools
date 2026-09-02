#!/usr/bin/env bash

# Fetch Open PDKs by immutable commit instead of relying on its default branch.
# Volare 0.18.1 assumes that the upstream branch is named "master", but the
# repository now uses "main".
prepare_open_pdks() {
    local pdk_family="$1"

    case "$pdk_family" in
        sky130|gf180mcu)
            ;;
        *)
            echo "Unsupported PDK family: $pdk_family" >&2
            return 2
            ;;
    esac

    OPEN_PDKS_SOURCE="/tmp/volare-open-pdks-${pdk_family}"
    rm -rf "$OPEN_PDKS_SOURCE"

    git init "$OPEN_PDKS_SOURCE"
    git -C "$OPEN_PDKS_SOURCE" remote add origin "$OPEN_PDKS_REPO_URL"
    # Volare checks the pinned commit's ancestry before building, so retain
    # commit history while Git's blob filter avoids downloading unused files.
    git -C "$OPEN_PDKS_SOURCE" fetch --filter=blob:none origin "$OPEN_PDKS_REPO_COMMIT"
    git -C "$OPEN_PDKS_SOURCE" checkout --detach FETCH_HEAD

    if [ "$(git -C "$OPEN_PDKS_SOURCE" rev-parse HEAD)" != "$OPEN_PDKS_REPO_COMMIT" ]; then
        echo "Open PDKs checkout does not match $OPEN_PDKS_REPO_COMMIT" >&2
        return 1
    fi

    export OPEN_PDKS_SOURCE
}
