// ==============================================================================
// Makita-Vacuum-Nozzles-Mount.scad
// ==============================================================================
// Parametric Wall / IKEA SKÅDIS Mount for Makita Cordless Vacuum Cleaner Nozzles
// Compatible with Makita DCL180, DCL182, DCL280, CL106, etc. (28mm pipe size)
// Matches IKEA SKÅDIS 40mm/20mm hole grid
//
// Supports two mounting styles:
// 1. "vertical": Nozzles hang vertically flat against the wall, saving room space
//    in narrow corridors or utility closets.
// 2. "horizontal": Nozzles stick out perpendicularly from the wall.
//
// Version: v0.04 (2026-07-10)
// Author: Zed Coding Agent
// License: Creative Commons - Attribution - ShareAlike
// ==============================================================================

/* [Mounting Style Options] */
// Style of the mount. "vertical" keeps nozzles flat against the wall (highly recommended for narrow spaces); "horizontal" lets them stick out.
mount_style = "vertical"; // ["vertical", "horizontal"]

// Distance from the wall to the center of the pegs (mm) - only used in "vertical" style.
// Ensures that the nozzle bodies have enough room and do not touch the wall.
wall_clearance = 32.0; // [25.0:1.0:50.0]

// Thickness of the vertical triangular support ribs/gussets (mm) - only used in "vertical" style.
gusset_thickness = 4.0; // [2.0:0.5:10.0]


/* [Nozzle Peg Parameters] */
// Standard Makita nozzle inner diameter (mm).
nozzle_diameter = 28.0; // [25.0:0.1:35.0]

// Height of the mounting peg (mm).
peg_length = 35.0; // [20.0:1.0:60.0]

// Taper of the peg (mm). Reduces diameter at the tip for a wedge/friction fit.
peg_taper = 1.0; // [0.0:0.1:3.0]

// Upward angle of the pegs (degrees) - only used in "horizontal" style.
peg_angle = 12.0; // [0.0:0.5:25.0]

// Number of pegs to generate.
num_pegs = 3; // [1:1:5]

// Distance between pegs center-to-center (mm).
// Recommend 80mm or 120mm to avoid nozzle collision and align with Skadis grid.
peg_spacing = 80.0; // [40.0:10.0:200.0]

// Whether the pegs should be hollow to save filament and printing time.
hollow_pegs = true;

// Wall thickness of the hollow pegs (mm). Only active if hollow_pegs is true.
peg_wall_thickness = 3.5; // [2.0:0.5:8.0]

// Diameter of dust drain hole in the center of each peg (mm). 0 to disable.
// Prevents debris and dust from collecting inside the pegs.
drain_hole_diameter = 6.0; // [0.0:1.0:15.0]


/* [Base / Flange Parameters] */
// Thickness of the mounting base plate/flange (mm).
base_thickness = 4.5; // [3.0:0.5:10.0]

// Corner radius for the base plate (mm) for rounded corners.
base_corner_radius = 6.0; // [0.0:1.0:15.0]


/* [IKEA SKÅDIS / Mounting Grid Parameters] */
// IKEA SKÅDIS horizontal column spacing (mm). 40mm is the default grid, but you can use 20mm for fine adjustments.
skadis_grid_x = 40.0;

// IKEA SKÅDIS vertical row spacing (mm). 40mm is the standard vertical grid spacing.
skadis_grid_y = 40.0;

// Number of horizontal screw holes.
num_holes_x = 4; // [1:1:6]

// Number of vertical screw holes.
num_holes_y = 1; // [1:1:4]

// Diameter of the mounting screw/bolt shaft (mm). 4.5mm or 5.0mm works well for M4/M5 on Skadis.
screw_hole_diameter = 4.5; // [3.0:0.1:6.0]

// Diameter of the screw head counterbore/recess (mm) to make screw flush.
screw_recess_diameter = 9.0; // [5.0:0.1:15.0]

// Depth of the screw head counterbore recess (mm).
screw_recess_depth = 2.0; // [0.0:0.5:8.0]


/* [Rendering Parameters] */
// Smoothness factor for curves ($fn). Higher is smoother but slower to render.
render_smoothness = 80; // [20:10:150]

// ==============================================================================
// CALCULATIONS & VALS (DO NOT CHANGE)
// ==============================================================================
$fn = render_smoothness;

// Calculate distance between outermost holes
calculated_hole_spacing_x = (num_holes_x - 1) * skadis_grid_x;
calculated_hole_spacing_y = (num_holes_y - 1) * skadis_grid_y;

// Calculate minimum dimensions needed for horizontal style
min_base_width_for_pegs = (num_pegs - 1) * peg_spacing + nozzle_diameter + 16.0;
min_base_width_for_holes = calculated_hole_spacing_x + 20.0;

base_width = max(min_base_width_for_pegs, min_base_width_for_holes);
base_height = calculated_hole_spacing_y + 24.0; // Height of base for horizontal mount

// Parameters specifically for vertical L-bracket style
flange_height = calculated_hole_spacing_y + 24.0; // Height of vertical wall flange
shelf_depth = wall_clearance + nozzle_diameter / 2 + 5.0; // Horizontal extension of shelf

// Print diagnostic info to console
echo("=== Makita Vacuum Nozzles Mount Diagnostic ===");
echo(str("Mount Style: ", mount_style));
echo(str("Base Plate Width: ", base_width, " mm"));
if (mount_style == "vertical") {
    echo(str("Vertical Flange Height: ", flange_height, " mm"));
    echo(str("Horizontal Shelf Depth: ", shelf_depth, " mm"));
    echo(str("Wall-to-Peg Clearance: ", wall_clearance, " mm"));
} else {
    echo(str("Base Plate Height: ", base_height, " mm"));
}
echo(str("Peg Spacing: ", peg_spacing, " mm"));
echo(str("Horizontal Hole Spacing: ", calculated_hole_spacing_x, " mm (Grid: ", skadis_grid_x, " mm)"));
echo(str("Vertical Hole Spacing: ", calculated_hole_spacing_y, " mm (Grid: ", skadis_grid_y, " mm)"));
echo("==============================================");

// ==============================================================================
// MAIN ROUTINE
// ==============================================================================

if (mount_style == "vertical") {
    vertical_mount();
} else {
    horizontal_mount();
}

// ==============================================================================
// MOUNT MODULES
// ==============================================================================

// Module for generating the vertical space-saving L-bracket mount
module vertical_mount() {
    union() {
        // 1. VERTICAL FLANGE (Flat against the wall, standing up in Z, thickness along Y)
        difference() {
            // Rounded corners on the top edge, perfectly flat/square on the bottom edge where it meets the shelf
            translate([0, base_thickness, 0])
                rotate([90, 0, 0])
                    half_rounded_plate(base_width, flange_height, base_thickness, base_corner_radius);

            // Subtract screw holes (horizontal cylinders through the flange along Y axis)
            for (i = [0 : num_holes_x - 1]) {
                for (j = [0 : num_holes_y - 1]) {
                    hole_x = (num_holes_x > 1) ? (-calculated_hole_spacing_x / 2 + i * skadis_grid_x) : 0;
                    hole_z = (num_holes_y > 1) ? (flange_height / 2 - calculated_hole_spacing_y / 2 + j * skadis_grid_y) : flange_height / 2;

                    translate([hole_x, 0, hole_z])
                        horizontal_screw_hole(screw_hole_diameter, screw_recess_diameter, screw_recess_depth, base_thickness);
                }
            }
        }

        // 2. HORIZONTAL SHELF (Extends horizontally from flange at y=base_thickness to y=base_thickness+shelf_depth)
        difference() {
            // Main shelf body - rounded corners on the front edge, perfectly flat/square on the back meeting edge
            translate([0, base_thickness, 0])
                half_rounded_plate(base_width, shelf_depth, base_thickness, base_corner_radius);

            // Subtract vertical drain holes through the shelf (aligned with peg centers)
            for (k = [0 : num_pegs - 1]) {
                peg_x = (num_pegs > 1) ? (-((num_pegs - 1) * peg_spacing) / 2 + k * peg_spacing) : 0;
                peg_y = base_thickness + wall_clearance;

                if (drain_hole_diameter > 0) {
                    translate([peg_x, peg_y, -1.0])
                        cylinder(d=drain_hole_diameter, h=base_thickness + 2.0, $fn=50);
                }
            }
        }

        // 3. VERTICAL PEGS (Pointing straight up in Z, centered at peg_y = base_thickness + wall_clearance)
        for (k = [0 : num_pegs - 1]) {
            peg_x = (num_pegs > 1) ? (-((num_pegs - 1) * peg_spacing) / 2 + k * peg_spacing) : 0;
            peg_y = base_thickness + wall_clearance;

            translate([peg_x, peg_y, base_thickness]) {
                nozzle_peg(0); // Angle is 0 because the peg stands straight up
            }
        }

        // 4. TRIANGULAR SUPPORT RIBS (GUSSETS)
        // Strengthens the 90° angle between the vertical flange and the horizontal shelf.
        // Outer edge and inner gap calculations
        gusset_width = shelf_depth - 10.0;
        gusset_height = flange_height - base_corner_radius - base_thickness;

        // Left outer gusset
        translate([-base_width / 2 + gusset_thickness / 2, base_thickness, base_thickness])
            gusset(gusset_width, gusset_height, gusset_thickness);

        // Right outer gusset
        translate([base_width / 2 - gusset_thickness / 2, base_thickness, base_thickness])
            gusset(gusset_width, gusset_height, gusset_thickness);

        // Inner gussets (automatically placed in the gaps between adjacent pegs)
        if (num_pegs > 1) {
            for (g = [0 : num_pegs - 2]) {
                gap_x = -((num_pegs - 1) * peg_spacing) / 2 + g * peg_spacing + peg_spacing / 2;
                translate([gap_x, base_thickness, base_thickness])
                    gusset(gusset_width, gusset_height, gusset_thickness);
            }
        }
    }
}

// Module for generating the original horizontal flat-pack mount
module horizontal_mount() {
    union() {
        // 1. BASE PLATE WITH HOLES & OPTIONAL LABEL
        difference() {
            // Main base plate body
            rounded_cube([base_width, base_height, base_thickness], base_corner_radius);

            // Subtract screw holes (centered symmetrically)
            for (i = [0 : num_holes_x - 1]) {
                for (j = [0 : num_holes_y - 1]) {
                    hole_x = (num_holes_x > 1) ? (-calculated_hole_spacing_x / 2 + i * skadis_grid_x) : 0;
                    hole_y = (num_holes_y > 1) ? (-calculated_hole_spacing_y / 2 + j * skadis_grid_y) : 0;

                    translate([hole_x, hole_y, 0])
                        screw_hole(screw_hole_diameter, screw_recess_diameter, screw_recess_depth, base_thickness);
                }
            }
        }

        // 2. MOUNTING PEGS (Centered symmetrically, angled upwards by peg_angle)
        for (k = [0 : num_pegs - 1]) {
            peg_x = (num_pegs > 1) ? (-((num_pegs - 1) * peg_spacing) / 2 + k * peg_spacing) : 0;
            peg_y = 0;

            translate([peg_x, peg_y, base_thickness]) {
                nozzle_peg(peg_angle);
            }
        }
    }
}

// ==============================================================================
// COMPONENT MODULES & HELPER FUNCTIONS
// ==============================================================================

// Module for generating a single tapered, angled mounting peg
module nozzle_peg(angle) {
    difference() {
        union() {
            // Main tapered peg rotated
            rotate([-angle, 0, 0])
                cylinder(d1=nozzle_diameter, d2=nozzle_diameter - peg_taper, h=peg_length, $fn=$fn);

            // Beveled reinforcement collar at the base for maximum strength
            cylinder(d1=nozzle_diameter + 4.0, d2=nozzle_diameter, h=3.0, $fn=$fn);
        }

        // Hollow out the core of the peg if enabled (aligned with rotated peg)
        if (hollow_pegs) {
            rotate([-angle, 0, 0])
                translate([0, 0, 2.0]) // Leave a solid 2mm thick floor at the base of the peg
                    cylinder(d1=nozzle_diameter - 2 * peg_wall_thickness,
                             d2=nozzle_diameter - peg_taper - 2 * peg_wall_thickness,
                             h=peg_length, $fn=$fn);
        }

        // Dust drain hole (goes straight down vertically through the shelf/base plate)
        if (drain_hole_diameter > 0) {
            translate([0, 0, -base_thickness - 1.0])
                cylinder(d=drain_hole_diameter, h=base_thickness + 10.0, $fn=50);
        }
    }
}

// Module for a vertical screw hole with optional counterbore/recess (horizontal mount)
module screw_hole(d, head_d, head_h, total_h) {
    // Screw shaft hole going completely through the plate
    translate([0, 0, -1.0])
        cylinder(d=d, h=total_h + 2.0, $fn=50);

    // Screw head recess at the top of the plate
    if (head_h > 0 && head_d > d) {
        translate([0, 0, total_h - head_h])
            cylinder(d=head_d, h=head_h + 0.1, $fn=50);
    }
}

// Module for a horizontal screw hole with optional counterbore (vertical mount flange)
module horizontal_screw_hole(d, head_d, head_h, total_h) {
    // Screw shaft hole drilled through flange along Y axis
    translate([0, -1.0, 0])
        rotate([-90, 0, 0])
            cylinder(d=d, h=total_h + 2.0, $fn=50);

    // Screw head recess on the front face (y = total_h)
    if (head_h > 0 && head_d > d) {
        translate([0, total_h - head_h, 0])
            rotate([-90, 0, 0])
                cylinder(d=head_d, h=head_h + 0.1, $fn=50);
    }
}

// Module for a rounded cube centered on X and Y, flat on Z (0 to z)
module rounded_cube(size, r) {
    x = size[0];
    y = size[1];
    z = size[2];

    if (r > 0) {
        translate([-x/2, -y/2, 0]) {
            hull() {
                translate([r, r, 0]) cylinder(r=r, h=z, $fn=50);
                translate([x-r, r, 0]) cylinder(r=r, h=z, $fn=50);
                translate([r, y-r, 0]) cylinder(r=r, h=z, $fn=50);
                translate([x-r, y-r, 0]) cylinder(r=r, h=z, $fn=50);
            }
        }
    } else {
        translate([-x/2, -y/2, 0])
            cube(size);
    }
}

// Module for generating a plate with rounded corners on ONLY ONE edge (e.g., top or front)
// The bottom/back edge remains perfectly square/flat. Centered horizontally on X.
module half_rounded_plate(w, h, thickness, r) {
    if (r > 0) {
        linear_extrude(height = thickness) {
            hull() {
                // Flat rectangle spanning the bottom/back edge to retain sharp 90° corners
                translate([-w / 2, 0])
                    square([w, r]);

                // Rounded circles for the opposite/outer edge
                translate([-w / 2 + r, h - r])
                    circle(r = r, $fn = 50);
                translate([w / 2 - r, h - r])
                    circle(r = r, $fn = 50);
            }
        }
    } else {
        translate([-w / 2, 0, 0])
            cube([w, h, thickness]);
    }
}

// Module for generating a triangular support rib/gusset in the Y-Z plane
module gusset(y_len, z_len, thick) {
    translate([thick / 2, 0, 0])
        rotate([0, -90, 0])
            linear_extrude(height = thick)
                polygon(points = [[0, 0], [z_len, 0], [0, y_len]]);
}
