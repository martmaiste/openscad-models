// Title: Kiteboard Handle Spacer
// File: Kiteboard-Handle-Spacer.scad
// Version: v0.01
// Date: 2026-05-26
// Author: Zed Coding Agent
// Description: Parametric spacer to raise a kiteboard handle by 40mm.
//              Features a right-trapezoid side profile (sloped outer face, vertical inner face)
//              and a symmetric trapezoid end profile. Fits Crazyfly and other standard handles.

/* [Spacer Dimensions] */
// Total height of the spacer (raises the handle by this amount)
spacer_height = 47; // [10:1:100]

// Width of the spacer at the top interface with the handle (transverse to handle)
top_width = 24; // [10:1:100]

// Width of the spacer at the bottom interface with the board (transverse to handle)
bottom_width = 36; // [10:1:100]

// Length of the spacer at the top (along the length of the handle)
top_length = 37; // [10:1:100]

// Length of the spacer at the bottom (along the length of the handle)
bottom_length = 47; // [10:1:100]

// Corner radius for rounding vertical edges (smooth corners for safety and aerodynamics)
corner_radius = 4; // [0:0.5:15]

/* [Anti-Rotation Lip] */
// Enable the anti-rotation lip at the top edge of the straight vertical inner wall
enable_wall_lip = true;

// Height of the wall lip (normally 1.5mm, corresponds to cylinder radius)
wall_lip_height = 1.5; // [0.5:0.1:5]

// Width of the wall lip (normally 3.0mm, corresponds to cylinder diameter)
wall_lip_width = 3.0; // [1.0:0.1:10]

// Length of the wall lip along the X-axis (normally 14.0mm)
wall_lip_length = 14.0; // [5:1:30]

// Position style: true = flush with the vertical wall (Y=0 to Y=width), false = centered on the vertical wall
wall_lip_flush = true;

/* [Bolt Hole Settings] */
// Distance of the bolt hole from the flat/straight vertical inner side
bolt_distance_from_straight = 20; // [5:1:50]

// Diameter of the bolt through-hole (M6 screw is standard, 6.5mm allows easy clearance)
bolt_diameter = 6.5; // [4:0.1:10]

// Add an optional counterbore/recess for the screw head or washer at the top
enable_counterbore = false;

// Diameter of the counterbore recess (if enabled)
counterbore_diameter = 11.0; // [8:0.1:20]

// Depth of the counterbore recess from the top surface (if enabled)
counterbore_depth = 5.0; // [1:0.5:20]

/* [Advanced / Print Optimization] */
// Smoothness of circles and curves
$fn = 80; // [12:4:200]

// Recommended 3D Printing Settings for Kiteboard Handles:
// - Material: ASA or PETG (ASA is preferred for excellent UV resistance and strength)
// - Perimeters: 4 or more (for high mechanical strength around bolt holes)
// - Infill: 25% to 40% (Gyroid or Grid infill patterns work best)
// - Support: Not required if printed flat on the bottom face (z = 0)

// Helper module to generate a 2D rounded rectangle
// Centered at X = 0, and spanning from Y = 0 to Y = length
module profile_2d(width, length, radius) {
    inner_w = width - 2 * radius;
    inner_l = length - 2 * radius;

    if (inner_w > 0 && inner_l > 0) {
        translate([-inner_w / 2, radius])
        offset(r = radius)
        square([inner_w, inner_l]);
    } else {
        // Fallback to simple rectangle if radius is too large
        translate([-width / 2, 0])
        square([width, length]);
    }
}

module spacer_body() {
    // Clamp corner radius to prevent geometric errors
    safe_r_top = min(corner_radius, top_width / 2 - 0.1, top_length / 2 - 0.1);
    safe_r_bot = min(corner_radius, bottom_width / 2 - 0.1, bottom_length / 2 - 0.1);

    hull() {
        // Bottom profile at z = 0
        linear_extrude(height = 0.05)
        profile_2d(bottom_width, bottom_length, safe_r_bot);

        // Top profile at z = spacer_height - 0.05
        translate([0, 0, spacer_height - 0.05])
        linear_extrude(height = 0.05)
        profile_2d(top_width, top_length, safe_r_top);
    }
}

// Helper module to generate a 3D half-cylinder along the X-axis
module half_cylinder(diameter, length) {
    radius = diameter / 2;
    difference() {
        rotate([0, 90, 0])
        cylinder(d = diameter, h = length, center = true);

        // Cut away the bottom half (Z < 0)
        translate([-length, -radius - 1, -radius * 2])
        cube([length * 2, radius * 2 + 2, radius * 2]);
    }
}

module spacer_with_holes() {
    difference() {
        union() {
            spacer_body();

            // Add the anti-rotation wall lip
            if (enable_wall_lip && wall_lip_length > 0 && wall_lip_width > 0) {
                y_pos = wall_lip_flush ? (wall_lip_width / 2) : 0;
                translate([0, y_pos, spacer_height])
                half_cylinder(wall_lip_width, wall_lip_length);
            }
        }

        // Bolt through-hole
        translate([0, bolt_distance_from_straight, -1])
        cylinder(d = bolt_diameter, h = spacer_height + 2);

        // Optional counterbore at the top
        if (enable_counterbore) {
            translate([0, bolt_distance_from_straight, spacer_height - counterbore_depth])
            cylinder(d = counterbore_diameter, h = counterbore_depth + 1);
        }
    }
}

// Instantiate the model
spacer_with_holes();
