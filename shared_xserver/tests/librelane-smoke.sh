#!/usr/bin/env bash
# LibreLane smoke test using the image PDKs (no Ciel download).
# Run inside the container:
#   /home/designer/shared/tests/librelane-smoke.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_design_env
require_command librelane

RUN_DIR="${SCRIPT_DIR}/run/librelane-smoke"
LOG_FILE="${RUN_DIR}/librelane.log"

rm -rf "${RUN_DIR}"
mkdir -p "${RUN_DIR}"

echo ">>> librelane --manual-pdk --smoke-test"
cd "${RUN_DIR}"
if ! librelane --manual-pdk --smoke-test >"${LOG_FILE}" 2>&1; then
	cat "${LOG_FILE}" >&2
	fail "librelane --manual-pdk --smoke-test failed"
fi

pass "librelane --manual-pdk --smoke-test completed"
echo
echo "INFO: Congratulations! all validations passed!"
echo
exit 0
