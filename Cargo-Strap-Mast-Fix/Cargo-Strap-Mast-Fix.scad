/*
 * Parametric Cargo Strap Guide for Wing Foil Boards
 * Version: v0.07
 * Mounts under the mast base plate rear bolt and provides a
 * secure, low-profile loop for a cargo strap.
 */

// --- Parameters ---

/* [Strap Dimensions] */
// Width of the cargo strap (mm)
strap_width = 25.0; // [10:0.5:50]

// Thickness of the cargo strap (mm)
strap_thickness = 1.0; // [1:0.1:5]

// Clearance for the strap to easily pass through (mm)
strap_clearance = 0.5; // [0:0.1:3]

/* [Hardware Dimensions] */
// Diameter of the mast track bolt hole (M6 -> 6.5mm, M8 -> 8.5mm)
bolt_diameter = 6.5; // [5:0.1:10]

// Diameter of the washer / flat area for the bolt head (mm)
bolt_head_dia = 16.0; // [10:1:25]

// Thickness of the mast base plate (mm)
base_plate_thickness = 8.0; // [4:0.5:15]

// Distance from bolt center to the rear edge of the base plate (mm)
// Set to 14mm to bring the hole as close as possible according to the 14-16mm range.
bolt_to_edge_dist = 16.0; // [10:1:30]

/* [Part Settings] */
// Clearance between base plate edge and the drop-down of the holder (mm)
// Set to 0 to tuck the drop-down immediately behind the base plate edge.
edge_clearance = 0.0; // [0:0.5:5]

// Clearance between the bottom of the holder and the board to avoid scratching (mm)
// Set to 0 so the part sits completely flush against the board with no gap.
board_clearance = 0.0; // [0:0.5:5]

// General wall thickness (determines strength) (mm)
wall_thickness = 4.0; // [2:0.5:8]

// Overall width of the holder (mm)
part_width = 20.0; // [15:1:35]

// Drop-down vertical support wall thickness to prevent snapping (mm)
support_wall_thickness = 4.0; // [2:0.5:10]

// Radius for edge chamfering/rounding to remove sharp edges (mm)
chamfer_radius = 1.0; // [0:0.5:3]

// Smoothness (number of facets for cylinders)
$fn = 64;

/* [Hidden] */
tunnel_inner_length = strap_width + strap_clearance * 2;
tunnel_inner_height = strap_thickness + strap_clearance * 2;

arm_thickness = wall_thickness;
tunnel_outer_length = tunnel_inner_length + support_wall_thickness + wall_thickness;
tunnel_outer_height = tunnel_inner_height + wall_thickness * 2;

// Ensure the part is wide enough for the washer
actual_part_width = max(part_width, bolt_head_dia + 4);
flat_end_y = actual_part_width / 2;

// Ensure the tunnel doesn't interfere with the flat washer mounting surface
tunnel_y_start = max(bolt_to_edge_dist + edge_clearance, flat_end_y);

// Determine the top height of the tunnel block
tunnel_top = max(base_plate_thickness + arm_thickness, board_clearance + tunnel_outer_height);

// Safe chamfer radius so we don't invert normals or break geometry
safe_chamfer = max(0, min(chamfer_radius, wall_thickness/2 - 0.05, arm_thickness/2 - 0.05));

module rounded_rect_yz(length, height, radius, width) {
    r = min(radius, min(length/2, height/2) - 0.01);
    if (r < 0.1) {
        cube([width, length, height]);
    } else {
        translate([0, r, r])
        hull() {
            translate([0, 0, 0]) rotate([0, 90, 0]) cylinder(r=r, h=width);
            translate([0, length - 2*r, 0]) rotate([0, 90, 0]) cylinder(r=r, h=width);
            translate([0, 0, height - 2*r]) rotate([0, 90, 0]) cylinder(r=r, h=width);
            translate([0, length - 2*r, height - 2*r]) rotate([0, 90, 0]) cylinder(r=r, h=width);
        }
    }
}

module flared_strap_hole(y, z, inner_L, inner_H, r, part_W, c) {
    // Central hole
    translate([-part_W/2 - 1, y, z])
        rounded_rect_yz(inner_L, inner_H, r, part_W + 2);

    // Left flare (-X)
    hull() {
        translate([-part_W/2 + c, y, z])
            rounded_rect_yz(inner_L, inner_H, r, 0.01);
        translate([-part_W/2 - 0.1, y - c - 0.1, z - c - 0.1])
            rounded_rect_yz(inner_L + 2*(c+0.1), inner_H + 2*(c+0.1), r + c + 0.1, 0.01);
    }

    // Right flare (+X)
    hull() {
        translate([part_W/2 - c - 0.01, y, z])
            rounded_rect_yz(inner_L, inner_H, r, 0.01);
        translate([part_W/2 + 0.1, y - c - 0.1, z - c - 0.1])
            rounded_rect_yz(inner_L + 2*(c+0.1), inner_H + 2*(c+0.1), r + c + 0.1, 0.01);
    }
}

module strap_guide_body_raw(c) {
    union() {
        // Bolt ring
        translate([0, 0, base_plate_thickness + c])
            cylinder(d=actual_part_width - 2*c, h=max(0.01, arm_thickness - 2*c));

        // Fill corners so the arm is a solid rectangle up to the flat_end_y
        // We overlap backwards to y = -0.1 to avoid microscopic gaps at y=0
        translate([-(actual_part_width - 2*c)/2, -0.1, base_plate_thickness + c])
            cube([actual_part_width - 2*c, flat_end_y + 0.2, max(0.01, arm_thickness - 2*c)]);

        // Sloped arm extension to connect smoothly with the tunnel block
        if (tunnel_y_start > flat_end_y) {
            translate([-(actual_part_width - 2*c)/2, flat_end_y, base_plate_thickness + c])
                hull() {
                    // Overlap with the fill corners
                    translate([0, -0.1, 0])
                        cube([actual_part_width - 2*c, 0.2, max(0.01, arm_thickness - 2*c)]);

                    // Extend it well INTO the tunnel block by crossing the boundary
                    translate([0, tunnel_y_start - flat_end_y + c + 0.5, 0])
                        cube([actual_part_width - 2*c, 0.1, max(0.01, tunnel_top - base_plate_thickness - 2*c)]);
                }
        }

        // Solid drop-down support wall (extends from the bottom of the arm down to the board clearance level)
        // This prevents the part from snapping when under tension by filling the gap between the arm and the board behind the base plate
        if (flat_end_y > bolt_to_edge_dist + edge_clearance) {
            translate([-(actual_part_width - 2*c)/2, bolt_to_edge_dist + edge_clearance, board_clearance + c])
                cube([
                    actual_part_width - 2*c,
                    flat_end_y - (bolt_to_edge_dist + edge_clearance) + c + 0.1, // fill all the way to the tunnel
                    base_plate_thickness - board_clearance // fill from board clearance up to base plate height
                ]);
        }

        // Tunnel block
        r = max(0.01, min(wall_thickness/2, 3) - c); // corner radius for back edges
        translate([-(actual_part_width - 2*c)/2, tunnel_y_start + c, board_clearance + c]) {
            hull() {
                // Front bottom face
                translate([0, 0, 0]) cube([actual_part_width - 2*c, 0.1, 0.01]);
                // Front top face
                translate([0, 0, max(0.01, tunnel_top - board_clearance - 2*c - 0.01)]) cube([actual_part_width - 2*c, 0.1, 0.01]);

                // Back bottom rounded edge
                translate([0, tunnel_outer_length - 2*c - r, r])
                    rotate([0, 90, 0]) cylinder(r=r, h=actual_part_width - 2*c);
                // Back top rounded edge
                translate([0, tunnel_outer_length - 2*c - r, max(r, tunnel_top - board_clearance - 2*c - r)])
                    rotate([0, 90, 0]) cylinder(r=r, h=actual_part_width - 2*c);
            }
        }
    }
}

module rounded_solid_body(c) {
    if (c > 0) {
        minkowski() {
            strap_guide_body_raw(c);
            sphere(r=c, $fn=16); // Lower fn for performance during minkowski
        }
    } else {
        strap_guide_body_raw(0);
    }
}

module strap_guide() {
    difference() {
        // --- Solid body (fully rounded exterior) ---
        rounded_solid_body(safe_chamfer);

        // --- Subtractions ---

        // Bolt hole
        translate([0, 0, -1])
            cylinder(d=bolt_diameter, h=tunnel_top + 2);

        // Bolt hole top & bottom chamfers
        if (safe_chamfer > 0) {
            // top chamfer
            translate([0, 0, base_plate_thickness + arm_thickness - safe_chamfer])
                cylinder(d1=bolt_diameter, d2=bolt_diameter + 2*safe_chamfer, h=safe_chamfer + 0.1);
            // bottom chamfer
            translate([0, 0, base_plate_thickness - 0.1])
                cylinder(d1=bolt_diameter + 2*safe_chamfer, d2=bolt_diameter, h=safe_chamfer + 0.1);
        }

        // Tunnel strap hole with flared (chamfered) openings
        hole_r = 1.0;
        if (safe_chamfer > 0) {
            flared_strap_hole(
                tunnel_y_start + support_wall_thickness,
                board_clearance + wall_thickness,
                tunnel_inner_length,
                tunnel_inner_height,
                hole_r,
                actual_part_width,
                safe_chamfer
            );
        } else {
            translate([-actual_part_width/2 - 1, tunnel_y_start + support_wall_thickness, board_clearance + wall_thickness])
                rounded_rect_yz(tunnel_inner_length, tunnel_inner_height, hole_r, actual_part_width + 2);
        }

        // Trim anything below Z=0 to ensure the base stays perfectly flat for printing
        translate([-actual_part_width, -actual_part_width, -10])
            cube([actual_part_width*2, tunnel_y_start + tunnel_outer_length + actual_part_width, 10]);
    }
}

// Render the part
// By setting board_clearance to 0, the bottom of the part rests perfectly on Z=0,
// and the bottom of the attaching eye (bolt ring) sits exactly at Z=base_plate_thickness (8mm).
strap_guide();
