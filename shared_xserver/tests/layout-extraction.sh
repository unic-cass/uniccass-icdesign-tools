#!/usr/bin/env bash
# Magic parasitic extraction of the IHP inverter GDS fixture.
# Run inside the container:
#   /home/designer/shared/tests/layout-extraction.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_design_env
require_command magic

GDS="${SCRIPT_DIR}/artifacts/test_inv.gds"
CELL="test_inv"
OUTPUT_FILE="test_inv.spice"
RUN_DIR="${SCRIPT_DIR}/run/layout-extraction"
MAGIC_RCFILE="${PDK_ROOT}/ihp-sg13g2/libs.tech/magic/ihp-sg13g2.magicrc"
CMD_FILE="${RUN_DIR}/extract.tcl"
OUTPUT_FILE_PATH="${RUN_DIR}/${OUTPUT_FILE}"

if [[ ! -f "${GDS}" ]]; then
	fail "GDS fixture not found: ${GDS}"
fi
if [[ ! -f "${MAGIC_RCFILE}" ]]; then
	fail "Magic RC file not found: ${MAGIC_RCFILE}"
fi

rm -rf "${RUN_DIR}"
mkdir -p "${RUN_DIR}"

cat <<EOF >"${CMD_FILE}"
gds flatglob *pmos*
gds flatglob *nmos*
gds read ${GDS}
load ${CELL}
select top cell
extract path extfiles
extract do resistance
extract all
ext2sim labels on
ext2sim -p extfiles
extresist threshold 0
extresist minresist 0
extresist mindelay 0
extresist simplify off
extresist all
ext2spice lvs
ext2spice cthresh 0
ext2spice rthresh 0
ext2spice extresist on
ext2spice -p extfiles -o ${OUTPUT_FILE}
quit -noprompt
EOF

echo ">>> Extracting layout using magic..."
(
	cd "${RUN_DIR}"
	magic -dnull -noconsole -rcfile "${MAGIC_RCFILE}" <"${CMD_FILE}"
)

echo ">>> Checking generated spice file"

if [[ -f "${OUTPUT_FILE_PATH}" ]]; then
	pass "file exists at ${OUTPUT_FILE_PATH}"
else
	fail "file not found: ${OUTPUT_FILE_PATH}"
fi

NCAP="$(grep -cE '^C' "${OUTPUT_FILE_PATH}" || true)"
NRES="$(grep -cE '^R' "${OUTPUT_FILE_PATH}" || true)"

if [[ "${NCAP}" -gt 0 ]]; then
	pass "extracted netlist has ${NCAP} parasitic capacitances"
else
	fail "parasitic capacitances were not extracted"
fi

if [[ "${NRES}" -gt 0 ]]; then
	pass "extracted netlist has ${NRES} parasitic resistances"
else
	fail "parasitic resistors were not extracted"
fi

echo
echo "INFO: Congratulations! all validations passed!"
echo
exit 0
