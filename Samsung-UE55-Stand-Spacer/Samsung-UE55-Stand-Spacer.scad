// Samsung-UE55-Stand-Spacer.scad
// Version: v0.12
// Description: Parametric OpenSCAD design for a Samsung UE55J5502AK angled stand spacer.
//              The spacer provides a taper so the TV leans slightly backward, and has
//              rounded top corners and mounting holes that are oriented along the Y-axis
//              and cut straight through the tapered body.

// --- Parameters for the Spacer ---
width = 230;            // Total width of the spacer (X-axis)
height = 70;            // Total height of the spacer (Z-axis)
bottom_thickness = 10;  // Thickness at the bottom (Y-axis, at Z=0)
top_thickness = 2;      // Thickness at the top (Y-axis, at Z=height)
corner_radius = 10;     // Radius for the rounded top corners

// --- Mounting Hole Parameters ---
hole_diameter = 5;      // Diameter of the mounting holes
hole_radius = hole_diameter / 2;

// Bottom holes
bottom_hole_z_pos = 7;           // Distance from the bottom edge (Z=0) to the center of the bottom holes
bottom_hole_spacing_x = 200;     // Distance between the centers of the two bottom holes (X-axis)

// Top holes
top_hole_z_pos = 62;             // Distance from the bottom edge (Z=0) to the center of the top holes
top_hole_spacing_x = 150;        // Distance between the centers of the two top holes (X-axis)

// --- Internal Helper Variables ---
half_width = width / 2;

// Function to calculate the Y-thickness at any given Z-height
function get_y_thickness(z_val) = bottom_thickness - (z_val / height) * (bottom_thickness - top_thickness);

// --- Main Spacer Module ---
module samsung_ue55_stand_spacer() {
    // The spacer has the following characteristics:
    // 1. `width` in X-direction.
    // 2. `height` in Z-direction.
    // 3. Tapers in Y-direction, from `bottom_thickness` at Z=0 to `top_thickness` at Z=height.
    // 4. Has sharp bottom corners and rounded top corners in the X-Z plane.
    // 5. Features flat front (Y=0) and back (Y=thickness(Z)) faces.

    // The most accurate way to define this shape in OpenSCAD is by using `polyhedron`
    // for the main tapered body, and then using `difference` to carve out the rounded top corners.

    // Define vertices for the sharp-cornered trapezoidal prism.
    // The Y-coordinate represents the thickness, tapering along the Z-height.
    // X-coordinates are centered around 0.
    // (x, y, z)

    // Vertices for the bottom plane (Z=0)
    v0 = [-half_width, 0, 0];                               // Bottom-Front-Left
    v1 = [half_width, 0, 0];                                // Bottom-Front-Right
    v2 = [half_width, get_y_thickness(0), 0];               // Bottom-Back-Right
    v3 = [-half_width, get_y_thickness(0), 0];              // Bottom-Back-Left

    // Vertices for the top plane (Z=height)
    // The front face (Y=0) is flat, so these points have Y=0.
    v4 = [-half_width, 0, height];                          // Top-Front-Left
    v5 = [half_width, 0, height];                           // Top-Front-Right
    // The back face tapers, so Y-coordinates are `top_thickness` at Z=height.
    v6 = [half_width, get_y_thickness(height), height];     // Top-Back-Right
    v7 = [-half_width, get_y_thickness(height), height];    // Top-Back-Left

    poly_vertices = [v0, v1, v2, v3, v4, v5, v6, v7];

    // Define the faces of the polyhedron. Each face is a list of vertex indices.
    // Faces must be specified in counter-clockwise order when viewed from outside the object.
    poly_faces = [
        [0, 1, 2, 3], // Bottom face
        [0, 4, 5, 1], // Front face
        [3, 7, 6, 2], // Back face
        [0, 3, 7, 4], // Left side face
        [1, 5, 6, 2], // Right side face
        [4, 7, 6, 5]  // Top face
    ];

    // Construct the final spacer by taking the main polyhedron and subtracting the holes
    // and the rounded corner cutting shapes.
    difference() {
        // The core trapezoidal prism (with initially sharp corners)
        polyhedron(points = poly_vertices, faces = poly_faces, convexity = 10);

        // --- Rounding the top corners ---
        // We subtract quarter-cylinders to create the desired rounded top corners.
        // These cutters are extruded along the Y-axis to ensure they cover the full thickness range.

        // Cutter for the Top-Right-Front corner
        // Positioned at the sharp corner, slightly extending into Y negative to ensure full cut.
        translate([half_width - corner_radius, 0, height - corner_radius]) {
            difference() {
                // Cube to represent the sharp corner area to remove
                cube([corner_radius, bottom_thickness + 2, corner_radius]);
                // Cylinder to define the rounded shape that remains
                translate([0, (bottom_thickness + 2)/2, 0]) // Adjust Y-center for cylinder
                    rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                        cylinder(h = bottom_thickness + 2, r = corner_radius, $fn=64, center = true);
                    }
            }
        }

        // Cutter for the Top-Left-Front corner
        // Positioned at the sharp corner.
        translate([-half_width, 0, height - corner_radius]) {
            difference() {
                // Cube to represent the sharp corner area to remove
                cube([corner_radius, bottom_thickness + 2, corner_radius]);
                // Cylinder to define the rounded shape that remains
                translate([corner_radius, (bottom_thickness + 2)/2, 0]) // Adjust Y-center for cylinder
                    rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                        cylinder(h = bottom_thickness + 2, r = corner_radius, $fn=64, center = true);
                    }
            }
        }

        // --- Mounting Holes ---
        // These holes are oriented along the Y-axis and pass straight through the spacer's thickness.
        // They are positioned with their center in Y at the middle of the thickness at their Z position.
        // The length (along Y) is made sufficiently long to ensure a complete cut.

        // Bottom holes
        // Y-position for the center of the hole at bottom_hole_z_pos
        hole_y_center_bottom = get_y_thickness(bottom_hole_z_pos) / 2;
        translate([-bottom_hole_spacing_x/2, hole_y_center_bottom, bottom_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_y_thickness(bottom_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }
        translate([bottom_hole_spacing_x/2, hole_y_center_bottom, bottom_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_y_thickness(bottom_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }

        // Top holes
        // Y-position for the center of the hole at top_hole_z_pos
        hole_y_center_top = get_y_thickness(top_hole_z_pos) / 2;
        translate([-top_hole_spacing_x/2, hole_y_center_top, top_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_y_thickness(top_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }
        translate([top_hole_spacing_x/2, hole_y_center_top, top_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_y_thickness(top_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }
    }
}

// Call the main module to render the spacer
samsung_ue55_stand_spacer();
