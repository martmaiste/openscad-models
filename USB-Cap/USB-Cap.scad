// v0.09 - Added chamfers to all four edges of the back end of the cap.
// Parameters for the USB-A plug
plug_width = 12.5;
plug_thickness = 2.1;
plug_length = 10;

// Parameters for the cap
cap_thickness = 2;

// Parameters for the ears
ear_leg_x = 5; // Length of the leg extending the cap's width (along X-axis)
ear_leg_y = 8; // Length of the leg extending into the cap from its front face (along Y-axis)

// Parameters for rounding
round_radius = 1; // Radius for rounding the outer edges

// Parameters for chamfering
chamfer_size = 1; // Size for chamfering the back edges

// Calculate outer dimensions of the cap
outer_width = plug_width + (2 * cap_thickness);
outer_length = plug_length + (2 * cap_thickness);
outer_height = plug_thickness + (2 * cap_thickness);

// Calculate inner dimensions of the cap (cavity)
inner_width = plug_width;
inner_length = plug_length;
inner_height = plug_thickness;
module usb_cap() {
    union() {
        // Main cap body with the cavity/opening
        difference() {
            // Outer body of the cap, which is a simple cube
            cube([outer_width, outer_length, outer_height]);

            // Chamfers for the four edges of the back end
            // 1. Top-back edge (along X-axis, at Y=outer_length, Z=outer_height)
            // Chamfers for the four edges of the back end
            //
            // 1. Bottom-back edge (along X-axis, at Y=outer_length, Z=outer_height)
            translate([0, outer_length ,  0]) {
                rotate([0, 90, 0]) { // Align polygon in YZ, extrude along X
                    linear_extrude(height = outer_width) {
                        #polygon([[0,0], [-chamfer_size, 0], [0, -chamfer_size]]);
                    }
                }
            }

            // 2. Top-back edge (along X-axis, at Y=outer_length, Z=0)
            translate([0, outer_length, outer_height]) {
                rotate([0, 90, 0]) { // Align polygon in YZ, extrude along X
                    linear_extrude(height = outer_width) {
                        polygon([[0,0], [chamfer_size, 0], [0, -chamfer_size]]);
                    }
                }
            }

            // 3. Left-back edge (along Z-axis, at X=0, Y=outer_length)
            translate([0, outer_length, 0]) {
                linear_extrude(height = outer_height) {
                    polygon([[0,0], [chamfer_size, 0], [0, -chamfer_size]]);
                }
            }

            // 4. Right-back edge (along Z-axis, at X=outer_width, Y=outer_length)
            translate([outer_width, outer_length, 0]) {
                linear_extrude(height = outer_height) {
                    polygon([[0,0], [-chamfer_size, 0], [0, -chamfer_size]]);
                }
            }

            // Inner cavity with an opening on one side
            // Position the cavity to start at Y=0 of the outer body
            // and extend inward for inner_length + cap_thickness,
            // leaving a cap_thickness wall at the other end.
            translate([cap_thickness, 0, cap_thickness]) {
                // This cube represents the void for the USB plug.
                // It cuts through the cap from the Y=0 side.
                cube([inner_width, inner_length + cap_thickness, inner_height]);
            }
        }

        // Triangular ears
        // Ear 1: on the right side of the cap (positive X side)
        // Its top surface is aligned with the cap's top surface.
        // It starts at the front edge (Y=0) of the cap.
        translate([
            outer_width, // Start at the positive X edge of the cap
            0, // Start at the front (Y=0) edge of the cap
            outer_height - cap_thickness // Bottom of extrusion aligns with cap's top surface
        ]) {
            linear_extrude(height = cap_thickness) {
                polygon([
                    [0, 0],                             // Corner on the cap's front-right edge (local X,Y)
                    [0, ear_leg_y],                     // Leg extending backwards along the cap's Y-direction (into the cap)
                    [ear_leg_x, 0]                      // Leg extending outwards along the cap's X-direction (making it wider)
                ]);
            }
        }

        // Ear 2: on the left side of the cap (negative X side)
        // Its top surface is aligned with the cap's top surface.
        // It starts at the front edge (Y=0) of the cap.
        translate([
            0, // Start at the negative X edge of the cap
            0, // Start at the front (Y=0) edge of the cap
            outer_height - cap_thickness // Bottom of extrusion aligns with cap's top surface
        ]) {
            linear_extrude(height = cap_thickness) {
                polygon([
                    [0, 0],                             // Corner on the cap's front-left edge (local X,Y)
                    [0, ear_leg_y],                     // Leg extending backwards along the cap's Y-direction (into the cap)
                    [-ear_leg_x, 0]                     // Leg extending outwards along the cap's X-direction (making it wider)
                ]);
            }
        }
    }
}

usb_cap();
