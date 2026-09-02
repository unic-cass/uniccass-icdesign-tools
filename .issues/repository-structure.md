# Clarify repository structure

Status: proposed; not implemented

## Problem

The root Dockerfile, Makefile, installer scripts, runtime configuration, examples, and legacy build-log tooling overlap in responsibility. Version metadata and image defaults are repeated, and it is not always clear which verification files are automated tests versus interactive examples.

## Proposed work

1. Define stable top-level areas for Docker build definitions, runtime configuration, automated tests, and user examples.
2. Split the Dockerfile into logical inputs only if the chosen BuildKit frontend preserves readable stages and cache behavior; otherwise generate or validate it from a single manifest.
3. Consolidate tool URL, revision, and version metadata into one machine-readable source that can drive Docker arguments, version checks, and documentation.
4. Extract shared installer helpers for clone retries, immutable checkout verification, bounded parallel builds, and cleanup.
5. Replace or retire `handled_build.sh` after its useful stage logging behavior is available through maintained build tooling.
6. Add a short ownership/readme file to complex directories and clearly label exploratory material under `shared_xserver/verification/`.

## Acceptance criteria

- Each version, image default, and common build behavior has one authoritative definition.
- A contributor can locate build, runtime, test, and example files from the root documentation.
- Structural moves preserve existing Make and Docker entry points or provide documented compatibility wrappers.
- A full build and integration suite show no behavior regression after the reorganization.

## Non-goals

- Do not reorganize files solely for naming consistency without reducing duplication or ambiguity.
- Do not combine unrelated upstream tool builds into a single opaque installer.
