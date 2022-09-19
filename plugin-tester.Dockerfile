FROM buildkite/plugin-tester:v3.0.1

# Install a real version of `realpath` which respects the
# `--relative-to` option. (The `busybox` version built into the
# upstream `buildkite/plugin-tester` image does not).
RUN apk add --no-cache coreutils=9.0-r2
