// File: Pipe-Plug-WS85.scad
// Version: v0.16
// Description: Parametric plug with a conical riser and mount for a WS85 anemometer.
//              Features a robust filleted mount pocket for improved printability and
//              optional degree markings on the flange.
//              optional degree markings on the flange.

/* [Plug Dimensions] */

// Outer Diameter of the plug body (mm). Should match the pipe ID.
plug_od = 33.9; // [10:200]

// Length of the part of the plug that goes inside the pipe (mm).
plug_length = 30; // [10:200]

// Diameter of the wider flange/stop (mm). Should be larger than pipe OD.
flange_od = 40; // [20:250]

// Thickness of the flange (mm).
flange_height = 5; // [1:50]

// Length of the tapered section at the insertion end (mm).
taper_length = 10; // [0:50]

// Diameter reduction at the tip of the taper (mm).
taper_reduction = 2; // [0:20]

// Wall thickness of the plug (mm).
wall_thickness = 4; // [1:20]

/* [Riser Dimensions] */

// Height of the conical riser on top of the flange (mm).
riser_height = 30;

// Diameter of the riser at its tip (mm).
riser_tip_diameter = 20;

/* [Anemometer Mount] */

// Side length of the square recession at the tip (mm).
mount_recession_side = 10.5;

// Depth of the square recession (mm).
mount_recession_depth = 13;

// Radius for the inner corners and bottom fillet of the square recession (mm).
mount_corner_radius = 1; // [0:5]

// Diameter of the central hole for the M3 bolt (mm).
m3_hole_diameter = 3.2; // Slightly larger for clearance

// Diameter of the counterbore for the M3 bolt head/nut (mm).
m3_counterbore_diameter = 8;

// Depth of the counterbore from the inside ceiling of the plug (mm).
// This reduces the material thickness to allow a shorter bolt.
m3_counterbore_depth = 17; // Reduces bolt travel from ~22mm to ~8mm

// Thickness of the sacrificial layer at the top of the bolt hole for support-free printing.
// Set to 0 to make the hole go all the way through.
sacrificial_layer_thickness = 0.4; // [0:5]



/* [Flange Markings] */

// Enable or disable the vertical degree marks on the flange.
flange_marks_enabled = true;

// Angle between each mark in degrees.
flange_mark_angle_step = 10;

// Radius of the standard marks (mm).
mark_radius = 0.5;

// Radius of the major marks at 0, 90, 180, 270 degrees (mm).
major_mark_radius = 1;

/* [Hidden] */
$fn = 200; // Fragment number for smoothness

// --- Helper Modules ---

// A torus with major radius R and minor radius r.
// Includes a check to prevent rotate_extrude() errors when the major radius is zero.
module torus(R, r) {
    // If the major radius is effectively zero, a sphere is topologically equivalent
    // and avoids the rotate_extrude() error.
    if (R < 0.001) {
        sphere(r = r);
    } else {
        rotate_extrude(convexity = 10)
            translate([R, 0, 0])
                circle(r = r);
    }
}

// A cylinder with a filleted bottom edge.
module filleted_bottom_cylinder(h, r, fillet_r) {
    hull() {
        // The main part of the cylinder, sitting on top of the fillet
        translate([0, 0, fillet_r])
            cylinder(h = h - fillet_r, r = r);

        // The torus that forms the rounded bottom edge
        translate([0, 0, fillet_r])
            torus(R = r - fillet_r, r = fillet_r);
    }
}

// --- Main Module ---

module pipe_plug_with_mount() {
    // Calculated values
    tip_od = plug_od - taper_reduction;
    inner_d = plug_od - (2 * wall_thickness);

    difference() {
        // --- 1. Create the main solid body ---
        union() {
            // Tapered Plug Tip (at the bottom, z=0)
            cylinder(d1 = tip_od, d2 = plug_od, h = taper_length);

            // Straight part of the plug body
            translate([0, 0, taper_length])
                cylinder(d = plug_od, h = plug_length - taper_length);

            // Flange
            translate([0, 0, plug_length])
                cylinder(d = flange_od, h = flange_height);

            // Conical Riser on top of the flange
            translate([0, 0, plug_length + flange_height])
                cylinder(d1 = flange_od, d2 = riser_tip_diameter, h = riser_height);

            // Vertical degree marks on the flange
            if (flange_marks_enabled) {
                for (a = [0:flange_mark_angle_step:359]) {
                    is_major_mark = (a % 90 == 0);
                    current_radius = is_major_mark ? major_mark_radius : mark_radius;
                    // Ensure flange is tall enough for the marks
                    if (flange_height >= 2 * current_radius) {
                        rotate([0, 0, a]) {
                            // Position capsule on the outer surface of the flange, flush with top and bottom
                            translate([flange_od / 2, 0, plug_length]) {
                                hull() {
                                    translate([0, 0, current_radius])
                                        sphere(r = current_radius);
                                    translate([0, 0, flange_height - current_radius])
                                        sphere(r = current_radius);
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- 2. Subtract the inner and mounting shapes ---
        union() {
            // Inner hollow part of the plug body
            if (inner_d > 0) {
                translate([0, 0, -1])
                    cylinder(d = inner_d, h = plug_length + 2);
            }

            // Square recession with rounded corners and bottom fillet
            recession_z_start = plug_length + flange_height + riser_height - mount_recession_depth;
            recession_height = mount_recession_depth + 1; // +1 for clean cut
            fillet_radius = mount_corner_radius;
            translate([0, 0, recession_z_start]) {
                offset = mount_recession_side / 2 - fillet_radius;
                hull() {
                    // Place a filleted cylinder at each corner to create the rounded pocket
                    translate([offset, offset, 0])
                        filleted_bottom_cylinder(h = recession_height, r = fillet_radius, fillet_r = fillet_radius);
                    translate([-offset, offset, 0])
                        filleted_bottom_cylinder(h = recession_height, r = fillet_radius, fillet_r = fillet_radius);
                    translate([offset, -offset, 0])
                        filleted_bottom_cylinder(h = recession_height, r = fillet_radius, fillet_r = fillet_radius);
                    translate([-offset, -offset, 0])
                        filleted_bottom_cylinder(h = recession_height, r = fillet_radius, fillet_r = fillet_radius);
                }
            }



            // Counterbore for the M3 bolt head/nut inside the plug
            translate([0, 0, plug_length])
                cylinder(d = m3_counterbore_diameter, h = m3_counterbore_depth + 0.1);

            // Central M3 bolt hole
            hole_start_z = plug_length;
            material_thickness = (flange_height + riser_height) - mount_recession_depth - m3_counterbore_depth;
            hole_height = material_thickness - sacrificial_layer_thickness;
            total_hole_height = hole_height + m3_counterbore_depth;
            translate([0, 0, hole_start_z])
                cylinder(d = m3_hole_diameter, h = total_hole_height);
        }
    }
}

// --- Render the final model ---
pipe_plug_with_mount();
