/*
 * XT90 Male Connector Cap
 * Version: v0.07 (2026-07-28)
 * Author: Zed Coding Agent
 *
 * Description:
 *   A fully parametric, 3D-printable protective cap for XT90 male connectors.
 *   Features a customizable lanyard/thread attachment eyelet to prevent loss
 *   when the battery/device is in use. Includes a tapered lead-in (chamfer)
 *   for smooth insertion and a visualization preview of the connector itself.
 *
 * 3D Printing Tips:
 *   - Material: TPU (flexible) is highly recommended for a snug, rubbery seal.
 *               PETG or PLA can be used, but may require slightly more clearance.
 *   - Orientation: Print flat-side down (Z=0 on the build plate).
 *   - Supports: No supports needed if using "diagonal-corner", "flat-tab-x" or "flat-tab-y"!
 *   - Clearance: Standard is 0.15mm. If using TPU, 0.05mm - 0.1mm is often perfect.
 */

/* [Connector Nominal Dimensions] */
// Width of the XT90 male plug outer housing (mm)
connector_width = 19.5; // [19.0:0.1:22.0]

// Height of the XT90 male plug outer housing (mm)
connector_height = 8.05; // [9.0:0.1:11.5]

// Chamfer size for polarity-keying corners (mm)
connector_chamfer = 2.5; // [1.5:0.1:3.5]

// Corner radius for the outer shell rounding (mm)
corner_radius = 1.0; // [0.0:0.1:2.0]


/* [Cap Settings] */
// Clearance around the connector for fit tolerance (mm). Increase if too tight, decrease if too loose.
clearance = 0.0; // [0.0:0.05:0.5]

// Thickness of the cap's walls (mm)
wall_thickness = 1.6; // [1.0:0.1:3.0]

// Inside depth of the cap cavity (mm)
cap_depth = 11.5; // [8.0:0.5:15.0]


/* [Entry Chamfer / Lead-in] */
// Height of the entry chamfer (mm) to ease insertion
lead_in_height = 1.2; // [0.0:0.1:3.0]

// Width of the entry chamfer lead-in (mm)
lead_in_chamfer = 0.8; // [0.0:0.1:2.0]


/* [Lanyard Attachment] */
// Enable the lanyard/thread attachment loop
enable_lanyard = true;

// Type and position of the lanyard/thread attachment loop
lanyard_position = "diagonal-corner"; // [diagonal-corner, flat-tab-x, flat-tab-y, vertical-bottom]

// Inner diameter of the lanyard hole (mm)
lanyard_hole_diameter = 2; // [1.0:0.1:4.0]

// Outer diameter of the lanyard loop tab (mm)
lanyard_loop_diameter = 4.0; // [3.0:0.1:8.0]

// Thickness of the lanyard loop tab (mm) - (For vertical-bottom loop. Horizontal loops automatically match wall_thickness to prevent cavity intrusion)
lanyard_loop_thickness = 2.0; // [1.0:0.1:4.0]


/* [Preview Settings] */
// Show a semi-transparent preview of the XT90 male connector in the editor
show_preview = true;


/* [Detail Level] */
// Smoothness of circles ($fn)
detail_level = 64; // [16, 32, 64, 128]

// Apply detail level to OpenSCAD system variable
$fn = detail_level;


// =========================================================================
// MAIN ASSEMBLY
// =========================================================================

union() {
    // The main cap body
    cap_body();

    // Add the requested lanyard attachment
    if (enable_lanyard) {
        if (lanyard_position == "diagonal-corner") {
            diagonal_tab();
        } else if (lanyard_position == "flat-tab-x") {
            flat_tab_x();
        } else if (lanyard_position == "flat-tab-y") {
            flat_tab_y();
        } else if (lanyard_position == "vertical-bottom") {
            vertical_bottom_loop();
        }
    }
}

// Visualize the connector inside the cap in the preview
if ($preview && show_preview) {
    connector_visualization();
}


// =========================================================================
// MODULES
// =========================================================================

// Base 2D profile of the nominal XT90 connector housing
// Matches real-world XT90: Left end is flat/square, Right end has both corners chamfered
module xt90_base_profile(w, h, chamfer, r) {
    if (r > 0) {
        offset(r = r) {
            w_inner = w - 2*r;
            h_inner = h - 2*r;
            c_inner = chamfer - r;
            if (c_inner > 0) {
                polygon(points=[
                    [-w_inner/2, -h_inner/2],
                    [w_inner/2 - c_inner, -h_inner/2],
                    [w_inner/2, -h_inner/2 + c_inner],
                    [w_inner/2, h_inner/2 - c_inner],
                    [w_inner/2 - c_inner, h_inner/2],
                    [-w_inner/2, h_inner/2]
                ]);
            } else {
                square([w_inner, h_inner], center=true);
            }
        }
    } else {
        polygon(points=[
            [-w/2, -h/2],
            [w/2 - chamfer, -h/2],
            [w/2, -h/2 + chamfer],
            [w/2, h/2 - chamfer],
            [w/2 - chamfer, h/2],
            [-w/2, h/2]
        ]);
    }
}

// 3D Cap body constructed by subtracting cavity from outer solid
module cap_body() {
    difference() {
        // Outer Shell
        linear_extrude(height = cap_depth + wall_thickness) {
            offset(r = clearance + wall_thickness) {
                xt90_base_profile(connector_width, connector_height, connector_chamfer, corner_radius);
            }
        }

        // Inner Cavity (Main Body)
        translate([0, 0, wall_thickness]) {
            linear_extrude(height = cap_depth - lead_in_height + 0.05) {
                offset(r = clearance) {
                    xt90_base_profile(connector_width, connector_height, connector_chamfer, corner_radius);
                }
            }
        }

        // Inner Cavity (Tapered Lead-in / Entry Chamfer)
        if (lead_in_height > 0 && lead_in_chamfer > 0) {
            translate([0, 0, cap_depth + wall_thickness - lead_in_height]) {
                linear_extrude(
                    height = lead_in_height + 0.1,
                    scale = [
                        1 + lead_in_chamfer / (connector_width / 2 + clearance),
                        1 + lead_in_chamfer / (connector_height / 2 + clearance)
                    ]
                ) {
                    offset(r = clearance) {
                        xt90_base_profile(connector_width, connector_height, connector_chamfer, corner_radius);
                    }
                }
            }
        }
    }
}

// Flat tab extending diagonally along the chamfered corner (highly compact and neat)
module diagonal_tab() {
    // Total offset radius of the outer cap surface
    R = clearance + wall_thickness;

    // Normal direction of the bottom-right chamfer (45 degrees down-right)
    nx = 1 / sqrt(2);
    ny = -1 / sqrt(2);

    // Tangent direction along the chamfer (45 degrees up-right)
    tx = 1 / sqrt(2);
    ty = 1 / sqrt(2);

    // Midpoint of the nominal chamfer line
    mx_nominal = connector_width/2 - connector_chamfer/2;
    my_nominal = -connector_height/2 + connector_chamfer/2;

    // Midpoint of the outer chamfer face (nominal + R * normal)
    mx = mx_nominal + R * nx;
    my = my_nominal + R * ny;

    // Height of the loop is matched to the cap bottom plate thickness to prevent cavity intrusion
    loop_h = wall_thickness;

    // Center of the lanyard loop - moved back (outward) so that the cylinder edge
    // is flush with the inner cavity wall and does not protrude into the hollow cavity space.
    d_offset = max(0, (lanyard_loop_diameter / 2) - wall_thickness);
    cx = mx + d_offset * nx;
    cy = my + d_offset * ny;

    // Inward anchor midpoint (shifted slightly inside the wall to guarantee a perfect merge)
    ax = mx - 0.5 * nx;
    ay = my - 0.5 * ny;

    difference() {
        hull() {
            // Lanyard eyelet cylinder
            translate([cx, cy, 0])
                cylinder(d=lanyard_loop_diameter, h=loop_h);

            // Left and right anchor points inside the chamfer wall
            translate([ax - tx * (lanyard_loop_diameter / 2), ay - ty * (lanyard_loop_diameter / 2), 0])
                cube([0.1, 0.1, loop_h]);
            translate([ax + tx * (lanyard_loop_diameter / 2), ay + ty * (lanyard_loop_diameter / 2), 0])
                cube([0.1, 0.1, loop_h]);
        }
        // Lanyard thread hole
        translate([cx, cy, -1])
            cylinder(d=lanyard_hole_diameter, h=loop_h + 2);
    }
}

// Flat tab extending horizontally along X-axis (extremely 3D-print friendly)
module flat_tab_x() {
    x_pos = connector_width/2 + clearance + wall_thickness;
    loop_h = wall_thickness;

    // Move center back so cylinder is flush with the inner cavity wall
    d_offset = max(0, (lanyard_loop_diameter / 2) - wall_thickness);
    cx = x_pos + d_offset;

    difference() {
        hull() {
            // Circle representing the outer loop
            translate([cx, 0, 0])
                cylinder(d=lanyard_loop_diameter, h=loop_h);

            // Connection block to fuse solidly into the cap wall
            translate([x_pos - 0.5, -lanyard_loop_diameter/2, 0])
                cube([0.6, lanyard_loop_diameter, loop_h]);
        }
        // Thread hole
        translate([cx, 0, -1])
            cylinder(d=lanyard_hole_diameter, h=loop_h + 2);
    }
}

// Flat tab extending horizontally along Y-axis (extremely 3D-print friendly)
module flat_tab_y() {
    y_pos = connector_height/2 + clearance + wall_thickness;
    loop_h = wall_thickness;

    // Move center back so cylinder is flush with the inner cavity wall
    d_offset = max(0, (lanyard_loop_diameter / 2) - wall_thickness);
    cy = y_pos + d_offset;

    difference() {
        hull() {
            // Circle representing the outer loop
            translate([0, cy, 0])
                cylinder(d=lanyard_loop_diameter, h=loop_h);

            // Connection block to fuse solidly into the cap wall
            translate([-lanyard_loop_diameter/2, y_pos - 0.5, 0])
                cube([lanyard_loop_diameter, 0.6, loop_h]);
        }
        // Thread hole
        translate([0, cy, -1])
            cylinder(d=lanyard_hole_diameter, h=loop_h + 2);
    }
}

// Vertical loop sticking out from the closed bottom end (Z < 0)
module vertical_bottom_loop() {
    difference() {
        hull() {
            // Main ring cylinder laid on its side
            translate([0, 0, -lanyard_loop_diameter/2])
                rotate([90, 0, 0])
                    cylinder(d=lanyard_loop_diameter, h=lanyard_loop_thickness, center=true);

            // Connection transition up to the cap's bottom face
            translate([-lanyard_loop_diameter/2, -lanyard_loop_thickness/2, -0.5])
                cube([lanyard_loop_diameter, lanyard_loop_thickness, 0.6]);
        }
        // Thread hole
        translate([0, 0, -lanyard_loop_diameter/2])
            rotate([90, 0, 0])
                cylinder(d=lanyard_hole_diameter, h=lanyard_loop_thickness + 2, center=true);
    }
}

// Simplified visualization of an XT90 male plug for checking fit in preview
module connector_visualization() {
    // Translate the connector up so it sits exactly inside the cap cavity
    translate([0, 0, wall_thickness]) {
        // Shroud body (transparent yellow/orange plastic)
        color([1.0, 0.5, 0.0, 0.4]) {
            linear_extrude(height = 15.0) {
                xt90_base_profile(connector_width, connector_height, connector_chamfer, corner_radius);
            }
        }

        // Two gold-colored bullet pins inside the shroud
        color([0.9, 0.75, 0.15, 0.75]) {
            // Center distance for XT90 pins is ~11mm
            translate([-11.0/2, 0, 0])
                cylinder(d=4.5, h=12.5);

            translate([11.0/2, 0, 0])
                cylinder(d=4.5, h=12.5);
        }
    }
}
