# syntax=docker/dockerfile:1

# build: bundles the site with webpack, then tests the bundle, on the build platform.
FROM --platform=$BUILDPLATFORM node:26-alpine AS build
WORKDIR /src
COPY package.json package-lock.json ./
RUN npm ci
COPY webpack.config.js ./
COPY src src
COPY test test
RUN npm run build && npm test && cp -R dist /out

# artifact: the release artifact, exported by scripts/release.sh artifact.
FROM scratch AS artifact
COPY --from=build /out /

FROM nginx:1.31-alpine

LABEL org.opencontainers.image.title="sample-webpack" \
      org.opencontainers.image.description="A sample webpack site on Nginx" \
      org.opencontainers.image.source="https://github.com/nalbam/sample-webpack"

ARG VERSION=v0.0.0-dev

# The image entrypoint renders /etc/nginx/templates/*.template into
# /etc/nginx/conf.d and substitutes only PORT and VERSION.
ENV PORT=8080 \
    VERSION=${VERSION} \
    NGINX_ENVSUBST_FILTER="^(PORT|VERSION)$"

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/templates /etc/nginx/templates

# The unprivileged nginx user (uid 101) writes the rendered config.
RUN rm -f /etc/nginx/conf.d/default.conf \
 && chown -R 101:101 /etc/nginx/conf.d

COPY --from=artifact / /usr/share/nginx/html/

USER 101

EXPOSE 8080
