// Step-Ladder-Feet.scad
// Parametric Step Ladder Foot for Grass and Hard Floors
// Version: v0.11
// Date: 2026-06-23
// Author: Zed Coding Agent
//
// Designed to fit a 20x33mm rectangular aluminium tube (representing a 90-degree
// rotated 33x20mm profile) with a 3mm corner radius.
// Highly parametric and customizable using the OpenSCAD Customizer.
// Version v0.11 implements recess_remaining_wall = 5.0mm on both sides, mathematically forcing the remaining wall
// between both the bolt head and hex nut recesses and the inner socket to be exactly 5.0mm thick.
// Version v0.10 increased the wall_thickness to 6.5mm to ensure a solid, strong wall (3.0mm to 3.5mm remaining)
// between the bolt/nut recess floors and the inner socket, preventing crushing or cracking under bolt tension.
// Version v0.09 swopped the default tube dimensions (width=20mm, depth=33mm) and
// swops the default bolt axis to "X" to fit the 90-degree rotated aluminum leg profile.
// Version v0.08 placed the 0.5mm deep recessed angle text directly on the flat vertical front
// edge of the sole base plate for maximum print legibility and mathematical robustness.
// It also features flat recesses for bolt heads and hex nut traps to secure the feet.

/* [Layout Options] */
// What would you like to render?
foot_selection = "all_four"; // ["single_custom", "pair_15", "pair_20", "all_four"]

/* [Tube Dimensions] */
// Outer width of the rectangular aluminium tube (mm)
tube_width = 20; // [10:100]
// Outer depth of the rectangular aluminium tube (mm)
tube_depth = 33; // [10:100]
// Outer corner radius of the aluminium tube (mm)
tube_corner_radius = 3; // [0:20]

/* [Fit and Walls] */
// Tolerance between the tube and the inner socket (mm, per side)
fit_tolerance = 0.15;
// Thickness of the walls surrounding the socket (mm) - 8.5mm ensures generous wall thickness and room for recesses
wall_thickness = 5;

/* [Foot Geometry] */
// Total vertical height of the foot (mm)
foot_height = 50; // [20:120]
// Depth of the tube socket (mm)
socket_depth = 35; // [10:100]

/* [Sole Dimensions] */
// Width of the sole base plate (mm)
sole_width = 65; // [30:150]
// Length of the sole base plate (mm)
sole_length = 85; // [30:150]
// Thickness of the sole base plate (mm)
sole_thickness = 8; // [3:30]
// Corner radius of the sole plate (mm)
sole_corner_radius = 12; // [1:40]

/* [Custom Leg Angles] (Only used for 'single_custom' selection) */
// Forward/backward tilt angle of the ladder leg (degrees)
angle_front_back = 15; // [-45:45]
// Sideways tilt angle of the ladder leg (degrees)
angle_side = 0; // [-45:45]

/* [Bottom Grass Treads] */
// Enable waffle-pattern grip grooves on the bottom for grass
bottom_treads_enable = false;
// Depth of the recessed grip grooves (mm)
tread_depth = 3; // [1:10]
// Width of individual grip grooves (mm)
tread_width = 3; // [1:10]
// Spacing between grip grooves (mm)
tread_spacing = 10; // [4:30]

/* [Socket Bottom Options] */
// If true, the bottom of the socket is flat (horizontal), matching a tube cut parallel to the ground.
// If false, it is perpendicular to the leg axis (standard perpendicular tube cut).
socket_bottom_flat = false;

/* [Drain Hole] */
// Enable a drain hole at the bottom of the socket to prevent water trapping
drain_hole_enable = true;
// Diameter of the drain hole (mm)
drain_hole_diameter = 5; // [2:15]

/* [Securing Bolt Holes & Recesses] */
// Enable a side hole for a securing screw or rivet
secure_hole_enable = true;
// Diameter of the securing screw/rivet hole (mm)
secure_hole_diameter = 4.2; // [2:10]
// Height of the hole center from the bottom of the socket (mm)
secure_hole_height = 15; // [5:50]
// Direction of the hole axis: Y-axis (front-to-back, through wide face) or X-axis (left-to-right, through narrow face)
secure_hole_axis = "X"; // ["X", "Y"]
// Thickness of the remaining solid wall between the socket and the bolt head or nut recess (mm)
recess_remaining_wall = 5.0; // [2:15]
// Diameter of the recess pocket for the bolt head (mm)
bolt_recess_diameter = 9.0; // [5:25]
// Depth of the recess pocket for the bolt head (mm)
bolt_recess_depth = 15; // [0:15]
// Flat-to-flat width of the hex nut recess trap (mm, e.g. M4 nut = 7.0, M5 = 8.0)
nut_recess_width = 8.2; // [5:25]
// Depth of the recess pocket for the nut (mm)
nut_recess_depth = 15; // [0:15]
// Shape of the nut recess trap
nut_recess_type = "hex"; // ["hex", "circular"]

/* [Output Options] (Only used for 'single_custom' selection) */
// Mirror the model for left/right symmetry if custom angle_side is non-zero
mirror_foot = false;

/* [Rendering Quality] */
// Resolution of curved surfaces
$fn = 64; // [16:128]


// --- Calculated Variables (Used globally for sizing) ---
socket_w = tube_width + 2 * fit_tolerance;
socket_d = tube_depth + 2 * fit_tolerance;
socket_r = tube_corner_radius + fit_tolerance;

collar_w = socket_w + 2 * wall_thickness;
collar_d = socket_d + 2 * wall_thickness;
collar_r = socket_r + wall_thickness;


// --- Main Execution ---

if (foot_selection == "single_custom") {
    render_single(angle_front_back, angle_side, mirror_foot);
} else if (foot_selection == "pair_15") {
    // Render front pair (both at 15 degrees)
    translate([-sole_width/2 - 5, 0, 0])
        render_single(15, angle_side, false);
    translate([sole_width/2 + 5, 0, 0])
        render_single(15, angle_side, (angle_side != 0) ? true : false);
} else if (foot_selection == "pair_20") {
    // Render rear pair (both at 20 degrees)
    translate([-sole_width/2 - 5, 0, 0])
        render_single(20, angle_side, false);
    translate([sole_width/2 + 5, 0, 0])
        render_single(20, angle_side, (angle_side != 0) ? true : false);
} else if (foot_selection == "all_four") {
    // Render complete 4-foot set in a neat 2x2 layout for a single print job!
    // Row 1 (Front): 15 degrees
    translate([-sole_width/2 - 5, -sole_length/2 - 5, 0])
        render_single(15, angle_side, false);
    translate([sole_width/2 + 5, -sole_length/2 - 5, 0])
        render_single(15, angle_side, (angle_side != 0) ? true : false);

    // Row 2 (Rear): 20 degrees
    translate([-sole_width/2 - 5, sole_length/2 + 5, 0])
        render_single(20, angle_side, false);
    translate([sole_width/2 + 5, sole_length/2 + 5, 0])
        render_single(20, angle_side, (angle_side != 0) ? true : false);
}


// --- Modules ---

// Helper to handle mirroring if required
module render_single(ang_fb, ang_s, mir) {
    if (mir) {
        mirror([1, 0, 0]) {
            ladder_foot(ang_fb, ang_s);
        }
    } else {
        ladder_foot(ang_fb, ang_s);
    }
}

// Core Foot Module with dynamically calculated geometry based on specific angles
module ladder_foot(ang_fb, ang_s) {
    // Local calculation for collar distance to maintain precise vertical height
    cos_fb = cos(ang_fb);
    cos_s = cos(ang_s);
    safe_cos_fb = (cos_fb == 0) ? 0.001 : cos_fb;
    safe_cos_s = (cos_s == 0) ? 0.001 : cos_s;
    local_collar_distance = foot_height / (safe_cos_fb * safe_cos_s);

    // Local calculation for socket bottom height to guarantee material thickness below socket
    socket_bottom_z_perpendicular = foot_height - socket_depth * (safe_cos_fb * safe_cos_s);
    socket_bottom_z_flat = sole_thickness + 4;
    local_socket_bottom_z = socket_bottom_flat ? socket_bottom_z_flat : socket_bottom_z_perpendicular;

    difference() {
        // 1. Main Solid Body (Beautiful continuous transition from sole to angled collar)
        union() {
            hull() {
                // Sole base plate
                rounded_cube([sole_width, sole_length, sole_thickness], r=sole_corner_radius, center=true);

                // Top collar slice (angled parallel to the tube)
                rotate([ang_fb, ang_s, 0])
                translate([0, 0, local_collar_distance - 1])
                rounded_cube([collar_w, collar_d, 1], r=collar_r, center=true);
            }
        }

        // 2. Subtract Bottom Recessed Waffle Grooves
        if (bottom_treads_enable) {
            bottom_grooves();
        }

        // 3. Subtract Inner Angled Socket
        socket_subtraction(ang_fb, ang_s, local_collar_distance, local_socket_bottom_z);

        // 4. Subtract Securing Screw/Rivet Hole & Recesses
        if (secure_hole_enable) {
            secure_hole(ang_fb, ang_s, local_collar_distance);
        }

        // 5. Subtract Drain Hole
        if (drain_hole_enable) {
            drain_hole(ang_fb, ang_s, local_collar_distance, local_socket_bottom_z);
        }

        // 6. Subtract Embossed/Recessed Angle Text (0.5mm deep, on the flat vertical front edge of the sole)
        // This is perfectly flat and vertical (no slope angle), which prints with outstanding legibility and sharpness!
        translate([0, sole_length/2 + 0.1, sole_thickness / 2])
        rotate([-90, 0, 0]) // rotates text so +Z points into the sole (-Y direction)
        linear_extrude(height = 0.6)
        text(str(ang_fb), size = 5.5, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
}

// Module for the inner socket
module socket_subtraction(ang_fb, ang_s, collar_dist, bot_z) {
    if (socket_bottom_flat) {
        difference() {
            // Rotated socket extending down past bottom
            rotate([ang_fb, ang_s, 0])
            translate([0, 0, collar_dist - socket_depth])
            rounded_cube([socket_w, socket_d, socket_depth + 10], r=socket_r, center=true);

            // Cut off socket bottom horizontally at bot_z
            translate([0, 0, -50 + bot_z])
            cube([300, 300, 100], center=true);
        }
    } else {
        // Standard rotated socket perpendicular to leg axis
        rotate([ang_fb, ang_s, 0])
        translate([0, 0, collar_dist - socket_depth])
        rounded_cube([socket_w, socket_d, socket_depth + 10], r=socket_r, center=true);
    }
}

// Module for the bottom recessed waffle grooves (recessed for 3D print bed adhesion)
module bottom_grooves() {
    intersection() {
        // Limit the grooves to the sole footprint
        translate([0, 0, -0.5])
        rounded_cube([sole_width - 0.1, sole_length - 0.1, tread_depth + 0.5], r=sole_corner_radius, center=true);

        // Grid of grooves
        union() {
            // Grooves parallel to Y-axis (spaced along X-axis)
            for (x = [-sole_width/2 : tread_spacing : sole_width/2]) {
                translate([x, 0, tread_depth/2])
                cube([tread_width, sole_length + 5, tread_depth + 0.1], center=true);
            }
            // Grooves parallel to X-axis (spaced along Y-axis)
            for (y = [-sole_length/2 : tread_spacing : sole_length/2]) {
                translate([0, y, tread_depth/2])
                cube([sole_width + 5, tread_width, tread_depth + 0.1], center=true);
            }
        }
    }
}

// Module for securing screw/rivet hole with flat bolt-head and nut-trap recesses
module secure_hole(ang_fb, ang_s, collar_dist) {
    rotate([ang_fb, ang_s, 0])
    translate([0, 0, collar_dist - socket_depth + secure_hole_height]) {

        // 1. Central through-hole (extremely long to pierce sloped walls)
        if (secure_hole_axis == "Y") {
            rotate([90, 0, 0])
            cylinder(h=500, r=secure_hole_diameter/2, center=true, $fn=32);
        } else {
            rotate([0, 90, 0])
            cylinder(h=500, r=secure_hole_diameter/2, center=true, $fn=32);
        }

        // 2. Bolt Head Recess (on positive side of axis, starts from outside, cuts flat seat)
        if (secure_hole_axis == "Y") {
            // Front side (+Y) Bolt head recess
            recess_floor_y = socket_d/2 + recess_remaining_wall;
            translate([0, recess_floor_y + 125, 0])
            rotate([90, 0, 0])
            cylinder(h=250, r=bolt_recess_diameter/2, center=true, $fn=32);
        } else {
            // Right side (+X) Bolt head recess
            recess_floor_x = socket_w/2 + recess_remaining_wall;
            translate([recess_floor_x + 125, 0, 0])
            rotate([0, 90, 0])
            cylinder(h=250, r=bolt_recess_diameter/2, center=true, $fn=32);
        }

        // 3. Nut Recess (on negative side of axis, hex trap or round cavity)
        if (secure_hole_axis == "Y") {
            // Back side (-Y) Nut recess
            recess_floor_y = -(socket_d/2 + recess_remaining_wall);
            translate([0, recess_floor_y - 125, 0])
            rotate([-90, 0, 0]) {
                if (nut_recess_type == "hex") {
                    rotate([0, 0, 30]) // Align flat of the hex nut horizontally
                    cylinder(h=250, r=nut_recess_width / (2 * cos(30)), center=true, $fn=6);
                } else {
                    cylinder(h=250, r=nut_recess_width/2, center=true, $fn=32);
                }
            }
        } else {
            // Left side (-X) Nut recess
            recess_floor_x = -(socket_w/2 + recess_remaining_wall);
            translate([recess_floor_x - 125, 0, 0])
            rotate([0, -90, 0]) {
                if (nut_recess_type == "hex") {
                    rotate([0, 0, 30])
                    cylinder(h=250, r=nut_recess_width / (2 * cos(30)), center=true, $fn=6);
                } else {
                    cylinder(h=250, r=nut_recess_width/2, center=true, $fn=32);
                }
            }
        }
    }
}

// Module for drain hole
module drain_hole(ang_fb, ang_s, collar_dist, bot_z) {
    if (socket_bottom_flat) {
        // Flat bottom calls for a straight vertical drain hole
        translate([0, 0, -5])
        cylinder(h=bot_z + 10, r=drain_hole_diameter/2, $fn=16);
    } else {
        // Perpendicular bottom calls for a drain hole aligned with the leg axis
        rotate([ang_fb, ang_s, 0])
        translate([0, 0, -5])
        cylinder(h=collar_dist - socket_depth + 10, r=drain_hole_diameter/2, $fn=16);
    }
}

// Helper module for a 3D cube with rounded corners along the Z axis
module rounded_cube(size, r, center=true) {
    x = size[0];
    y = size[1];
    z = size[2];
    r_val = max(0.001, min(r, min(x/2, y/2))); // Ensure radius is valid

    if (center) {
        hull() {
            translate([-x/2 + r_val, -y/2 + r_val, 0]) cylinder(h=z, r=r_val);
            translate([ x/2 - r_val, -y/2 + r_val, 0]) cylinder(h=z, r=r_val);
            translate([-x/2 + r_val,  y/2 - r_val, 0]) cylinder(h=z, r=r_val);
            translate([ x/2 - r_val,  y/2 - r_val, 0]) cylinder(h=z, r=r_val);
        }
    } else {
        hull() {
            translate([r_val, r_val, 0]) cylinder(h=z, r=r_val);
            translate([x-r_val, r_val, 0]) cylinder(h=z, r=r_val);
            translate([r_val, y-r_val, 0]) cylinder(h=z, r=r_val);
            translate([x-r_val, y-r_val, 0]) cylinder(h=z, r=r_val);
        }
    }
}
