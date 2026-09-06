# abydos-examples

Projects to develop *with*, rather than to read. Each one is small enough to
take in at a glance and real enough to exercise something the editor does:
running a service in a cluster, sending it the file it will not start without,
replacing one container of somebody else's chart, stepping through a language
that is not Go, drawing a diagram with a tool nobody installed, or opening a
repository that is in an awkward state.

Open one of them as a project. They all carry their own launch configurations
in `.abydos/run`, so pressing run is the first thing you can do.

```sh
make build       # everything that has a build
make scenarios   # the git repositories
make secrets     # the secret files git cannot carry
make diagrams    # draw the .puml files in a container
make charts      # lint the chart
```

## The projects

| project | what it is for |
|---|---|
| [go-service](go-service) | a backend with nothing in it but the shape of one: run it here, run it in a cluster, debug it there, profile it — and the one project with a backlog and an OpenSpec directory, so the bottom panel has something to draw |
| [smart-home-microservice](smart-home-microservice) | a service that will not start without its configuration file, with a page to look at — the awkward one to develop in a cluster |
| [multi-tier](multi-tier) | somebody else's chart: an application and a web front end in one pod, a database and a cache beside them, a values file per stage |
| [native/odin-hello](native/odin-hello) | odin, written the way Odin is written — and running in a cluster, which its own linker cannot manage alone |
| [native/zig-hello](native/zig-hello) | zig, built by make and debugged with LLDB |
| [native/rust-hello](native/rust-hello) | rust, the same |
| [native/c-hello](native/c-hello) | C, the same |
| [native/cpp-hello](native/cpp-hello) | C++, the same |
| [java/maven-service](java/maven-service) | Java and Maven: a service with no dependencies, run and debugged here and in a cluster |
| [java/hot-swap](java/hot-swap) | Java and Maven again, and only about one thing: changing a method body in a JVM that never stops. It keeps count out loud, so a swap can be told from a restart |
| [java/gradle-service](java/gradle-service) | Java and Gradle in the Kotlin DSL: a worker that would be over before you arrived, so the pod's JVM waits |
| [openscad](openscad) | two parametric models — change a number, save, watch the preview; an adapter that had to fit something real, and a dollhouse a metre tall |
| [cadova-models](cadova-models) | the same idea in Swift: a Cadova package whose three executables each write a 3MF, carrying no launch configurations because its `Package.swift` is enough to say what it can run — and one of the three is a real printed object, big enough that a preview has to behave while it thinks |
| [plantuml](plantuml) | four diagrams and no PlantUML: the project names an image, and docker or Apple's container draws them |
| [mermaid](mermaid) | six diagrams and nothing to install, in the six shapes Mermaid draws differently |
| [drawio](drawio) | four `.drawio` documents — pages, stencils, and one saved as an SVG that is also a diagram |
| [devcontainers](devcontainers) | eight projects and nine `devcontainer.json` between them, a field each — one refused on purpose and written to work anyway, and one carrying the project's own language server |
| [secrets](secrets) | the covers and SOPS, which are not the same feature: four encrypted files, four plaintext ones, and the three things git can be told about a `.env` |
| [media](media) | a video that plays, one that is meant to fall back, and a picture — files whose rendered form is the whole of them |
| [git-scenarios](git-scenarios) | twelve repositories, each stuck in a state worth looking at — including a superproject of submodules and a picture painted three times |

## One repository, many projects

This repository is itself the case for subprojects: open it and the tree shows
everything, but there is no one set of launch configurations, no one module to
build, no one thing `go test` means. Right-click a folder — `go-service`,
`native/odin-hello`, `multi-tier` — and choose **Open as Subproject**: the tree
stays whole, and the run configurations, the build, git and the language server
all follow the part being worked on. The pill beside the project name says
which one, and its cross gives the whole repository back.

Which is why the PlantUML image is named twice — in `plantuml/.abydos/tools.json`
and again at the top of the repository. `.abydos` is read from whichever of the
two is open, and a diagram should draw either way.

`git-scenarios/out` is the harder case, since each of those is a repository of
its own inside this one. Opening one as a subproject points git at *that* work
tree — the changes pane, the history and the branch name all come from it. Its
`superproject` goes one further: a repository whose own submodules are twelve
more, and reading it as one working copy is what makes it worth generating.

`secrets` is the case that has to be opened on its own. The offer to encrypt a
plaintext file is read from the `.sops.yaml` at the *project* root, so from the
top of the repository that folder's rules are not it — the decrypt works either
way, and only the offer needs the subproject.

## What needs what

Nothing here needs a cluster to *build*. The cluster examples need one to run,
and they are written to refuse anything that is not obviously a development
cluster — `allowedContexts` is `k3c-*, k3d-*, *-local`, so a configuration
that follows the current context cannot follow it onto production.

| project | needs |
|---|---|
| go-service, smart-home-microservice | Go, and a local cluster for the cluster configurations |
| multi-tier | Go, helm, and a local cluster |
| native/* | odin, zig, cargo, cc, c++ — whichever you want to try |
| java/* | a JDK; `jdtls` for completion and problems, and the java-debug bundle for debugging |
| openscad | OpenSCAD, for the preview |
| cadova-models | a Swift 6.3 toolchain, and the network once: seven packages to resolve and a minute to build the first time |
| plantuml | nothing, if docker or Apple's container is here — otherwise plantuml, and graphviz for two of the four |
| mermaid, drawio, media | nothing |
| devcontainers | docker, for the ones that come up |
| secrets | `sops`, to decrypt anything; the example carries its own throwaway key |
| git-scenarios | git, and python3 for two of the twelve |

The cluster examples all use the namespace `abydos-examples`, so clearing up is
one command:

```sh
kubectl delete namespace abydos-examples
```

## What is not here yet

**Node and Python in a cluster.** Go, Zig, Rust, C, C++, Odin and Java all run
*and debug* in a cluster, in two arrangements: a native binary is
cross-compiled here, pushed into the pod and held there by Delve or gdbserver,
and a jar is built here, pushed into a pod that has a JVM, and debugged over
JDWP with the JVM suspended until the debugger arrives. Node and Python would
need a third — sources copied in, and their own protocols — and that is not
built.

Python is here for *editing*, which is a different thing:
[devcontainers/python-language-server](devcontainers/python-language-server) is
a project whose `pyright` lives in the container and answers from there. There
is no Node example at all.

**A tag, a submodule and a picture are here; a worktree is not.** The git
scenarios cover the states a repository gets stuck in, and now a superproject
too, but nothing here has a second worktree checked out — which is what the
backlog's *start* makes, and what its cards offer to open.
