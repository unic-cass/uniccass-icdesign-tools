# AGENTS.md

## Project overview

UNIC-CASS IC Design Tools builds an Ubuntu 22.04 Docker image containing an open-source integrated-circuit design environment. The final image combines analog and digital EDA tools, the Sky130A, GF180MCU, and IHP SG13G2 PDKs, LibreLane, and GUI/VNC support. Most tools are compiled in independent Docker stages and copied into the final `unic-cass-tools-nix` stage.

The root `Dockerfile` is the source of truth for upstream repository URLs and immutable revisions. Tool-specific installation logic lives under `images/<tool>/install.sh`. Runtime configuration is assembled from `images/final_structure/`, while `shared_xserver/` contains examples and files mounted into a running container.

## Prerequisites

- Docker with BuildKit support. Building the complete image requires substantial disk space, memory, and time.
- GNU Make and Bash for the repository wrappers.
- An X server for host-rendered GUI applications. Linux uses the host X11 socket, Windows uses VcXsrv, and macOS support is experimental.
- Network access to the pinned upstream repositories, package archives, and Nix caches.

Run commands from the repository root unless a command explicitly states otherwise.

## Build commands

Build the complete image with the repository defaults:

```bash
./build/build-image.sh
```

Build an individual Docker stage for focused development or cache warming:

```bash
./build/build-stage.sh magic
./build/build-stage.sh ihp_pdk
```

The stage builder tags its output as `isaiassh/unic-cass-tools:1.1.0-<stage>`. The full build produces `isaiassh/unic-cass-tools:1.1.0`. Supported overrides include:

```bash
DOCKER_USER=myuser DOCKER_TAG=dev MAX_BUILD_JOBS=4 ./build/build-image.sh
NO_CACHE=1 ./build/build-stage.sh xschem
ENABLE_GUI=1 ./build/build-image.sh
```

Create a local configuration before using the Make targets:

```bash
cp .env.example .env
```

The example lists all supported user-facing settings. Make targets load `.env` automatically. Before calling a build script directly, export the file with `set -a; source .env; set +a`. Keep tool and PDK source revisions in the Dockerfile rather than adding them to `.env`.

Equivalent Make targets are available:

```bash
make build
make STAGE=magic build
make NO_CACHE=Y MAX_BUILD_JOBS=4 build
```

Useful runtime targets include `make start`, `make start-vnc`, `make attach`, `make start-raw`, `make start-notebook`, `make pull`, and `make push`. Run `make print` to inspect the resolved image, ports, mounts, and container name. Local values belong in `.env`; this file is intentionally ignored while `.env.example` is committed.

## Test and validation commands

Integration tests live under `shared_xserver/tests/` so they are available at `/home/designer/shared/tests` when that directory is mounted into a running container. They write ignored output under `shared_xserver/tests/run/`.

Run them inside the container:

```bash
/home/designer/shared/tests/layout-extraction.sh
/home/designer/shared/tests/run-all.sh
```

`run-all.sh` executes every test and exits 0 if all pass, or 1 if any fail.

Use these lightweight checks before starting a long image build:

```bash
bash -n build/*.sh images/*/install.sh images/final_structure/{configure,install}/*.sh shared_xserver/tests/*.sh
docker build --check .
git diff --check
```

## Repository conventions

- Keep tool versions and upstream URLs in the top-level Dockerfile `ARG` declarations. Prefer immutable commit SHAs; use a release tag only when the requested upstream version is itself a tag.
- When changing a pin, update its adjacent date/version comment and verify the installer actually checks out that argument. Preserve recursive submodule initialization where the upstream project needs it.
- Keep each tool build isolated in `images/<tool>/install.sh`. Install compiled output beneath `/opt/<tool>/<revision>` and copy only required runtime artifacts into the final stage.
- Respect `MAX_BUILD_JOBS`; do not replace bounded compilation with unconditional `nproc` in memory-intensive stages.
- Write Bash with LF endings, a Bash shebang, strict failure behavior for new scripts, quoted expansions, and arrays for constructed commands. Check scripts with `bash -n`.
- Keep Docker build contexts reproducible. Use BuildKit bind mounts for repository scripts and remove downloaded sources or temporary build products in the same stage that creates them.
- Do not commit `.env`, logs, notebook checkpoints, simulation output, `shared_xserver/tests/run/`, `_build_logs`, or `.issues/drafts/`.
- Treat `shared_xserver/verification/` as examples and exploratory verification unless a file is explicitly wired into `shared_xserver/tests/`.
- Update documentation when commands, image names, tags, supported PDKs, or runtime requirements change.

## Change expectations

Keep changes scoped and avoid opportunistic upgrades of unrelated tools. For Docker or installer changes, report which stages were statically checked or built; do not claim a full-image validation when only syntax or target checks ran. A complete build is expensive, so targeted stages are acceptable during development, but release changes should eventually validate the final image and the layout-extraction test.
