#!/usr/bin/env bash
# KLayout DRC smoke test using the IHP SG13G2 upstream DRC runner.
# Run inside the container:
#   /home/designer/shared/tests/klayout-ihp-drc.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_design_env
require_command klayout
require_command python3

GDS="${SCRIPT_DIR}/artifacts/test_inv.gds"
TOPCELL="test_inv"
RUN_DIR="${SCRIPT_DIR}/run/klayout-ihp-drc"
VERSIONS_FILE="${PDK_ROOT}/versions.txt"
DRC_RUNNER="${PDK_ROOT}/ihp-sg13g2/libs.tech/klayout/tech/drc/run_drc.py"
REPORT="${RUN_DIR}/test_inv_${TOPCELL}_activ.lyrdb"

if [[ ! -f "${GDS}" ]]; then
	fail "GDS fixture not found: ${GDS}"
fi
if [[ ! -f "${VERSIONS_FILE}" ]]; then
	fail "IHP versions manifest not found: ${VERSIONS_FILE}"
fi
if ! grep -qE '^klayout[[:space:]]+' "${VERSIONS_FILE}"; then
	fail "KLayout version is missing from: ${VERSIONS_FILE}"
fi
if [[ ! -f "${DRC_RUNNER}" ]]; then
	fail "IHP DRC runner not found: ${DRC_RUNNER}"
fi

rm -rf "${RUN_DIR}"
mkdir -p "${RUN_DIR}"

echo ">>> Running IHP SG13G2 KLayout DRC..."
set +e
python3 "${DRC_RUNNER}" \
	--path="${GDS}" \
	--topcell="${TOPCELL}" \
	--table=activ \
	--no_density \
	--run_dir="${RUN_DIR}"
DRC_STATUS=$?
set -e

if [[ ! -s "${REPORT}" ]]; then
	fail "KLayout DRC report not generated: ${REPORT}"
fi

if [[ "${DRC_STATUS}" -eq 0 ]]; then
	pass "IHP KLayout DRC completed with no violations"
elif [[ "${DRC_STATUS}" -eq 1 ]]; then
	pass "IHP KLayout DRC completed and reported violations"
else
	fail "IHP KLayout DRC exited unexpectedly with status ${DRC_STATUS}"
fi

pass "KLayout DRC report exists at ${REPORT}"
echo
echo "INFO: Congratulations! all validations passed!"
echo
