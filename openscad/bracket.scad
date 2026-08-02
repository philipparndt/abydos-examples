// A bracket, parametric enough to be worth editing.
//
// The point of this example is the loop: change a number, save, and watch the
// preview follow. Everything here is one file so there is nothing to set up.

thickness   = 4;      // wall thickness
width       = 40;     // across the face
height      = 60;     // up the wall
depth       = 35;     // out from the wall
hole        = 5.2;    // for an M5 screw
fillet      = 6;      // corner radius

module plate(w, h, t, r) {
    hull() {
        for (x = [r, w - r], y = [r, h - r])
            translate([x, y, 0]) cylinder(h = t, r = r, $fn = 32);
    }
}

module holes(w, h) {
    inset = hole * 1.6;
    for (x = [inset, w - inset], y = [inset, h - inset])
        translate([x, y, -1]) cylinder(h = 20, d = hole, $fn = 24);
}

module bracket() {
    difference() {
        union() {
            plate(width, height, thickness, fillet);
            rotate([-90, 0, 0])
                translate([0, 0, -thickness])
                    plate(width, depth, thickness, fillet);
            // The gusset that stops it folding.
            translate([width / 2 - thickness / 2, 0, 0])
                rotate([0, -90, 0])
                    linear_extrude(thickness)
                        polygon([[0, 0], [height * 0.7, 0], [0, depth * 0.7]]);
        }
        holes(width, height);
        rotate([-90, 0, 0]) translate([0, 0, -thickness - 1]) holes(width, depth);
    }
}

bracket();
