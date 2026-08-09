# devcontainers

Small projects that exist to be *opened*, one field of `devcontainer.json`
each. The projects above this folder — `go-service`, `smart-home-microservice`,
`multi-tier` — carry the devcontainers a real project would have; these carry
the ones that would be noise inside a real project, and the ones that are
refused.

Open any of them as a project and choose **View ▸ New Terminal in Container**.

```sh
./devcontainers/check.sh    # bring up everything that is meant to come up
```

## The ones that come up

| project | what it is for | image |
|---|---|---|
| [../go-service](../go-service) | the plainest thing that works: one `image`, nothing else | `golang:1.24-alpine` (259 MB) |
| [../smart-home-microservice](../smart-home-microservice) | `forwardPorts`, `containerEnv` and `remoteEnv`, on a service that actually serves | `golang:1.24-alpine` (shared) |
| [dockerfile-build](dockerfile-build) | `build.dockerfile`, `context`, `args` and `target`, each checkable from inside | built here from `alpine:3.21` (8 MB + `jq`) |
| [non-root-user](non-root-user) | `containerUser` and `remoteUser` being the two different things they are | `mcr.microsoft.com/devcontainers/base:alpine-3.21` (735 MB) |
| [substitutions](substitutions) | every `${...}` the reader answers, plus `workspaceMount`, `mounts`, `runArgs` | `alpine:3.21` (8 MB) |

Everything is pinned, and Alpine wherever an Alpine exists. `go-service` names
`golang:1.24-alpine` rather than `mcr.microsoft.com/devcontainers/go` on purpose:
it is the same toolchain and a fifth of the download, and anybody who opens
these examples pulls what they name.

## The ones that are refused

These are not broken, and nothing about them should look broken. Each is a file
the reference `devcontainer up` builds without complaint. Abydos reads a stated
subset of the spec and says so by name when a file is outside it, in one
sentence somebody can act on — because a container quietly started without the
half of the file that was not understood does not look like an unsupported
file, it looks like a broken editor.

| project | what it says | what lifts it |
|---|---|---|
| [../multi-tier](../multi-tier) | `dockerComposeFile`, naming the compose file | somebody teaching Abydos compose |
| [features](features) | `features`, naming the first one it found | step 4 of 0424 |
| [post-create](post-create) | `postCreateCommand` | step 5 of 0424 |
| [post-create-fails](post-create-fails) | `postCreateCommand` — the same sentence, a command that fails | step 5 of 0424 |
| [two-containers](two-containers) | more than one `devcontainer.json`, naming both | somewhere to ask which one |

They are the fixtures those steps will be built against, which is why the parts
that are refused today are nevertheless written to work: `multi-tier`'s compose
file brings four services up, `features` names features that exist, and both
`post-create` scripts run — one slowly, one into a failure with an exit code.

## What is not covered here

`portsAttributes`, `waitFor`, `shutdownAction`, `overrideCommand`,
`userEnvProbe`, `hostRequirements` and `customizations` are read by nobody and
refused by nobody, so an example of one would be an example of nothing.
`updateRemoteUserUID` is the one worth naming: `non-root-user` is where it would
belong, and it is deliberately absent rather than present and quietly ignored.
