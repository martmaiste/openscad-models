// =========================================================================
// Parametric SUP Nozzle Adapters
// File: SUP-Nozzle/SUP-Nozzle.scad
// Version: v0.04
// Date: 2026-10-18
// Description: Modular parametric OpenSCAD model of nozzle adapters that
//              connect a shared threaded air line to inflatable gear:
//
//   sup_adapter()    - Standard SUP pump male bayonet (Halkey-Roberts) to
//                      threaded nozzle (original v0.01 design).
//   boston_adapter() - Boston straight tapered barrel (20mm long, 17mm OD
//                      at the tip, 18.11mm OD at the base, same 1:18 taper
//                      ratio; chamfered tip edges) to threaded nozzle.
//
//              All adapters share the same threaded end (with a 16mm x 2mm
//              counterbore at its open end, ending in a 45-degree transition
//              into the main bore) and the original wide grip lip
//              (collar) with chamfered top and bottom edges, optional grip
//              ribs and optional lanyard ears, between the
//              thread and the nozzle, so they all fit the same air line. The 20mm seal seat neck is part of the
//              SUP nozzle only. Choose which adapter to render with the
//              `adapter` setting below ("sup", "boston", or "both" for a
//              side-by-side preview).
//              Layout convention: threaded end points down (-Z), the valve
//              side points up (+Z).
// =========================================================================

/* [General Settings] */
// Level of detail (number of fragments for curves).
// This is the only $fn setting; no module overrides it.
$fn = 128;

// Which adapter to render: "sup", "boston", or "all"
adapter = "boston";

// Show a vertical section (cutaway) view: keeps only the x >= 0 half so
// the internal bores and counterbore are visible   w
section_view = false;

/* [Shared Threaded Nozzle Settings] */
// Base outer diameter of the thread cylinder (mm)
thread_base_dia = 21.0;
// Length of the threaded portion (mm)
thread_length = 15.0;
// Height of the thread ridge from the base (mm)
thread_height = 1.0;
// Thickness of the thread ridge (mm)
thread_thickness = 1.6;
// Thread step (pitch): axial advance per full turn (mm)
thread_step = 3.5;
// Crest width as a fraction of the ridge width at the surface (0..1).
// 1 = rectangular thread, 0.3 = trapezoid with a crest 30% as wide
thread_crest_ratio = 0.8;
// Internal bore diameter for air passage through the neck/thread (mm)
bore_dia = 14.0;
// Counterbore diameter at the open (tip) end of the thread (mm)
cbore_dia = 16.0;
// Depth of the counterbore before the 45-degree transition into the main bore (mm)
cbore_depth = 2.0;
// Chamfer on the counterbore's open-end edge (mm)
open_cbore_chamfer_h = 0.2;

/* [SUP Adapter Settings (Female 21mm Bayonet Side)] */
// Standard SUP nozzle bayonet outer diameter (mm)
bayonet_outer_dia = 21.0;
// Inner diameter to receive the male hose end (mm)
bayonet_inner_dia = 14.0;
// Total length of the bayonet cylinder section from the lip (mm)
bayonet_length = 24.0;
// Width of the J-slot for locking pins (mm)
slot_width = 6.0;
// Axial depth of the J-slot from the rim (mm)
slot_depth = 13.5;
// Angle of the circumferential rotation for locking (degrees)
slot_angle = 50.0;
// Depth of the small circular locking notch on the ceiling (mm)
notch_depth = 0.5;
// Rounding radius on the sharp convex bayonet edges: rim corners and the
// base step down to the seal neck (mm)
rim_round = 0.8;
// Thickness of the collar / lip (mm)
lip_thickness = 5.0;
// Outer diameter of the lip (absolute, mm). Must stay above the thread
// crest (23mm) so the fingers have clearance when turning it.
lip_dia = 32.0;
// Small chamfer on the lip's top and bottom edges (mm)
lip_chamfer_h = 0.4;
// Draw the vertical grip ribs (false = smooth collar)
grip_ribs = true;
// Number of lanyard ears on the collar (0 = plain round collar,
// 1 = single ear, 2 = two ears opposite each other)
lip_ears_n = 1; // [0, 1, 2]
// Width of each lanyard ear (mm)
lip_ear_width = 12.0;
// Radial length of each lanyard ear beyond the collar surface (mm)
lip_ear_length = 8.0;
// Chamfer on the top and bottom outer edges of each ear (mm)
lip_ear_chamfer_h = 0.4;
// Diameter of the lanyard hole through each ear (mm)
lip_ear_hole_dia = 4.0;
// Chamfer on the top and bottom edges of each lanyard hole (mm)
lip_ear_hole_chamfer_h = 0.4;
// Number of vertical grip ribs around the lip
lip_ribs_n = 24;
// Grip rib diameter (mm)
lip_rib_dia = 1.6;
// Grip rib protrusion beyond the lip surface (mm)
lip_rib_h = 0.6;
// Diameter of the 20mm seal seat neck on the bayonet side (mm)
seal_neck_dia = 20.0;
// Length of the seal seat neck (mm)
seal_neck_length = 4.0;

/* [Boston Adapter Settings (Straight Tapered Barrel)] */
// Total barrel length above the grip lip (mm)
boston_barrel_length = 20.0;
// Barrel outer diameter at the tip (mm)
boston_barrel_tip_dia = 17.0;
// Taper ratio: OD growth per unit length (mm OD per mm length). The
// original 18 mm barrel went 17 -> 18 mm, i.e. 1/18.
boston_barrel_taper_ratio = 1 / 18;
// Barrel outer diameter at the base (grip-lip) end, derived so the taper
// (and thus the profile at any distance from the tip) stays constant when
// the barrel length changes.
boston_barrel_base_dia = boston_barrel_tip_dia
                        + boston_barrel_length * boston_barrel_taper_ratio;
// Small chamfer size on the tip edges: outer rim and bore edge (mm)
boston_tip_chamfer_h = 0.4;

// =========================================================================
// Calculated Parameters
// =========================================================================
// The helix pitch is exactly the step set by the user
thread_pitch = thread_step;

// =========================================================================
// Main Assembly Execution
// =========================================================================
if (adapter == "sup") {
    sectioned() sup_adapter();
} else if (adapter == "boston") {
    sectioned() boston_adapter();
} else if (adapter == "all") {
    translate([-45, 0, 0]) sectioned() sup_adapter();
    translate([45, 0, 0]) sectioned() boston_adapter();
}

// Wraps children in an optional vertical cutaway: intersect with the
// x >= 0 half-space (cut plane contains the Z axis) when section_view
// is enabled.
module sectioned() {
    if (section_view) {
        intersection() {
            children();
            translate([0, -60, -60]) cube([120, 120, 120]);
        }
    } else {
        children();
    }
}

// =========================================================================
// Shared Building Blocks
// =========================================================================

// Threaded nozzle end, occupying z: -thread_length .. 0.
// Includes the thread ridge, lead-in tip chamfer, the internal bore and a
// counterbore at the open end that ends in a 45-degree transition into the
// main bore.
module threaded_end() {
    difference() {
        union() {
            // Thread base cylinder
            translate([0, 0, -thread_length])
                cylinder(d = thread_base_dia, h = thread_length);

            // Helical Thread Ridge
            translate([0, 0, -thread_length])
                helical_thread(
                    base_dia = thread_base_dia,
                    thread_h = thread_height,
                    thread_t = thread_thickness,
                    pitch = thread_pitch,
                    length = thread_length,
                    crest_ratio = thread_crest_ratio
                );
        }

        // Internal air passage (extends slightly past z = 0 so it stays
        // open where this end is unioned with the valve side)
        translate([0, 0, -thread_length - 1])
            cylinder(d = bore_dia, h = thread_length + 1.5);

        // Counterbore at the open end of the thread
        translate([0, 0, -thread_length])
            cylinder(d = cbore_dia, h = cbore_depth);

        // 45-degree chamfered transition from the counterbore into the main
        // bore (height = radial step = (cbore_dia - bore_dia) / 2)
        translate([0, 0, -thread_length + cbore_depth])
            cylinder(d1 = cbore_dia, d2 = bore_dia, h = (cbore_dia - bore_dia) / 2);

        // Small chamfer on the counterbore's open-end edge, same size as the
        // outer lead-in chamfer of the threaded tip
        translate([0, 0, -thread_length - 0.05])
            cylinder(
                d1 = cbore_dia + 2 * (open_cbore_chamfer_h + 0.05),
                d2 = cbore_dia,
                h = open_cbore_chamfer_h + 0.05
            );

        // Lead-in chamfer on the outer edge of the threaded tip, same size
        // as the counterbore open-end chamfer (45 degrees). Note tip_chamfer
        // adds +0.1 to its height, so the cone dimensions compensate to keep
        // the effective chamfer exactly open_cbore_chamfer_h deep at 45 deg.
        translate([0, 0, -thread_length - 0.05])
            tip_chamfer(
                d_outer = thread_base_dia + 0.2,
                d_inner = thread_base_dia - 2 * open_cbore_chamfer_h - 0.1,
                height = open_cbore_chamfer_h + 0.05
            );
    }
}

// The wide grip lip (collar) from the original v0.01 design, occupying
// z: 0 .. lip_thickness, with vertical grip ribs and small chamfers on
// both the top and bottom edges. Sits between the threaded end and the
// nozzle of every adapter, giving a wide finger grip. (The 20mm seal
// seat neck is part of the SUP nozzle only - see sup_female_end().)
module grip_lip() {
    union() {
        difference() {
            union() {
                // Simple circular lip (collar)
                cylinder(d = lip_dia, h = lip_thickness);

                // Vertical grip ribs around the collar (the edge chamfers
                // below trim their ends)
                if (grip_ribs) {
                    for (i = [0 : lip_ribs_n - 1]) {
                        rotate([0, 0, i * 360 / lip_ribs_n])
                            translate([lip_dia/2 + lip_rib_h - lip_rib_dia/2, 0, 0])
                                cylinder(d = lip_rib_dia, h = lip_thickness);
                    }
                }
            }

            // Bottom edge chamfer (face at z = 0): 45-degree cone from
            // (lip_dia/2 - c, 0) up to (lip_dia/2, c). The ring ends exactly
            // at the chamfer foot so it trims the rib ends cleanly.
            translate([0, 0, -0.1])
                difference() {
                    cylinder(d = lip_dia + 2.0, h = lip_chamfer_h + 0.1);
                    cylinder(d1 = lip_dia - 2 * lip_chamfer_h - 0.2, d2 = lip_dia, h = lip_chamfer_h + 0.1);
                }

            // Top edge chamfer (tip face at z = lip_thickness)
            translate([0, 0, lip_thickness - lip_chamfer_h])
                difference() {
                    cylinder(d = lip_dia + 2.0, h = lip_chamfer_h + 0.1);
                    cylinder(d1 = lip_dia, d2 = lip_dia - 2 * lip_chamfer_h - 0.2, h = lip_chamfer_h + 0.1);
                }
        }

        // Optional lanyard ears (kept outside the chamfer difference
        // so the ear faces stay flat)
        if (lip_ears_n > 0) {
            grip_lip_ears();
        }
    }
}

// Horizontal ears on the grip collar (lip_ears_n: 1 or 2; 0 draws nothing),
// each a rounded tab with chamfered top and bottom outer edges and a
// through hole for a lanyard, spanning z: 0 .. lip_thickness.
// With 2 ears they are placed opposite each other.
module grip_lip_ears() {
    // Radial distance of the rounded ear end center from the axis
    ear_c = lip_dia/2 + lip_ear_length - lip_ear_width/2;
    // Hole center: the rounded ear end center, so the hole looks centered
    // in the curved part of the ear. A minimum keeps the hole and its
    // countersink openings clear of the collar wall (needed when a wide
    // tab pulls ear_c close to the wall, which would create non-manifold
    // geometry where the surfaces touch).
    hole_c = max(ear_c,
                 lip_dia/2 + lip_ear_hole_dia/2 + lip_ear_hole_chamfer_h + 0.5);

    ec = lip_ear_chamfer_h;

    difference() {
        for (i = [0 : lip_ears_n - 1]) {
            // Hull of three ear-profile slices: the end slices are inset
            // by the chamfer, so the connecting faces are 45-degree
            // chamfers on the top and bottom outer edges of the ear.
            rotate([0, 0, i * 360 / lip_ears_n])
                hull() {
                    ear_slice(lip_ear_width - 2 * ec, 0, 0.03);
                    ear_slice(lip_ear_width, ec, lip_thickness - 2 * ec);
                    ear_slice(lip_ear_width - 2 * ec, lip_thickness - 0.03, 0.03);
                }
        }

        // Lanyard hole through each ear, with 45-degree chamfer cones
        // opening it on the bottom (z = 0) and top (z = lip_thickness)
        // faces. The cones extend 0.05 mm past each face; their 1:1 slope
        // keeps the opening exactly lip_ear_hole_dia + 2 * ch at the face.
        ch = lip_ear_hole_chamfer_h;
        for (i = [0 : lip_ears_n - 1]) {
            rotate([0, 0, i * 360 / lip_ears_n]) {
                translate([hole_c, 0, -0.1])
                    cylinder(d = lip_ear_hole_dia, h = lip_thickness + 0.2);

                translate([hole_c, 0, -0.05])
                    cylinder(d1 = lip_ear_hole_dia + 2 * ch + 0.1,
                             d2 = lip_ear_hole_dia,
                             h = ch + 0.05);

                translate([hole_c, 0, lip_thickness - ch])
                    cylinder(d1 = lip_ear_hole_dia,
                             d2 = lip_ear_hole_dia + 2 * ch + 0.1,
                             h = ch + 0.05);
            }
        }
    }
}

// One horizontal slice of the ear profile: a rounded tab (hull of two
// cylinders of diameter w) from z = z0 with height h. The inset end
// slices of the ear body use a reduced w so the hull faces are 45-degree
// chamfers.
module ear_slice(w, z0, h) {
    ear_c = lip_dia/2 + lip_ear_length - lip_ear_width/2;

    translate([0, 0, z0])
        hull() {
            // Base cylinder embedded in the collar
            translate([lip_dia/2 - 1.6, 0, 0])
                cylinder(d = w, h = h);
            // Rounded ear end
            translate([ear_c, 0, 0])
                cylinder(d = w, h = h);
        }
}

// Creates a subtractive ring to form a clean chamfer on a screw tip
module tip_chamfer(d_outer, d_inner, height) {
    difference() {
        cylinder(d = d_outer + 1.0, h = height + 0.1, center = false);
        cylinder(d1 = d_inner, d2 = d_outer, h = height + 0.1, center = false);
    }
}

// Creates a mathematically precise, 100% solid helical thread ridge
// using a polyhedron sweep to avoid OpenSCAD's linear_extrude rendering bugs.
module helical_thread(base_dia, thread_h, thread_t, pitch, length, crest_ratio = 0.3, start_offset = 1.5) {
    // Stop 0.3mm short of the top so the tapered end cap is fully buried
    // inside the base cylinder (an end cap exactly at the cylinder's top
    // plane leaves coplanar sliver faces that slicers flag as non-manifold).
    active_length = length - start_offset - 0.3;
    turns = active_length / pitch;
    total_angle = turns * 360;

    // Smoothness: 36 slices per turn for an incredibly clean finish
    slices_per_turn = 144;
    N = round(turns * slices_per_turn);

    r_actual_base = base_dia / 2;
    // Surface points sit 0.02mm inside the nominal radius: this is below
    // even the 128-gon base cylinder's apothem (~0.003mm inside the
    // circumradius), so the surface ribbon and the tapered end caps stay
    // strictly buried inside the cylinder. Protruding them outside instead
    // creates a near-parallel double wall (0.02mm apart) that every
    // boolean crossing shatters into non-manifold slivers. Effect on the
    // measured ridge width: <0.01mm.
    r_surf = r_actual_base - 0.02;
    r_base = r_actual_base - 0.8; // 0.8mm overlap into the cylinder to ensure a perfect manifold union

    // We taper the thread at both ends (start and stop) over a smooth 60-degree turn
    taper_angle = 60;

    // Generate the vertices of the 3D helical spiral with smooth tapers
    vertices = [
        for (i = [0 : N])
            let(
                angle = i * total_angle / N,
                z = start_offset + i * active_length / N,
                c = cos(angle),
                s = sin(angle),

                // Calculate the taper factor 't' (from 0 at ends to 1 in middle)
                t = (angle < taper_angle) ? (angle / taper_angle) :
                    ((angle > total_angle - taper_angle) ? ((total_angle - angle) / taper_angle) : 1.0),

                active_h = thread_h * t,
                // The taper starts 0.05mm below the base radius so the
                // ridge tip (and its end-cap corners) start strictly
                // buried inside the base cylinder and pierce its wall
                // transversally. Starting exactly at r_actual_base would
                // make the near-zero-height tip graze the polygon's
                // circumcircle tangentially (non-manifold slivers).
                // At t=1 the crest is at the nominal r_actual_base+thread_h.
                r_proj = (r_actual_base - 0.05) + (thread_h + 0.05) * t,

                // Trapezoidal cross-section: axial width is exactly thread_t
                // where the ridge meets the cylinder surface (r_actual_base),
                // tapering to thread_t * thread_crest_ratio at the crest.
                // From the surface it runs straight down (constant width)
                // through the 0.8mm union-overlap zone, so the buried part
                // does not narrow the visible thread. (All widths taper to ~0
                // at the helix start/stop via t.)
                h_surf = thread_t * (0.1 + 0.9 * t),
                h_tip = (thread_t * crest_ratio) * (0.1 + 0.9 * t)
            )
            for (pt = [
                [r_base, z - h_surf/2],                 // 0: inner bottom (deep inside cylinder)
                [r_surf, z - h_surf/2],                 // 1: surface bottom
                [r_proj, z - h_tip/2],                  // 2: outer bottom
                [r_proj, z + h_tip/2],                  // 3: outer top
                [r_surf, z + h_surf/2],                 // 4: surface top
                [r_base, z + h_surf/2]                  // 5: inner top
            ])
            [pt[0] * c, pt[0] * s, pt[1]]
    ];

    // Generate the CCW outward-facing faces connecting the slices.
    // Each slice quad is split into two triangles: the quads are slightly
    // twisted (non-planar) along the helix, and CGAL's Nef importer chokes
    // on them (assertion in polygon_mesh_to_nef_3, silently dropping the
    // whole ridge from the boolean result). Triangles are always planar.
    faces = concat(
        // Start cap (bottom): fan-triangulated hexagon
        [[0, 1, 2], [0, 2, 3], [0, 3, 4], [0, 4, 5]],
        [
            for (i = [0 : N - 1])
                for (j = [0 : 5])
                    let(
                        next_j = (j + 1) % 6,
                        curr_curr = 6 * i + j,
                        curr_next = 6 * i + next_j,
                        next_curr = 6 * (i + 1) + j,
                        next_next = 6 * (i + 1) + next_j
                    )
                    for (k = [0 : 1])
                        // k = 0: lower triangle, k = 1: upper triangle
                        (k == 0) ? [curr_curr, next_curr, next_next]
                                  : [curr_curr, next_next, curr_next]
        ],
        // End cap (top): reversed fan
        [[6*N + 5, 6*N + 4, 6*N + 3], [6*N + 5, 6*N + 3, 6*N + 2],
         [6*N + 5, 6*N + 2, 6*N + 1], [6*N + 5, 6*N + 1, 6*N + 0]]
    );

    polyhedron(points = vertices, faces = faces, convexity = 10);
}

// Creates a helical ramp cutout for guiding pins into the slots
module helical_cutout(r, z_high, z_low, angle_start, angle_end) {
    steps = 30;
    da = (angle_end - angle_start) / steps;
    dz = (z_high - z_low) / steps;

    for (i = [0 : steps - 1]) {
        a1 = angle_start + i * da;
        a2 = angle_start + (i + 1) * da;
        z1 = z_high - i * dz;
        z2 = z_high - (i + 1) * dz;

        hull() {
            rotate([0, 0, a1]) translate([0, -0.1, z1]) cube([r, 0.2, z_high - z1 + 5.0]);
            rotate([0, 0, a2]) translate([0, -0.1, z2]) cube([r, 0.2, z_high - z2 + 5.0]);
        }
    }
}

// =========================================================================
// SUP Adapter
// =========================================================================

// Female 21mm bayonet receiver end, occupying z: 0 .. lip + seal neck + bayonet.
// Includes the lip (collar), seal seat neck, J-slots, lead-in ramps and the
// internal bore with its 45-degree shoulder transition.
module sup_female_end() {
    z_seal = lip_thickness;
    z_bayonet = z_seal + seal_neck_length;
    z_front = lip_thickness + bayonet_length;
    transition_h = 1.5; // Creates a neat 45-degree angle transition from 14mm to 17mm

    difference() {
        union() {
            // Wide grip lip (collar)
            grip_lip();

            // 20mm diameter, 4mm long seal groove neck (SUP nozzle only)
            translate([0, 0, z_seal])
                cylinder(d = seal_neck_dia, h = seal_neck_length);

            // Standard bayonet cylinder (OD 21mm, remaining length)
            translate([0, 0, z_bayonet])
                cylinder(d = bayonet_outer_dia, h = bayonet_length - seal_neck_length);
        }

        // Internal air passage through the collar and seal neck
        // (extends below z = 0 so it stays open where this end is
        // unioned with the threaded end)
        translate([0, 0, -0.5])
            cylinder(d = bore_dia, h = z_bayonet + 0.5);

        // Printable chamfered shoulder transition (45 degrees)
        translate([0, 0, z_bayonet])
            cylinder(d1 = bore_dia, d2 = bayonet_inner_dia, h = transition_h);

        // Bayonet side chamber
        translate([0, 0, z_bayonet + transition_h])
            cylinder(d = bayonet_inner_dia, h = z_front - z_bayonet - transition_h + 1);

        // Mirrored Bayonet features (J-slots and funnel ramps) for correct Clockwise (CW) locking
        mirror([0, 1, 0]) {
            // J-slots on the bayonet end
            sup_jslots(z_front);

            // Helical lead-in ramps on the top rim (funnels the pins into the slots)
            let (zf = z_front) {
                helical_cutout(r = bayonet_outer_dia/2 + 2.0, z_high = zf, z_low = zf - 12, angle_start = slot_angle + 60, angle_end = slot_angle + 90+26);
                helical_cutout(r = bayonet_outer_dia/2 + 2.0, z_high = zf, z_low = zf - 12, angle_start = slot_angle + 180 + 60, angle_end = slot_angle + 180 + 90+26);
            }
        }

        // Round the sharp rim edges at the socket opening
        if (rim_round > 0) {
            rim_fillet_cutter(bayonet_outer_dia/2 - rim_round, bayonet_outer_dia/2 + 1,
                              bayonet_outer_dia/2 - rim_round, z_front, rim_round);
            rim_fillet_cutter(bayonet_inner_dia/2 - 1, bayonet_inner_dia/2 + rim_round,
                              bayonet_inner_dia/2 + rim_round, z_front, rim_round);

            // Round the bayonet base edge where it steps down to the seal neck
            rim_fillet_cutter(bayonet_outer_dia/2 - rim_round, bayonet_outer_dia/2 + 1,
                              bayonet_outer_dia/2 - rim_round, z_bayonet, rim_round,
                              up = false);
        }
    }
}

// Subtractive cutter rounding a convex circular edge at radius rho_e, z = zf.
// up = true:  solid lies below the edge (air above, e.g. the socket rim);
//             band [zf-r .. zf], torus centered at (rho_c, zf - r).
// up = false: solid lies above the edge (air below, e.g. an overhang step);
//             band [zf .. zf+r], torus centered at (rho_c, zf + r).
module rim_fillet_cutter(rho_a, rho_b, rho_c, zf, r, up = true) {
    z_band = up ? zf - r : zf - 0.001;
    z_c = up ? zf - r : zf + r;
    difference() {
        translate([0, 0, z_band]) difference() {
            cylinder(r = rho_b, h = r + 0.002);
            cylinder(r = rho_a, h = r + 0.002);
        }
        translate([0, 0, z_c])
            rotate_extrude()
                // Tube scaled 2% radially: an exact circle reaches the
                // wall with a tangent equator, and the tangent ring of
                // polygon vertices pokes through the wall's flat chord
                // faces (sliver intersections slicers flag as
                // non-manifold). The 2% squash makes the fillet surface
                // cross the wall transversally; cost is ~0.02mm.
                translate([rho_c, 0]) scale([1.02, 1]) circle(r = r);
    }
}

// Creates subtractive J-slots for Halkey-Roberts locking pin mechanism
// This perfectly models the swept volume of the circular locking pin for authentic curves.
module sup_jslots(z_front) {
    z_bottom = z_front - slot_depth + slot_width/2;

    // Generate two symmetric J-slots rotated 180 degrees apart
    for (a = [0, 180]) {
        rotate([0, 0, a]) {
            // 1. Vertical entry channel
            translate([bayonet_inner_dia/2 - 1.0, -slot_width/2, z_bottom])
                cube([(bayonet_outer_dia - bayonet_inner_dia)/2 + 2.0, slot_width, z_front - z_bottom + 1.0]);

            // 2. Horizontal twist slot (flat bottom edge)
            translate([0, 0, z_bottom - slot_width/2])
                rotate_extrude(angle = slot_angle)
                    translate([bayonet_inner_dia/2 - 1.0, 0])
                        square([(bayonet_outer_dia - bayonet_inner_dia)/2 + 2.0, slot_width]);

            // 3. End of horizontal slot rounding
            rotate([0, 0, slot_angle])
                translate([0, 0, z_bottom])
                    rotate([0, 90, 0])
                        cylinder(d = slot_width, h = bayonet_outer_dia/2 + 2.0);

            // 4. Locking notch on the ceiling (allows pin to click upwards into the detent)
            rotate([0, 0, slot_angle])
                translate([0, 0, z_bottom + notch_depth])
                    rotate([0, 90, 0])
                        cylinder(d = slot_width, h = bayonet_outer_dia/2 + 2.0);

            // 5. Clean vertical wall on the right edge to connect the notch and bottom smoothly
            rotate([0, 0, slot_angle])
                translate([bayonet_inner_dia/2 - 1.0, 0, z_bottom])
                    cube([(bayonet_outer_dia - bayonet_inner_dia)/2 + 2.0, slot_width/2, notch_depth]);

            // 6. Entry corner rounding (rounds the inner hook corner for smooth insertion)
            rotate([0, 0, 0])
                translate([0, 0, z_bottom])
                    rotate([0, 90, 0])
                        cylinder(d = slot_width, h = bayonet_outer_dia/2 + 2.0);
        }
    }
}

// The original SUP adapter: standard pump hose (21mm male bayonet) on top,
// threaded nozzle on the bottom.
module sup_adapter() {
    union() {
        sup_female_end();
        threaded_end();
    }
}

// =========================================================================
// Boston Adapter
// =========================================================================

// Straight tapered barrel for the Boston valve, occupying
// z: 0 .. boston_barrel_length in local coordinates (the adapter seats
// it on the grip lip). z = 0 is the base (grip lip) end, the tip points
// up at z = boston_barrel_length.
module boston_barrel() {
    cylinder(d1 = boston_barrel_base_dia, d2 = boston_barrel_tip_dia,
             h = boston_barrel_length);
}

// Small 45-degree chamfers on both edges of the barrel tip: the outer
// rim and the bore edge in the tip face (deburring + easy handling).
module boston_tip_chamfer() {
    z_tip = lip_thickness + boston_barrel_length;
    c = boston_tip_chamfer_h;

    // Outer edge: cut from the tip face, running down along the barrel wall
    translate([0, 0, z_tip - c])
        difference() {
            cylinder(d = boston_barrel_tip_dia + 2.0, h = c + 0.1);
            cylinder(d1 = boston_barrel_tip_dia, d2 = boston_barrel_tip_dia - 2 * c - 0.2, h = c + 0.1);
        }

    // Inner edge: cut from the bore edge, running out into the tip face
    translate([0, 0, z_tip - c])
        cylinder(d1 = bore_dia, d2 = bore_dia + 2 * c + 0.2, h = c + 0.1);
}

// Boston adapter: grip lip + straight tapered barrel on top, threaded
// nozzle on the bottom - fits the same air line as the SUP adapter.
module boston_adapter() {
    z_base = lip_thickness;

    difference() {
        union() {
            threaded_end();
            grip_lip();
            translate([0, 0, z_base])
                boston_barrel();
        }

        // Air passage through the grip lip and barrel (extends
        // below z = 0 into the threaded end's bore)
        translate([0, 0, -0.5])
            cylinder(d = bore_dia, h = z_base + boston_barrel_length + 1.5);

        boston_tip_chamfer();
    }
}
