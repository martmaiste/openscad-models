// Oil-Bottle-Base.scad
// Version: v0.02
// Description: Parametric base to protect tables from oil bottle drips with chamfered edges.

/* [Bottle Dimensions] */
// Diameter of the oil bottle
bottle_diameter = 85;
// Extra space around the bottle for easy placement
clearance = 0.5;

/* [Base Dimensions] */
// Thickness of the walls and the bottom
wall_thickness = 2.0;
// Total height of the base tray
base_height = 5.0;
// Size of the chamfers for edges
chamfer = 0.5;

/* [Rendering] */
// Quality of curves (higher = smoother)
$fn = 100;

// Derived calculations
inner_diameter = bottle_diameter + clearance;
outer_diameter = inner_diameter + (2 * wall_thickness);

module oil_bottle_base() {
    difference() {
        // Outer Body
        union() {
            // Bottom outer chamfer
            cylinder(h = chamfer, d1 = outer_diameter - 2 * chamfer, d2 = outer_diameter);

            // Main middle section
            translate([0, 0, chamfer])
                cylinder(h = base_height - 2 * chamfer, d = outer_diameter);

            // Top outer chamfer
            translate([0, 0, base_height - chamfer])
                cylinder(h = chamfer, d1 = outer_diameter, d2 = outer_diameter - 2 * chamfer);
        }

        // Inner Cutout
        union() {
            // Main inner hole
            translate([0, 0, wall_thickness])
                cylinder(h = base_height - wall_thickness - chamfer, d = inner_diameter);

            // Top inner chamfer (to match the outer top chamfer)
            translate([0, 0, base_height - chamfer])
                cylinder(h = chamfer, d1 = inner_diameter, d2 = inner_diameter + 2 * chamfer);
        }
    }
}

// Render the base
oil_bottle_base();
