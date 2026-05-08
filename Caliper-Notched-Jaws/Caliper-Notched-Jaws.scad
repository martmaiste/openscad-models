/*
 * Parametric OpenSCAD design for a caliper notched jaw cover.
 * Version: v0.03
 * Designed to exactly match the provided sketch with robust geometric handling.
 * Fixed: Robust handling of small jaw_tip_slant_height using vector-based offsets.
 */

/* [Version] */
version = "0.03";

/* [General Settings] */
// Which part to generate
part = "half"; // [both, half]

// --- Profile Data [length, thickness, base_width, tip_width, tip_height] ---
profile_kl2      = [32.0, 3.1, 14.0, 7.0, 1.0];
profile_bmrs     = [32.0, 3.5, 15.0, 9.0, 4.0];
profile_kalev    = [41.0, 3.6, 16.0, 6.2, 3.0];
profile_example  = [40.0, 3.5, 15.0, 8.0, 2.0];

/* [Caliper Profile Selection] */
profile = profile_kalev;

jaw_length           = profile[0];
jaw_thickness        = profile[1];
jaw_base_width       = profile[2];
jaw_tip_slant_width  = profile[3];
jaw_tip_slant_height = profile[4];

/* [Cover Dimensions] */
// Total thickness of the printed cover
cover_total_thickness = 8.0;
// Thickness of the plastic on the measuring (straight) face
wall_measuring_face = 5.0;
// Thickness of the plastic on the outer (slanted) faces (perpendicular thickness)
wall_outer_face = 2.0;
// Thickness of the plastic at the bottom tip
wall_tip = 4.0;

/* [Notch Dimensions] */
// Distance from the inner metal jaw tip to the center of the V-notch
notch_distance_from_tip = 15.0;
// Total vertical height of the V-notch opening
notch_height = 8.0;
// Depth of the V-notch into the plastic
notch_depth = 4.0;

// --- Implementation ---
$fn = 64;

// Calculate Z wall thickness to perfectly center the cavity
wall_z = (cover_total_thickness - jaw_thickness) / 2;

// --- Robust Math for Outer Walls ---
// We use vector math to avoid division by zero when angles are sharp
eps = 0.0001;
sh_safe = max(eps, jaw_tip_slant_height);

// Points of the metal jaw profile
p_jaw0 = [0, 0];
p_jaw1 = [-jaw_tip_slant_width, sh_safe];
p_jaw2 = [-jaw_base_width, jaw_length];

// Vectors of the segments
v01 = p_jaw1 - p_jaw0;
v12 = p_jaw2 - p_jaw1;

// Lengths
l01 = sqrt(v01[0]*v01[0] + v01[1]*v01[1]);
l12 = sqrt(v12[0]*v12[0] + v12[1]*v12[1]);

// Unit Normals (pointing left/outward)
n01 = [-v01[1]/l01, v01[0]/l01];
n12 = [-v12[1]/l12, v12[0]/l12];

// Intersection of offset segments 1 and 2
// Solve for intersection of Line 1 and Line 2
// Line 1: (p_jaw0 + wall_outer_face*n01) + t*v01
// Line 2: (p_jaw1 + wall_outer_face*n12) + u*v12
det = -v01[0]*v12[1] + v01[1]*v12[0];
t_int = (abs(det) < eps) ? 0 : (-(p_jaw1[0] - p_jaw0[0] + wall_outer_face*(n12[0] - n01[0]))*v12[1] + (p_jaw1[1] - p_jaw0[1] + wall_outer_face*(n12[1] - n01[1]))*v12[0]) / det;

p_int = (abs(det) < eps) ? (p_jaw1 + wall_outer_face*n01) : [ (p_jaw0[0] + wall_outer_face*n01[0]) + t_int*v01[0], (p_jaw0[1] + wall_outer_face*n01[1]) + t_int*v01[1] ];

x_int = p_int[0];
y_int = p_int[1];

// Function for X coordinates along the main offset wall
function outer_main_x(y) = (abs(v12[1]) < eps) ? (p_jaw2[0] + wall_outer_face*n12[0]) : (p_jaw2[0] + wall_outer_face*n12[0]) + ((y - (p_jaw2[1] + wall_outer_face*n12[1])) / v12[1]) * v12[0];

x_top_left = outer_main_x(jaw_length);

// Metal jaw width calculation
function get_jaw_width(y) = jaw_tip_slant_width + (jaw_base_width - jaw_tip_slant_width) * ((y - jaw_tip_slant_height) / max(eps, jaw_length - jaw_tip_slant_height));

module jaw_cover_2d_profile() {
    p_outer = [
        // Bottom Right
        [wall_measuring_face, -wall_tip],
        // Notch bottom
        [wall_measuring_face, notch_distance_from_tip - notch_height/2],
        // Notch inner point
        [wall_measuring_face - notch_depth, notch_distance_from_tip],
        // Notch top
        [wall_measuring_face, notch_distance_from_tip + notch_height/2],
        // Top right
        [wall_measuring_face, jaw_length],
        // Top left
        [x_top_left, jaw_length],
        // Miter Point (where outer cutback meets outer main slant)
        [x_int, y_int],
        // Bottom Mid (at axis)
        [0, -wall_tip]
    ];
    polygon(p_outer);
}

module cavity_2d_profile() {
    p_cavity = [
        [0, 0], // Bottom right "Tip"
        [-jaw_tip_slant_width, jaw_tip_slant_height], // Bottom left cutback point
        [-get_jaw_width(jaw_length + 1.0), jaw_length + 1.0], // Top left
        [0, jaw_length + 1.0] // Top right
    ];
    polygon(p_cavity);
}

module single_jaw_cover() {
    difference() {
        linear_extrude(height = cover_total_thickness)
            jaw_cover_2d_profile();
        translate([0, 0, wall_z])
            linear_extrude(height = jaw_thickness)
                cavity_2d_profile();
    }
}

// --- Render Logic ---
if (part == "both") {
    translate([-10, 0, 0]) single_jaw_cover();
    translate([10, 0, 0]) mirror([1, 0, 0]) single_jaw_cover();
} else if (part == "half") {
    // Render the bottom half of the cover
    intersection() {
        single_jaw_cover();
        translate([-50, -50, 0]) cube([100, 100, cover_total_thickness / 2]);
    }
}
