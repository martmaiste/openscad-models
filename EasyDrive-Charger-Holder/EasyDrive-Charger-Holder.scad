// ==============================================================================
// EasyDrive Battery Charger Wall Mount
// File: EasyDrive-Charger-Holder.scad
// Version: v0.17
// Date: 2026-06-07
// Description: Minimalist horizontal wall mount for the EasyDrive battery charger.
// Features clean 1mm chamfers (phases) on outward-facing edges and front/side wall
// top entry edges. Uses an exact 0.01mm thickness 3D pyramid hull to create perfectly
// mitered inner chamfers at exactly 1.0mm height, while keeping the backplate 100% flat.
// Includes side recessions for ventilation, countersunk screw holes, and bottom cutout.
// ==============================================================================

/* [Charger Dimensions] */
// Width of the charger (left-to-right) in mm
charger_width = 157;
// Depth of the charger (front-to-back) in mm
charger_depth = 55;
// Height of the charger (top-to-bottom) in mm
charger_height = 76;

/* [Holder Settings] */
// Height of the pocket holding the charger (how deep it sits) in mm
pocket_height = 20;
// Tolerance clearance around the charger (added to inner width and depth) in mm
clearance = 1.0;
// Wall thickness of the holder in mm
wall_thickness = 4.0;
// Thickness of the bottom support plate in mm
bottom_thickness = 3.0;
// Chamfer (phase) size for outward-facing edges in mm
chamfer_size = 1.0;

/* [Wall Mounting] */
// Total height of the back plate in mm (should be higher than pocket_height)
back_wall_height = 50;
// Diameter of the screw shaft in mm (typically 4mm wood/drywall screws)
screw_diameter = 4.0;
// Diameter of the countersunk screw head in mm
screw_head_diameter = 8.0;
// Depth of the countersink taper in mm
screw_countersink_depth = 3.0;
// Spacing of the two wall screws (center-to-center distance) in mm
screw_spacing = 100;

/* [Ventilation and Recessions] */
// Enable circular cutouts on both side walls to prevent blocking vents
enable_side_recessions = true;
// Radius of the side wall ventilation cutouts in mm
side_recession_radius = 20;
// Vertical offset of the cutout center relative to the top of side walls (pocket_height)
// Positive values move the center up, leaving more wall at the bottom of the pocket.
side_recession_z_offset = 5;

// Enable a large ventilation/material-saving cutout in the bottom plate
enable_bottom_cutout = true;
// Margin of solid material left around the bottom plate cutout in mm
bottom_margin = 12;

/* [Preview Options] */
// Show a translucent ghost representation of the charger for visualization
show_charger_mockup = true;

// ==============================================================================
// CALCULATED CONSTANTS
// ==============================================================================
W_inner = charger_width + 2 * clearance;
D_inner = charger_depth + 2 * clearance;
W_outer = W_inner + 2 * wall_thickness;
D_outer = D_inner + 2 * wall_thickness;

// ==============================================================================
// MAIN MODULE CALL
// ==============================================================================
easy_drive_charger_mount();

// ==============================================================================
// CORE MODULES
// ==============================================================================

module easy_drive_charger_mount() {
    // Center-to-center spacing capped safely to fit within the backplate width
    actual_screw_spacing = min(screw_spacing, W_inner - screw_head_diameter - 4);

    difference() {
        // --- positive volume (solid blocks with perfect, groove-free joints) ---
        union() {
            // 1. Bottom plate
            translate([-wall_thickness, -wall_thickness, -bottom_thickness])
            cube([W_outer, D_outer, bottom_thickness]);

            // 2. Back wall
            translate([-wall_thickness, -wall_thickness, 0])
            cube([W_outer, wall_thickness, back_wall_height]);

            // 3. Front wall
            translate([-wall_thickness, D_inner, 0])
            cube([W_outer, wall_thickness, pocket_height]);

            // 4. Left wall
            translate([-wall_thickness, 0, 0])
            cube([wall_thickness, D_inner, pocket_height]);

            // 5. Right wall
            translate([W_inner, 0, 0])
            cube([wall_thickness, D_inner, pocket_height]);
        }

        // --- negative volume (subtractions) ---

        // 1. Screw holes on the back wall
        translate([W_inner/2 - actual_screw_spacing/2, 0, pocket_height + (back_wall_height - pocket_height)/2])
        countersunk_screw();

        translate([W_inner/2 + actual_screw_spacing/2, 0, pocket_height + (back_wall_height - pocket_height)/2])
        countersunk_screw();

        // 2. Side recessions for ventilator/exhaust vents
        if (enable_side_recessions) {
            // Center recession cylinder along depth (Y) and offset in height (Z)
            translate([-wall_thickness - 1, D_inner / 2, pocket_height + side_recession_z_offset])
            rotate([0, 90, 0])
            cylinder(r = side_recession_radius, h = W_outer + 2, $fn = 128);
        }

        // 3. Bottom plate cutout (ventilation & material saving)
        if (enable_bottom_cutout && (W_inner > 2 * bottom_margin) && (D_inner > 2 * bottom_margin)) {
            translate([bottom_margin, bottom_margin, -bottom_thickness - 1])
            cube([W_inner - 2 * bottom_margin, D_inner - 2 * bottom_margin, bottom_thickness + 2]);
        }

        // 4. CHAMFERS (PHASES) ON OUTWARD-FACING EDGES ONLY
        if (chamfer_size > 0) {
            let (c = chamfer_size, s2 = sqrt(2) * chamfer_size) {
                // --- Vertical front corners (Z-axis) ---
                // Front-left corner
                translate([-wall_thickness, D_inner + wall_thickness, (pocket_height - bottom_thickness)/2])
                rotate([0, 0, 45])
                cube([s2, s2, pocket_height + bottom_thickness + 2], center=true);

                // Front-right corner
                translate([W_inner + wall_thickness, D_inner + wall_thickness, (pocket_height - bottom_thickness)/2])
                rotate([0, 0, 45])
                cube([s2, s2, pocket_height + bottom_thickness + 2], center=true);

                // --- Top rim horizontal edges (X/Y axes) ---
                // Top-front edge (X-axis)
                translate([W_inner/2, D_inner + wall_thickness, pocket_height])
                rotate([45, 0, 0])
                cube([W_outer + 2, s2, s2], center=true);

                // Top-left edge (Y-axis) - starts exactly at Y=0 to avoid cutting into the back wall
                translate([-wall_thickness, (D_inner + wall_thickness + 1)/2, pocket_height])
                rotate([0, 45, 0])
                cube([s2, D_inner + wall_thickness + 1, s2], center=true);

                // Top-right edge (Y-axis) - starts exactly at Y=0 to avoid cutting into the back wall
                translate([W_inner + wall_thickness, (D_inner + wall_thickness + 1)/2, pocket_height])
                rotate([0, 45, 0])
                cube([s2, D_inner + wall_thickness + 1, s2], center=true);

                // --- Top pocket-facing entry edges (X/Y axes) ---
                // Single 3-sided tapered wedge hull that creates perfectly mitered inner chamfers
                // on the front, left, and right inside walls, while keeping the back wall 100% flat.
                // Uses 0.01mm sheets to ensure the chamfer height is exactly c (no step offsets).
                hull() {
                    translate([0, 0, pocket_height - c])
                    cube([W_inner, D_inner, 0.01]);

                    translate([-c, 0, pocket_height - 0.01])
                    cube([W_inner + 2 * c, D_inner + c, 0.01]);
                }

                // --- Bottom plate horizontal edges (X/Y axes) ---
                // Bottom-front edge (X-axis)
                translate([W_inner/2, D_inner + wall_thickness, -bottom_thickness])
                rotate([45, 0, 0])
                cube([W_outer + 2, s2, s2], center=true);

                // Bottom-left edge (Y-axis) - runs exactly to the wall face (Y=-wall_thickness) but not beyond
                translate([-wall_thickness, (D_inner + 1)/2, -bottom_thickness])
                rotate([0, 45, 0])
                cube([s2, D_inner + 2 * wall_thickness + 1, s2], center=true);

                // Bottom-right edge (Y-axis) - runs exactly to the wall face (Y=-wall_thickness) but not beyond
                translate([W_inner + wall_thickness, (D_inner + 1)/2, -bottom_thickness])
                rotate([0, 45, 0])
                cube([s2, D_inner + 2 * wall_thickness + 1, s2], center=true);
            }
        }
    }

    // --- charger mockup preview (non-printed) ---
    if (show_charger_mockup) {
        %translate([clearance, clearance, 0])
        cube([charger_width, charger_depth, charger_height]);
    }
}

// ==============================================================================
// HELPERS
// ==============================================================================

// Countersunk screw cutout (points in negative Y-direction)
module countersunk_screw() {
    // Screw shaft (slightly oversized for clearance)
    translate([0, 1, 0])
    rotate([90, 0, 0])
    cylinder(d = screw_diameter + 0.5, h = wall_thickness + 2, $fn = 32);

    // Countersink cone starting at Y=0.01 and going backwards
    translate([0, 0.01, 0])
    rotate([90, 0, 0])
    cylinder(d1 = screw_head_diameter + 0.5, d2 = screw_diameter + 0.5, h = screw_countersink_depth, $fn = 32);
}
