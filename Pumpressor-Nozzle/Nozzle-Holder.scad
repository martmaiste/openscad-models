/*
 * Nozzle holder strip (standalone)
 * --------------------------------
 * 4 through-threaded ACME holes, hole centers 50 mm apart, strip
 * 15 mm thick, rounded outer ends, chamfered outer edges. The
 * threaded holes are open on both faces and get a 45° lead-in
 * chamfer on each side.
 *
 * 3 mounting holes (Ø4 through) sit between each pair of threaded
 * holes, with Ø9 x 4 mm counterbores for round bolt heads on both
 * faces. The bottom counterbore stays fully open; only the Ø4 bore is
 * capped by a thin sacrificial membrane just above the counterbore
 * floor, so the hole can be printed without supports and the membrane
 * is poked out after printing.
 *
 * ACME thread geometry (self-contained, same construction as
 * acme_nut.scad): trapezoidal grooves with 29° included flank angle
 * are cut outward from a bore of diameter major_d - 2*thread_h.
 */

// ---------- Thread parameters ----------
pitch          = 3.5;    // thread step (axial distance between flanks)
major_d        = 23;     // thread OD = major diameter of the internal thread
thread_h       = 1.0;    // thread height (radial depth of groove)
groove_w       = 2.0;    // thread width: groove opening width at the bore
flank_angle    = 14.5;   // half of ACME 29° included angle

// ---------- Fit clearance ----------
clear_r        = 0.15;   // radial clearance (print-in-place / fit)
clear_a        = 0.2;    // axial (flank) clearance

// ---------- Thread derived ----------
minor_d        = major_d - 2 * thread_h;
tan_f          = tan(flank_angle);
r_bore         = minor_d / 2;
r_major        = major_d / 2;

// ---------- Strip parameters ----------
n_holes     = 4;
hole_pitch  = 50;      // center-to-center distance between holes
strip_t     = 15;      // strip thickness (Z)
edge_cham   = 1.5;     // chamfer on outer perimeter edges
hole_cham   = 1.5;     // 45° lead-in chamfer on hole edges, both faces
end_margin  = 2;       // material ring beyond thread major dia at the ends

// mounting holes (between each pair of threaded holes)
mount_d        = 4.0;  // mounting hole through-bore diameter
mount_cb_d     = 9.0;  // counterbore dia for round bolt head
mount_cb_dep   = 4.0;  // counterbore depth, on each face
mount_bore_ch  = 0.8;  // 45° chamfer on bore edges at counterbore floors
mount_cb_ch    = 0.8;  // 45° chamfer on head-bore openings at outer surfaces
mount_sacrif_t = 0.6;  // sacrificial membrane thickness left across the
                       // Ø4 bore just above the bottom counterbore floor
                       // (0 = plain through hole)

// derived
end_r       = r_major + 4 + end_margin;              // radius of rounded ends
half_span   = (n_holes - 1) * hole_pitch / 2;        // outer hole centers from origin
hole_x      = [ for (i = [0 : n_holes - 1]) -half_span + i * hole_pitch ];

$fa = 3;
$fs = 0.3;

// ---------- Cutter profile ----------
// Trapezoid of the male-thread ridge (used as boolean cutter).
// Points are [radius, axial_half_width]; width shrinks with radius.
module thread_profile() {
    r0 = r_bore - 0.25;                       // embed slightly into core
    r1 = r_major + clear_r;                   // crest (slight overshoot)
    // width at radius r: groove_w + 2*clear_a - 2*(r - r_bore)*tan_f
    w_at = function(r) (groove_w + 2 * clear_a) - 2 * (r - r_bore) * tan_f;
    w0v  = w_at(r0);
    w1v  = max(w_at(r1), 0.15);               // keep a small crest flat
    polygon([
        [r0, -w0v / 2],
        [r1, -w1v / 2],
        [r1,  w1v / 2],
        [r0,  w0v / 2],
    ]);
}

// ---------- Helical thread ridge ----------
module helix_thread(pitch, length, segs_per_turn = 90) {
    n = ceil(length / pitch * segs_per_turn);
    // thin extrusion: pure rotation of a flat 2D polygon would be
    // deleted by OpenSCAD as a degenerate (zero-thickness) object
    for (i = [0 : n - 1])
        hull() {
            translate([0, 0, i * pitch / segs_per_turn])
                rotate([0, 0, i * 360 / segs_per_turn])
                    rotate([90, 0, 0])
                        linear_extrude(height = 0.01, center = true) thread_profile();
            translate([0, 0, (i + 1) * pitch / segs_per_turn])
                rotate([0, 0, (i + 1) * 360 / segs_per_turn])
                    rotate([90, 0, 0])
                        linear_extrude(height = 0.01, center = true) thread_profile();
        }
}

// ---------- 2D footprint: stadium shape ----------
module strip_footprint() {
    hull() {
        translate([-half_span, 0]) circle(r = end_r);
        translate([ half_span, 0]) circle(r = end_r);
    }
}

// ---------- Body with chamfered top/bottom perimeter edges ----------
// Hull a shrunken footprint at each face with the full footprint inset
// by the chamfer: gives straight walls + chamfers top and bottom.
module strip_body() {
    c = edge_cham;
    hull() {
        // chamfered bottom edge
        linear_extrude(height = 0.01)
            offset(r = -c) strip_footprint();
        // straight wall section
        translate([0, 0, c])
            linear_extrude(height = strip_t - 2 * c)
                strip_footprint();
        // chamfered top edge
        translate([0, 0, strip_t])
            linear_extrude(height = 0.01)
                offset(r = -c) strip_footprint();
    }
}

// ---------- One ACME threaded-hole cutter ----------
// Core cylinder + helical ridge, running past both faces of the strip.
module hole_cutter() {
    extra   = pitch;
    h_total = strip_t + 2 * extra;
    rc      = r_bore + clear_r;
    ch      = hole_cham;
    union() {
        cylinder(h = h_total, d = 2 * rc, center = true);
        translate([0, 0, -h_total / 2 + extra])
            helix_thread(pitch, h_total);
        // 45° lead-in chamfers on both faces (extend past the face so
        // the cone cuts the full edge)
        translate([0, 0, -strip_t / 2 - 0.5])
            cylinder(h = ch + 0.5, r1 = rc + ch + 0.5, r2 = rc);
        translate([0, 0, strip_t / 2 - ch])
            cylinder(h = ch + 0.5, r1 = rc, r2 = rc + ch + 0.5);
    }
}

// midpoints between adjacent threaded holes
mount_x = [ for (i = [0 : n_holes - 2]) (hole_x[i] + hole_x[i + 1]) / 2 ];

// ---------- Final strip ----------
module strip_solid() {
    difference() {
        strip_body();
        for (x = hole_x)
            translate([x, 0, strip_t / 2])
                hole_cutter();
    }
}

module strip_with_mounts() {
    difference() {
        strip_solid();
        for (x = mount_x)
            translate([x, 0, strip_t / 2]) {
                // bore: starts at the sacrificial membrane just above
                // the bottom counterbore floor and cuts through the top
                // (with mount_sacrif_t = 0 this is a plain through bore)
                translate([0, 0, -strip_t / 2 + mount_cb_dep + mount_sacrif_t])
                    cylinder(h = strip_t + 4, d = mount_d);
                // 45° chamfers on the bore edges at both counterbore
                // floors (bottom one sits on the membrane above the floor)
                translate([0, 0, strip_t / 2 - mount_cb_dep - mount_bore_ch])
                    cylinder(h = mount_bore_ch,
                             r1 = mount_d / 2,
                             r2 = mount_d / 2 + mount_bore_ch);
                // the bottom floor chamfer is wider than the bore at
                // every height, so it would cut the membrane away and is
                // only kept for a plain through hole
                if (mount_sacrif_t == 0)
                    translate([0, 0, -strip_t / 2 + mount_cb_dep])
                        cylinder(h = mount_bore_ch,
                                 r1 = mount_d / 2 + mount_bore_ch,
                                 r2 = mount_d / 2);
                // 45° chamfers on the head-bore openings at the outer
                // surfaces (extend past the face to cut the full edge)
                translate([0, 0, -strip_t / 2 - 0.5])
                    cylinder(h = mount_cb_ch + 0.5,
                             r1 = mount_cb_d / 2 + mount_cb_ch + 0.5,
                             r2 = mount_cb_d / 2);
                translate([0, 0, strip_t / 2 - mount_cb_ch])
                    cylinder(h = mount_cb_ch + 0.5,
                             r1 = mount_cb_d / 2,
                             r2 = mount_cb_d / 2 + mount_cb_ch + 0.5);
                // head counterbores, both faces (extend 0.5 mm past the
                // face so the boolean doesn't leave a flush sliver
                // layer; the bottom one stops short of the floor by the
                // membrane thickness)
                translate([0, 0, -strip_t / 2 - 0.5])
                    cylinder(h = mount_cb_dep + 0.5 - mount_sacrif_t,
                             d = mount_cb_d);
                translate([0, 0, strip_t / 2 - mount_cb_dep])
                    cylinder(h = mount_cb_dep + 0.5, d = mount_cb_d);
            }
    }
}

render_strip = 1;
if (render_strip) strip_with_mounts();
