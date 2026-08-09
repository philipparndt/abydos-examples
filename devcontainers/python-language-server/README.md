# A language server that is not on this machine

Every other devcontainer example here proves a container **comes up**. This one
proves something is **working inside it**: open the project, open `main.py`, and
⌘-click `Reading`. The definition opens `stations/reading.py` — at a path on
this machine, in the ordinary editor, with the ordinary tab — and the server
that answered is a `pyright-langserver` that exists only inside the container.

## Why Python, and not Go

Because the proof has to be a proof.

A Go example would be easier to write, and it would demonstrate nothing:
anybody with a Go checkout has `gopls` in `~/go/bin`, so a hover that works
could have been the copy on the host answering. The same is true of
`rust-analyzer`, `clangd`, `typescript-language-server` and `jdtls` — they come
with a toolchain somebody already installed.

Almost nobody has `pyright` unless they went and installed it, and Abydos does
not substitute one machine's server for another's: a container that lacks the
server is reported as lacking it, by name, with the hint about the file that
would have to carry it. So with this example there are only two outcomes, and
they are both informative:

- **completion, hover and go-to-definition work** — then the container did it,
  because nothing else could have; or
- **the editor says the server is missing** — then the container is not there,
  and it says so rather than sitting quietly doing nothing.

Try the second one on purpose: copy `main.py` and `stations/` somewhere with no
`.devcontainer` beside them and open that instead.

## How pyright gets in: baked into the image

`.devcontainer/Dockerfile` installs it, pinned, and `.devcontainer/devcontainer.json`
names the Dockerfile. The alternative was a `postCreateCommand` running
`npm install -g pyright`, which now runs and would have been three lines shorter.
It was not chosen, for three reasons:

- **A lifecycle command runs once per *container*, not once per project.** The
  marker Abydos writes lives inside the container, deliberately, so a rebuild, a
  swept container or a restarted machine installs the server again — minutes and
  a network round trip every time, at the moment somebody is trying to open a
  file.
- **A `postCreateCommand` that fails takes the container with it.** That is the
  right behaviour, and it means a flaky npm registry turns "open this project"
  into "no container at all". A pinned layer in an image is fetched once and is
  then a fact.
- **`devcontainers/post-create` already demonstrates lifecycle commands**, and
  demonstrates them better, because that is what it is for. This example is about
  the language server; two features in one example teaches neither.

The cost is a slower first open — the image is built rather than pulled — and
everything after it instant.

`.devcontainer/Dockerfile` says why the server needs Python *and* Node beside
it, and why the version is pinned; it does not repeat the argument in
`ToolImages/gopls/Dockerfile` in the Abydos repository, which is the same
argument for gopls and worth reading once.

## What it costs to open

| | |
|---|---|
| `python:3.12-alpine3.21`, pulled | **18 MB** (arm64, compressed), 52 MB on disk |
| plus `nodejs`, `npm`, `pyright@1.1.411` | built here |
| `abydos-devcontainer:python-language-server` | **143 MB** on disk |

`mcr.microsoft.com/devcontainers/python` carries Python and Node already and is
over a gigabyte, which is the whole reason this builds its own. Anybody who
opens an example pulls whatever it names.

## The code

Three files, so that the interesting questions cross a boundary:

- `main.py` — imports `Reading`, `Scale` and `warmest`, and uses all three.
- `stations/__init__.py` — a package, so the import is resolved rather than
  found next door.
- `stations/reading.py` — a frozen dataclass with five attributes, a property
  and three methods, and a function returning `Reading | None`.

Worth trying, with the caret in `main.py`:

- ⌘-click `Reading` on the import line — it opens `stations/reading.py` here.
- Type `first.` inside `main()` — completion offers `celsius`, `converted`,
  `describe`, `fahrenheit`, `hour`, `humidity`, `is_muggy`, `scale`, `station`.
- Hover `warmest` — its docstring, and the `Reading | None` it answers.
- Delete the `if first is not None:` and its indentation — the line below is
  underlined, which is the other half of having a language server at all.

It also just runs, on this machine or in the container:

```sh
python3 main.py
```
