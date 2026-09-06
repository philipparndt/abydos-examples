import Cadova
import Foundation

// Dimensions measured from "Gravitrax high speed curve" by Bas (CC BY-NC-SA).
// Millimetres throughout.

/// The six sides of the tile, counter-clockwise, starting with the side that faces +X.
enum Side: Int, CaseIterable {
    case right = 0, upperRight, upperLeft, left, lowerLeft, lowerRight

    var angle: Angle { Angle(degrees: Double(rawValue) * 60) }

    var direction: Vector2D { Vector2D(cos(angle.radians), sin(angle.radians)) }

    func advanced(by steps: Int) -> Side {
        Side(rawValue: ((rawValue + steps) % 6 + 6) % 6)!
    }

    /// 0...3 — how many sides apart two sides are.
    func separation(to other: Side) -> Int {
        let d = abs(rawValue - other.rawValue)
        return min(d, 6 - d)
    }
}

enum Tile {
    static let apothem = 30.0          // 60 mm across flats
    static let cornerRadius = 2.0
    static let wallHeight = 10.0       // vertical up to here, then the dome
    static let height = 18.0

    static var circumradius: Double { apothem / cos(30°.radians) }

    // The dome's horizontal sections stay hexagonal near the walls and become round
    // towards the top. Two superellipses in the (radius, z) plane describe it, as
    // `(r / a)^n + ((z - wallHeight) / b)^n = 1`.
    static let flatProfile = (a: 30.05, b: 8.06, n: 1.824)
    static let cornerProfile = (a: 34.36, b: 8.05, n: 1.737)

    static func superellipse(_ p: (a: Double, b: Double, n: Double), z: Double) -> Double {
        let t = min(max((z - wallHeight) / p.b, 0), 1)
        return p.a * pow(max(1 - pow(t, p.n), 0), 1 / p.n)
    }

    static func section(at z: Double) -> any Geometry2D {
        guard z > wallHeight else { return hexagon(apothem: apothem, cornerRadius: cornerRadius) }
        let a = superellipse(flatProfile, z: z)
        let c = superellipse(cornerProfile, z: z)
        // A hexagon of apothem `a` with corners rounded by `rho` has its corners at
        // a/cos30 - rho * (1/cos30 - 1); solve for rho.
        let k = 1 / cos(30°.radians) - 1
        let rho = (a / cos(30°.radians) - c) / k
        if rho >= a * 0.999 {
            return Circle(radius: a)
        }
        return hexagon(apothem: a, cornerRadius: max(rho, cornerRadius))
    }

    static var blank: any Geometry3D {
        var heights: [Double] = []
        heights += stride(from: wallHeight + 0.2, to: 17.4, by: 0.2)
        heights += stride(from: 17.4, to: 17.9, by: 0.1)
        heights += [17.95, height]
        return Loft {
            Loft.Section(at: 0..<wallHeight) { section(at: 0) }
            for z in heights {
                Loft.Section(at: z) { section(at: z) }
            }
        }
    }
}

func hexagon(apothem: Double, cornerRadius: Double = 0) -> any Geometry2D {
    let hex = RegularPolygon(sideCount: 6, apothem: apothem).rotated(30°)
    return cornerRadius > 0 ? hex.rounded(radius: cornerRadius) : hex
}

// MARK: - Ball channels

/// A channel between two sides. Adjacent sides are joined by a tight 120° bend, sides
/// two apart by a wide 60° bend, opposite sides by a straight run. Every channel is the
/// same bore, so a tile can carry any mix.
struct Track {
    static let boreRadius = 6.75        // 13.5 mm bore for the 12.7 mm ball
    static let centerHeight = 10.0
    static let roofAngle = 50°          // self-supporting when printed
    static let arcMargin = 10°          // revolve past both faces so the cut is clean

    let from: Side
    let to: Side

    init(_ from: Side, _ to: Side) {
        precondition(from != to, "A track needs two different sides")
        self.from = from
        self.to = to
    }

    var sides: [Side] { [from, to] }

    /// A circle whose top is closed by two tangents, so the channel is enclosed except
    /// for a narrow slit where the roof pokes through the dome.
    static var profile: any Geometry2D {
        Circle(radius: boreRadius)
            .convexHull(adding: Vector2D(0, boreRadius / cos(roofAngle.radians)))
    }

    var cut: any Geometry3D {
        switch from.separation(to: to) {
        case 3:
            return straightCut
        case 1:
            let corner = from.rawValue == to.advanced(by: 1).rawValue ? to : from
            let center = Tile.circumradius * direction(of: corner.angle + 30°)
            let radius = Tile.apothem * tan(30°.radians)
            return arcCut(center: center, radius: radius)
        case 2:
            let between = from.advanced(by: 1) == to.advanced(by: -1) ? from.advanced(by: 1) : from.advanced(by: -1)
            let center = 2 * Tile.apothem * between.direction
            let radius = Tile.apothem * sqrt(3)
            return arcCut(center: center, radius: radius)
        default:
            fatalError("unreachable")
        }
    }

    private func direction(of angle: Angle) -> Vector2D {
        Vector2D(cos(angle.radians), sin(angle.radians))
    }

    private func arcCut(center: Vector2D, radius: Double) -> any Geometry3D {
        // Both side centres as seen from the arc centre, ordered the short way round.
        let angles = sides.map { side -> Angle in
            let v = Tile.apothem * side.direction - center
            return Angle(radians: atan2(v.y, v.x))
        }
        var start = angles[0], end = angles[1]
        var span = end - start
        while span > 180° { span = span - 360° }
        while span <= -180° { span = span + 360° }
        if span < 0° { swap(&start, &end); span = -span }
        return Track.profile
            .translated(x: radius, y: Track.centerHeight)
            .revolved(in: (start - Track.arcMargin)..<(start + span + Track.arcMargin))
            .translated(x: center.x, y: center.y)
    }

    private var straightCut: any Geometry3D {
        let length = 2 * Tile.circumradius + 10
        return Track.profile
            .extruded(height: length)
            .translated(z: -length / 2)
            .rotated(x: 90°)
            .rotated(z: from.angle - 90°)
            .translated(z: Track.centerHeight)
    }
}

// MARK: - Rail slots

/// Pockets that the hooks of the standard Gravitrax rails clip into.
enum RailSlot {
    static let width = 3.7
    static let offset = 4.9            // from the side's centre line, along the face
    static let endCenter = 24.0        // x of the pocket's rounded inner end, +X side
    static let floor = 1.0
    static let lipInside = 29.0        // the lip fills x 29...30 up to `lipHeight`
    static let lipHeight = 2.8
    static let ceiling = Track.centerHeight

    static var pair: any Geometry3D {
        Union {
            for y in [-offset, offset] {
                Circle(radius: width / 2)
                    .translated(x: endCenter, y: y)
                    .adding {
                        Rectangle(x: lipInside - endCenter, y: width)
                            .translated(x: endCenter, y: y - width / 2)
                    }
                    .extruded(height: ceiling - floor)
                    .translated(z: floor)
                Rectangle(x: Tile.apothem + 2 - (lipInside - 1), y: width)
                    .translated(x: lipInside - 1, y: y - width / 2)
                    .extruded(height: ceiling - lipHeight)
                    .translated(z: lipHeight)
            }
        }
    }

    static func pockets(on side: Side) -> any Geometry3D {
        pair.rotated(z: side.angle)
    }
}

// MARK: - Foot

/// The hex plug glued into a groove in the tile's underside: a ring that sits in the
/// groove, with six tabs that protrude below the tile.
enum Foot {
    static let outerApothem = 15.5      // 31 mm across flats
    static let innerApothem = 11.5      // 23 mm across flats
    static let cornerRadius = 2.0
    static let ringHeight = 2.0
    static let chamfer = 0.4
    static let tabInner = 12.75
    static let tabThickness = 2.0
    static let tabLength = 11.836
    static let tabHeight = 3.0

    static let grooveClearance = 0.05
    static let grooveDepth = ringHeight

    /// Ring on the bottom, tabs up — the orientation it is printed in.
    static func part(tolerance: Double = 0) -> any Geometry3D {
        hexagon(apothem: outerApothem - tolerance, cornerRadius: cornerRadius)
            .subtracting { hexagon(apothem: innerApothem + tolerance) }
            .extruded(height: ringHeight, bottomEdge: .chamfer(depth: chamfer))
            .adding {
                Rectangle(x: tabThickness, y: tabLength)
                    .translated(x: tabInner, y: -tabLength / 2)
                    .extruded(height: tabHeight)
                    .translated(z: ringHeight)
                    .repeated(around: .z, count: 6)
            }
    }

    static var groove: any Geometry3D {
        hexagon(apothem: outerApothem + grooveClearance)
            .subtracting { hexagon(apothem: innerApothem - grooveClearance, cornerRadius: cornerRadius) }
            .extruded(height: grooveDepth)
    }
}

// MARK: - The tile

func tile(tracks: [Track]) -> any Geometry3D {
    let sides = Set(tracks.flatMap(\.sides))
    return Tile.blank.subtracting {
        Union(tracks.map(\.cut))
        Foot.groove
        Union(sides.map { RailSlot.pockets(on: $0) })
    }
}
