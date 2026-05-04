/*
 * Parametric Pipe Bracket for 40mm Pipe
 * Version: 0.01
 * Description: Heavy-duty wall bracket with offset, securing a pipe via an M8 bolt.
 * Designed to be sturdy enough such that two brackets can securely hold a 3m pipe.
 *
 * Printing: Recommended to print flat on the wall-mounting side (Z=0).
 * No supports should be required.
 */

// --- Parameters ---

// Pipe outer diameter (mm)
pipe_diameter = 40;

// Distance from the wall to the center of the pipe (mm)
wall_offset = 60;

// Diameter of the main holding bolt (M8 = 8.6mm for clearance)
bolt_hole_diameter = 8.6;

// Nut or Bolt head across-flats width for captive recess on wall side (M8 = ~13.0mm, using 13.6mm for 3D printing tolerance)
nut_width_af = 13.6;

// Depth of the captive nut/bolt head recess
nut_depth = 7.0;

// Distance between the two wall mounting screws
wall_screw_distance = 75;

// Wall mounting screw shaft diameter
wall_screw_diameter = 5.5;

// Wall mounting screw head diameter (for countersink and flat clearance)
wall_screw_head_diameter = 12.0;

// Overall width of the bracket (mm)
bracket_width = 30;

// Thickness of the base plate against the wall
base_thickness = 10;

// How deep the pipe sits in the bracket cradle (mm)
cradle_depth = 12;

// Global resolution for smooth curves
$fn = 100;

// --- Derived Values ---
// Calculate height of the center column to correctly match the cradle depth
column_height = wall_offset - (pipe_diameter / 2) + cradle_depth;

// Convert across-flats distance to outer diameter for the $fn=6 cylinder
nut_diameter = nut_width_af / cos(30);

// --- Main Module ---
module pipe_bracket() {
    difference() {
        // 1. Solid Body
        union() {
            // Base Plate
            hull() {
                translate([wall_screw_distance/2, 0, 0])
                    cylinder(d=bracket_width, h=base_thickness);
                translate([-wall_screw_distance/2, 0, 0])
                    cylinder(d=bracket_width, h=base_thickness);
            }

            // Central Support Column
            cylinder(d=bracket_width, h=column_height);

            // Structural Ribs (Tapering before screw holes to leave a flat driving surface)
            hull() {
                cylinder(d=bracket_width, h=column_height);
                translate([wall_screw_distance/2 - wall_screw_head_diameter/2 - 2, -bracket_width/2, 0])
                    cube([0.1, bracket_width, base_thickness]);
            }
            hull() {
                cylinder(d=bracket_width, h=column_height);
                translate([-(wall_screw_distance/2 - wall_screw_head_diameter/2 - 2) - 0.1, -bracket_width/2, 0])
                    cube([0.1, bracket_width, base_thickness]);
            }
        }

        // 2. Subtractive Cutouts

        // Pipe Cradle Cutout (Runs along the Y-axis)
        translate([0, 0, wall_offset])
            rotate([-90, 0, 0])
                translate([0, 0, -bracket_width/2 - 1])
                    cylinder(d=pipe_diameter, h=bracket_width + 2);

        // Main M8 Bolt Hole (Runs through the Z-axis)
        translate([0, 0, -1])
            cylinder(d=bolt_hole_diameter, h=wall_offset + pipe_diameter + 2);

        // Captive Hex Nut/Bolt Head Recess (At the wall side)
        translate([0, 0, -1])
            cylinder(d=nut_diameter, h=nut_depth + 1, $fn=6);

        // Wall Mount Screw Holes (Countersunk)
        for(x = [wall_screw_distance/2, -wall_screw_distance/2]) {
            translate([x, 0, -1]) {
                // Main shaft hole
                cylinder(d=wall_screw_diameter, h=base_thickness + 2);

                // Countersink cone (prints cleanly without supports facing upwards)
                translate([0, 0, base_thickness - 4 + 1])
                    cylinder(d1=wall_screw_diameter, d2=wall_screw_head_diameter, h=4.01);

                // Vertical clearance above the base to allow screwdriver access
                translate([0, 0, base_thickness + 1])
                    cylinder(d=wall_screw_head_diameter, h=column_height + 2);
            }
        }
    }
}

// Render the bracket
pipe_bracket();
