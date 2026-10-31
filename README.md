# sample-webpack

[![build](https://img.shields.io/github/actions/workflow/status/nalbam/sample-webpack/push.yaml?branch=main&label=build&style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/actions/workflows/push.yaml)
[![release](https://img.shields.io/github/v/release/nalbam/sample-webpack?style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/releases)

<!-- [![CircleCI](https://circleci.com/gh/nalbam/sample-webpack.svg?style=svg)](https://circleci.com/gh/nalbam/sample-webpack) -->

## Docker

```bash
docker pull ghcr.io/nalbam/sample-webpack
```

## Requirements

- Node.js 22.15 or later (CI uses Node.js 24)

## Build and run

```bash
# install exact versions from package-lock.json and build to dist/
npm ci
npm run build

# start the webpack dev server (http://localhost:8080)
npm start

# remove dist and node_modules
npm run clean
```

`./build.sh` runs `npm ci && npm run build`. To build and run the Docker image locally, run `npm run build` first because the image copies `dist/`.

```bash
docker build -t sample-webpack .
docker run -d -p 3000:80 sample-webpack
```

## CI

`.github/workflows/push.yaml` (check name `build`) runs on pull requests and pushes to `main`/`master`, and is reused by the release workflow. On Node.js 24 it runs `npm ci` and `npm run build` as separate steps, so a failure fails the job. It then builds the Docker image and checks that `/` contains `Hello, world!` and `/webpack.png` responds. It does not bump versions, publish, or dispatch. The project has no `npm test` script, so CI does not run one.

## Release

Branch pushes only run CI. To release, push a `v*` SemVer tag such as `v0.10.0` or `v0.10.0-rc.1`:

```bash
git tag v0.10.0
git push origin v0.10.0
```

Tags must match `vMAJOR.MINOR.PATCH` with an optional prerelease suffix. The workflow rejects leading zeros, `+build` metadata, and tags longer than 128 characters, so the Git tag and the image tag stay identical.

The [release workflow](.github/workflows/release.yml) runs these jobs in order. Each job runs only if the previous job succeeds.

1. `tag` validates the tag.
2. `verify` runs the CI above for the tag commit and uploads the checked `dist/` as the `dist-<commit SHA>` artifact of the run. A missing `dist/` fails the job.
3. `image` checks out the same commit, downloads that artifact to `dist/`, and builds the image from `.` (the `Dockerfile` copies `dist/` to the Nginx document root). It pushes `ghcr.io/nalbam/sample-webpack:<tag>` for `linux/amd64` and `linux/arm64`. Stable tags also update `latest`; prerelease tags push only their version tag.
4. `github-release` creates a GitHub Release with the commit subjects since the previous reachable version tag. It excludes merge commits and `chore: release` commits. The first release lists all commits. Tags with a prerelease suffix create GitHub prereleases. A re-run updates the existing release.

Release runs are serialized across tags and are not cancelled, because they share `latest`. The `dist/` artifact is internal; it is not attached to the release or published to npm.

Requirements:

- No repository secrets. The workflow uses `GITHUB_TOKEN`: `packages: write` only in `image` and `contents: write` only in `github-release`. Other jobs have `contents: read`.
- Actions must be allowed to write to the `ghcr.io/nalbam/sample-webpack` package. If the package exists and is not linked to this repository, grant this repository write access in the package settings.
- Anyone who can push a `v*` tag can start a release. To restrict this, add a tag ruleset for `v*`.

The release ends at the image and GitHub Release. It does not trigger GitOps deployment, because `opspresso/argocd-env-demo` has no chart or phase values for this project. A GitOps step needs that target chart, phase, and image address first.

Git tags are the release version source. The `VERSION` and `BUMP` files are not used by the release workflow. `.circleci/config.yml` keeps only its `build` and `publish` jobs.
