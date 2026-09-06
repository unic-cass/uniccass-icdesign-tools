#!/usr/bin/env bash
# Run every in-container integration test and exit 0 on full success, 1 otherwise.
# Intended for local use and CI pipelines:
#   /home/designer/shared/tests/run-all.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tests=(
	layout-extraction.sh
	klayout-ihp-drc.sh
	ngspice-ihp-mosfet.sh
	librelane-smoke.sh
)

passed=0
failed=0

for test_name in "${tests[@]}"; do
	test_path="${SCRIPT_DIR}/${test_name}"
	echo "========== Running ${test_name} =========="
	if [[ ! -f "${test_path}" ]]; then
		echo "ERROR: test script not found: ${test_path}" >&2
		failed=$((failed + 1))
		echo "========== ${test_name}: FAIL =========="
		echo
		continue
	fi
	if bash "${test_path}"; then
		passed=$((passed + 1))
		echo "========== ${test_name}: PASS =========="
	else
		failed=$((failed + 1))
		echo "========== ${test_name}: FAIL ==========" >&2
	fi
	echo
done

echo "Summary: ${passed} passed, ${failed} failed"
if [[ "${failed}" -eq 0 ]]; then
	exit 0
fi
exit 1
