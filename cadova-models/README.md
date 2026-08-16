# cadova-models

Two 3D models written in Swift, using [Cadova](https://github.com/tomasf/Cadova).
Each executable writes a 3MF into `Models/` beside this file; change a number,
run it again, and look at what came out.

| run | what it makes |
|---|---|
| `swift run hex-key-holder` | the hex key holder from Cadova's README: a block with a row of hexagonal holes, 1.5 mm to 5 mm — 460 vertices, 916 triangles |
| `swift run coaster` | a round coaster with a chamfered rim and a recess — 1,280 vertices, 2,556 triangles |

There is no `.abydos/run` here, and that is the point of this example: a Swift
package's executables are read out of `Package.swift` and offered on their own.
The two are spelled the two different ways a package can spell an executable —
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
the manifest pins `.upToNextMinor(from: "0.9.0")` — which is what Cadova's own
README recommends — and `Package.resolved` is committed. An example that stops
compiling in six months is worse than no example.

## The directory is not called `cadova`

It was, for about ten minutes. SwiftPM takes a package's identity from its
directory name and a dependency's from its URL, and `Cadova.git` gives
`cadova`, so a package in a directory of that name depends on itself. Nothing
says so: `swift package resolve` exits 0 in a third of a second having fetched
nothing and written no `Package.resolved`, and the first thing to complain is
the build, with `product 'Cadova' required by package 'cadova' target
'coaster' not found`.
