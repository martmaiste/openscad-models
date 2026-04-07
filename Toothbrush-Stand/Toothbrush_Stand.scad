// Toothbrush Stand
// Version: v0.13
// Description: A parametric OpenSCAD model for a toothbrush stand.
// Features a central crossbeam at the base with conical indentations
// to support and secure the base of the toothbrushes, with drain holes to prevent moisture buildup.
// The stand now includes spherical feet at each corner to minimize counter contact, lifting the entire stand by the feet\'s radius.
// Recommendation: For best 3D printing results without supports,
// rotate the model -90 degrees around the X-axis so it lays flat on its back.

/* [General Settings] */
// Model Version

// Number of toothbrushes to hold
num_brushes = 3;
// Diameter of the holes to allow head to pass (mm)
hole_diameter = 22;
// Distance between the centers of each hole (mm)
spacing = 32;
// Total height of the stand (mm)
stand_height = 60;

/* [Advanced Settings] */
// Thickness of the top plate (mm)
plate_thickness = 6;
// Wall thickness around the holes (mm)
wall_thickness = 8;
// Thickness of the side legs and support beams (mm)
leg_thickness = 8;
// Corner radius for smooth edges (mm)
corner_radius = 4;
// Additional depth for a more stable base (mm)
base_extension_depth = 20;
// Clearance height for the cross-beam from the counter (mm) - set to 0 as feet provide clearance
cross_beam_clearance = 0;
// Width (Y-axis) of the central cross-beam (mm)
beam_width = 16;
// Diameter of the conical indentation at the top of the beam (mm)
indent_diameter = 14;
// Depth of the conical indentation (mm)
indent_depth = 4;
// Diameter of the small drain hole at the bottom of the indentation (mm)
drain_hole_diameter = 5;
// Chamfer size for the toothbrush holes (mm)
chamfer_size = 1.5;
// Number of fragments for smooth curves
$fn = 64;

// Calculated Dimensions
total_width = (num_brushes - 1) * spacing + hole_diameter + 2 * wall_thickness + 2 * chamfer_size;
total_depth = hole_diameter + 2 * wall_thickness + base_extension_depth + 2 * chamfer_size;
hole_y_pos = total_depth / 2;

module rounded_rect(w, d, h, r) {
    r_safe = min(r, w/2, d/2);
    hull() {
        translate([r_safe, r_safe, 0]) cylinder(r=r_safe, h=h);
        translate([w-r_safe, r_safe, 0]) cylinder(r=r_safe, h=h);
        translate([r_safe, d-r_safe, 0]) cylinder(r=r_safe, h=h);
        translate([w-r_safe, d-r_safe, 0]) cylinder(r=r_safe, h=h);
    }
}

module Toothbrush_Stand() {
    translate([0, 0, corner_radius]) { // Lift the entire stand by the corner_radius
        difference() {
            union() {
                // Top Plate
                difference() {
                    translate([0, 0, stand_height - plate_thickness])
                        rounded_rect(total_width, total_depth, plate_thickness, corner_radius);

                    // Holes for toothbrushes with chamfers
                    for (i = [0 : num_brushes - 1]) {
                        x_pos = wall_thickness + chamfer_size + hole_diameter/2 + i * spacing;
                        union() {
                            // Main cylindrical hole
                            translate([x_pos, hole_y_pos, stand_height - plate_thickness - 1])
                                cylinder(d=hole_diameter, h=plate_thickness + 2, $fn=$fn);

                            // Top chamfer
                            translate([x_pos, hole_y_pos, stand_height - chamfer_size])
                                cylinder(d1=hole_diameter, d2=hole_diameter + 2*chamfer_size, h=chamfer_size + 0.1, $fn=$fn);

                            // Bottom chamfer
                            translate([x_pos, hole_y_pos, stand_height - plate_thickness - 0.1])
                                cylinder(d1=hole_diameter + 2*chamfer_size, d2=hole_diameter, h=chamfer_size + 0.1, $fn=$fn);
                        }
                    }
                }

                // Left Leg
                translate([0, 0, 0])
                    rounded_rect(leg_thickness, total_depth, stand_height, corner_radius);

                // Right Leg
                translate([total_width - leg_thickness, 0, 0])
                    rounded_rect(leg_thickness, total_depth, stand_height, corner_radius);

                // Central Support Beam (At the base, centered under holes)
                translate([0, hole_y_pos - beam_width/2, 0]) // Changed translate Z to 0
                    rounded_rect(total_width, beam_width, leg_thickness, corner_radius);

                // Spherical Feet at corners, matching corner_radius
                // Front-Left
                translate([corner_radius, corner_radius, 0])
                    sphere(r=corner_radius, $fn=$fn);
                // Front-Right
                translate([total_width - corner_radius, corner_radius, 0])
                    sphere(r=corner_radius, $fn=$fn);
                // Back-Left
                translate([corner_radius, total_depth - corner_radius, 0])
                    sphere(r=corner_radius, $fn=$fn);
                // Back-Right
                translate([total_width - corner_radius, total_depth - corner_radius, 0])
                    sphere(r=corner_radius, $fn=$fn);

            }

            // Conical Indentations for Toothbrush Bases
            for (i = [0 : num_brushes - 1]) {
                translate([wall_thickness + chamfer_size + hole_diameter/2 + i * spacing, hole_y_pos, cross_beam_clearance + leg_thickness - indent_depth])
                    cylinder(d1=4, d2=indent_diameter, h=indent_depth + 1, $fn=$fn);
            }

            // Small drain holes in the center of conical indentations
            for (i = [0 : num_brushes - 1]) {
                translate([wall_thickness + chamfer_size + hole_diameter/2 + i * spacing, hole_y_pos, cross_beam_clearance - 1])
                    cylinder(d=drain_hole_diameter, h=leg_thickness + indent_depth + 2, $fn=$fn);
            }
        }
    }
}

// Example of how to call the Toothbrush_Stand module:
// Toothbrush_Stand();
Toothbrush_Stand();
