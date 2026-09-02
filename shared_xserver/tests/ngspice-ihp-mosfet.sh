#!/usr/bin/env bash
# Smoke test ngspice with an IHP SG13G2 LV MOSFET operating point.
# Run inside the container:
#   /home/designer/shared/tests/ngspice-ihp-mosfet.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_design_env
require_command ngspice

NETLIST="${SCRIPT_DIR}/artifacts/ihp_nmos_op.spice"
RUN_DIR="${SCRIPT_DIR}/run/ngspice-ihp-mosfet"
LOG_FILE="${RUN_DIR}/ngspice.log"
OSDI="${PDK_ROOT}/ihp-sg13g2/libs.tech/ngspice/osdi/psp103_nqs.osdi"

if [[ ! -f "${NETLIST}" ]]; then
	fail "netlist not found: ${NETLIST}"
fi
if [[ ! -s "${OSDI}" ]]; then
	fail "IHP OSDI model not found: ${OSDI}"
fi

rm -rf "${RUN_DIR}"
mkdir -p "${RUN_DIR}"

echo ">>> Smoke test ngspice con MOSFET IHP"
if ! ngspice -b "${NETLIST}" >"${LOG_FILE}" 2>&1; then
	cat "${LOG_FILE}" >&2
	fail "ngspice exited with a non-zero status"
fi

if grep -Eqi 'couldn.?t be loaded|No such file or directory|Error on line' "${LOG_FILE}"; then
	cat "${LOG_FILE}" >&2
	fail "ngspice reported a model or netlist error"
fi

ID_LINE="$(grep -E '^[[:space:]]*id[[:space:]]+=' "${LOG_FILE}" | tail -n 1 || true)"
if [[ -z "${ID_LINE}" ]]; then
	ID_LINE="$(grep 'SMOKE_ID=' "${LOG_FILE}" | tail -n 1 || true)"
fi
if [[ -z "${ID_LINE}" ]]; then
	cat "${LOG_FILE}" >&2
	fail "drain current was not printed by ngspice"
fi

ID_VALUE="$(printf '%s\n' "${ID_LINE}" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?' | tail -n 1)"
if [[ -z "${ID_VALUE}" ]]; then
	cat "${LOG_FILE}" >&2
	fail "could not parse drain current from: ${ID_LINE}"
fi

python3 - "${ID_VALUE}" <<'PY' || fail "IHP MOSFET drain current is out of the expected range"
import sys
value = float(sys.argv[1])
# Expected around 1.15e-6 A for W=1u L=0.13u Vgs=0.4 V Vds=1.0 V.
if not (1e-7 <= value <= 1e-5):
    raise SystemExit(1)
PY

pass "ngspice MOSFET IHP id = ${ID_VALUE} A"
echo
echo "INFO: Congratulations! all validations passed!"
echo
exit 0
