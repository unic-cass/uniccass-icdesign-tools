# Reduce Docker build time

Status: proposed; not implemented

## Problem

The final image compiles many independent EDA projects and PDKs. A cold build is lengthy, while package downloads and compiler outputs are not consistently cached across builds or CI runners. There is no per-stage timing baseline to show where optimization work has the most impact.

## Proposed work

1. Capture cold and warm build timings, peak disk use, and image-layer sizes for every named Docker stage.
2. Prioritize the largest stages and add BuildKit cache mounts for package-manager, compiler, Nix, and safe source-download caches.
3. Separate dependency installation from frequently changing source builds so pin updates invalidate fewer layers.
4. Review which independent stages can be built concurrently with `docker buildx bake` while retaining `MAX_BUILD_JOBS` inside each compiler build.
5. Configure a portable registry or GitHub Actions cache and document local cache import/export commands.
6. Compare final image contents with the runtime requirements and remove duplicate toolchains or build-only artifacts without changing supported commands.

## Acceptance criteria

- A repeatable benchmark records cold and warm build time for the final image.
- Warm CI and local builds reuse caches without using unpinned build inputs.
- The optimized build produces the same tool revisions and passes the existing integration tests.
- Build-time and image-size changes are recorded in the pull request that implements this issue.

## Non-goals

- Do not trade immutable version pins for moving branches.
- Do not increase default compiler parallelism beyond memory-safe limits without measurements.
