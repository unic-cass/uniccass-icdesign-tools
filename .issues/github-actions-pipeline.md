# Add a GitHub Actions test and DockerHub pipeline

Status: proposed; not implemented

## Goal

Run tests for pushes to every branch and for pull requests. After tests pass on `main`, build the final image and push it to DockerHub.

## Proposed workflow

Create `.github/workflows/docker.yml` with these triggers and controls:

- `push` for all branches.
- `pull_request` targeting any branch.
- `workflow_dispatch` for manual recovery and validation.
- A concurrency group based on workflow and ref, cancelling an older in-progress run for the same non-main ref.
- Read-only repository permissions except where GitHub cache/attestation features explicitly require more.

Implement the following jobs:

1. `static-checks` runs `bash -n`, ShellCheck, Hadolint, `docker build --check`, and repository consistency checks.
2. `build-and-test` uses Docker Buildx, restores a GitHub Actions cache, builds `unic-cass-tools-nix` with a local CI tag, loads it into Docker, and runs the non-interactive integration suite against that exact tag. It runs after static checks on every push and pull request.
3. `publish` runs only when `github.ref == 'refs/heads/main'` and the earlier jobs succeed. It logs in with `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`, rebuilds from the tested commit using the shared cache, and pushes:
   - `isaiassh/unic-cass-tools:latest`
   - `isaiassh/unic-cass-tools:sha-<short-commit>`
   - The repository release tag, such as `1.1.0`, when intentionally configured for that release.

Before enabling the workflow, implement the cleanup and explicit-image changes described in `testing-practices.md` so CI tests cannot hang on `-it` or collide on a fixed container name.

## Secrets and protection

- Store a least-privilege DockerHub access token as `DOCKERHUB_TOKEN` and the account name as `DOCKERHUB_USERNAME` in GitHub Actions secrets.
- Configure DockerHub tags under the `isaiassh/unic-cass-tools` repository.
- Protect `main` by requiring `static-checks` and `build-and-test`; do not make `publish` a pull-request requirement because secrets are unavailable to untrusted forks.
- Never expose DockerHub credentials to pull-request jobs or pass them as Docker build arguments.

## Acceptance criteria

- Every branch push and pull request reports static and integration-test status.
- Failed tests prevent publishing.
- A successful `main` run pushes `latest` and a traceable commit tag to DockerHub.
- Re-running the same commit is safe and cache reuse is visible in the job summary.
- Forked pull requests run tests without access to DockerHub credentials.

## Non-goals

- This issue does not define automated releases, changelog generation, or multi-architecture images.
- Do not implement the workflow until CI-safe test cleanup is available.
