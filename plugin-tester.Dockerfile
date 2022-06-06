FROM buildkite/plugin-tester:v2.0.0

# Install a real version of `realpath` which respects the
# `--relative-to` option. (The `busybox` version built into the
# upstream `buildkite/plugin-tester` image does not).
RUN apk add --no-cache coreutils=9.0-r2
