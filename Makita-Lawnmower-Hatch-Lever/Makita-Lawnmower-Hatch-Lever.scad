// Makita Lawnmower Hatch Lever
// File: Makita-Lawnmower-Hatch-Lever.scad
// Version: v0.03
// Date: 2026-07-23
// Description: Parametric lever to hold open a Makita lawnmower hatch with an optional hexagonal nut recess and chamfered edges.
//
// Designed to be printed flat on the print bed with zero support material.
// The lever pivots on an M6 bolt and hooks under the lawnmower's handle bar.

/* [Lever Dimensions] */
// Total length of the lever (mm)
lever_length = 130; // [50:300]
// Width of the lever (mm)
lever_width = 20; // [10:100]
// Thickness of the lever (mm)
lever_thickness = 10; // [5:50]
// Chamfer size for the top and bottom edges (mm). Use 0 for flat edges.
chamfer_size = 1.0; // [0:5]

/* [Pivot Hole (M6)] */
// Bolt hole diameter (mm). M6 clearance hole is typically 6.4mm.
bolt_hole_diameter = 6.4;
// Offset of the bolt hole from the pivot end (mm)
bolt_hole_offset = 10;

/* [Nut Recession (Hex Pocket)] */
// Enable hexagonal recess for nut or bolt head
nut_recess_enable = true;
// Flat-to-flat distance of the hex nut (mm). M6 nut is typically 10mm + 0.3mm print tolerance.
nut_recess_flat_to_flat = 10.3;
// Depth of the nut recess (mm)
nut_recess_depth = 4; // [1:20]
// Whether the nut recess is on the top surface (true) or bottom surface (false)
nut_recess_on_top = true;

/* [Handle Cutout] */
// Diameter of the lawnmower handle bar cylinder (mm)
cutout_diameter = 32;
// Depth of the cylindrical cutout (mm)
cutout_depth = 5;
// Position of the cutout center from the pivot end (mm)
cutout_offset = 110;
// Whether the cutout is on the top surface (true) or bottom surface (false)
cutout_on_top = true;
// Angle of the handle relative to the perpendicular direction (degrees)
cutout_angle = 0; // [-60:60]

/* [Rendering Resolution] */
// Circle smoothness ($fn value)
resolution = 120; // [30:200]

// --- Helper Modules ---

// A cylinder with chamfered top and bottom edges
module chamfered_cylinder(h, r, c) {
    // Ensure the chamfer size is safe and doesn't exceed half the height
    safe_c = min(c, h / 2 - 0.01);

    if (safe_c <= 0) {
        cylinder(h = h, r = r, center = false);
    } else {
        // Bottom cone
        cylinder(h = safe_c, r1 = r - safe_c, r2 = r, center = false);
        // Middle section
        translate([0, 0, safe_c])
            cylinder(h = h - 2 * safe_c, r = r, center = false);
        // Top cone
        translate([0, 0, h - safe_c])
            cylinder(h = safe_c, r1 = r, r2 = r - safe_c, center = false);
    }
}

// --- Main Model Assembly ---

module makita_lawnmower_hatch_lever() {
    $fn = resolution;
    cutout_radius = cutout_diameter / 2;

    difference() {
        // 1. Solid capsule-shaped lever body with chamfered edges
        hull() {
            // Rounding at the pivot end
            translate([lever_width/2, 0, 0])
                chamfered_cylinder(h = lever_thickness, r = lever_width/2, c = chamfer_size);

            // Rounding at the far end
            translate([lever_length - lever_width/2, 0, 0])
                chamfered_cylinder(h = lever_thickness, r = lever_width/2, c = chamfer_size);
        }

        // 2. Pivot hole (M6 bolt)
        translate([bolt_hole_offset, 0, -1])
            cylinder(h = lever_thickness + 2, d = bolt_hole_diameter, center = false);

        // 3. Cylindrical handle cutout
        // Calculate appropriate Z position for top vs. bottom cutout
        z_offset = cutout_on_top ?
            (lever_thickness - cutout_depth + cutout_radius) :
            (cutout_depth - cutout_radius);

        translate([cutout_offset, 0, z_offset])
            rotate([0, 0, cutout_angle])
            rotate([90, 0, 0])
                cylinder(h = lever_width * 2, r = cutout_radius, center = true);

        // 4. Hexagonal nut recess
        if (nut_recess_enable) {
            // Calculate appropriate Z position for top vs. bottom recess
            nut_z_offset = nut_recess_on_top ?
                (lever_thickness - nut_recess_depth) :
                -1;

            // Hexagon outer radius (vertex radius) based on flat-to-flat width
            nut_recess_radius = (nut_recess_flat_to_flat / 2) / cos(30);

            translate([bolt_hole_offset, 0, nut_z_offset])
                cylinder(h = nut_recess_depth + 1, r = nut_recess_radius, $fn = 6, center = false);
        }
    }
}

// Render the lever
makita_lawnmower_hatch_lever();
