// Gustavsberg-Hydrant-Valve-Key.scad
// Version: v0.06
// Description: Parametric model for a Garden and Hydrant Valve Key.

/* [Socket Parameters] */
// Side length of the square socket (mm)
socket_size = 7.5;
// Depth of the square socket (mm)
socket_depth = 11;

/* [Shaft Parameters] */
// Diameter of the body (socket and shaft) (mm)
body_dia = 20;
// Length of the shaft between socket and handle (mm)
shaft_length = 0;

/* [Handle Parameters] */
// Diameter of the round knob (mm)
handle_dia = 40;
// Height of the round knob (mm)
handle_height = 15;

/* [Detail Parameters] */
// Size of general chamfers (mm)
chamfer_size = 1.5;
// Size of the lead-in chamfer for the square socket (mm)
socket_chamfer = 1.0;
// Number of grip grooves on the knob
grip_count = 24;
// Depth of grip grooves (mm)
grip_depth = 0.8;

/* [General Settings] */
// Resolution of circles/cylinders
$fn = 64;



// Correction for the tip chamfer to avoid overlapping cylinders
module valve_key_fixed() {
    union() {
        // Socket and Shaft
        difference() {
            union() {
                // Body minus the tip chamfer height
                translate([0, 0, chamfer_size])
                    cylinder(h = socket_depth + shaft_length - chamfer_size, d = body_dia);

                // Tip chamfer
                cylinder(h = chamfer_size, r1 = (body_dia/2) - chamfer_size, r2 = body_dia/2);
            }

            // Main Square cutout
            translate([0, 0, socket_depth/2])
                cube([socket_size, socket_size, socket_depth + 2], center = true);

            // Lead-in chamfer for the square socket
            hull() {
                translate([0, 0, -1])
                    cube([socket_size + 2 * socket_chamfer, socket_size + 2 * socket_chamfer, 0.1], center = true);
                translate([0, 0, socket_chamfer])
                    cube([socket_size, socket_size, 0.1], center = true);
            }
        }

        // Handle (Round Knob)
        translate([0, 0, socket_depth + shaft_length])
        difference() {
            union() {
                // Main knob body
                translate([0, 0, chamfer_size])
                    cylinder(h = handle_height - 2*chamfer_size, d = handle_dia);

                // Bottom knob chamfer
                cylinder(h = chamfer_size, r1 = (handle_dia/2) - chamfer_size, r2 = handle_dia/2);

                // Top knob chamfer
                translate([0, 0, handle_height - chamfer_size])
                    cylinder(h = chamfer_size, r1 = handle_dia/2, r2 = (handle_dia/2) - chamfer_size);
            }

            // Grip grooves
            for (i = [0 : grip_count - 1]) {
                rotate([0, 0, i * 360 / grip_count])
                    translate([handle_dia / 2, 0, handle_height/2])
                        cylinder(h = handle_height + 2, d = grip_depth * 2, center = true);
            }
        }
    }
}

// Render the model
valve_key_fixed();
