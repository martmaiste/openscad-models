//====================================================================
// OSRAM Nightlux Stair Wall Mount
// File: OSRAM-Nightlux-Stair-Mount.scad
// Version: v0.02
// Date: 2026-06-19
// Description: Parametric slide-in wall mount for OSRAM Nightlux Stair.
//              Features full-length top and bottom tracking lips with
//              soft retention notches on the edges to securely lock the
//              light when slid in from the side.
//====================================================================

/* [Light Dimensions] */
// Width of the light body (side-to-side)
light_width = 84.0; // [50:120]
// Height of the light body (top-to-bottom)
light_height = 73.2; // [50:150]
// Depth of the light body (front-to-back at the edges)
light_depth = 12.4; // [15:50]

/* [Mount Options] */
// Thickness of the backplate
backplate_thickness = 3.0; // [2:6]
// Clearance around the light width (for sliding tolerance)
clearance_width = 0.5; // [0:3]
// Clearance around the light height (for sliding tolerance)
clearance_height = 0.0; // [0:3]
// Clearance around the light depth (for sliding tolerance)
clearance_depth = 0.5; // [0:2]

/* [Slide Rails & Lips] */
// Thickness of the top and bottom walls/lips
wall_thickness = 3.5; // [2:6]
// How far the front lips overlap the light to hold it
lip_overlap = 2.0; // [2:15]

/* [Magnetic Plate Recess] */
// Enable circular recess in the backplate to accommodate the original magnetic mount
enable_recess = true;
// Diameter of the magnetic plate recess
recess_diameter = 34.2; // [20:60]
// Depth of the recess (must be less than backplate_thickness)
recess_depth = 1.5; // [0.5:4]

/* [Screw Holes] */
// Diameter of the screw shaft (3mm screw clearance hole is typically 3.5mm)
screw_shaft_dia = 3.5; // [2.5:5]
// Diameter of the countersink head
screw_head_dia = 6.5; // [4:10]
// Depth of the countersink recess
screw_head_depth = 2.0; // [1:4]
// Distance of vertical screws from the top and bottom edges of the mount
screw_y_offset = 15.0; // [10:40]
// Distance of horizontal screws from the left and right edges of the mount
screw_x_offset = 15.0; // [10:40]

/* [Visualization] */
// Show a translucent placeholder of the OSRAM light to verify fit
show_light = false;

/* [Rendering Quality] */
// Circle resolution
$fn = 60; // [20:120]

// Constant for small overlaps to prevent non-manifold geometries
epsilon = 0.02;

// --- Derived Dimensions ---
// Internal tracking dimensions
track_w = light_width + 2 * clearance_width;
track_h = light_height + 2 * clearance_height;
track_d = light_depth + clearance_depth;

// Outer mount dimensions
total_h = track_h + 2 * wall_thickness;
total_w = track_w;

// Outer edge chamfer for a cleaner print and look
chamfer = min(wall_thickness, 2.0);

// Visualizer alignment coordinates
light_x = clearance_width;
light_y = wall_thickness + clearance_height;


module countersink_screw_hole() {
    // Shaft hole (clearance) going all the way through
    translate([0, 0, -backplate_thickness - 1])
        cylinder(d = screw_shaft_dia, h = backplate_thickness + 2, $fn = $fn);

    // Countersink cone starting at Z = 0 and tapering down in -Z
    translate([0, 0, -screw_head_depth])
        cylinder(d1 = screw_shaft_dia, d2 = screw_head_dia, h = screw_head_depth + epsilon, $fn = $fn);
}

module rail_profile() {
    // 2D Profile of the rails.
    // X in 2D represents Z in 3D (-Z to correctly map the rotation later).
    // Y in 2D represents Y in 3D.
    polygon([
        // Bottom Rail
        [0, 0],
        [-track_d, 0],
        [-(track_d + wall_thickness), chamfer],
        [-(track_d + wall_thickness), wall_thickness + lip_overlap],
        [-track_d, wall_thickness + lip_overlap],
        [-track_d, wall_thickness],
        [0, wall_thickness],

        // Top Rail
        [0, total_h - wall_thickness],
        [-track_d, total_h - wall_thickness],
        [-track_d, total_h - wall_thickness - lip_overlap],
        [-(track_d + wall_thickness), total_h - wall_thickness - lip_overlap],
        [-(track_d + wall_thickness), total_h - chamfer],
        [-track_d, total_h],
        [0, total_h]
    ]);
}

module wall_mount() {
    difference() {
        union() {
            // 1. Solid Backplate
            translate([0, 0, -backplate_thickness])
                cube([total_w, total_h, backplate_thickness]);

            // 2. Extruded Top and Bottom Slide Rails
            translate([0, 0, 0])
                rotate([0, 90, 0])
                    linear_extrude(height = total_w)
                        rail_profile();
        }

        // --- SUBTRACTIONS ---

        // A. Screw Holes (Countersunk)
        // Bottom Vertical Screw
        translate([total_w / 2, screw_y_offset, 0])
            countersink_screw_hole();

        // Top Vertical Screw
        translate([total_w / 2, total_h - screw_y_offset, 0])
            countersink_screw_hole();

        // Left Horizontal Screw
        translate([screw_x_offset, total_h / 2, 0])
            countersink_screw_hole();

        // Right Horizontal Screw
        translate([total_w - screw_x_offset, total_h / 2, 0])
            countersink_screw_hole();

        // B. Magnetic Plate Recess (if enabled)
        if (enable_recess) {
            // Recess is subtracted from the front face of the backplate (Z = 0) down in -Z
            translate([total_w / 2, total_h / 2, -recess_depth])
                cylinder(d = recess_diameter, h = recess_depth + epsilon, $fn = $fn);
        }
    }
}

// Render the assembly
wall_mount();

// Render translucent placeholder of the OSRAM Nightlux Stair light
if (show_light) {
    translate([light_x, light_y, 0]) {
        color([0.9, 0.9, 0.95, 0.4]) {
            // Main body
            cube([light_width, light_height, light_depth]);

            // Motion sensor dome (simplified)
            translate([light_width / 2, light_height * 0.35, light_depth]) {
                color([0.95, 0.95, 0.95, 0.5])
                    sphere(r = 11, $fn = 40);
                color([0.9, 0.9, 0.9, 0.6])
                    cylinder(r = 14, h = 1.5, $fn = 40);
            }

            // LED diffuse window (top half)
            translate([4, light_height * 0.55, light_depth - 1])
                color([1.0, 1.0, 0.9, 0.5])
                cube([light_width - 8, light_height * 0.4, 2]);
        }
    }
}
