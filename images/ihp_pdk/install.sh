#!/bin/bash

set -ex
cd /tmp

IHP_PDK_REPO_BRANCH="${IHP_PDK_REPO_BRANCH:-main}"

git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

set +e
for i in {1..5}; do
    if git clone --branch "$IHP_PDK_REPO_BRANCH" --depth 1 --recurse-submodules "$IHP_PDK_REPO_URL" ihp; then
        break
    else
        if [ $i -lt 5 ]; then
            echo "Git clone failed, retrying in 15 seconds... (attempt $i/5)"
            sleep 15
            rm -rf ihp 2>/dev/null || true
        else
            echo "Git clone failed after 5 attempts"
            set -e
            exit 1
        fi
    fi
done
set -e

cd /tmp/ihp

# The branch controls the shallow clone source; the immutable commit controls
# the actual PDK revision installed in the image.
if ! git checkout --detach "$IHP_PDK_REPO_COMMIT"; then
    git fetch --depth 1 origin "$IHP_PDK_REPO_COMMIT"
    git checkout --detach FETCH_HEAD
fi

if [ "$(git rev-parse HEAD)" != "$IHP_PDK_REPO_COMMIT" ]; then
    echo "Checked out IHP PDK revision does not match $IHP_PDK_REPO_COMMIT" >&2
    exit 1
fi

git submodule update --init --recursive

rm -rf \
    ihp-sg13g2/libs.doc/meas \
    ihp-sg13g2/libs.tech/klayout/tech/lvs/testing \
    ihp-sg13g2/libs.tech/openems/testcase

find . -name "*.sch" -exec sed -i '/pre_osdi/d' {} \;

mkdir -p "$PDK_ROOT"
mv ihp-sg13g2 "$PDK_ROOT/$IHP_PDK_NAME"

# Compile Verilog-A models using openvaf (v0.3.0+ structure)
NGSPICE_DIR="$PDK_ROOT/$IHP_PDK_NAME/libs.tech/ngspice"
OSDI_DIR="$NGSPICE_DIR/osdi"
LEGACY_OSDI_DIR="$NGSPICE_DIR/openvaf"

cd "$PDK_ROOT/$IHP_PDK_NAME/libs.tech/verilog-a"
bash openvaf-compile-va.sh

required_osdi=(
    psp103.osdi
    psp103_nqs.osdi
    r3_cmc.osdi
    mosvar.osdi
    cap_cmomi.osdi
    cap_cmomf.osdi
)
for osdi_file in "${required_osdi[@]}"; do
    if [ ! -s "$OSDI_DIR/$osdi_file" ]; then
        echo "Missing or empty OSDI file: $OSDI_DIR/$osdi_file" >&2
        exit 1
    fi
done

# Older schematics and course materials reference ngspice/openvaf/*.osdi.
if [ -e "$LEGACY_OSDI_DIR" ] && [ ! -L "$LEGACY_OSDI_DIR" ]; then
    rm -rf "$LEGACY_OSDI_DIR"
fi
ln -sfn osdi "$LEGACY_OSDI_DIR"

if [ ! -s "$LEGACY_OSDI_DIR/psp103_nqs.osdi" ]; then
    echo "Legacy OSDI path does not resolve: $LEGACY_OSDI_DIR/psp103_nqs.osdi" >&2
    exit 1
fi

cd /tmp
rm -rf ihp
