#!/usr/bin/env bash

# Extract the Pulumi project name from the output of the stack.
#
# The output of `pulumi stack export` looks like this:
# {
#     "version": 3,
#     "deployment": {
#         "manifest": { ... },
#         "secrets_providers": {
#             "type": "service",
#             "state": {
#                 "url": "https://api.pulumi.com",
#                 "owner": "grapl",
#                 "project": "foo",
#                 "stack": "testing"
#             }
#         },
#         "resources": [...]
#     }
# }
#
# We'll just use `jq` to extract the project name.
project_name() {
    local -r directory="${1}"
    local -r stack_id="${2}"

    pulumi stack export \
        --cwd="${directory}" \
        --stack="${stack_id}" |
        jq --raw-output \
            ".deployment.secrets_providers.state.project"
}
