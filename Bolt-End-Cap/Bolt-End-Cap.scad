// Bolt-End-Cap.scad
// Version: v0.08
// Date: 2026-06-18
// Description: Parametric M6 Bolt End Cap for Wing-Foil tracks.
// Helps prevent the end of the M6 bolt from damaging the track box bottom.

// ========================
// PARAMETERS
// ========================

/* [Cap Dimensions] */
// Diameter of the round cap (8mm to fit perfectly in the track)
cap_diameter = 8.4;        // [5:15]
// Chamfer size on top/bottom outer edges to prevent catching inside the track
outer_chamfer = 1.0;     // [0:2]

/* [Thread Parameters] */
// Nominal thread diameter (M6 = 6)
thread_diameter = 6;     // [3:12]
// Thread pitch (M6 standard = 1.0)
thread_pitch = 1.0;      // [0.5:2.5]
// Depth of internal threads (3mm as requested)
thread_depth = 3.0;      // [2:10]
// Additional solid material thickness at the bottom (2mm as requested)
material_thickness = 2.0;// [1:10]

/* [3D Printing Adjustments] */
// Extra clearance on diameter for 3D printed threads to fit easily
clearance = 0.25;        // [0:1]

/* [Visualization] */
// Set to true to see a 50% cutaway of the internal threads
show_cross_section = true;

// ========================
// COMPUTED VALUES
// ========================
total_height = thread_depth + material_thickness;

// ========================
// MAIN ASSEMBLY
// ========================

module main() {
    if (show_cross_section) {
        difference() {
            bolt_cap();
            // Cut away the front-right quadrant to inspect threads
            translate([0, -cap_diameter, -1]) {
                cube([cap_diameter, cap_diameter * 2, total_height + 2]);
            }
        }
    } else {
        bolt_cap();
    }
}

module bolt_cap() {
    d_cleared = thread_diameter + clearance;
    R_max = d_cleared / 2;
    R_min = R_max - 0.541266 * thread_pitch;

    // Core cylinder is made slightly larger than R_min to overlap with the thread teeth,
    // which prevents coplanar surface errors in CGAL.
    R_core = R_min + 0.05;

    z_start = -1; // Extend below the bottom for clean cut

    // Total turns of the thread (from z_start to depth)
    turns = (thread_depth - z_start) / thread_pitch;
    S = round(turns * 64); // Total segments

    difference() {
        // Outer body of the cap: beautifully chamfered cylinder so it never catches
        chamfered_cylinder(cap_diameter, total_height, outer_chamfer);

        // 1. Subtract the core cylinder hole
        translate([0, 0, z_start]) {
            cylinder(h = thread_depth - z_start, r = R_core, $fn = 64);
        }

        // 2. Subtract the helical thread teeth (perfect manifold closed tube)
        // With corrected winding (CCW) on all 4 faces to ensure validity in CGAL.
        let (
            vertices = [
                for (s = [0 : S])
                    for (p = [0 : 3])
                        let (
                            theta = s * 360 / 64,
                            z_center = z_start + s * thread_pitch / 64,
                            c = cos(theta),
                            si = sin(theta),
                            r = (p == 1 || p == 2) ? R_max : R_min,
                            dz = (p == 0) ? thread_pitch * 7/16 :
                                 (p == 1) ? thread_pitch * 1/16 :
                                 (p == 2) ? -thread_pitch * 1/16 : -thread_pitch * 7/16
                        )
                        [ r * c, r * si, z_center + dz ]
            ],
            faces = concat(
                // Helical tube sides (triangulated and winding-corrected!)
                [
                    for (s = [0 : S-1])
                        for (p = [0 : 3])
                            let (
                                i0 = s * 4 + p,
                                i1 = s * 4 + (p + 1) % 4,
                                i2 = (s + 1) * 4 + (p + 1) % 4,
                                i3 = (s + 1) * 4 + p
                            )
                            if (p == 3)
                                each [ [ i1, i0, i3 ], [ i1, i3, i2 ] ]
                            else
                                each [ [ i0, i1, i2 ], [ i0, i2, i3 ] ]
                ],
                // Start cap (triangulated, s = 0) - corrected manifold winding!
                [
                    [ 1, 0, 3 ], [ 1, 3, 2 ]
                ],
                // End cap (triangulated, s = S)
                [
                    [ S * 4, S * 4 + 1, S * 4 + 2 ], [ S * 4, S * 4 + 2, S * 4 + 3 ]
                ]
            )
        ) {
            polyhedron(points = vertices, faces = faces, convexity = 10);
        }
    }
}

// ========================
// MODULES
// ========================

// Fast chamfered cylinder with parametric height and chamfer size
module chamfered_cylinder(d, h, c) {
    actual_c = min(c, min(d/4, h/2)); // Ensure chamfer size is geometrically valid
    if (actual_c <= 0) {
        cylinder(d = d, h = h, $fn = 64);
    } else {
        union() {
            // Bottom chamfer cone
            cylinder(h = actual_c, r1 = d/2 - actual_c, r2 = d/2, $fn = 64);
            // Middle cylinder body
            translate([0, 0, actual_c]) {
                cylinder(h = h - 2*actual_c, r = d/2, $fn = 64);
            }
            // Top chamfer cone
            translate([0, 0, h - actual_c]) {
                cylinder(h = actual_c, r1 = d/2, r2 = d/2 - actual_c, $fn = 64);
            }
        }
    }
}

main();
