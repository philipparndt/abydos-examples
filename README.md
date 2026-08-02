# ideai-examples

Projects to develop *with*, rather than to read. Each one is small enough to
take in at a glance and real enough to exercise something the editor does:
running a service in a cluster, sending it the file it will not start without,
replacing one container of somebody else's chart, stepping through a language
that is not Go, or opening a repository that is in an awkward state.

Open one of them as a project. They all carry their own launch configurations
in `.ideai/run`, so pressing run is the first thing you can do.

```sh
make build       # everything that has a build
make scenarios   # the git repositories
make charts      # lint the chart
```

## The projects

| project | what it is for |
|---|---|
| [go-service](go-service) | a backend with nothing in it but the shape of one: run it here, run it in a cluster, debug it there, profile it |
| [lamarzocco-style](lamarzocco-style) | a service that will not start without its configuration file, with a page to look at — the awkward one to develop in a cluster |
| [multi-tier](multi-tier) | somebody else's chart: an application and a web front end in one pod, a database and a cache beside them, a values file per stage |
| [native/zig-hello](native/zig-hello) | zig, built by make and debugged with LLDB |
| [native/rust-hello](native/rust-hello) | rust, the same |
| [native/c-hello](native/c-hello) | C, the same |
| [native/cpp-hello](native/cpp-hello) | C++, the same |
| [openscad](openscad) | one parametric model — change a number, save, watch the preview |
| [git-scenarios](git-scenarios) | nine repositories, each stuck in a state worth looking at |

## What needs what

Nothing here needs a cluster to *build*. The cluster examples need one to run,
and they are written to refuse anything that is not obviously a development
cluster — `allowedContexts` is `k3c-*, k3d-*, *-local`, so a configuration
that follows the current context cannot follow it onto production.

| project | needs |
|---|---|
| go-service, lamarzocco-style | Go, and a local cluster for the cluster configurations |
| multi-tier | Go, helm, and a local cluster |
| native/* | zig, cargo, cc, c++ — whichever you want to try |
| openscad | OpenSCAD, for the preview |
| git-scenarios | git |

The cluster examples all use the namespace `ideai-examples`, so clearing up is
one command:

```sh
kubectl delete namespace ideai-examples
```

## What is not here yet

Debugging a native binary *in a cluster*. The development pod runs any static
binary, but the debugger it starts is Delve, which is Go's. Zig, Rust, C and
C++ debug locally with LLDB; in a cluster they run, and stepping through them
there is not built yet.
