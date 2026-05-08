// Samsung-UE55-Stand-Spacer-Symmetrical.scad
// Version: v0.02
// Description: Parametric OpenSCAD design for a Samsung UE55J5502AK symmetrical angled stand spacer.
//              The spacer has a symmetrical trapezoidal cross-section, ensuring both surfaces are at the same angle.
//              It features rounded top corners and mounting holes that pass straight through on the Y-axis.

// --- Parameters for the Spacer ---
width = 230;            // Total width of the spacer (X-axis)
height = 70;            // Total height of the spacer (Z-axis)
bottom_thickness = 10;  // Thickness at the bottom (Total Y-axis thickness, at Z=0)
top_thickness = 2;      // Thickness at the top (Total Y-axis thickness, at Z=height)
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

// Function to calculate the TOTAL Y-thickness at any given Z-height
function get_total_y_thickness(z_val) = bottom_thickness - (z_val / height) * (bottom_thickness - top_thickness);

// --- Main Spacer Module ---
module samsung_ue55_stand_spacer_symmetrical() {
    // The spacer has the following characteristics:
    // 1. `width` in X-direction.
    // 2. `height` in Z-direction.
    // 3. Symmetrical trapezoidal cross-section in the Y-Z plane.
    //    Thickness varies from `bottom_thickness` at Z=0 to `top_thickness` at Z=height,
    //    centered around the Y=0 plane.
    // 4. Has sharp bottom corners and rounded top corners in the X-Z plane.
    // 5. Features flat front and back faces (angled relative to Y=0).

    // Define vertices for the sharp-cornered symmetrical trapezoidal prism.
    // X-coordinates are centered around 0.
    // Y-coordinates are centered around 0, representing half of the total thickness.
    // (x, y, z)

    // Vertices for the bottom plane (Z=0)
    v0 = [-half_width, -get_total_y_thickness(0)/2, 0];    // Bottom-Front-Left
    v1 = [half_width, -get_total_y_thickness(0)/2, 0];     // Bottom-Front-Right
    v2 = [half_width, get_total_y_thickness(0)/2, 0];      // Bottom-Back-Right
    v3 = [-half_width, get_total_y_thickness(0)/2, 0];     // Bottom-Back-Left

    // Vertices for the top plane (Z=height)
    v4 = [-half_width, -get_total_y_thickness(height)/2, height]; // Top-Front-Left
    v5 = [half_width, -get_total_y_thickness(height)/2, height];  // Top-Front-Right
    v6 = [half_width, get_total_y_thickness(height)/2, height];   // Top-Back-Right
    v7 = [-half_width, get_total_y_thickness(height)/2, height];  // Top-Back-Left

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
        // We subtract specific cutters to create the desired rounded top corners.
        // Each cutter is a difference of a cube (defining the sharp corner area) and a cylinder (defining the rounded shape to keep).
        // The cylinders are rotated to align with the Y-axis to cut through the spacer's thickness.

        // Common variables for cutter dimensions at the top
        full_thickness_at_top = get_total_y_thickness(height);
        cutter_y_length = full_thickness_at_top + 2; // Ensure cutter covers full thickness
        cylinder_y_offset = cutter_y_length / 2;     // Y-offset to center cylinder within cutter cube's Y-length

        // Cutter for the Top-Right-Front (TRF) corner
        // Cube defines sharp corner region (X: half_width-r to half_width, Y: -half_thickness-1 to ..., Z: height-r to height)
        // The difference origin is where the cube starts (min X, min Y, min Z) for the region to be cut.
        translate([half_width - corner_radius, -full_thickness_at_top/2 - 1, height - corner_radius]) { // Cube start X, Y, Z
            difference() {
                cube([corner_radius, cutter_y_length, corner_radius]); // Cube defining sharp corner region
                translate([0, cylinder_y_offset, 0]) // Center cylinder within cube's Y length
                    rotate([90, 0, 0]) { // Rotate 90 deg around X-axis to align cylinder with Y-axis
                        cylinder(h = cutter_y_length, r = corner_radius, $fn=64, center = true);
                    }
            }
        }

        // Cutter for the Top-Left-Front (TLF) corner
        // Cube defines sharp corner region (X: -half_width to -half_width+r, Y: -half_thickness-1 to ..., Z: height-r to height)
        translate([-half_width, -full_thickness_at_top/2 - 1, height - corner_radius]) { // Cube start X, Y, Z
            difference() {
                cube([corner_radius, cutter_y_length, corner_radius]);
                translate([corner_radius, cylinder_y_offset, 0]) // Offset X by corner_radius and center Y
                    rotate([90, 0, 0]) {
                        cylinder(h = cutter_y_length, r = corner_radius, $fn=64, center = true);
                    }
            }
        }

        // Cutter for the Top-Right-Back (TRB) corner
        // Cube defines sharp corner region (X: half_width-r to half_width, Y: +half_thickness+1 to ..., Z: height-r to height)
        translate([half_width - corner_radius, full_thickness_at_top/2 - 1, height - corner_radius]) { // Cube start X, Y, Z
            difference() {
                cube([corner_radius, -cutter_y_length, corner_radius]); // Negative length to extend forwards from back face
                translate([0, -cylinder_y_offset, 0]) // Center cylinder within cube's Y length, negative offset for negative cube length
                    rotate([90, 0, 0]) {
                        cylinder(h = cutter_y_length, r = corner_radius, $fn=64, center = true);
                    }
            }
        }

        // Cutter for the Top-Left-Back (TLB) corner
        // Cube defines sharp corner region (X: -half_width to -half_width+r, Y: +half_thickness+1 to ..., Z: height-r to height)
        translate([-half_width, full_thickness_at_top/2 - 1, height - corner_radius]) { // Cube start X, Y, Z
            difference() {
                cube([corner_radius, -cutter_y_length, corner_radius]); // Negative length to extend forwards from back face
                translate([corner_radius, -cylinder_y_offset, 0]) // Offset X by corner_radius and center Y, negative offset for negative cube length
                    rotate([90, 0, 0]) {
                        cylinder(h = cutter_y_length, r = corner_radius, $fn=64, center = true);
                    }
            }
        }

        // --- Mounting Holes ---
        // These holes are oriented along the Y-axis and pass straight through the spacer's thickness.
        // They are positioned with their center at Y=0 (due to symmetry) at their respective Z-positions.
        // The length (along Y) is made sufficiently long to ensure a complete cut.

        // Bottom holes
        // Y-position for the center of the hole is 0 due to symmetrical cross-section
        translate([-bottom_hole_spacing_x/2, 0, bottom_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_total_y_thickness(bottom_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }
        translate([bottom_hole_spacing_x/2, 0, bottom_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_total_y_thickness(bottom_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }

        // Top holes
        // Y-position for the center of the hole is 0 due to symmetrical cross-section
        translate([-top_hole_spacing_x/2, 0, top_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_total_y_thickness(top_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }
        translate([top_hole_spacing_x/2, 0, top_hole_z_pos]) {
            rotate([90, 0, 0]) { // Rotate 90 degrees around X-axis to align cylinder with Y-axis
                cylinder(h = get_total_y_thickness(top_hole_z_pos) + 2, r = hole_radius, $fn=32, center = true);
            }
        }
    }
}

// Call the main module to render the spacer
samsung_ue55_stand_spacer_symmetrical();
