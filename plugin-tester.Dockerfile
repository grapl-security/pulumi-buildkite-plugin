# latest, as of 2022-05-17
FROM buildkite/plugin-tester@sha256:476a1024936901889147f53d2a3d8e71e99d76404972d583825514f5608083dc

# Install a real version of `realpath` which respects the
# `--relative-to` option. (The `busybox` version built into the
# upstream `buildkite/plugin-tester` image does not).
RUN apk add --no-cache coreutils=8.29-r2
