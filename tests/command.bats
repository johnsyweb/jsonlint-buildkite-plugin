#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

#
# To debug stubs...
#
#     docker-compose run -eDEBUG_STUBS=1 --rm tests
#
if [[ ! -z "${DEBUG_STUBS}" ]]
then
   export DOCKER_STUB_DEBUG=/dev/tty
fi


@test "Checks *.*json files by default" {
  run "$PWD/hooks/command"

  assert_output --partial "checking JSON files (*.*json)"
}

@test "Checks the pattern in BUILDKITE_PLUGIN_JSON_LINT_PATTERN" {
  export BUILDKITE_PLUGIN_JSON_LINT_PATTERN="valid.json"

  run "$PWD/hooks/command"

  assert_output --partial "checking JSON files (valid.json)"
}

@test "Uses the latest Docker image by default" {
  export BUILDKITE_PLUGIN_JSON_LINT_PATTERN="valid.json"

  _DOCKER_ARGS='run --rm -v /plugin:/mnt --workdir /mnt cytopia/jsonlint:latest ./tests/data/valid.json'

  stub docker "${_DOCKER_ARGS} : echo 'Success'"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Success"
}

@test "Uses the BUILDKITE_PLUGIN_JSON_LINT_VERSION of Docker image if supplied" {
  export BUILDKITE_PLUGIN_JSON_LINT_PATTERN="valid.json"
  export BUILDKITE_PLUGIN_JSON_LINT_VERSION="3.14"

  _DOCKER_ARGS='run --rm -v /plugin:/mnt --workdir /mnt cytopia/jsonlint:3.14 ./tests/data/valid.json'

  stub docker "${_DOCKER_ARGS} : echo 'Success'"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Success"
}
