# sample-webpack

[![build](https://img.shields.io/github/actions/workflow/status/nalbam/sample-webpack/push.yaml?branch=main&label=build&style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/actions/workflows/push.yaml)
[![release](https://img.shields.io/github/v/release/nalbam/sample-webpack?style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/releases)

<!-- [![CircleCI](https://circleci.com/gh/nalbam/sample-webpack.svg?style=svg)](https://circleci.com/gh/nalbam/sample-webpack) -->

## Docker

```bash
docker pull ghcr.io/nalbam/sample-webpack
```

## Requirements

- Node.js 26 (CI uses the latest Node.js 26 release; verified with 26.13.0).
- `engines` allows Node.js 22.15 or later, because `webpack-dev-server` 6 needs 22.15. CI does not test Node.js 22. If a build fails on Node.js 22, use Node.js 26.

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

`./build.sh` runs `npm ci` and then `npm run build`. If `npm ci` fails, it stops before the build. If either step fails, it prints `- npm ci failed` or `- npm run build failed` and exits with status 1, so a calling script or CI job also fails. It exits with status 0 only after both steps succeed.

`npm test` checks this behavior with a fake `npm` (`test/build-sh.test.sh`). It does not test the web page.

To build and run the Docker image locally, run `npm run build` first because the image copies `dist/`.

```bash
docker build --pull -t sample-webpack .
docker run --rm sample-webpack nginx -v   # prints the nginx patch version
docker run -d -p 3000:80 sample-webpack
```

Then open `http://localhost:3000/`. The page loads Bootstrap 5.3.8, jQuery 4.0.0, and Font Awesome Free 7.3.1 from public CDNs. The webpack logo and the thumbs-up and thumbs-down buttons must show.

Known limitation: `index.html` loads `/counter.js` and `/dropper.js`, but this repository does not contain them. They return 404 and the counters stay at 0.

## CI

`.github/workflows/push.yaml` (check name `build`) runs on pull requests and pushes to `main`/`master`, and is reused by the release workflow. On Node.js 26 it runs these steps. A failed step fails the job.

1. `npm test` checks the failure handling of `./build.sh`.
2. `npm ci` and `npm run build` run as separate steps. The job checks that `dist/` has `index.html`, `main.bundle.js`, `main.bundle.css`, `webpack.png`, and `favicon.ico`.
3. `docker build --pull` builds the image and `nginx -v` prints the nginx version. The job starts the image and checks that `/` contains `Hello, world!` and that the bundle, `webpack.png`, and `favicon.ico` respond.
4. Buildx builds the image for `linux/amd64` and `linux/arm64` without pushing.

CI does not bump versions, publish, or dispatch.

`.gitlab-ci.yml` and `.circleci/config.yml` are optional builders. Both run `npm ci` and `npm run build` first. GitLab then builds `Dockerfile` from that `dist/` and pushes to its own project registry. CircleCI keeps its `build` and `publish` jobs, and `publish` runs `target/builder.sh` from the shared workspace.

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

To check a release:

1. In **Actions**, open the `release` run for the tag. Check that the run commit is the tag commit (`git rev-parse v0.10.0^{commit}`) and that all four jobs passed.
2. In the run summary, under **Artifacts**, check that `dist-<commit SHA>` uses the same SHA. You can download it with `gh run download <run-id> -n dist-<commit SHA>`.
3. Check the image manifest has both platforms:

   ```bash
   docker buildx imagetools inspect ghcr.io/nalbam/sample-webpack:v0.10.0
   ```

   The output must list `linux/amd64` and `linux/arm64`. For a stable tag, `:latest` must show the same digest.
4. Check the GitHub Release: `gh release view v0.10.0`. A prerelease tag must show as a prerelease.

If a job fails, the later jobs do not run. Fix the cause and re-run the failed jobs of the same run. A re-run uses the same commit and updates the existing release.

The release ends at the image and GitHub Release. It does not trigger GitOps deployment, because `opspresso/argocd-env-demo` has no chart or phase values for this project. A GitOps step needs that target chart, phase, and image address first.

Git tags are the release version source. The `VERSION` and `BUMP` files are not used by the release workflow. `.circleci/config.yml` keeps only its `build` and `publish` jobs.
