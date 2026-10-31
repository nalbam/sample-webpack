#!/bin/bash
# Regression test: ./build.sh must stop and exit non-zero when npm ci or
# npm run build fails, and exit 0 only after both succeed.
# A fake npm on PATH records each call and fails the step named in FAKE_NPM_FAIL.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

mkdir -p "${WORK}/bin" "${WORK}/app"
cat > "${WORK}/bin/npm" <<'NPM'
#!/bin/bash
echo "$*" >> "${FAKE_NPM_LOG}"
case "$*" in
  ci) [ "${FAKE_NPM_FAIL}" != "ci" ] ;;
  "run build") [ "${FAKE_NPM_FAIL}" != "build" ] ;;
  *) exit 99 ;;
esac
NPM
chmod +x "${WORK}/bin/npm"
cp "${ROOT}/build.sh" "${WORK}/app/build.sh"
echo '{}' > "${WORK}/app/package.json"

FAILED=0

# check <case> <fail step> <expected exit> <expected npm calls>
check() {
  local log="${WORK}/$1.log" code calls
  : > "${log}"
  (
    cd "${WORK}/app" &&
      env -u CIRCLE_PROJECT_USERNAME -u GITLAB_USER_ID \
        PATH="${WORK}/bin:${PATH}" FAKE_NPM_LOG="${log}" FAKE_NPM_FAIL="$2" \
        bash ./build.sh > "${WORK}/$1.out" 2>&1
  )
  code=$?
  calls="$(paste -sd, "${log}")"
  if [ "${code}" == "$3" ] && [ "${calls}" == "$4" ]; then
    echo "ok   $1: exit=${code} npm=[${calls}]"
  else
    echo "FAIL $1: exit=${code} (want $3) npm=[${calls}] (want [$4])"
    cat "${WORK}/$1.out"
    FAILED=1
  fi
}

check install-failure ci 1 "ci"
check build-failure build 1 "ci,run build"
check success none 0 "ci,run build"

exit ${FAILED}
