// swift-tools-version: 6.3
import PackageDescription

// Two executables on purpose, spelled the two different ways a package can
// spell one, so that a run list has something to get wrong:
//
//   * `hex-key-holder` is a *product* whose target is called `HexKeyHolder`.
//     `swift run HexKeyHolder` answers "error: no executable product named
//     'HexKeyHolder'", so the product's name is the runnable one.
//   * `coaster` is a bare executable target that no product claims. SwiftPM
//     gives it an implicit product of its own name, and it runs under that.
//
// Both names are plain string literals rather than computed, which is what
// anything reading this manifest as text can see.
//
// **On `dev` rather than a version, and only until the next tag.** Cadova asks
// for `upToNextMinor` — it is below 1.0 and keeps its API stable only within a
// minor version — and that is what belongs here. What it is on `dev` for is
// `CADOVA_REVEAL_FILES`, added upstream on 2026-08-18 in `d358a4fd` and in no
// release: it is what lets whoever starts a build say that this one should not
// open a Finder window, and a preview pane that opens one on every rebuild is
// unusable. That commit also deleted the `Settings` type these models used to
// set from the inside, so this is not a pin that can be undone on its own —
// going back before it means putting those lines back.
//
// Put `.upToNextMinor(from:)` back the moment there is a tag containing that
// setting. A branch dependency has no version to reason about, so nothing warns
// anybody this is temporary except this paragraph.
//
// `Package.resolved` is committed beside this file, so a fresh checkout builds
// the same packages this one was written against rather than whatever is
// newest. On a branch that pin is a *revision*, which is what keeps this
// reproducible while `dev` moves under it.
//
// The directory is `cadova-models` and not `cadova`, which is worth knowing
// before anybody renames it back. SwiftPM takes a package's *identity* from
// its directory name and a dependency's from its URL, and `Cadova.git` gives
// `cadova`: a package sitting in a directory of that name declares a
// dependency on itself, and SwiftPM says nothing about it. `swift package
// resolve` exits 0 in a third of a second having fetched nothing, no
// `Package.resolved` appears, and the first complaint is from the build —
// "product 'Cadova' required by package 'cadova' target 'coaster' not found".
let package = Package(
    name: "cadova-models",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "hex-key-holder", targets: ["HexKeyHolder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", branch: "dev"),
    ],
    targets: [
        .executableTarget(
            name: "HexKeyHolder",
            dependencies: ["Cadova"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .executableTarget(
            name: "coaster",
            dependencies: ["Cadova"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
