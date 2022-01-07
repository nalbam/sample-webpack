# Dockerfile

FROM nginx:1.13-alpine

LABEL maintainer="me@nalbam.com" \
      org.opencontainers.image.description="A Sample Docker image for Webpack App" \
      org.opencontainers.image.authors="Jungyoul Yu, me@nalbam.com, https://www.nalbam.com/" \
      org.opencontainers.image.source="https://github.com/nalbam/sample-webpack" \
      org.opencontainers.image.title="sample-webpack"

# RUN apk add --no-cache bash curl

EXPOSE 80

COPY dist /usr/share/nginx/html
