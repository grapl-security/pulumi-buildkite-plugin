#!/usr/bin/env bash

# mock `pulumi` binary
#
# This prevents the actual `pulumi` binary from being executed during
# these tests. Every invocation is logged to a file.
#
# To make assertions, simply inspect the contents of the file to
# ensure that the expected commands _would_ have been invoked.
pulumi() {
    echo "${FUNCNAME[0]} $*" >> "${ALL_COMMANDS}"

    case "$*" in
        stack\ export*)
            cat << EOF
{
  "version": 3,
  "deployment": {
      "manifest": {},
      "secrets_providers": {
          "type": "service",
          "state": {
              "url": "https://api.pulumi.com",
              "owner": "grapl",
              "project": "foo",
              "stack": "testing"
          }
      },
      "resources": [ ]
  }
}
EOF
            ;;
        *) ;;
    esac
}

recorded_commands() {
    if [ -f "${ALL_COMMANDS}" ]; then
        cat "${ALL_COMMANDS}"
    fi
}

oneTimeSetUp() {
    # shellcheck source-path=SCRIPTDIR
    source "$(dirname "${BASH_SOURCE[0]}")/pulumi.sh"
    export ALL_COMMANDS="${SHUNIT_TMPDIR}/all_commands"
}

setUp() {
    # Ensure any recorded commands from the last test are removed so
    # we start with a clean slate.
    rm -f "${ALL_COMMANDS}"
}

test_project_name_from_stack_export() {

    actual_value="$(project_name some/directory my-org/my-stack)"
    expected_value="foo" # from the mock above!

    expected_commands=$(
        cat << EOF
pulumi stack export --cwd=some/directory --stack=my-org/my-stack
EOF
    )

    assertEquals "The expected pulumi commands were not run" \
        "${expected_commands}" \
        "$(recorded_commands)"
    assertEquals "The expected project name was not extracted" \
        "${expected_value}" \
        "${actual_value}"
}
