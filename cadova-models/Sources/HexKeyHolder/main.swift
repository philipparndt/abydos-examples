import Cadova

// The hex key holder from Cadova's own README, unmodified apart from being
// wrapped in a Project: a block with a row of hexagonal holes in it, one for
// each key from 1.5 mm to 5 mm.
//
// `Project(packageRelative:)` rather than a bare `Model`, so the 3MF lands in
// `Models/` next to this package however the program was started. A plain
// `Model("hex-key-holder")` writes to the working directory, and a run from a
// terminal, from an editor and from Xcode all choose a different one.
await Project(packageRelative: "Models") {
    await Model("hex-key-holder") {
        let height = 22.0
        let spacing = 8.0
        Stack(.x, spacing: spacing) {
            for size in stride(from: 1.5, through: 5.0, by: 0.5) {
                RegularPolygon(sideCount: 6, widthAcrossFlats: size)
            }
        }.measuringBounds { holes, bounds in
            Stadium(bounds.size + spacing * 2)
                .extruded(height: height)
                .subtracting {
                    holes.aligned(at: .centerX)
                        .extruded(height: height)
                        .translated(z: 2)
                }
        }
    }
}
