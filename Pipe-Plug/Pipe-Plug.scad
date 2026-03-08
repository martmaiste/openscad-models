// File: Pipe-Plug.scad
// Version: v0.03
// Description: Parametric plug with a constant diameter hollow inside.

/* [Dimensions] */

// Outer Diameter of the plug body (mm). Should match the pipe ID.
plug_od = 50; // [10:200]

// Length of the part of the plug that goes inside the pipe (mm).
plug_length = 40; // [10:200]

// Diameter of the wider flange/stop (mm). Should be larger than pipe OD.
flange_od = 60; // [20:250]

// Thickness of the flange (mm).
flange_height = 5; // [1:50]

// Length of the tapered section at the insertion end (mm).
taper_length = 10; // [0:50]

// Diameter reduction at the tip of the taper (mm).
taper_reduction = 2; // [0:20]

// Wall thickness of the plug (mm).
wall_thickness = 4; // [1:20]

/* [Hidden] */
$fn = 200; // Fragment number for smoothness

module pipe_plug() {
    // Calculate tip diameter for the outer shape
    tip_od = plug_od - taper_reduction;

    difference() {
        // --- Create the outer, solid shape first ---
        union() {
            // Flange (stopper)
            cylinder(d = flange_od, h = flange_height);

            // Straight part of the plug body
            translate([0, 0, flange_height])
                cylinder(d = plug_od, h = plug_length - taper_length);

            // Tapered part of the plug body
            translate([0, 0, flange_height + plug_length - taper_length])
                cylinder(d1 = plug_od, d2 = tip_od, h = taper_length);
        }

        // --- Create the inner cylindrical shape to be subtracted ---

        // Calculate inner diameter
        inner_d = plug_od - (2 * wall_thickness);

        // Only proceed if the wall thickness is not too large
        if (inner_d > 0) {
            // Create a single cylinder starting from the top of the flange and
            // extending slightly beyond the top of the plug (+1) to ensure a clean cut.
            translate([0, 0, flange_height])
                cylinder(d = inner_d, h = plug_length + 1);
        }
    }
}

// Render the final plug
pipe_plug();
