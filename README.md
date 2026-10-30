# sample-webpack

[![build](https://img.shields.io/github/workflow/status/nalbam/sample-webpack/build?label=build&style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/actions/workflows/push.yaml)
[![release](https://img.shields.io/github/v/release/nalbam/sample-webpack?style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/releases)

<!-- [![CircleCI](https://circleci.com/gh/nalbam/sample-webpack.svg?style=svg)](https://circleci.com/gh/nalbam/sample-webpack) -->

[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/nalbam/sample-webpack?label=Docker%20Hub&style=for-the-badge&logo=docker)](https://hub.docker.com/r/nalbam/sample-webpack)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/nalbam/sample-webpack?style=for-the-badge&logo=docker)](https://hub.docker.com/r/nalbam/sample-webpack)
[![Docker Pulls](https://img.shields.io/docker/pulls/nalbam/sample-webpack?style=for-the-badge&logo=docker)](https://hub.docker.com/r/nalbam/sample-webpack)

<!-- [![DockerHub Badge](http://dockeri.co/image/nalbam/sample-webpack)](https://hub.docker.com/r/nalbam/sample-webpack/) -->

## Docker

```bash
docker pull nalbam/sample-webpack
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

`.github/workflows/push.yaml` runs the build and a Docker image build with a start check on pull requests and on pushes to `main`/`master`. Version bump, release, GitOps dispatch and image push run only on pushes.
