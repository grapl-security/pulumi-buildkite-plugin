#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

# Uncomment to enable stub debugging
# export PULUMI_STUB_DEBUG=/dev/tty
# export PANTS_VENV_SETUP_STUB_DEBUG=/dev/tty

setup() {
    export BUILDKITE_BUILD_URL=https://buildkite.com/my-org/my-pipeline/builds/1
    export BUILDKITE_PLUGIN_PULUMI_PROJECT_DIR=pulumi/my-project
    export BUILDKITE_PLUGIN_PULUMI_STACK=my-org/my-stack
}

teardown() {
    unset BUILDKITE_BUILD_URL
    unset BUILDKITE_PLUGIN_PULUMI_COMMAND
    unset BUILDKITE_PLUGIN_PULUMI_PROJECT_DIR
    unset BUILDKITE_PLUGIN_PULUMI_STACK
    unset BUILDKITE_PLUGIN_PULUMI_REFRESH
    unset BUILDKITE_PLUGIN_PULUMI_POLICY_PACK
}

@test "defaults to running 'pulumi preview'" {
    stub pulumi \
         "login : echo 'Logging in to Pulumi SaaS'" \
         "stack export --cwd=pulumi/my-project --stack=my-org/my-stack : echo '{\"deployment\": {\"secrets_providers\": {\"state\": {\"project\": \"my-project\"}}}}'" \
         "config set aws:skipMetadataApiCheck false --cwd=pulumi/my-project --stack=my-org/my-stack : echo 'enabling metadataApiCheck'" \
         "preview --cwd=pulumi/my-project --stack=my-org/my-stack --show-replacement-steps --non-interactive --refresh=true --diff --message=\"Previewing from https://buildkite.com/my-org/my-pipeline/builds/1\" : echo 'Doing a Pulumi preview'"

    stub pants_venv_setup \
         ": echo 'used Pants for virtualenv'"

  run "${PWD}/hooks/command"

  assert_output --partial "used Pants for virtualenv"
  assert_output --partial "Logging in to Pulumi SaaS"
  assert_output --partial "--- :pulumi: Previewing changes to my-project + my-org/my-stack infrastructure"
  assert_output --partial "Doing a Pulumi preview"
  assert_success
  unstub pulumi
  unstub pants_venv_setup

}

@test "can run 'pulumi update'" {
    stub pulumi \
         "login : echo 'Logging in to Pulumi SaaS'" \
         "stack export --cwd=pulumi/my-project --stack=my-org/my-stack : echo '{\"deployment\": {\"secrets_providers\": {\"state\": {\"project\": \"my-project\"}}}}'" \
         "config set aws:skipMetadataApiCheck false --cwd=pulumi/my-project --stack=my-org/my-stack : echo 'enabling metadataApiCheck'" \
         "update --cwd=pulumi/my-project --stack=my-org/my-stack --show-replacement-steps --non-interactive --refresh=true --diff --yes --message=\"Updating from https://buildkite.com/my-org/my-pipeline/builds/1\" : echo 'Doing a Pulumi update'"

    stub pants_venv_setup \
         ": echo 'used Pants for virtualenv'"

    # shellcheck disable=SC2030,SC2031
    export BUILDKITE_PLUGIN_PULUMI_COMMAND=update

    run "${PWD}/hooks/command"

    assert_output --partial "used Pants for virtualenv"
    assert_output --partial "Logging in to Pulumi SaaS"
    assert_output --partial "--- :pulumi: Updating my-project + my-org/my-stack infrastructure"
    assert_output --partial "Doing a Pulumi update"
    assert_success

    unstub pulumi
    unstub pants_venv_setup
}


@test "pulumi update respects a configurable refresh" {
    # We are primarily interested in the `--refresh=false` being picked up here.

    stub pulumi \
         "login : echo 'Logging in to Pulumi SaaS'" \
         "stack export --cwd=pulumi/my-project --stack=my-org/my-stack : echo '{\"deployment\": {\"secrets_providers\": {\"state\": {\"project\": \"my-project\"}}}}'" \
         "config set aws:skipMetadataApiCheck false --cwd=pulumi/my-project --stack=my-org/my-stack : echo 'enabling metadataApiCheck'" \
         "update --cwd=pulumi/my-project --stack=my-org/my-stack --show-replacement-steps --non-interactive --refresh=false --diff --yes --message=\"Updating from https://buildkite.com/my-org/my-pipeline/builds/1\" : echo 'Doing a Pulumi update'"

    stub pants_venv_setup \
         ": echo 'used Pants for virtualenv'"

    # shellcheck disable=SC2030,SC2031
    export BUILDKITE_PLUGIN_PULUMI_COMMAND=update
    export BUILDKITE_PLUGIN_PULUMI_REFRESH=0

    run "${PWD}/hooks/command"

    assert_output --partial "used Pants for virtualenv"
    assert_output --partial "Logging in to Pulumi SaaS"
    assert_output --partial "--- :pulumi: Updating my-project + my-org/my-stack infrastructure"
    assert_output --partial "Doing a Pulumi update"
    assert_success

    unstub pulumi
    unstub pants_venv_setup
}

@test "unrecognized commands are failures" {
    # shellcheck disable=SC2030,SC2031
    export BUILDKITE_PLUGIN_PULUMI_COMMAND=foobar

    run "${PWD}/hooks/command"

    assert_output --partial "Unrecognized command: 'foobar'!"
    assert_failure
}

@test "can run policy packs" {

    export BUILDKITE_PLUGIN_PULUMI_COMMAND=update

    # These are *real* paths within this repository. We're using them
    # for this particular test to exercise the relativization of the
    # policy pack's path, which is a little trickier to stub out.
    export BUILDKITE_PLUGIN_PULUMI_PROJECT_DIR=pulumi/pulumi_buildkite_plugin_test
    export BUILDKITE_PLUGIN_PULUMI_POLICY_PACK=pulumi/policy

    stub pulumi \
         "login : echo 'Logging in to Pulumi SaaS'" \
         "stack export --cwd=pulumi/pulumi_buildkite_plugin_test --stack=my-org/my-stack : echo '{\"deployment\": {\"secrets_providers\": {\"state\": {\"project\": \"pulumi-buildkite-plugin-test\"}}}}'" \
         "config set aws:skipMetadataApiCheck false --cwd=pulumi/pulumi_buildkite_plugin_test --stack=my-org/my-stack : echo 'enabling metadataApiCheck'" \
         "update --cwd=pulumi/pulumi_buildkite_plugin_test --stack=my-org/my-stack --show-replacement-steps --non-interactive --refresh=true --diff --yes --policy-pack=../policy --message=\"Updating from https://buildkite.com/my-org/my-pipeline/builds/1\" : echo 'Doing a Pulumi update with a policy pack'"

    stub pants_venv_setup \
         ": echo 'used Pants for virtualenv'"

    run "${PWD}/hooks/command"

    assert_output --partial "Doing a Pulumi update with a policy pack"
    assert_success
}
