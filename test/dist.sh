#!/bin/sh
#
# Checks the webpack output in dist/. Run it after "npm run build":
#
#   npm test
#
# The Dockerfile build stage runs it.

set -eu

cd "$(dirname "$0")/.."
failures=0

fail() {
  echo "FAIL: $*"
  failures=$((failures + 1))
}

for file in index.html main.bundle.js main.bundle.css webpack.png favicon.ico; do
  if [ -s "dist/$file" ]; then
    echo "ok: dist/$file"
  else
    fail "dist/$file is missing or empty"
  fi
done

# HtmlWebpackPlugin injects the bundles with the build hash as the query string.
for ref in 'main.bundle.js?' 'main.bundle.css?' '<title>Hello, world!</title>'; do
  if grep -qF "$ref" dist/index.html; then
    echo "ok: index.html has $ref"
  else
    fail "index.html does not have $ref"
  fi
done

[ "$failures" -eq 0 ] || exit 1
echo "dist checks passed"
