// =========================================================================
// IKEA-BROGRUND-Battery-Knob.scad
//
// Parametric thumb knob replacement for the IKEA BROGRUND battery box lid.
// Replaces the awkward internal hex socket bolt with an easy-to-turn knob
// using a standard M4 hex head bolt (M4x30, with 16mm protruding).
//
// Version History:
//   v0.01 (2026-07-10) - Initial release. Robust parametric design with
//                        ergonomic flutes, automatic height checking, and
//                        an optional printable hex-socket cap.
//
// Printing Instructions:
//   - Material: PETG or PLA (PETG is recommended for durability and flex).
//   - Orientation: Print the knob standing upright on its flat bottom face.
//                  Print the cap flat-face down (stem pointing upwards).
//   - Supports: None needed! The internal bridging and outer flare angles
//               are optimized for support-free printing.
//   - Infill: 30% to 50% (Gyroid or Grid) for strength.
//   - Walls/Perimeters: 3 or 4 to ensure the hex socket is extremely strong.
//
// Assembly:
//   1. Insert the M4x30 hex head bolt from the top of the knob.
//   2. Pull or press the bolt head into the hexagonal socket until it seats.
//      (If tight, you can screw a nut on the protruding end to pull it in).
//   3. (Optional) Press-fit the cap into the top of the knob to hide the bolt head.
// =========================================================================

/* [Output Selection] */
// Select which part to render: "knob" for the main knob, "cap" for the bolt-head cover, or "both" to print side-by-side.
part = "knob"; // ["knob", "cap", "both"]

/* [Bolt Dimensions] */
// Total length of the M4 bolt shank (under the head), in mm
bolt_length = 30.0; // [20:1:50]

// Desired length of the bolt thread protruding from the bottom of the knob, in mm
bolt_protrusion = 16.0; // [5:1:40]

// Width across flats for the M4 hex head (standard is 7.0mm)
hex_flat_width = 7.0;

// Height of the hex head (standard is 2.8mm, we use 3.0 for printing tolerance)
hex_head_height = 3.0;

// Clearance around the hex head for a snug fit, in mm
hex_clearance = 0.0;

// Clearance around the bolt shank, in mm
shaft_clearance = 0.0;

/* [Knob Profile] */
// Maximum outer diameter of the knob (must not exceed 15.0mm for battery box clearances!)
knob_max_diameter = 14.5; // [10:0.5:15]

// Neck diameter at the bottom of the knob to fit into lid recesses, in mm
knob_neck_diameter = 9.5; // [8:0.5:14]

// Height of the narrow neck part, in mm
knob_neck_height = 4.0; // [0:1:10]

// Total height of the knob (must be at least bolt_length - bolt_protrusion + hex_head_height + 1), in mm
knob_total_height = 18.5; // [15:0.5:30]

// Size of the chamfer/bevel at the top edge, in mm
top_bevel_size = 1.0; // [0:0.1:3]

/* [Ergonomic Grip] */
// Number of finger grooves around the perimeter (0 to disable fluting)
num_grooves = 6; // [0:1:12]

// Radius of each vertical groove cylinder, in mm
groove_radius = 1.8; // [0.5:0.1:4]

// Depth adjustment of the grooves (0 is flush with outer radius, negative is deeper, positive is shallower)
groove_depth_offset = 0.0; // [-2:0.1:2]


// =========================================================================
// CALCULATED PROPERTIES & SAFETY OVERRIDES
// =========================================================================

// Depth of the central shaft hole through which the bolt shank passes
shaft_hole_depth = bolt_length - bolt_protrusion;

// Enforce a minimum knob height so the bolt head does not stick out of the top
min_required_height = shaft_hole_depth + hex_head_height + 1.0;
effective_knob_height = max(knob_total_height, min_required_height);

// Diagnostics Console Output
echo("--- IKEA BROGRUND Battery Knob Parametric Model ---");
echo(str("Bolt Length: ", bolt_length, " mm"));
echo(str("Required Protrusion: ", bolt_protrusion, " mm"));
echo(str("Calculated Internal Shaft Depth: ", shaft_hole_depth, " mm"));
if (knob_total_height < min_required_height) {
    echo(str("WARNING: Requested knob height (", knob_total_height, " mm) is too small!"));
    echo(str("-> Automatically adjusted height to ", effective_knob_height, " mm to accommodate bolt head and shoulder."));
} else {
    echo(str("Effective Knob Height: ", effective_knob_height, " mm"));
}
if (knob_max_diameter > 15.0) {
    echo("WARNING: Knob diameter exceeds 15mm! Ensure it fits your BROGRUND battery box lid clearance.");
}

// =========================================================================
// MAIN GENERATOR
// =========================================================================

if (part == "knob") {
    battery_knob();
} else if (part == "cap") {
    battery_knob_cap();
} else if (part == "both") {
    // Render both side-by-side with a clean offset for printing
    translate([-knob_max_diameter * 0.7, 0, 0])
        battery_knob();
    translate([knob_max_diameter * 0.7, 0, 0])
        battery_knob_cap();
}

// =========================================================================
// MODULES
// =========================================================================

// The main thumb-knob body
module battery_knob() {
    // Width across corners of hex head for OpenSCAD's 6-sided cylinder
    hex_w = hex_flat_width + 2 * hex_clearance;
    hex_r = (hex_w / 2) / cos(30);

    // Bolt shank diameter with clearance
    bolt_hole_diameter = 4.0 + 2 * shaft_clearance;

    difference() {
        // --- 1. SOLID KNOB OUTER SHAPE ---
        union() {
            // A. Bottom neck section (straight cylinder)
            cylinder(h = knob_neck_height, r = knob_neck_diameter / 2, $fn = 100);

            // B. Transition/flared section (conical)
            transition_height = effective_knob_height - knob_neck_height - top_bevel_size;
            translate([0, 0, knob_neck_height])
                cylinder(h = transition_height, r1 = knob_neck_diameter / 2, r2 = knob_max_diameter / 2, $fn = 100);

            // C. Beveled top section (conical bevel)
            translate([0, 0, effective_knob_height - top_bevel_size])
                cylinder(h = top_bevel_size, r1 = knob_max_diameter / 2, r2 = knob_max_diameter / 2 - top_bevel_size, $fn = 100);
        }

        // --- 2. BOLT SHANK THROUGH-HOLE ---
        translate([0, 0, -1])
            cylinder(d = bolt_hole_diameter, h = effective_knob_height + 2, $fn = 64);

        // --- 3. HEX HEAD SOCKET RECESS ---
        translate([0, 0, shaft_hole_depth])
            cylinder(r = hex_r, h = effective_knob_height - shaft_hole_depth + 1, $fn = 6);

        // --- 4. ERGONOMIC GRIP FLUTES (FINGER GROOVES) ---
        if (num_grooves > 0) {
            for (i = [0 : num_grooves - 1]) {
                rotate([0, 0, i * 360 / num_grooves])
                    translate([knob_max_diameter / 2 + groove_depth_offset, 0, knob_neck_height - 0.5])
                        // Grooves cut from top of neck to the top of the knob
                        cylinder(h = effective_knob_height - knob_neck_height + 1, r = groove_radius, $fn = 64);
            }
        }
    }
}

// Optional snap-fit cover cap for the hex head recess
module battery_knob_cap() {
    // Disk size to sit flush on top of the knob
    cap_outer_diameter = knob_max_diameter - 2 * top_bevel_size;
    cap_disk_height = 1.2;

    // Hex socket dimensions
    hex_w = hex_flat_width + 2 * hex_clearance;

    // Cap stem dimensions (slightly tighter fit for a firm press-fit)
    cap_stem_clearance = 0.05;
    cap_stem_w = hex_w - 2 * cap_stem_clearance;
    cap_stem_r = (cap_stem_w / 2) / cos(30);

    // Calculate how much free height is in the hex socket above the bolt head
    socket_free_depth = effective_knob_height - shaft_hole_depth - hex_head_height;
    // Set stem height to fit comfortably inside without hitting the bolt head
    cap_stem_height = max(1.5, socket_free_depth - 0.5);

    // Designed with the flat top printed directly on the build plate (support-free)
    union() {
        // A. Flat cover disk (sits on bed)
        cylinder(h = cap_disk_height, r = cap_outer_diameter / 2, $fn = 64);

        // B. Hexagonal press-fit stem pointing upwards
        translate([0, 0, cap_disk_height])
            cylinder(r = cap_stem_r, h = cap_stem_height, $fn = 6);
    }
}
