# cadova-models

Three 3D models written in Swift, using [Cadova](https://github.com/tomasf/Cadova).
Each executable writes a 3MF into `Models/` beside this file; change a number,
run it again, and look at what came out.

| run | what it makes |
|---|---|
| `swift run hex-key-holder` | the hex key holder from Cadova's README: a block with a row of hexagonal holes, 1.5 mm to 5 mm — 2,840 vertices, 5,676 triangles |
| `swift run coaster` | a round coaster with a chamfered rim and a recess — 1,280 vertices, 2,556 triangles |
| `swift run high-speed-curve` | a Gravitrax-compatible hexagonal tile with enclosed ball channels, and its foot laid out beside it — about 19,000 vertices and 38,000 triangles |

The third one is the one that is a real printed object rather than a shape
chosen to be looked at, and it is the reason this example is worth opening: a
lofted dome, revolved cuts through it, and a rebuild slow enough that a preview
has to behave while it is thinking. `Sources/high-speed-curve/main.swift` is
only the choice of which channels the tile carries — ten arrangements, one line
saying which is built, and `three-short` the default. `Tile.swift` beside it is
the geometry.

**About nineteen thousand, not exactly nineteen thousand.** That model's
segmentation is adaptive, and three runs of the same source gave 18,970, 18,975
and 18,978 vertices. The other two are stable to the vertex.

There is no `.abydos/run` here, and that is the point of this example: a Swift
package's executables are read out of `Package.swift` and offered on their own.
The first two are spelled the two different ways a package can spell an executable —
`hex-key-holder` is a product whose target is called `HexKeyHolder`, and
`coaster` is a bare executable target that no product claims — so a run list
that offers `HexKeyHolder` is offering something `swift run` will refuse.

## What it needs

A Swift 6.3 toolchain, and the network once. Measured on an M-series laptop,
from a fresh checkout:

| | |
|---|---|
| `swift package resolve` | 23 s, seven packages |
| first `swift build` | 65 s (`-j 4`; it compiles a C++ geometry kernel) |
| `swift run <either>` afterwards | about 3 s, of which the model itself is a fraction of a second |

Nothing built is committed — not `.build`, and not the 3MF files in `Models/`.
A 3MF in git is the output of the source next to it, with nothing to say when
the two stop agreeing.

## Pinning

Cadova is below 1.0 and keeps its API stable only within a minor version, so
`.upToNextMinor(from:)` is what belongs here and `Package.resolved` is
committed. An example that stops compiling in six months is worse than no
example.

Right now the manifest is on the `dev` branch instead, pinned by revision in
`Package.resolved`, and `Package.swift` says at length why: `CADOVA_REVEAL_FILES`
is in no tagged release, and without it a rebuild opens a Finder window — which
makes a preview pane that rebuilds on every save unusable. Put the version range
back the moment there is a tag carrying it.

## Where the tile came from

`high-speed-curve` is a re-implementation, not a copy: every dimension in
`Tile.swift` was measured from the STLs of **"Gravitrax high speed curve" by
Bas**, published under **CC BY-NC-SA**. None of that download is in this
repository — no STL, no 3MF, no Fusion file — but the measurements are its
shape, so the credit belongs here as well as at the top of `Tile.swift`.

## The directory is not called `cadova`

It was, for about ten minutes. SwiftPM takes a package's identity from its
directory name and a dependency's from its URL, and `Cadova.git` gives
`cadova`, so a package in a directory of that name depends on itself. Nothing
says so: `swift package resolve` exits 0 in a third of a second having fetched
nothing and written no `Package.resolved`, and the first thing to complain is
the build, with `product 'Cadova' required by package 'cadova' target
'coaster' not found`.
