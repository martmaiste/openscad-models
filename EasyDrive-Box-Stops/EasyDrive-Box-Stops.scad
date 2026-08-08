// =========================================================================
// EasyDrive Box Stops
// Version: v0.01
// Date: 2026-07-28
// Author: Zed Coding Agent
// Description: Parametric OpenSCAD design for EasyDrive Box stops that are
//              glued with double-sided tape on inflatable or rigid
//              wing-foil boards. Prevents the box from moving side-to-side
//              while cargo straps hold the box down on the board.
// =========================================================================

/* [Box & Stop Dimensions] */
// Depth of the box to be secured (mm)
box_depth = 94; // [20:300]

// Width of the double-sided tape / stop profile width (mm)
stop_width = 19; // [5:100]

// Height/thickness of the stop (mm)
stop_height = 7; // [2:20]

// Length of the bracket ends wrapping around the front/back of the box (mm)
end_length = 15; // [5:100]

/* [Smoothing & Rounding] */
// Smoothing/fillet radius for the bottom edges (mm) - keeps a small chamfer/fillet
bottom_smoothing = 0.5; // [0:0.1:5]

// Smoothing/fillet radius for the top edges (mm) - larger to protect bare feet/legs
top_smoothing = 1.5; // [0:0.1:10]

// Inner corner radius in the horizontal XY plane (mm) - keeps corners strong and matches box corners
corner_radius_inner = 2.0; // [0:0.1:20]

// Outer corner radius in the horizontal XY plane (mm) - smooths the profile corners
corner_radius_outer = 4.0; // [0:0.1:20]

/* [Render Options] */
// Which part to render for export
part_to_render = "left"; // ["left": Left Stop, "right": Right Stop, "both": Both Stops]

// Spacing between stops (typically box width) when rendering "both" (mm)
box_width = 160; // [50:500]

// Number of slices for the bottom fillet transition (higher is smoother but slower)
steps_bottom = 8; // [2:30]

// Number of slices for the top fillet transition (higher is smoother but slower)
steps_top = 16; // [2:50]

/* [Visualization Preview] */
// Show 3D mockup of the board, box, and strap in preview mode
show_preview = true;

// Height of the preview box (mm)
preview_box_height = 80;

// Width of the preview cargo strap (mm)
preview_strap_width = 25;


/* [Detail Level] */
// Smoothness of circular segments (number of fragments)
$fn = 64; // [16:128]


// =========================================================================
// Calculated Internal Parameters & Protection Checks
// =========================================================================

// Safety checks to ensure smoothing radii do not exceed stop height
actual_r_bottom = min(bottom_smoothing, stop_height / 2);
actual_r_top = min(top_smoothing, stop_height - actual_r_bottom);

// =========================================================================
// Main Logic & Positioning
// =========================================================================

if (part_to_render == "left") {
    // Render left stop at origin for easy STL export (no color applied to active object)
    stop_3d();

    if ($preview && show_preview) {
        // Render right stop in preview mode (no color)
        translate([box_width, 0, 0])
            mirror([1, 0, 0])
            stop_3d();

        // Render surrounding scenery translated relative to the left stop
        translate([box_width / 2, 0, 0]) {
            draw_preview_scenery();
        }
    }
} else if (part_to_render == "right") {
    // Render right stop at origin for easy STL export (no color applied to active object)
    mirror([1, 0, 0]) stop_3d();

    if ($preview && show_preview) {
        // Render left stop in preview mode (no color)
        translate([-box_width, 0, 0])
            stop_3d();

        // Render surrounding scenery translated relative to the right stop
        translate([-box_width / 2, 0, 0]) {
            draw_preview_scenery();
        }
    }
} else if (part_to_render == "both") {
    // Render both in their actual relative positions (no color applied to active objects)
    translate([-box_width / 2, 0, 0])
        stop_3d();

    translate([box_width / 2, 0, 0])
        mirror([1, 0, 0])
        stop_3d();

    if ($preview && show_preview) {
        draw_preview_scenery();
    }
}

// =========================================================================
// Modules
// =========================================================================

// Generates a single left stop bracket
module stop_3d() {
    smooth_extrude(stop_height, actual_r_bottom, actual_r_top, steps_bottom, steps_top) {
        bracket_2d(box_depth, stop_width, end_length, corner_radius_inner, corner_radius_outer);
    }
}

// 2D profile of the bracket with rounded corners
module bracket_2d(depth, width, ends, r_in, r_out) {
    y_half = depth / 2;

    // 8-point polygon defining the bracket shape [
    // Center of the box edge lies along x=0, y=[-y_half to y_half]
    vertices = [
        [ends, -y_half],                     // 1. Inner back-right tip
        [0, -y_half],                        // 2. Inner back corner
        [0, y_half],                         // 3. Inner front corner
        [ends, y_half],                      // 4. Inner front-right tip
        [ends, y_half + width],              // 5. Outer front-right tip
        [-width, y_half + width],            // 6. Outer front corner
        [-width, -y_half - width],           // 7. Outer back corner
        [ends, -y_half - width]              // 8. Outer back-right tip
    ];

    round_corners_2d(r_in, r_out) {
        polygon(vertices);
    }
}

// 2D double-rounding utility
module round_corners_2d(r_in, r_out) {
    offset(r = r_out)
        offset(r = -(r_in + r_out))
        offset(r = r_in)
        children();
}

// Slices the 2D child shape and extrudes layer-by-layer to form smooth 3D fillets
module smooth_extrude(h, r_bottom, r_top, steps_b, steps_t) {
    // 1. Bottom fillet transition
    if (r_bottom > 0 && steps_b > 0) {
        dz = r_bottom / steps_b;
        for (i = [0 : steps_b - 1]) {
            z_start = i * dz;
            z_mid = (i + 0.5) * dz;
            // Circular profile offset: starts contracted by r_bottom, ends at nominal size (offset=0)
            off = -r_bottom + sqrt(max(0, 2 * r_bottom * z_mid - z_mid * z_mid));

            translate([0, 0, z_start])
                linear_extrude(height = dz + 0.01)
                offset(r = off)
                children();
        }
    }

    // 2. Middle vertical section
    middle_h = h - r_bottom - r_top;
    if (middle_h > 0) {
        translate([0, 0, r_bottom])
            linear_extrude(height = middle_h + 0.01)
            children();
    }

    // 3. Top fillet transition
    if (r_top > 0 && steps_t > 0) {
        dz = r_top / steps_t;
        for (i = [0 : steps_t - 1]) {
            z_start = h - r_top + i * dz;
            z_mid_local = (i + 0.5) * dz;
            // Circular profile offset: starts at nominal size (offset=0), ends contracted by r_top
            off = -r_top + sqrt(max(0, r_top * r_top - z_mid_local * z_mid_local));

            translate([0, 0, z_start])
                linear_extrude(height = dz + 0.01)
                offset(r = off)
                children();
        }
    }
}

// Renders the board, cargo strap, and box for 3D context
module draw_preview_scenery() {
    // 1. Board mockup (extended in Y to fit the strap anchors)
    color([0.7, 0.7, 0.7, 0.3]) {
        translate([0, 0, -50])
            cube([box_width + 120, box_depth + 100, 100], center = true);
    }

    // 2. Secure Box mockup
    color([0.2, 0.4, 0.8, 0.35]) {
        translate([0, 0, preview_box_height / 2])
            cube([box_width, box_depth, preview_box_height], center = true);
    }

    // 3. Cargo strap mockup - runs front-to-back (Y-axis) and slants down to anchors 30mm out
    color([0.9, 0.4, 0.1, 0.65]) {
        // Top flat strap piece (runs in Y, width in X)
        translate([0, 0, preview_box_height + 1])
            cube([preview_strap_width, box_depth, 2], center = true);

        // Front slanting segment (slants down from box_depth/2 to box_depth/2 + 30)
        hull() {
            translate([0, box_depth / 2, preview_box_height])
                cube([preview_strap_width, 2, 2], center = true);
            translate([0, box_depth / 2 + 30, 1])
                cube([preview_strap_width, 2, 2], center = true);
        }

        // Back slanting segment (slants down from -box_depth/2 to -box_depth/2 - 30)
        hull() {
            translate([0, -box_depth / 2, preview_box_height])
                cube([preview_strap_width, 2, 2], center = true);
            translate([0, -box_depth / 2 - 30, 1])
                cube([preview_strap_width, 2, 2], center = true);
        }
    }
}
