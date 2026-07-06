// Version: v0.01
// Description: Parametric ergonomic knob for turning a marquise (awning) 10mm diameter crank.

/* [Main Dimensions] */
// Diameter of the metal crank rod (mm)
crank_diameter = 10.0;
// Tolerance for the rod hole (mm) - increase if it needs to spin freely, decrease for tight fit
tolerance = 0.4;
// Maximum outer diameter of the knob (mm)
knob_max_diameter = 42.0;
// Minimum outer diameter of the knob at the ends (mm)
knob_min_diameter = 34.0;
// Total height of the knob (mm)
knob_height = 80.0;
// How deep the crank rod inserts into the knob (mm)
insertion_depth = 70.0;

/* [Ergonomics] */
// Number of grip grooves around the knob
num_grooves = 6;
// Depth of the grip grooves (mm)
groove_depth = 3.5;
// Rounding radius for top and bottom edges (mm)
rounding_radius = 5.0;

/* [Fastening] */
// Set screw hole diameter (mm) (Set to 0 to disable) - default 2.8 for M3 tap
set_screw_diameter = 2.8;
// Height of the set screw from the bottom of the knob (mm)
set_screw_height = 15.0;

/* [Hidden] */
$fn = 100;

module knob() {
    difference() {
        // Main body
        body();

        // Central hole for the crank
        translate([0, 0, -1])
            cylinder(d=crank_diameter + tolerance, h=insertion_depth + 1);

        // Ergonomic grooves
        if (num_grooves > 0) {
            for (i = [0 : num_grooves - 1]) {
                rotate([0, 0, i * (360 / num_grooves)])
                // Using a stretched sphere for smooth, comfortable groove ends
                translate([(knob_max_diameter / 2) + groove_depth/1.5, 0, knob_height / 2])
                    scale([1, 1, knob_height / 18])
                    sphere(d=groove_depth * 3);
            }
        }

        // Set screw hole (goes from center to one side)
        if (set_screw_diameter > 0) {
            translate([0, 0, set_screw_height])
            rotate([-90, 0, 0])
            cylinder(d=set_screw_diameter, h=knob_max_diameter / 2 + 5, center=false);
        }
    }
}

module body() {
    // Create a barrel-like shape for ergonomic grip
    rotate_extrude() {
        hull() {
            // Bottom rounded corner
            translate([knob_min_diameter/2 - rounding_radius, rounding_radius])
                circle(r=rounding_radius);
            // Top rounded corner
            translate([knob_min_diameter/2 - rounding_radius, knob_height - rounding_radius])
                circle(r=rounding_radius);
            // Middle bulge for barrel shape
            translate([knob_max_diameter/2 - rounding_radius, knob_height / 2])
                circle(r=rounding_radius);
            // Center axis to make it solid
            translate([0, 0])
                square([0.1, knob_height]);
        }
    }
}

// Render the knob
knob();
