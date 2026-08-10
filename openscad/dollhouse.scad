// A dollhouse at 1:12, the same editing loop as bracket.scad and three orders
// of magnitude bigger: a metre of house in millimetres, cut from sheet stock.
//
// It is here for the size. A bracket fits in the preview whatever you do to it;
// this one has to be framed, and every number is load-bearing — move the ridge
// and two roof panels, a mitre and an attic wall all follow.
//
// Sheet goods, so the model is built the way it would be cut:
//   - carcass of 18 mm birch ply
//   - 8 mm back panel, screwed on behind, no groove to rout
//   - roof mitred at the ridge, flush over the back panel
//   - windows in the side walls, arched doorways in the partitions
//
// X = width, Y = depth, Z = height. Origin at the front left corner of the
// base. Everything in millimetres.

/* [Stock] */
t          = 18;        // carcass ply
back_t     = 8;         // back panel

/* [Outside] */
W          = 900;       // outside width
D          = 450;       // carcass depth, back panel not counted
wall_l_h   = 900;       // left side wall, above the base
wall_r_h   = 820;       // right side wall — deliberately the shorter one

/* [Storeys] */
h_ground   = 320;       // clear height, ground floor
h_first    = 300;       // clear height, first floor

/* [Roof] */
// The ridge is not a given number: pick where it sits and how steep the left
// side is, and the right pitch is whatever reaches the lower wall.
ridge_x    = 340;       // ridge position, measured from the left
pitch_l    = 45;        // pitch of the left roof, degrees
overhang   = 110;       // eaves overhang, measured along the slope
back_over  = 0;         // extra roof behind the back panel

/* [Partitions] */
div_depth  = 400;       // depth of the upright partitions
room_g_l   = 460;       // clear room width, ground floor left
room_f_l   = 240;       // clear room width, first floor left
room_a_l   = 560;       // clear room width, attic left

/* [Doorways] */
arch_w     = 220;       // width, in Y
arch_h     = 270;       // total height including the round top

/* [Windows] */
win_w      = 140;       // width, in Y — across the depth of the house
win_h      = 150;       // height
win_sill   = 70;        // sill above the floor it stands on
win_arched = false;     // true = round top, to match the doorways
win_ground = true;
win_first  = true;
win_attic  = true;      // left always; right only if that wall is tall enough

/* [View] */
explode    = 0;         // 0 = assembled, 150 = exploded
show_back  = true;
show_roof  = true;

$fn = 64;

// =====================================================================
// Derived
// =====================================================================

w_in   = W - 2*t;           // clear inside width
x_in   = t;                 // inside face of the left wall

z_base   = 0;               // base, full width
z_ground = t;               // top of the base = ground floor
z_d2     = z_ground + h_ground;
z_first  = z_d2 + t;
z_d3     = z_first + h_first;
z_attic  = z_d3 + t;

top_l  = t + wall_l_h;      // top edge of the left wall
top_r  = t + wall_r_h;      // top edge of the right wall

roof_depth = D + back_t + back_over;   // the roof covers the back panel too

// --- Pitches. The left one is given; the right one falls out of it. ---
ridge_z = top_l + ridge_x * tan(pitch_l);

dx_l    = ridge_x;
dz_l    = ridge_z - top_l;
len_l   = sqrt(dx_l*dx_l + dz_l*dz_l);

dx_r    = W - ridge_x;
dz_r    = ridge_z - top_r;
pitch_r = atan2(dz_r, dx_r);
len_r   = sqrt(dx_r*dx_r + dz_r*dz_r);

panel_l = len_l + overhang;   // small panel, left, on the underside
panel_r = len_r + overhang;   // large panel, right

angle_ridge   = 180 - pitch_l - pitch_r;
angle_eaves_l = 90 + pitch_l;
angle_eaves_r = 90 + pitch_r;

// --- Mitre plane at the ridge: the bisector of the two roof planes ---
bx_  = cos(pitch_r) - cos(pitch_l);
bz_  = -(sin(pitch_l) + sin(pitch_r));
bl_  = sqrt(bx_*bx_ + bz_*bz_);
bxn  = bx_ / bl_;
bzn  = bz_ / bl_;
mitre = atan2(-bxn, -bzn);          // tilt of the mitre plane off vertical
blade = 90 - angle_ridge/2;         // blade tilt to set on the saw

// Normal of the mitre plane, pointing towards +x
nx_ = -bzn;
nz_ =  bxn;

// Where a line crosses the mitre plane, parameter s from (ex, ez)
function s_ridge(ex, ez, dx, dz) =
    ((ridge_x - ex)*nx_ + (ridge_z - ez)*nz_) / (dx*nx_ + dz*nz_);

// Eaves corners of the undersides
ex_l = ridge_x - cos(pitch_l)*panel_l;
ez_l = ridge_z - sin(pitch_l)*panel_l;
ex_r = ridge_x + cos(pitch_r)*panel_r;
ez_r = ridge_z - sin(pitch_r)*panel_r;

// Cut length = the longer of the two edges once the mitre is taken off
sl_low = s_ridge(ex_l, ez_l, cos(pitch_l), sin(pitch_l));
sl_up  = s_ridge(ex_l - t*sin(pitch_l), ez_l + t*cos(pitch_l), cos(pitch_l), sin(pitch_l));
sr_low = s_ridge(ex_r, ez_r, -cos(pitch_r), sin(pitch_r));
sr_up  = s_ridge(ex_r + t*sin(pitch_r), ez_r + t*cos(pitch_r), -cos(pitch_r), sin(pitch_r));

cut_l = max(sl_low, sl_up);
cut_r = max(sr_low, sr_up);

// Outside height over the ridge
ridge_outside = ridge_z + t / cos((pitch_l + pitch_r)/2);

// Room widths on the other side of each partition
room_g_r = w_in - room_g_l - t;
room_f_r = w_in - room_f_l - t;
room_a_r = w_in - room_a_l - t;

x_div_a = x_in + room_a_l;

// Underside of the roof at x
function roof_z(x) = (x <= ridge_x)
    ? top_l + x * tan(pitch_l)
    : top_r + (W - x) * tan(pitch_r);

div_h_a   = roof_z(x_div_a) - z_attic;
div_h_a_r = roof_z(x_div_a + t) - z_attic;   // other face, the roof has moved

win_top = win_sill + win_h;

// Does a window still fit under the low right wall in the attic?
// (20 mm of material over the head is the least worth cutting.)
attic_r_fits = (z_attic + win_top) <= (top_r - 20);

// =====================================================================
// Parts
// =====================================================================

module base_floor()  cube([W, D, t]);
module inner_floor() cube([w_in, D, t]);

// Everything above the two roof planes — used to take the tops off walls
module above_roof() {
    translate([ridge_x, -10, ridge_z]) {
        rotate([0, -pitch_l, 0]) translate([-3000, 0, 0]) cube([3000, roof_depth + 20, 3000]);
        rotate([0,  pitch_r, 0])                          cube([3000, roof_depth + 20, 3000]);
    }
}

// A window, cut through the full thickness of a side wall
module window_cut(z_floor) {
    r  = win_w / 2;
    y0 = (D - win_w) / 2;
    z0 = z_floor + win_sill;
    translate([t + 1, y0, z0])
        rotate([0, -90, 0])
            linear_extrude(t + 2)
                if (win_arched)
                    union() {
                        square([win_h - r, win_w]);
                        translate([win_h - r, r]) circle(r);
                    }
                else
                    square([win_h, win_w]);
}

module side_wall(x, is_left) {
    difference() {
        translate([x, 0, t]) cube([t, D, ridge_z - t]);
        above_roof();
        translate([x, 0, 0]) {
            if (win_ground) window_cut(z_ground);
            if (win_first)  window_cut(z_first);
            if (win_attic && (is_left || attic_r_fits)) window_cut(z_attic);
        }
    }
}

// The doorway, as a negative
module archway(z0) {
    r  = arch_w / 2;
    y0 = (D - div_depth) + (div_depth - arch_w) / 2;
    translate([t + 1, y0, z0])
        rotate([0, -90, 0])
            linear_extrude(t + 2)
                union() {
                    square([arch_h - r, arch_w]);
                    translate([arch_h - r, r]) circle(r);
                }
}

// to_roof = true: the top is taken off by the roof, as in the attic.
// Otherwise the part stops dead under the floor above.
module divider(x, z0, h, arched = true, to_roof = false) {
    difference() {
        translate([x, D - div_depth, z0])
            cube([t, div_depth, to_roof ? h + 60 : h]);
        if (arched)  translate([x, 0, 0]) archway(z0);
        if (to_roof) above_roof();
    }
}

// The two half-spaces either side of the mitre plane
module past_ridge_right() {
    translate([ridge_x, -10, ridge_z]) rotate([0, mitre, 0])
        translate([0, 0, -3000]) cube([3000, roof_depth + 20, 6000]);
}
module past_ridge_left() {
    translate([ridge_x, -10, ridge_z]) rotate([0, mitre, 0])
        translate([-3000, 0, -3000]) cube([3000, roof_depth + 20, 6000]);
}

module roof_left() {
    difference() {
        translate([ridge_x, 0, ridge_z]) rotate([0, -pitch_l, 0])
            translate([-panel_l, 0, 0]) cube([panel_l + 60, roof_depth, t]);
        past_ridge_right();
    }
}

module roof_right() {
    difference() {
        translate([ridge_x, 0, ridge_z]) rotate([0, pitch_r, 0])
            translate([-60, 0, 0]) cube([panel_r + 60, roof_depth, t]);
        past_ridge_left();
    }
}

module back_panel() {
    translate([0, D + back_t, 0]) rotate([90, 0, 0])
        linear_extrude(back_t)
            polygon([[0, 0], [W, 0], [W, top_r], [ridge_x, ridge_z], [0, top_l]]);
}

// =====================================================================
// Assembly
// =====================================================================

module dollhouse() {
    color("BurlyWood") {
        translate([0, 0, z_base])              base_floor();
        translate([x_in, 0, z_d2 + explode])   inner_floor();
        translate([x_in, 0, z_d3 + 2*explode]) inner_floor();

        translate([-explode, 0, 0]) side_wall(0,     true);
        translate([ explode, 0, 0]) side_wall(W - t, false);
    }

    color("Tan") {
        divider(x_in + room_g_l, z_ground, h_ground);
        translate([0, 0, explode])   divider(x_in + room_f_l, z_first, h_first);
        translate([0, 0, 2*explode]) divider(x_div_a, z_attic, div_h_a, true, true);
    }

    if (show_roof)
        color("Sienna") translate([0, 0, 3*explode]) {
            roof_left();
            roof_right();
        }

    if (show_back)
        color("Peru", 0.85) translate([0, explode, 0]) back_panel();
}

dollhouse();

// =====================================================================
// Cut list, in the console
// =====================================================================

echo();
echo("=============== DOLLHOUSE — CUT LIST ===============");
echo(str("stock, carcass / back    : ", t, " / ", back_t, " mm"));
echo(str("outside, W x D           : ", W, " x ", D + back_t, " mm"));
echo(str("ridge, inside / outside  : ", ridge_z, " / ", ridge_outside, " mm"));
echo(str("clear inside width       : ", w_in, " mm"));
echo();
echo("--- floors ---");
echo(str("base, full width         : ", W, " x ", D, " mm"));
echo(str("two inner floors         : ", w_in, " x ", D, " mm  <-- not the full ", W));
echo();
echo("--- side walls ---");
echo(str("left                     : ", wall_l_h, " x ", D, " mm, top at z = ", top_l));
echo(str("right                    : ", wall_r_h, " x ", D, " mm, top at z = ", top_r));
echo();
echo(str("--- partitions, ", div_depth, " mm deep ---"));
echo(str("ground : ", h_ground, " mm  at x = ", x_in + room_g_l));
echo(str("first  : ", h_first,  " mm  at x = ", x_in + room_f_l));
echo(str("attic  : ", div_h_a, " mm left / ", div_h_a_r, " mm right, at x = ", x_div_a));
echo();
echo("--- rooms, clear widths ---");
echo(str("ground : ", room_g_l, " + ", t, " + ", room_g_r, " = ", room_g_l + t + room_g_r));
echo(str("first  : ", room_f_l, " + ", t, " + ", room_f_r, " = ", room_f_l + t + room_f_r));
echo(str("attic  : ", room_a_l, " + ", t, " + ", room_a_r, " = ", room_a_l + t + room_a_r));
echo();
echo("--- roof ---");
echo(str("small panel, left        : ", cut_l, " x ", roof_depth, " mm"));
echo(str("large panel, right       : ", cut_r, " x ", roof_depth, " mm"));
echo(str("pitch, left / right      : ", pitch_l, " / ", pitch_r, " deg"));
echo(str("ridge angle              : ", angle_ridge, " deg"));
echo(str("mitre, each panel        : ", blade, " deg of blade tilt"));
echo(str("eaves, left / right      : ", angle_eaves_l, " / ", angle_eaves_r, " deg"));
echo(str("overhang                 : ", overhang, " mm along the slope"));
echo();
echo("--- windows ---");
echo(str("size                     : ", win_w, " x ", win_h, " mm",
         win_arched ? ", round top" : ", square"));
echo(str("in Y                     : ", (D - win_w)/2, " .. ", (D + win_w)/2,
         " mm from the front"));
echo(str("sill                     : ", win_sill, " mm over the floor"));
echo(str("how many                 : ", (win_ground ? 2 : 0) + (win_first ? 2 : 0)
                                      + (win_attic ? (attic_r_fits ? 2 : 1) : 0)));
echo();
echo("--- heights ---");
echo(str("ground  ", z_ground, " .. ", z_d2, "  = ", h_ground, " mm"));
echo(str("first   ", z_first,  " .. ", z_d3, "  = ", h_first,  " mm"));
echo(str("attic   from ", z_attic, ", clear at the left wall ", top_l - z_attic,
         ", right ", top_r - z_attic));
echo();
echo("--- does it hold together ---");
if (ridge_z <= top_r)
    echo("ERROR: the ridge is not above the right wall — lower pitch_l or move ridge_x");
if (ridge_x <= t || ridge_x >= W - t)
    echo("ERROR: the ridge is outside the walls");
if (room_g_l + t + room_g_r != w_in) echo("ERROR: ground floor rooms do not fit the width");
if (room_f_l + t + room_f_r != w_in) echo("ERROR: first floor rooms do not fit the width");
if (room_a_l + t + room_a_r != w_in) echo("ERROR: attic rooms do not fit the width");
if (h_ground < arch_h + 20) echo(str("WARNING: only ", h_ground - arch_h, " mm over the ground floor doorway"));
if (h_first  < arch_h + 20) echo(str("WARNING: only ", h_first  - arch_h, " mm over the first floor doorway"));
if (div_depth > D) echo("ERROR: the partitions are deeper than the carcass");
if (arch_w > div_depth - 40) echo("WARNING: little material beside the doorway");
if (win_w > D - 60) echo("WARNING: wide window, not much edge front or back");
if (win_ground && z_ground + win_top > z_d2) echo("ERROR: the ground floor window runs into the floor above");
if (win_first  && z_first  + win_top > z_d3) echo("ERROR: the first floor window runs into the floor above");
if (win_attic  && z_attic  + win_top > top_l) echo("ERROR: the attic window runs over the left wall");
if (win_attic && !attic_r_fits)
    echo(str("NOTE: no attic window on the right — that wall ends ", top_r - z_attic,
             " mm over the floor and the window needs ", win_top));
echo("====================================================");
