# two-containers

A project that offers a choice of two containers to work in, which is what
`.devcontainer/<name>/devcontainer.json` is for. **Abydos refuses this one**:

> This project has more than one devcontainer.json
> (.devcontainer/alpine/devcontainer.json, .devcontainer/go/devcontainer.json)
> and this app cannot yet ask which one you want — leave the one you work in and
> move the others out of .devcontainer.

Both files are fine on their own. It is the pair that is the problem, and the
problem is not a parsing one: picking the first quietly would be picking
somebody's toolchain for them, and they would find out by typing `go` and being
told there is no such thing.

The names are sorted rather than taken in whatever order the file system
answered in, so which one is named first is a fact about the names.
