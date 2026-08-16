import Cadova

// The second model, so that the package has two things to run and they are
// visibly different when one of them is on screen: a round coaster with a
// chamfered rim and a recess for the glass to sit in.
//
// Change `diameter`, `thickness` or `rim` and run it again — that is the whole
// loop this example is here for.
await Project(packageRelative: "Models") {
    await Model("coaster") {
        let diameter = 90.0
        let thickness = 5.0
        let rim = 4.0
        let recess = 2.0

        Circle(diameter: diameter)
            .extruded(height: thickness, topEdge: .chamfer(depth: 1))
            .subtracting {
                Circle(diameter: diameter - rim * 2)
                    .extruded(height: recess)
                    .translated(z: thickness - recess)
            }
    }
}
