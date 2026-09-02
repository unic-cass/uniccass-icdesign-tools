# Improve testing practices

Status: proposed; not implemented

## Problem

Testing is currently centered on one Docker-dependent Magic extraction script. The script has a fixed container name, creates files in the repository, does not guarantee cleanup on failure, and defaults to an image tag that can drift from the Makefile. Installer scripts and Docker stages have no consistent smoke-test contract.

## Proposed work

1. Establish test tiers: static Bash/Dockerfile checks, per-tool version smoke tests, PDK checks, and end-to-end layout/simulation flows.
2. Add ShellCheck and Hadolint with a reviewed baseline, then run `bash -n` over every maintained shell script.
3. Refactor container tests to use unique names, non-interactive `docker exec`, temporary output directories, and an `EXIT` trap that always removes containers.
4. Pass one explicit image reference to every Docker-dependent test instead of duplicating user/image/tag defaults.
5. Add small smoke commands for the major tools and assert that reported versions or source metadata match Dockerfile pins.
6. Add representative tests for Sky130A, GF180MCU, and IHP SG13G2, separating fast pull-request checks from scheduled exhaustive verification.

## Acceptance criteria

- Tests are deterministic, non-interactive, and leave no container or generated repository files after success or failure.
- One documented command runs the required pull-request suite against a specified image.
- Failures identify the tool, PDK, and command that failed.
- Full-image release validation covers tool availability and at least one end-to-end flow.

## Non-goals

- Do not convert exploratory notebooks into CI tests without first defining deterministic expected results.
- Do not require every long-running PDK flow on every commit.
