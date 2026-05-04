// Version: v0.10
// Parametric Toothbrush Holder

/* [General Settings] */
// Number of toothbrush holes
num_brushes = 4;
// Show half-cut view for internal inspection
show_cut_view = false;
// Diameter of each toothbrush hole (mm)
brush_dia = 20;
// Height of the conical bottom transition (mm)
cone_height = 10;
// Wall thickness (mm)
wall_thickness = 3;

/* [Base Settings] */
// Overall diameter of the base (mm)
base_dia = 80;
// Total height of the holder (mm)
base_height = 90;
// Diameter of the drainage holes at the bottom (mm)
drain_dia = 5;
// Diameter of the feet (mm)
foot_dia = 10;
// Size of the chamfers at top and bottom (mm)
chamfer_size = 2;

/* [Advanced Settings] */
// Resolution of circles
$fn = 256;

// Logic to calculate hole distribution radius
hole_radius = (base_dia / 2) - (brush_dia / 2) - wall_thickness;

module toothbrush_holder() {
    difference() {
        union() {
            // Main Body with chamfers
            cylinder(h = chamfer_size, d1 = base_dia - 2 * chamfer_size, d2 = base_dia);
            translate([0, 0, chamfer_size])
                cylinder(h = base_height - 2 * chamfer_size, d = base_dia);
            translate([0, 0, base_height - chamfer_size])
                cylinder(h = chamfer_size, d1 = base_dia, d2 = base_dia - 2 * chamfer_size);

            // Feet
            for (i = [0 : 3]) {
                angle = i * 90 + 45;
                foot_pos_radius = (base_dia / 2) * 0.8;
                translate([cos(angle) * foot_pos_radius, sin(angle) * foot_pos_radius, 0])
                    sphere(d = foot_dia);
            }
        }

        // Toothbrush Holes
        if (num_brushes == 1) {
            // Main shaft
            translate([0, 0, wall_thickness + cone_height - 0.1])
                cylinder(h = base_height - (wall_thickness + cone_height - 0.1) + 1, d = brush_dia);
            // Conical bottom
            translate([0, 0, wall_thickness])
                cylinder(h = cone_height, d1 = drain_dia, d2 = brush_dia);
            // Top chamfer
            translate([0, 0, base_height - chamfer_size])
                cylinder(h = chamfer_size + 1, d1 = brush_dia, d2 = brush_dia + 2 * chamfer_size);
        } else {
            for (i = [0 : num_brushes - 1]) {
                angle = i * 360 / num_brushes;
                pos = [cos(angle) * hole_radius, sin(angle) * hole_radius];

                // Main shaft
                translate([pos[0], pos[1], wall_thickness + cone_height - 0.1])
                    cylinder(h = base_height - (wall_thickness + cone_height - 0.1) + 1, d = brush_dia);
                // Conical bottom
                translate([pos[0], pos[1], wall_thickness])
                    cylinder(h = cone_height, d1 = drain_dia, d2 = brush_dia);
                // Top chamfer
                translate([pos[0], pos[1], base_height - chamfer_size])
                    cylinder(h = chamfer_size + 1, d1 = brush_dia, d2 = brush_dia + 2 * chamfer_size);

                // Individual drainage hole for each brush
                translate([pos[0], pos[1], -1])
                    cylinder(h = wall_thickness + 2, d = drain_dia);
            }
        }



        // Half-cut view for inspection
        if (show_cut_view) {
            translate([0, -base_dia/2, -1])
                cube([base_dia, base_dia, base_height + 2]);
        }
    }
}

// Render the model
toothbrush_holder();
