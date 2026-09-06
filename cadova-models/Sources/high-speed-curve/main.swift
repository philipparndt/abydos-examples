import Cadova

// Change `chosen`, save, and the preview redraws.

let arrangements: [(name: String, tracks: [Track])] = [
    ("three-short", [Track(.right, .upperRight), Track(.upperLeft, .left), Track(.lowerLeft, .lowerRight)]),
    ("curve", [Track(.upperLeft, .right), Track(.lowerLeft, .lowerRight)]),
    ("two-short", [Track(.right, .upperRight), Track(.left, .lowerLeft)]),
    ("two-long", [Track(.right, .upperLeft), Track(.left, .lowerRight)]),
    ("y", [Track(.right, .upperLeft), Track(.right, .lowerLeft)]),
    ("y-short", [Track(.right, .upperRight), Track(.right, .lowerRight)]),
    ("straight", [Track(.right, .left)]),
    ("straight-two-short", [Track(.right, .left), Track(.upperRight, .upperLeft), Track(.lowerLeft, .lowerRight)]),
    ("x", [Track(.upperRight, .lowerLeft), Track(.lowerRight, .upperLeft)]),
    ("two-y-short", [
        Track(.right, .upperRight), Track(.right, .lowerRight),
        Track(.left, .upperLeft), Track(.left, .lowerLeft),
    ]),
]

let chosen = "three-short"
let footGap = 5.0

guard let arrangement = arrangements.first(where: { $0.name == chosen }) else {
    fatalError("no arrangement called \(chosen); it is one of \(arrangements.map(\.name))")
}

await Project(packageRelative: "Models") {
    Environment {
        $0.segmentation = .adaptive(minAngle: 4°, minSize: 0.4)
    }

    await Model("high-speed-\(arrangement.name)") {
        tile(tracks: arrangement.tracks)
        Foot.part().translated(x: Tile.apothem + Foot.outerApothem + footGap)
    }
}
