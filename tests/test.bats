#!/usr/bin/env bats

# Run locally from the add-on root with bats-core, bats-assert, bats-file and
# bats-support installed:
#   bats ./tests/test.bats
# Exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'

setup() {
  set -eu -o pipefail

  export GITHUB_REPO=yanniboi/ddev-glab

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH:-}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats:/usr/local/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site --omit-containers db,ddev-ssh-agent
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  run ddev glab --version
  assert_success
  assert_output --partial "glab"

  # Config dir is wired to the persisted project directory.
  run ddev exec 'echo $GLAB_CONFIG_DIR'
  assert_success
  assert_output "/var/www/html/.ddev/glab"

  # Settings written in the container persist on the host.
  run ddev glab config set -g editor vim
  assert_success
  assert_file_exists "${TESTDIR}/.ddev/glab/config.yml"
  run ddev glab config get -g editor
  assert_success
  assert_output "vim"

  # Arguments with spaces survive the command wrapper.
  run ddev glab config set -g browser "my browser"
  assert_success
  run ddev glab config get -g browser
  assert_output "my browser"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
