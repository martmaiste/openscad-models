// Oil-Bottle-Base.scad
// Version: v0.03
// Description: Parametric base to protect tables from oil bottle drips with chamfered edges.
//              Supports circular and rectangular (rounded-corner) bottles.

/* [Bottle Shape] */
// Shape of the bottle cross-section
base_shape = "rectangular"; // [circular, rectangular]
// Diameter of the oil bottle (circular mode)
bottle_diameter = 59;
// Width of the oil bottle (rectangular mode)
bottle_width = 56;
// Depth of the oil bottle (rectangular mode)
bottle_depth = 56;
// Corner radius of the bottle (rectangular mode)
corner_radius = 7;
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
inner_w = (base_shape == "circular" ? bottle_diameter : bottle_width) + clearance;
inner_d = (base_shape == "circular" ? bottle_diameter : bottle_depth) + clearance;
inner_r = base_shape == "circular" ? inner_w / 2 : min(corner_radius + clearance, inner_w / 2, inner_d / 2);

outer_w = inner_w + (2 * wall_thickness);
outer_d = inner_d + (2 * wall_thickness);
outer_r = inner_r + wall_thickness;

// A circle is just a rounded rectangle with a full radius
module rounded_box(w, d, h, r) {
    linear_extrude(height = h)
        offset(r = r)
            square(size = [max(w - 2 * r, 0), max(d - 2 * r, 0)], center = true);
}

// Chamfered frustum between two rounded-rect cross-sections
module rounded_frustum(wb, db, rb, wt, dt, rt, h) {
    hull() {
        rounded_box(wb, db, 0.01, rb);
        translate([0, 0, h])
            rounded_box(wt, dt, 0.01, rt);
    }
}

module oil_bottle_base() {
    difference() {
        // Outer Body
        union() {
            // Bottom outer chamfer
            rounded_frustum(outer_w - 2 * chamfer, outer_d - 2 * chamfer, outer_r - chamfer,
                            outer_w, outer_d, outer_r, chamfer);

            // Main middle section
            translate([0, 0, chamfer])
                rounded_box(outer_w, outer_d, base_height - 2 * chamfer, outer_r);

            // Top outer chamfer
            translate([0, 0, base_height - chamfer])
                rounded_frustum(outer_w, outer_d, outer_r,
                                outer_w - 2 * chamfer, outer_d - 2 * chamfer, outer_r - chamfer, chamfer);
        }

        // Inner Cutout
        union() {
            // Main inner hole
            translate([0, 0, wall_thickness])
                rounded_box(inner_w, inner_d, base_height - wall_thickness - chamfer, inner_r);

            // Top inner chamfer (to match the outer top chamfer)
            translate([0, 0, base_height - chamfer])
                rounded_frustum(inner_w, inner_d, inner_r,
                                inner_w + 2 * chamfer, inner_d + 2 * chamfer, inner_r + chamfer, chamfer);
        }
    }
}

// Render the base
oil_bottle_base();
