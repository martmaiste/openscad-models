/*
 * Parametric Symmetrical Dual-Pipe Pole Mount
 * Version: v0.05
 *
 * Attaches to an 89mm post with two M6 bolts.
 * Accommodates a 30mm pipe with a 20mm deep socket on both sides.
 * Outer outline forms a perfect continuous cylinder when clamped together.
 * Outer top and bottom edges are chamfered to eliminate sharp corners.
 * Print two identical halves and clamp them around the post.
 */

$fn = 100; // High resolution for smooth curves

// --- Core Parameters ---

// Post Parameters
post_diameter = 89;

// Pipe Parameters
pipe_diameter = 30;
pipe_socket_depth = 20;

// Hardware & Assembly Parameters
bolt_diameter = 6;       // M6 Bolts
bolt_head_diameter = 16; // Diameter of bolt head / washer / socket wrench clearance
nut_width_across_flats = 10; // M6 nut width across flats
clamp_gap = 1;           // Total gap between the two halves to ensure tight clamping (1mm per side)

// Material & Structural Tuning
wall_thickness = 10;     // Minimum wall thickness around the pipe and post
flange_thickness = 10;   // Thickness of the material clamped tightly by the bolt
edge_chamfer = 3;        // Chamfer size for the top and bottom outer edges

// Fit Clearances (compensate for 3D printer tolerance)
pipe_clearance = 0.5;    // Added to pipe diameter for easy insertion
bolt_clearance = 0.8;    // Added to bolt diameter for easy insertion

// --- Derived Values ---
post_radius = post_diameter / 2;
pipe_radius = (pipe_diameter + pipe_clearance) / 2;
bolt_radius = (bolt_diameter + bolt_clearance) / 2;
bolt_head_radius = bolt_head_diameter / 2;
nut_radius = (nut_width_across_flats + bolt_clearance) / sqrt(3);

// The outer shape is a perfect cylinder. Radius is post + solid wall + socket depth.
outer_radius = post_radius + wall_thickness + pipe_socket_depth;

// Mount height is scaled to perfectly wrap the pipe diameter plus walls for uniform strength
mount_height = pipe_diameter + 2 * wall_thickness;

// Position bolts centrally in the solid mass between the post and the outer edge
bolt_distance = post_diameter + (outer_radius - post_radius);


// --- Main Module ---

module mount_half() {
    difference() {
        // -----------------------
        // 1. MAIN SOLID BODY
        // -----------------------
        // We start with the full outer chamfered cylinder and keep only the half we need
        intersection() {
            rotate_extrude() {
                polygon([
                    [0, -mount_height/2],
                    [outer_radius - edge_chamfer, -mount_height/2],
                    [outer_radius, -mount_height/2 + edge_chamfer],
                    [outer_radius, mount_height/2 - edge_chamfer],
                    [outer_radius - edge_chamfer, mount_height/2],
                    [0, mount_height/2]
                ]);
            }

            // Bounding box to cut the cylinder perfectly down the middle,
            // factoring in half of the clamping gap.
            translate([0, outer_radius + clamp_gap/2, 0])
                cube([outer_radius * 3, outer_radius * 2, mount_height + 2], center = true);
        }

        // -----------------------
        // 2. SUBTRACTIONS & HOLES
        // -----------------------

        // Post Cutout (Vertical cylinder)
        cylinder(r = post_radius, h = mount_height + 2, center = true);

        // Pipe Socket (Horizontal hole from the curved outer wall inwards)
        translate([0, outer_radius + 1, 0])
            rotate([90, 0, 0])
                cylinder(r = pipe_radius, h = pipe_socket_depth + 1);

        // Pipe Socket Chamfer (Helps guide the pipe in smoothly)
        translate([0, outer_radius + 0.1, 0])
            rotate([90, 0, 0])
                cylinder(r1 = pipe_radius + 1.5, r2 = pipe_radius, h = 1.6);

        // Bolt Holes & Counterbores (Left: Nut socket, Right: Bolt head)
        // Left side: Nut socket
        translate([-bolt_distance/2, clamp_gap/2 + flange_thickness + 1, 0])
            rotate([90, 0, 0])
                cylinder(r = bolt_radius, h = flange_thickness + 2);

        translate([-bolt_distance/2, clamp_gap/2 + flange_thickness, 0])
            rotate([-90, 0, 0]) // Extending outwards
                cylinder(r = nut_radius, h = outer_radius, $fn=6);

        // Right side: Bolt head counterbore
        translate([bolt_distance/2, clamp_gap/2 + flange_thickness + 1, 0])
            rotate([90, 0, 0])
                cylinder(r = bolt_radius, h = flange_thickness + 2);

        translate([bolt_distance/2, clamp_gap/2 + flange_thickness, 0])
            rotate([-90, 0, 0]) // Extending outwards
                cylinder(r = bolt_head_radius, h = outer_radius);
    }
}

// --- Assembly Visualization ---

module mount_assembly() {
    color("LightSteelBlue") mount_half();
    color("LightSlateGray") rotate([0, 0, 180]) mount_half();

    // Visualize the 89mm vertical post
    %cylinder(r=post_radius, h=mount_height*3, center=true);

    // Visualize the 30mm horizontal pipes
    %translate([0, outer_radius - pipe_socket_depth + 50, 0])
        rotate([90, 0, 0])
            cylinder(r=pipe_diameter/2, h=100, center=true);

    %translate([0, -(outer_radius - pipe_socket_depth + 50), 0])
        rotate([90, 0, 0])
            cylinder(r=pipe_diameter/2, h=100, center=true);
}

// ==========================================
// RENDER
// ==========================================

// Renders a single half, perfectly oriented to print flat on your build plate.
// (You will need to print two of these)
// *Note: We recommend adding standard build supports for the horizontal 30mm pipe socket
// and the counterbore bolt holes.*
mount_half();

// Uncomment the line below (and comment out the line above)
// to view the full assembled clamp mechanism with the post and pipes:
// mount_assembly();
