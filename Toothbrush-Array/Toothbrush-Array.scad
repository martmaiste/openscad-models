// ============================================================
// PARAMETRIC TOOTHBRUSH HOLDER
// ============================================================

/* [General Settings] */
// Number of toothbrushes to hold
num_brushes = 4;
// Diameter of each toothbrush hole (mm)
hole_diameter = 22;
// Height of the holder (mm)
holder_height = 110;
// Thickness of the walls and bottom (mm)
wall_thickness = 3;
// Space between the holes (mm)
spacing = 8;


/* [Conical Bottom Settings] */
// Height of the conical section at the bottom of each hole (mm)
cone_height = 15;
// Size of the chamfer at the top of the hole (mm)
chamfer_size = 2;
// Bottom diameter of the conical section is linked to drain_hole_dia

/* [Hole Depth Settings] */
// How far from bottom the holes end (mm) - leaves material for bottom wall
hole_depth_from_bottom = wall_thickness;

/* [Drainage Settings] */
// Diameter of the drainage holes at the bottom (mm)
drain_hole_dia = 6;


/* [Half-Cut View Settings] */
// Show half-cut view to see inside
enable_half_cut = false;

/* [Detail Settings] */
// Smoothness of curves (higher = smoother)
$fn = 64;

// ============================================================
// CALCULATIONS
// ============================================================

// Calculate the total width based on number of brushes
total_width = (num_brushes * hole_diameter) + ((num_brushes - 1) * spacing) + (2 * wall_thickness);
total_depth = hole_diameter + (2 * wall_thickness);

// ============================================================
// MODULES
// ============================================================

module main_body() {
    hull() {
        translate([wall_thickness, wall_thickness, 0])
            cylinder(r=wall_thickness, h=holder_height);
        translate([total_width - wall_thickness, wall_thickness, 0])
            cylinder(r=wall_thickness, h=holder_height);
        translate([wall_thickness, total_depth - wall_thickness, 0])
            cylinder(r=wall_thickness, h=holder_height);
        translate([total_width - wall_thickness, total_depth - wall_thickness, 0])
            cylinder(r=wall_thickness, h=holder_height);
    }
}

module feet() {
    translate([wall_thickness, wall_thickness, 0])
        sphere(r=wall_thickness);
    translate([total_width - wall_thickness, wall_thickness, 0])
        sphere(r=wall_thickness);
    translate([wall_thickness, total_depth - wall_thickness, 0])
        sphere(r=wall_thickness);
    translate([total_width - wall_thickness, total_depth - wall_thickness, 0])
        sphere(r=wall_thickness);
}

module brush_holes() {
    actual_hole_depth = holder_height - hole_depth_from_bottom;
    for (i = [0 : num_brushes - 1]) {
        // Calculate X position for each hole and translate
        translate([wall_thickness + (hole_diameter/2) + (i * (hole_diameter + spacing)), total_depth/2, hole_depth_from_bottom]) {
            // Conical bottom section for drainage (tapers from narrow bottom to wide top)
            cylinder(d1=drain_hole_dia, d2=hole_diameter, h=cone_height);

            // Main cylindrical section for toothbrush (above the cone)
            translate([0, 0, cone_height])
                cylinder(d=hole_diameter, h=actual_hole_depth - cone_height - chamfer_size);

            // Top chamfer section (wider at the top)
            translate([0, 0, actual_hole_depth - chamfer_size])
                cylinder(d1=hole_diameter, d2=hole_diameter + 2*chamfer_size, h=chamfer_size);

            // Drainage hole at bottom (centered on the bottom wall)
            translate([0, 0, -wall_thickness - 0.1])
                cylinder(d=drain_hole_dia + 0.2, h=wall_thickness * 2 + 0.2);
        }
    }
}

module half_cut_view() {
    difference() {
        union() {
            main_body();
            feet();
        }

        // Cut away front half along Y axis to expose all 4 holes
        translate([-1, -1, -1])
            cube([total_width + 2, total_depth/2, holder_height + 2]);

        // Subtract brush holes
        brush_holes();
    }
}

// ============================================================
// MODEL
// ============================================================

if (enable_half_cut) {
    // Half-cut view to see inside - show left half cut away with holes
    half_cut_view();
} else {
    // Full view - solid body with holes
    difference() {
        union() {
            main_body();
            feet();
        }
        brush_holes();
    }
}
