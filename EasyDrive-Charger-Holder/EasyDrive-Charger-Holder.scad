// ==============================================================================
// EasyDrive Battery Charger Wall Mount
// File: EasyDrive-Charger-Holder.scad
// Version: v0.28
// Date: 2026-07-29
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

/* [Status LED Hole] */
// Enable an optional cutout/hole in the front wall for the status LED
enable_led_hole = true;
// Diameter of the inner LED status hole in mm
led_hole_diameter = 6.0;
// Distance of the LED from the left side of the charger in mm (use 133 for 24mm from the right side)
led_x_offset = 133.0;
// Distance of the LED from the bottom of the charger in mm
led_z_offset = 14.0;
// Enable a flare/countersink on the outside of the LED hole for better viewing angle
enable_led_countersink = true;
// Outer diameter of the flare/countersink in mm (default 10.0mm creates a 45-degree angle with 2.0mm depth)
led_hole_countersink_diameter = 10.0;
// Depth of the flare/countersink taper into the wall in mm
led_hole_countersink_depth = 2.0;

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

        // 4. Status LED hole (optional)
        if (enable_led_hole) {
            // Main inner pilot hole (goes all the way through the wall)
            translate([clearance + led_x_offset, D_inner - 1, led_z_offset])
            rotate([-90, 0, 0])
            cylinder(d = led_hole_diameter, h = wall_thickness + 2, $fn = 64);

            // Optional outer flare/countersink for better angular visibility
            if (enable_led_countersink && led_hole_countersink_diameter > led_hole_diameter && led_hole_countersink_depth > 0) {
                let (depth = min(led_hole_countersink_depth, wall_thickness - 0.5)) {
                    // Tapered cone starting from the depth of the countersink up to the outer face
                    translate([clearance + led_x_offset, D_inner + wall_thickness - depth, led_z_offset])
                    rotate([-90, 0, 0])
                    cylinder(d1 = led_hole_diameter, d2 = led_hole_countersink_diameter, h = depth, $fn = 64);

                    // Clean-cut cylinder extending beyond the outer face to prevent any thin-wall artifacts
                    translate([clearance + led_x_offset, D_inner + wall_thickness - 0.01, led_z_offset])
                    rotate([-90, 0, 0])
                    cylinder(d = led_hole_countersink_diameter, h = 2, $fn = 64);
                }
            }
        }

        // 5. CHAMFERS (PHASES) ON OUTWARD-FACING EDGES ONLY
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

                // --- Back wall exposed portion corners/edges (Z and X axes) ---
                // Left-front vertical edge of back wall above side walls (Z-axis)
                translate([-wall_thickness, 0, pocket_height + (back_wall_height - pocket_height)/2])
                rotate([0, 0, 45])
                cube([s2, s2, back_wall_height - pocket_height + 0.1], center=true);

                // Right-front vertical edge of back wall above side walls (Z-axis)
                translate([W_inner + wall_thickness, 0, pocket_height + (back_wall_height - pocket_height)/2])
                rotate([0, 0, 45])
                cube([s2, s2, back_wall_height - pocket_height + 0.1], center=true);

                // Top-front edge of the back wall (X-axis) - guides the charger down and rounds the exposed top-front edge
                translate([W_inner/2, 0, back_wall_height])
                rotate([45, 0, 0])
                cube([W_outer + 2, s2, s2], center=true);

                // --- Transition spheres between back wall vertical chamfers and side wall horizontal chamfers ---
                // Left transition sphere to blend the horizontal side-wall and vertical back-wall chamfers
                translate([-wall_thickness, 0, pocket_height])
                sphere(r = c, $fn = 32);

                // Right transition sphere to blend the horizontal side-wall and vertical back-wall chamfers
                translate([W_inner + wall_thickness, 0, pocket_height])
                sphere(r = c, $fn = 32);

                // --- Back plate top-left and top-right corner chamfers (XZ plane) ---
                // Top-left corner
                translate([-wall_thickness, -wall_thickness / 2, back_wall_height])
                rotate([0, 45, 0])
                cube([s2, wall_thickness + 2, s2], center=true);

                // Top-right corner
                translate([W_inner + wall_thickness, -wall_thickness / 2, back_wall_height])
                rotate([0, -45, 0])
                cube([s2, wall_thickness + 2, s2], center=true);

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

                // --- Side ventilation cutouts chamfers (X-axis, outer & inner) ---
                if (enable_side_recessions) {
                    // Left outer side chamfer cone
                    translate([-wall_thickness - 1, D_inner / 2, pocket_height + side_recession_z_offset])
                    rotate([0, 90, 0])
                    cylinder(r1 = side_recession_radius + c + 1, r2 = side_recession_radius, h = c + 1, $fn = 128);

                    // Left inner side chamfer cone
                    translate([-c, D_inner / 2, pocket_height + side_recession_z_offset])
                    rotate([0, 90, 0])
                    cylinder(r1 = side_recession_radius, r2 = side_recession_radius + c + 1, h = c + 1, $fn = 128);

                    // Right inner side chamfer cone
                    translate([W_inner - 1, D_inner / 2, pocket_height + side_recession_z_offset])
                    rotate([0, 90, 0])
                    cylinder(r1 = side_recession_radius + c + 1, r2 = side_recession_radius, h = c + 1, $fn = 128);

                    // Right outer side chamfer cone
                    translate([W_inner + wall_thickness - c, D_inner / 2, pocket_height + side_recession_z_offset])
                    rotate([0, 90, 0])
                    cylinder(r1 = side_recession_radius, r2 = side_recession_radius + c + 1, h = c + 1, $fn = 128);
                }

                // --- Bottom plate cutout chamfer frustums (outer & inner) ---
                if (enable_bottom_cutout && (W_inner > 2 * bottom_margin) && (D_inner > 2 * bottom_margin)) {
                    let (W_cut = W_inner - 2 * bottom_margin, D_cut = D_inner - 2 * bottom_margin) {
                        // Outer bottom chamfer frustum (Z-axis)
                        hull() {
                            translate([bottom_margin - c, bottom_margin - c, -bottom_thickness - 0.01])
                            cube([W_cut + 2 * c, D_cut + 2 * c, 0.01]);

                            translate([bottom_margin, bottom_margin, -bottom_thickness + c])
                            cube([W_cut, D_cut, 0.01]);
                        }

                        // Inner bottom chamfer frustum (Z-axis)
                        hull() {
                            translate([bottom_margin, bottom_margin, -c])
                            cube([W_cut, D_cut, 0.01]);

                            translate([bottom_margin - c, bottom_margin - c, 0.01])
                            cube([W_cut + 2 * c, D_cut + 2 * c, 0.01]);
                        }
                    }
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

        // Status LED mockup on the front face of the charger (non-printed background object)
        %translate([clearance + led_x_offset, clearance + charger_depth, led_z_offset])
        rotate([-90, 0, 0])
        cylinder(d = 3, h = 1.0, $fn = 16);
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
