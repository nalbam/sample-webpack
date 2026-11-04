# sample-webpack

[![ci](https://img.shields.io/github/actions/workflow/status/nalbam/sample-webpack/ci.yml?branch=main&label=ci&style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/nalbam/sample-webpack?style=for-the-badge&logo=github)](https://github.com/nalbam/sample-webpack/releases)

A web page bundled with webpack and served by Nginx. It has no database or other dependencies.

## Run

```bash
docker run -d --name sample-webpack -p 8080:8080 ghcr.io/nalbam/sample-webpack
curl http://localhost:8080/health
docker rm -f sample-webpack
```

The image runs as the unprivileged `nginx` user (uid 101) and needs no Linux capabilities, so it works with `--cap-drop ALL`.

| Environment variable | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | Listen port. |
| `VERSION` | image tag | Version that `/health` reports. |

| Path | Response |
| --- | --- |
| `/health` | `{"result":"ok","version":"<VERSION>"}` |
| `/`, `/main.bundle.js`, `/main.bundle.css`, `/webpack.png`, `/favicon.ico` | The webpack output (`dist/`). |

## Develop

Prerequisites: Docker with Buildx, and `jq`.

```bash
docker buildx build --load -t sample-webpack:dev .   # builds dist/ and tests it in the build stage
scripts/smoke.sh sample-webpack:dev
```

Without Docker, use Node.js 26. `engines` allows Node.js 22.15 or later because `webpack-dev-server` 6 needs it.

```bash
npm ci
npm run build   # writes dist/
npm test        # checks dist/ (test/dist.sh)
npm start       # webpack dev server on http://localhost:8080
```

The page loads Bootstrap 5.3.8, jQuery 4.0.0 and Font Awesome Free 7.3.1 from public CDNs.

Known limitation: `index.html` loads `/counter.js` and `/dropper.js`, but this repository does not contain them.
They return 404 and the counters stay at 0.

## CI/CD

Pull requests and pushes to `main` run CI. A `v*` tag releases the image `ghcr.io/nalbam/sample-webpack:<tag>`
and a GitHub Release with the `dist/` archive. Jenkins can run the same pipeline with Nexus and Harbor or ECR.
See [docs/pipeline.md](docs/pipeline.md).
