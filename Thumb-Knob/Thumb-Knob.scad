// =========================================================================
// Generic-Metric-Bolt-Nut-Thumb-Knob.scad
//
// Parametric thumb knob replacement for generic metric bolts and nuts.
//
// Version History:
//    v0.15 (2026-08-24) - Removed fastener type distinction. Simplified model
//                         to rely on knob_total_height and min_bottom_thickness.
// =========================================================================

/* [Fastener Configuration] */
bolt_size = 5; // [4:M4, 5:M5, 6:M6]
hex_clearance = -0.1;
shaft_clearance = 0.0;

/* [Knob Profile] */
wall_thickness = 1.5;
knob_neck_diameter = 12.0;
knob_neck_height = 4.0; // [0:1:10]
minimum_knob_diameter = (bolt_size == 6) ? 18.0 : ((bolt_size == 5) ? 16.0 : 14.5);
knob_total_height = 18.5; // [10:0.5:40]
min_bottom_thickness = 3.0; // [1:0.5:10] Minimum solid material thickness below hex recess
top_bevel_size = 1.0; // [0:0.1:3]

/* [Chamfer Settings] */
hole_chamfer = 0.5; // [0:0.1:2] Global chamfer size for inner/outer bottom edges and top hole lead-in

/* [Ergonomic Grip] */
num_grooves = 6; // [0:1:12]
groove_radius = 1.8; // [0.5:0.1:4]
groove_depth_offset = 0.0; // [-2:0.1:2]


// =========================================================================
// CALCULATED PROPERTIES
// =========================================================================

bolt_hole_diameter = (bolt_size == 4) ? 4.5 + (2 * shaft_clearance) : 
                     (bolt_size == 5) ? 5.5 + (2 * shaft_clearance) : 
                                        6.6 + (2 * shaft_clearance);

// Standard DIN metric hex flat-to-flat sizes
hex_flat_width = (bolt_size == 4) ? 7.0 : 
                 (bolt_size == 5) ? 8.0 : 
                                    10.0;

hex_w = hex_flat_width + (2 * hex_clearance);
hex_across_corners = hex_w / cos(30);
auto_min_max_diameter = hex_across_corners + (2 * wall_thickness);

knob_max_diameter = max(minimum_knob_diameter, auto_min_max_diameter);
shaft_hole_depth = min_bottom_thickness;


// =========================================================================
// MAIN GENERATOR ROUTINE
// =========================================================================

battery_knob();

// =========================================================================
// MODULES
// =========================================================================

module battery_knob() {
    // Circumscribed outer radius for cylinder(r=..., $fn=6)
    hex_r = hex_across_corners / 2;

    difference() {
        // --- 1. SOLID OUTER BASE SHAPE ---
        union() {
            // A. Bottom chamfered neck segment
            if (hole_chamfer > 0) {
                cylinder(
                    h = hole_chamfer, 
                    r1 = (knob_neck_diameter / 2) - hole_chamfer, 
                    r2 = knob_neck_diameter / 2, 
                    $fn = 100
                );
            }

            // B. Straight neck segment
            translate([0, 0, hole_chamfer])
                cylinder(
                    h = knob_neck_height - hole_chamfer, 
                    r = knob_neck_diameter / 2, 
                    $fn = 100
                );

            // C. Flared body transition
            transition_height = knob_total_height - knob_neck_height - top_bevel_size;
            translate([0, 0, knob_neck_height])
                cylinder(
                    h = transition_height, 
                    r1 = knob_neck_diameter / 2, 
                    r2 = knob_max_diameter / 2, 
                    $fn = 100
                );

            // D. Beveled top edge
            translate([0, 0, knob_total_height - top_bevel_size])
                cylinder(
                    h = top_bevel_size, 
                    r1 = knob_max_diameter / 2, 
                    r2 = knob_max_diameter / 2 - top_bevel_size, 
                    $fn = 100
                );
        }

        // --- 2. BOLT SHANK HOLE ---
        translate([0, 0, -1])
            cylinder(d = bolt_hole_diameter, h = knob_total_height + 2, $fn = 64);

        // --- 3. INNER HOLE BOTTOM COUNTERSINK / CHAMFER ---
        if (hole_chamfer > 0) {
            translate([0, 0, -0.01])
                cylinder(
                    h = hole_chamfer + 0.01, 
                    r1 = (bolt_hole_diameter / 2) + hole_chamfer, 
                    r2 = bolt_hole_diameter / 2, 
                    $fn = 64
                );
        }

        // --- 4. INNER HOLE TOP CHAMFER (At hex recess transition) ---
        if (hole_chamfer > 0) {
            translate([0, 0, shaft_hole_depth - hole_chamfer])
                cylinder(
                    h = hole_chamfer + 0.01,
                    r1 = bolt_hole_diameter / 2,
                    r2 = (bolt_hole_diameter / 2) + hole_chamfer,
                    $fn = 64
                );
        }

        // --- 5. HEX RECESS ---
        translate([0, 0, shaft_hole_depth])
            cylinder(r = hex_r, h = knob_total_height - shaft_hole_depth + 1, $fn = 6);

        // --- 6. FINGER GROOVES ---
        if (num_grooves > 0) {
            for (i = [0 : num_grooves - 1]) {
                rotate([0, 0, i * 360 / num_grooves])
                    translate([knob_max_diameter / 2 + groove_depth_offset, 0, knob_neck_height - 0.5])
                        cylinder(h = knob_total_height - knob_neck_height + 1, r = groove_radius, $fn = 64);
            }
        }
    }
}