// An adapter for a Hubelino marble machine: a curved web on an axle, a paddle
// end cut at 30°, and a blind hole for the steel spring that replaced the
// printed one. Change a number at the top and the preview follows.

$fn=200;
axleHeight=17.5;

webLength    = 18.5;  // arc length of the centreline
webRadius    = 45;    // radius of the centreline
webWall      = 3;     // wall thickness
webHeight    = 5.5;   // height; 11.5 mm is clear between the axle collars
webAngle     = webLength/webRadius*180/PI;

springLength = 28;         // the printed spring, kept because it aims the hole
springRadius = 60;
springStart  = 30;         // start angle against the web's tangent
springOffset = 2;          // where it branches off, as arc length along the web
springWall   = 1.4;
springHeight = webHeight;
filletRadius = 0.6;        // fillet at the branch

endHeight       = 5.5;  // end piece height, independent of webHeight
taperLength     = 6;    // arc length the web tapers over
bevelAngle      = 30;   // bevel on the end piece
endRotation     = 0;    // rotation about the joining edge, negative = clockwise
endAnchorRadius = webRadius+webWall/2; // radius the joining edge lies on
endOverlap      = 0.5;  // how far the end piece sinks in; 0 tears open on export
endChamfer      = 1.5;  // chamfer on the outer corner (12,12)

// Blind hole for the steel spring, aimed at the free end the printed spring had.
holeDiameter      = 5;
holeDepth         = 2.5;
pinDiameter       = 3;          // centring pin, fits the spring's inner diameter
pinLength         = holeDepth;
holeEntryDistance = 6.93;       // entry, measured from (0,12) along the bevel

function rot2(p, a) = [p[0]*cos(a)-p[1]*sin(a), p[0]*sin(a)+p[1]*cos(a)];

function springEnd() =
    let(t  = springLength/springRadius*180/PI,
        p  = rot2([springRadius*(1-cos(t)), springRadius*sin(t)], springStart),
        branchAngle = springOffset/webRadius*180/PI)
    rot2([p[0]-webRadius, p[1]], -branchAngle) + [webRadius, 0];

// The same chain as the call at the bottom, in two dimensions.
function endToWorld(p) =
    rot2(rot2([p[0]-12*tan(bevelAngle), p[1]-endOverlap],
              180+endRotation) + [endAnchorRadius, 0],
         180-webAngle) + [webRadius, 0];

holeEntry  = [holeEntryDistance*sin(bevelAngle), 12-holeEntryDistance*cos(bevelAngle)];
holeTarget  = springEnd() - endToWorld(holeEntry);
holeDirection = atan2(holeTarget[1], holeTarget[0]) - (endRotation-webAngle) + 180;      // +180: into the material

module axle(h=axleHeight) {
    w=8;
    d=2;

    cylinder(d=3, h=h);

    translate([0,0,h-w-d])
    cylinder(d=4.5, h=w);

    translate([0,0,d])
    cylinder(d=4.5, h=w);
}

// The arc starts on the axle (0,0) and runs towards +y.
module web(length=webLength, r=webRadius, w=webWall, h=webHeight) {
    angle = length/r*180/PI;

    translate([r, 0, axleHeight/2-h/2])
    rotate([0, 0, 180-angle])
    rotate_extrude(angle=angle, $fn=500)
    translate([r-w/2, 0])
    square([w, h]);
}

// The web again, thinner and more tightly curved, branching off it.
module spring(length=springLength, r=springRadius, w=springWall, h=springHeight,
              start=springStart, branchOffset=springOffset) {
    branchAngle = branchOffset/webRadius*180/PI;

    translate([webRadius, 0, 0])
    rotate([0, 0, -branchAngle])
    translate([-webRadius, 0, 0])
    rotate([0, 0, start])
    web(length, r, w, h);
}

// Tapers the web to endHeight at the paddle end, with two inclined planes. Limited to
// the web's width in x so the spring is untouched.
module taperCut(len=taperLength) {
    alpha = atan((webHeight-endHeight)/2/len);

    // 0.1 mm proud of the paddle: flush would make the top faces coincident,
    // and that is a non-manifold edge.
    module wedge() {
        translate([0, 0, endHeight/2+0.1])
        rotate([alpha, 0, 0])
        translate([-4, 0, 0])
        cube([8, 40, 20]);
    }

    translate([webRadius, 0, axleHeight/2])
    rotate([0, 0, 180-webAngle])
    translate([webRadius, 0, 0]) {
        wedge();
        mirror([0, 0, 1]) wedge();
    }
}

// Web and spring as one body: both are prisms of the same height, so the fillet
// is done in the 2D section — offset(+r) then offset(-r) fills concave corners
// and leaves convex ones alone.
//
// This replaces web() and spring(); it is NOT unioned with them. Two
// polygonisations of the same arcs on top of each other (rotate_extrude vs.
// projection+offset) gave sliver faces — 291 non-manifold edges on export.
module webAndSpring(r=filletRadius) {
    difference() {
        translate([0, 0, axleHeight/2-webHeight/2])
        linear_extrude(webHeight)
        offset(r=-r) offset(r=r)
        projection() {
            web();
            //spring();
        }

        if (webHeight > endHeight) taperCut();
    }
}

module endPiece(angle=30, h=6, lipThickness=1.2, lipHeight=1.2, lipLength=11.3, lipOffset=0, chamfer=endChamfer) {
    bevel = 12/cos(angle);
    lipY   = lipLength*cos(angle);
    offsetY = lipOffset*cos(angle);

    cutoutX = 21;                     // cylindrical cutout on the right
    cutoutY = 4;
    cutoutDiameter = 20;
    cutoutEnd = cutoutY + sqrt(pow(cutoutDiameter/2, 2) - pow(12-cutoutX, 2));  // where it leaves x=12

    difference() {
        cube([12, 12, h]);

        translate([0, 12, 0])          // pivot = top left corner
        rotate([0, 0, angle])
        translate([-12, -20, -1])
        cube([12, 20, h+2]);

	   translate([cutoutX, cutoutY, 0])
	    	cylinder(d=cutoutDiameter, h=20);

        // Chamfer from where the cutout leaves x=12 to `chamfer` short of the corner.
        translate([0, 0, -1])
        linear_extrude(h+2)
        polygon([[12-chamfer, 12], [12, cutoutEnd], [14, cutoutEnd], [14, 14], [12-chamfer, 14]]);

        // Starts 2 mm in front of the face so the angled mouth breaks out cleanly.
        translate([holeEntry[0], holeEntry[1], h/2])
        rotate([0, 0, holeDirection])
        rotate([0, 90, 0])
        translate([0, 0, -2])
        cylinder(d=holeDiameter, h=holeDepth+2);
    }

    // Centring pin, after the difference() because it projects out of the hole.
    // The +1 sinks its foot into solid material: ending flush on the bottom of
    // the hole made the faces coplanar and the solid genus 17 instead of 0.
    translate([holeEntry[0], holeEntry[1], h/2])
    rotate([0, 0, holeDirection])
    rotate([0, 90, 0])
    translate([0, 0, holeDepth-pinLength])
    cylinder(d=pinDiameter, h=pinLength+1);

    // Lip along the bevel, above and below, trimmed parallel to the back.
    for (z = [-lipHeight, h])
    intersection() {
        translate([0, 12, 0])
        rotate([0, 0, angle])
        translate([0, -bevel, z])
        cube([lipThickness, bevel, lipHeight]);

        translate([0, 12-offsetY-lipY, z])
        cube([12, lipY, lipHeight]);
    }
}

axle();

webAndSpring();

// The front corner of the bevel falls on the joining edge of the web's end face.
translate([webRadius, 0, axleHeight/2-endHeight/2])
rotate([0, 0, 180-webAngle])
translate([endAnchorRadius, 0, 0])
rotate([0, 0, 180])
rotate([0, 0, endRotation])
translate([-12*tan(bevelAngle), -endOverlap, 0])
endPiece(angle=bevelAngle, h=endHeight);
