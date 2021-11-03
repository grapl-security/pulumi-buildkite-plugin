# Pulumi Buildkite Plugin

Runs [Pulumi](https://pulumi.com) commands in Buildkite.

At the moment, this plugin is concerned with Grapl's needs, and is not
sufficiently generalized or flexible enough for all uses. You have
been warned.

In particular, the following are currently assumed:
- Only Python codebases are used.
- The virtualenv for the Python code is managed manually by
  [Pants](https://pantsbuild.org) via a custom script in broad use at
  Grapl.
- Because of this, we do not run Pulumi from a container, so the
  pulumi binaries are expected to be present on the Buildkite Agent's
  machine.
- Only `preview` and `update` operations are supported.
- The stack configuration file is present locally.
- You are using the Pulumi SaaS.
- A valid access token is present in the environment as `$PULUMI_ACCESS_TOKEN`

## Example

```yml
steps:
  - label: "Pulumi Preview"
    plugins:
      - grapl-security/pulumi#v0.1.1:
          project_dir: pulumi/nomad
          stack: grapl/testing
```

Note that the default command is `preview`; this can also be expressed
explicitly:

```yml
steps:
  - label: "Pulumi Preview"
    plugins:
      - grapl-security/pulumi#v0.1.1:
          command: preview
          project_dir: pulumi/nomad
          stack: grapl/testing
```

To perform an update, simply specify the `update` command:

```yml
steps:
  - label: "Pulumi Update"
    plugins:
      - grapl-security/pulumi#v0.1.1:
          command: update
          project_dir: pulumi/nomad
          stack: grapl/testing
```

## Configuration

### command (optional, string)

The name of the plugin command to run; currently supports `preview`
and `update`.

Note that the value is not simply passed directly to `pulumi`. While
`preview` and `update` _are_ Pulumi CLI commands in their own right,
the values passed to this plugin are symbolic; we are not just running
`pulumi preview` or `pulumi update`. Rather, the plugin sets
additional options when `pulumi` is invoked to ensure the proper
infrastructure is being targeted, the command can run
non-interactively, etc.

Defaults to `preview`.

### project_dir (required, string)

The directory in which the desired Pulumi project can be found. This
directory should contain a `Pulumi.yaml` file, the necessary stack
configuration file, and the `__main__.py` program that will be
invoked.

Note that this is the _directory_ the project is contained in, and not
the _name_ of the project itself!

At Grapl, our current pattern is to put multiple sibling projects
together in a top-level `pulumi` directory. Thus, a typical value for
this might be `pulumi/foo` (for a project named "foo"). This plugin
does not inherently assume this structure, though.

### stack (required, string)

An identifier for the stack that will be operated on. This will
generally be in the form of `<ORGANIZATION>/<STACK>`, where
`<ORGANIZATION>` will be "grapl" (but this organization value is not
explicitly assumed by this plugin).

This should refer to a stack configuration file that exists within the
specified `project_dir` (see above).

### stack (optional, string)

Specifies whether `pulumi update` and `pulumi preview` should be passed the
`--refresh` flag, which updates Pulumi's view of the stack before performing an
update/preview respectively.

Defaults to `true`.

## Building

Requires `make`, `docker`, and `docker-compose`.

`make all` will run all formatting, linting, and testing, though
finer-grained targets are available.

## Release

Our Buildkite pipeline differs from the general pattern here at Grapl
in a few ways.

First, there is no separate `merge` pipeline that runs once a PR has
merged to the `main` branch. Since this repository will be a
low-traffic one, requiring only fast-forward merges will not impose
undue friction to the overall development process. This in turn means
that anything that merges to the `main` branch will have (by
definition) been tested in its exact form in a `verify` pipeline
run. Additionally, there are no artifacts that are generated from this
repository (the repository itself _is_ the artifact). Therefore, a
`merge` pipeline is not necessary.

By the same token, a `provision` and `testing` pipeline are not
required either. There is no infrastructure to deploy, and testing the
plugin in a real pipeline can be easily and (crucially) quickly be
done within the context of the `verify` pipeline itself.

### Test Pulumi Project

In order to exercise the plugin in a real pipeline, we have to have a
real Pulumi project, set up according to the assumptions of this
plugin. This project is found in
[pulumi/pulumi_buildkite_plugin_test](./pulumi/pulumi_buildkite_plugin_test). It
is a minimal project that exists solely for the exercise of this
plugin.
