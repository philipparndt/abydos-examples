import Cadova

// The hex key holder from Cadova's own README, unmodified apart from being
// wrapped in a Project: a block with a row of hexagonal holes in it, one for
// each key from 1.5 mm to 5 mm.
//
// `Project(packageRelative:)` rather than a bare `Model`, so the 3MF lands in
// `Models/` next to this package however the program was started. A plain
// `Model("hex-key-holder")` writes to the working directory, and a run from a
// terminal, from an editor and from Xcode all choose a different one.

// Cadova reveals what it wrote in Finder when it finishes, which is friendly
// from a terminal and not from an editor: a preview pane rebuilds on every save,
// so each one raised Finder over the window being typed into.
//
// **Nothing is said about it here any more, and that is the point.** This model
// used to turn it off itself, because `isFileRevealingEnabled` was a static var
// inside the process being built and nothing outside could reach it. Upstream
// seeds it from `CADOVA_REVEAL_FILES` now — `0`, `false`, `no` or `off` — so the
// process that starts a run says how it wants that run to behave, and a model
// says nothing at all. A model is about a shape, not about who is running it.
//
// Blocking it from outside was tried and measured before that existed: denying
// the process its Launch Services connection does not stop the reveal, and
// denying Apple Events stops it at the cost of a 30-second wait for a Finder
// port that never answers, against 0.06 s unhindered.

await Project(packageRelative: "Models") {
    await Model("hex-key-holder") {
        let height = 22.0
        let spacing = 8.0
        /// How far the mouth of each hole flares, and how deep the flare goes.
        let mouth = 0.8
        Stack(.x, spacing: spacing) {
            for size in stride(from: 1.5, through: 5.0, by: 0.5) {
                RegularPolygon(sideCount: 6, widthAcrossFlats: size)
            }
        // `holes` and `bounds` are this closure's own parameters, named here and
        // nowhere else: `measuringBounds` hands back the geometry it measured
        // along with its bounding box, so `holes` *is* the `Stack` above. See
        // `measuringBounds(scope:_:empty:)` in Cadova — the builder is
        // `(D.Geometry, D.BoundingBox) -> Output.Geometry`.
        }.measuringBounds { holes, bounds in
            Stadium(bounds.size + spacing * 2)
                .extruded(height: height, topEdge: .chamfer(depth: 1))
                .subtracting {
                    holes.aligned(at: .centerX)
                        .extruded(height: height)
                        .translated(z: 2)

                    // A funnel at the mouth of every hole, so a key finds its
                    // hole without being lined up with it first.
                    //
                    // **A chamfer cannot be asked for directly here, and that is
                    // worth knowing before trying.** `EdgeProfile` only ever
                    // *removes* material — `.chamfer(depth:height:)` is the
                    // triangle `[[0,0], [depth,0], [0,height]]` — so putting
                    // `topEdge:` on the solid being subtracted would make each
                    // hole *narrower* at the top, which is the opposite of
                    // insertion. The cavity has to grow instead, so this is a
                    // second piece of cavity unioned onto the first.
                    //
                    // `offset` widens each hexagon *in place*. Scaling would not:
                    // `topScale:` on the extrusion scales about the origin, and
                    // these hexagons are spread along x, so the far ones would
                    // slide outwards rather than open up. A `bottomEdge` chamfer
                    // as deep as the offset then takes the widened profile back
                    // to the original size at the bottom, which is the cone.
                    // At the *body's* top face, which is `height` — not the
                    // hole's top. The holes are translated up by 2 and are
                    // `height` tall, so they stand 2 mm proud of the block; a
                    // mouth placed relative to them would sit in mid-air above
                    // the part and cut nothing at all.
                    holes.aligned(at: .centerX)
                        .offset(amount: mouth, style: .round)
                        .extruded(height: mouth, bottomEdge: .chamfer(depth: mouth))
                        .translated(z: height - mouth)
                }
        }
    }
}
