#!/usr/bin/env bash
# Shared helpers for in-container tests. Source this file from each test script.

pass() {
	printf 'INFO: %s\t [PASS]\n' "$1"
}

fail() {
	printf 'ERROR: %s\t [FAIL]\n' "$1" >&2
	exit 1
}

load_design_env() {
	export USER="${USER:-designer}"
	export HOME="${HOME:-/home/designer}"
	export PDK_ROOT="${PDK_ROOT:-/opt/pdks}"
	export PDK="${PDK:-ihp-sg13g2}"
	export TOOLS="${TOOLS:-/opt}"

	if [[ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
		# shellcheck disable=SC1091
		source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
	fi

	# The image .bashrc appends EDA tool PATHs and calls set_pdk. It is not
	# guarded for non-interactive shells, so it can be sourced from tests.
	if [[ -f "${HOME}/.bashrc" ]]; then
		set +eu
		# shellcheck disable=SC1091
		source "${HOME}/.bashrc"
		set -eu
	fi

	export PDKPATH="${PDK_ROOT}/${PDK}"

	local tool_bin
	for tool_bin in "${TOOLS}/magic/"*/bin "${TOOLS}/ngspice/"*/bin; do
		if [[ -d "${tool_bin}" ]]; then
			export PATH="${tool_bin}:${PATH}"
		fi
	done
}

require_command() {
	if ! command -v "$1" >/dev/null 2>&1; then
		fail "required command not found: $1"
	fi
}
