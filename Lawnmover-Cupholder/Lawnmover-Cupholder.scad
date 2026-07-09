// Lawnmover-Cupholder v0.12
// Parametric, heavy-duty lawnmower cupholder designed to clamp onto a horizontal metal pipe.
//
// Recommended Print Settings:
// - Material: PETG, ASA, or ABS (highly recommended for outdoor/sun exposure; PLA will warp)
// - Perimeters/Walls: 4 or more (crucial for clamp strength)
// - Infill: 30% to 50% (Gyroid or Grid for structural strength)
// - Support: None needed! Designed to print completely support-free in "print" mode.
//
// Filename: Lawnmover-Cupholder.scad (templated from directory name)

/* [General Cup Dimensions] */
// Inner diameter of the cup holder cavity (matches your bottle/cup diameter, e.g., 77.0 for ant repellent bottle)
cup_diameter = 77.0; // [50:150]

// Height of the cup holder cylinder (bottle total length is 200mm, so 120mm provides excellent support)
cup_height = 120.0; // [50:200]

// Wall thickness of the cup holder cylinder
wall_thickness = 4.0; // [2:10]

// Thickness of the cup holder bottom plate
bottom_thickness = 5.0; // [3:15]

// Diameter of the drain hole at the bottom (prevents water/dust accumulation and allows pushing bottle up)
drain_hole_diameter = 40.0; // [0:60]

// Top/bottom lip chamfer/bevel size for smooth edges and clean printing
chamfer_size = 1.5; // [0:5]

/* [Clamp Mounting Dimensions] */
// Diameter of the horizontal metal mounting pipe (e.g., 19.0mm)
pipe_diameter = 19.0; // [10:50]

// Distance from the outer wall of the cup to the center of the horizontal pipe (smaller lowers leverage and increases rigidity)
pipe_offset = 11.5; // [8:40]

// Width of the clamp block along the pipe axis (longer provides more horizontal stability)
clamp_width = 35.0; // [20:80]

// Height of the clamp block (will be automatically adjusted to a safe minimum if set too small)
clamp_height = 50.0; // [30:100]

// Clearance gap between the clamp halves when tightened around the pipe (ensures strong clamping pressure)
clamp_gap = 2.0; // [1:5]

// Height of the pipe center from the bottom of the cupholder
clamp_z_offset = 75.0; // [20:180]

/* [Hardware Dimensions] */
// Clearance diameter for the bolt shaft (e.g., 5.3mm for a loose M5 bolt)
bolt_diameter = 5.3; // [3:10]

// Flat-to-flat width of the hex nut slot (e.g., 8.1mm for a snug M5 nut capture)
nut_flat_width = 8.1; // [5:15]

// Thickness of the hex nut slot (e.g., 4.5mm for standard M5 nut)
nut_thickness = 4.5; // [2:10]

// Diameter of the bolt head recess pocket (e.g., 10.0mm for M5 socket cap screw)
bolt_head_diameter = 10.0; // [5:20]

// Depth of the bolt head recess pocket (keeps bolt heads flush)
bolt_head_depth = 5.0; // [0:15]

// Chamfer size for all outer edges of the clamp block and cap (adds a smooth, professional feel)
clamp_chamfer_size = 2.0; // [0:5]

// Thickness of the thin sacrificial membrane at the bottom of the bolt head recess (enables 100% support-free printing of counterbored holes; easily poked through after printing)
sacrificial_membrane_thickness = 0.25; // [0:1]

/* [Display Configuration] */
// Which part or layout to show in OpenSCAD
mode = "print"; // ["assembly", "print", "cup", "cap"]

/* [Rendering Smoothness] */
// Circular fragment count (higher is smoother but slower to render)
$fn = 100; // [30:200]


// ==========================================
// CALCULATED CONSTANTS & SAFETY CHECKS
// ==========================================

r_in = cup_diameter / 2;
r_out = r_in + wall_thickness;
r_pipe = pipe_diameter / 2;

// Enforce a safe minimum clamp height to ensure plastic ears have enough material above/below the bolt holes
min_clamp_height = pipe_diameter + 2 * bolt_diameter + 16.0;
actual_clamp_height = max(clamp_height, min_clamp_height);

// Calculate optimal bolt placement relative to the pipe center to maximize ears strength
bolt_z_offset = actual_clamp_height / 2 - bolt_diameter / 2 - 5.0;

// Position of the nut slot inside the integrated clamp body
X_split = r_out + pipe_offset;
X_nut_center = X_split - clamp_gap / 2 - 6.0;

// Calculate the X coordinate where the clamp block and gussets must start
// to fully intersect and merge with the curved cup wall on the sides
Y_boundary = min(clamp_width / 2, r_out - 1.0);
X_back = sqrt(r_out * r_out - Y_boundary * Y_boundary) - 1.0;

// Automatic heights for reinforcing gussets to prevent them from extending into the top chamfer or bottom of the cup
top_gusset_height = max(0.0, min(25.0, (cup_height - chamfer_size - 2.0) - (clamp_z_offset + actual_clamp_height / 2)));
bottom_gusset_height = min(25.0, clamp_z_offset - actual_clamp_height / 2);


// ==========================================
// MAIN CONTROLLER
// ==========================================

if (mode == "assembly") {
    // Show how everything clamps together in place
    cup();
    clamp_cap();

    // Translucent reference metal pipe
    color([0.7, 0.7, 0.7, 0.4]) {
        translate([X_split, 0, clamp_z_offset])
            rotate([90, 0, 0])
                cylinder(h = clamp_width * 2, r = r_pipe, center = true);
    }
} else if (mode == "cup") {
    // Render only the cup (ready to print upright)
    cup();
} else if (mode == "cap") {
    // Render only the clamp cap (oriented flat on print bed)
    cap_printable();
} else if (mode == "print") {
    // Render both parts laid out flat on the print bed side-by-side
    cup();
    translate([cup_diameter + 25.0, 0, 0])
        cap_printable();
}


// ==========================================
// COMPONENT MODULES
// ==========================================

// --- MAIN CUP WITH INTEGRATED CLAMP BODY ---
module cup() {
    color([0.2, 0.6, 0.8]) {
        difference() {
            union() {
                // Main Cup Shell
                cylinder(h = cup_height, r = r_out);

                // Integrated Clamp Body Block (Sleek, solid, and fully merged on the sides)
                translate([X_back, -clamp_width / 2, clamp_z_offset - actual_clamp_height / 2])
                    cube([X_split - clamp_gap / 2 - X_back, clamp_width, actual_clamp_height]);

                // Top Reinforcement Gusset (Structural Wedge)
                if (top_gusset_height > 0) {
                    rotate([90, 0, 0])
                        linear_extrude(height = clamp_width, center = true)
                            polygon(points = [
                                [X_back, clamp_z_offset + actual_clamp_height / 2],
                                [X_split - clamp_gap / 2, clamp_z_offset + actual_clamp_height / 2],
                                [X_back, clamp_z_offset + actual_clamp_height / 2 + top_gusset_height]
                            ]);
                }

                // Bottom Reinforcement Gusset (Structural Wedge)
                if (bottom_gusset_height > 0) {
                    rotate([90, 0, 0])
                        linear_extrude(height = clamp_width, center = true)
                            polygon(points = [
                                [X_back, clamp_z_offset - actual_clamp_height / 2],
                                [X_split - clamp_gap / 2, clamp_z_offset - actual_clamp_height / 2],
                                [X_back, clamp_z_offset - actual_clamp_height / 2 - bottom_gusset_height]
                            ]);
                }
            }

            // --- CAVITY & DRAIN CUTOUTS ---

            // Inner Cup Cavity
            translate([0, 0, bottom_thickness])
                cylinder(h = cup_height, r = r_in);

            // Drain Hole at the bottom (with chamfers on both inner and outer edges)
            if (drain_hole_diameter > 0) {
                r_drain = drain_hole_diameter / 2;

                translate([0, 0, -1])
                    cylinder(h = bottom_thickness + 2.0, r = r_drain);

                // Bottom Outer Drain Chamfer
                if (chamfer_size > 0) {
                    translate([0, 0, -0.1])
                        cylinder(h = chamfer_size + 0.1, r1 = r_drain + chamfer_size, r2 = r_drain);
                }

                // Bottom Inner Drain Chamfer (slopes outward into the cup floor, cutting into the solid floor)
                if (chamfer_size > 0) {
                    translate([0, 0, bottom_thickness - chamfer_size])
                        cylinder(h = chamfer_size + 0.1, r1 = r_drain, r2 = r_drain + chamfer_size);
                }
            }

            // --- TOP & BOTTOM EDGE CHAMFERS ---

            // Top Inner Chamfer
            if (chamfer_size > 0) {
                translate([0, 0, cup_height - chamfer_size])
                    cylinder(h = chamfer_size + 0.1, r1 = r_in, r2 = r_in + chamfer_size);
            }

            // Top Outer Chamfer (F5-friendly, robust subtraction)
            if (chamfer_size > 0) {
                difference() {
                    translate([0, 0, cup_height - chamfer_size])
                        cylinder(h = chamfer_size + 0.1, r = r_out + 5.0);
                    translate([0, 0, cup_height - chamfer_size - 0.05])
                        cylinder(h = chamfer_size + 0.2, r1 = r_out, r2 = r_out - chamfer_size);
                }
            }

            // Bottom Outer Chamfer (F5-friendly, minimizes Elephant's Foot & sharp edges)
            if (chamfer_size > 0) {
                difference() {
                    translate([0, 0, -0.1])
                        cylinder(h = chamfer_size + 0.1, r = r_out + 5.0);
                    translate([0, 0, -0.15])
                        cylinder(h = chamfer_size + 0.2, r1 = r_out - chamfer_size, r2 = r_out);
                }
            }

            // --- MOUNTING AND BOLT CUTOUTS ---

            // Semi-Cylindrical Pipe Channel
            translate([X_split, 0, clamp_z_offset])
                rotate([90, 0, 0])
                    cylinder(h = clamp_width + 2.0, r = r_pipe, center = true);

            // Top Bolt Hole (runs all the way through to the inner cup cavity)
            translate([r_in - 1.0, 0, clamp_z_offset + bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = X_split - r_in + 2.0, r = bolt_diameter / 2);

            // Bottom Bolt Hole (runs all the way through to the inner cup cavity)
            translate([r_in - 1.0, 0, clamp_z_offset - bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = X_split - r_in + 2.0, r = bolt_diameter / 2);

            // Top Hex Nut Recess (inside the cup inner wall, oriented for direct slot insertion)
            translate([r_in + nut_thickness / 2 - 0.1, 0, clamp_z_offset + bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = nut_thickness + 0.2, r = nut_flat_width / sqrt(3), $fn = 6, center = true);

            // Bottom Hex Nut Recess (inside the cup inner wall, oriented for direct slot insertion)
            translate([r_in + nut_thickness / 2 - 0.1, 0, clamp_z_offset - bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = nut_thickness + 0.2, r = nut_flat_width / sqrt(3), $fn = 6, center = true);
        }
    }
}

// --- CLAMP CAP IN ASSEMBLY COORDINATES ---
module clamp_cap() {
    color([1.0, 0.4, 0.2]) {
        X_start = X_split + clamp_gap / 2;
        X_end = X_split + r_pipe + wall_thickness + 2.0; // solid cap width

        difference() {
            // Main Cap Body Block
            translate([X_start, -clamp_width / 2, clamp_z_offset - actual_clamp_height / 2])
                cube([X_end - X_start, clamp_width, actual_clamp_height]);

            // Semi-Cylindrical Pipe Channel
            translate([X_split, 0, clamp_z_offset])
                rotate([90, 0, 0])
                    cylinder(h = clamp_width + 2.0, r = r_pipe, center = true);

            // Top Bolt Hole (stops just before the recess to leave a thin sacrificial membrane)
            translate([X_start - 1.0, 0, clamp_z_offset + bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = (X_end - bolt_head_depth - sacrificial_membrane_thickness) - (X_start - 1.0), r = bolt_diameter / 2);

            // Top Bolt Head Recess
            translate([X_end - bolt_head_depth, 0, clamp_z_offset + bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = bolt_head_depth + 1.0, r = bolt_head_diameter / 2);

            // Bottom Bolt Hole (stops just before the recess to leave a thin sacrificial membrane)
            translate([X_start - 1.0, 0, clamp_z_offset - bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = (X_end - bolt_head_depth - sacrificial_membrane_thickness) - (X_start - 1.0), r = bolt_diameter / 2);

            // Bottom Bolt Head Recess
            translate([X_end - bolt_head_depth, 0, clamp_z_offset - bolt_z_offset])
                rotate([0, 90, 0])
                    cylinder(h = bolt_head_depth + 1.0, r = bolt_head_diameter / 2);

            // --- CLAMP CAP OUTER CHAMFERS ---
            if (clamp_chamfer_size > 0) {
                C_val = clamp_chamfer_size * sqrt(2);
                H_val = actual_clamp_height + 2.0;
                W_val = clamp_width + 2.0;
                L_val = (X_end - X_start) + 2.0;
                X_cap_center = X_start + (X_end - X_start) / 2;

                // Vertical outer-right back edge
                translate([X_end, clamp_width / 2, clamp_z_offset])
                    rotate([0, 0, 45])
                        cube([C_val, C_val, H_val], center = true);

                // Vertical outer-left back edge
                translate([X_end, -clamp_width / 2, clamp_z_offset])
                    rotate([0, 0, 45])
                        cube([C_val, C_val, H_val], center = true);

                // Top-outer horizontal back edge
                translate([X_end, 0, clamp_z_offset + actual_clamp_height / 2])
                    rotate([0, 45, 0])
                        cube([C_val, W_val, C_val], center = true);

                // Bottom-outer horizontal back edge
                translate([X_end, 0, clamp_z_offset - actual_clamp_height / 2])
                    rotate([0, 45, 0])
                        cube([C_val, W_val, C_val], center = true);

                // Side top-right edge
                translate([X_cap_center, clamp_width / 2, clamp_z_offset + actual_clamp_height / 2])
                    rotate([45, 0, 0])
                        cube([L_val, C_val, C_val], center = true);

                // Side top-left edge
                translate([X_cap_center, -clamp_width / 2, clamp_z_offset + actual_clamp_height / 2])
                    rotate([45, 0, 0])
                        cube([L_val, C_val, C_val], center = true);

                // Side bottom-right edge
                translate([X_cap_center, clamp_width / 2, clamp_z_offset - actual_clamp_height / 2])
                    rotate([45, 0, 0])
                        cube([L_val, C_val, C_val], center = true);

                // Side bottom-left edge
                translate([X_cap_center, -clamp_width / 2, clamp_z_offset - actual_clamp_height / 2])
                    rotate([45, 0, 0])
                        cube([L_val, C_val, C_val], center = true);
            }
        }
    }
}

// --- PRINT-READY CLAMP CAP (Laid flat on bed, no support needed) ---
module cap_printable() {
    X_end = X_split + r_pipe + wall_thickness + 2.0;

    // Rotate and translate cap so its flat outer back face lies exactly on Z=0
    rotate([0, 90, 0])
        translate([-X_end, 0, -clamp_z_offset])
            clamp_cap();
}
