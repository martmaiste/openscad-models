/*
 * Parametric OpenSCAD design for a caliper notched jaw cover.
 * Version: v0.07
 * Designed to exactly match the provided sketch:
 * - Straight measuring face with a V-notch
 * - Slanted outer face
 * - Top extension tab for alignment
 * - Slanted bottom tip
 */

/* [Version] */
version = "0.07";

/* [General Settings] */
// Which part to generate, laid flat for 3D printing
part = "split_halves"; // [left_fixed, right_sliding, both, cutaway, split_halves]

/* [Caliper Metal Jaw Dimensions] */
// Total length of the metal jaw to cover (including the tab area)
jaw_length = 40.0;
// Thickness of the metal jaw
jaw_thickness = 3.0;
// Width of the metal jaw at the base (top, where it meets the caliper body)
jaw_base_width = 16.0;
// Width of the metal jaw where the main outer slant begins (X offset at the cutback)
jaw_tip_slant_width = 6.0;
// Distance from the tip (Y=0) where the main outer slant begins (Y offset of the cutback)
jaw_tip_slant_height = 4.0;

/* [Cover Dimensions] */
// Total thickness of the printed cover
cover_total_thickness = 8.0;
// Thickness of the plastic on the measuring (straight) face
wall_measuring_face = 8.0;
// Thickness of the plastic on the outer (slanted) faces (perpendicular thickness)
wall_outer_face = 6.0;
// Thickness of the plastic at the bottom tip
wall_tip = 4.0;

/* [Tab and Cutout Dimensions] */
// Length of the cutout at the top to clear the caliper body (makes the tab)
cutout_length = 7.0;

/* [Notch Dimensions] */
// Distance from the inner metal jaw tip to the center of the V-notch
notch_distance_from_tip = 15.0;
// Total vertical height of the V-notch opening
notch_height = 12.0;
// Depth of the V-notch into the plastic
notch_depth = 6.0;

/* [Bolt Holes] */
// Add optional M2 bolt holes to clamp the cover
enable_bolt_holes = true;
// Y position (height) of the top bolt holes
bolt_hole_top_y = 28.0;
// Y position (height) of the bottom bolt holes
bolt_hole_bottom_y = 5.0;
// Diameter of the M2 bolt shaft clearance hole
m2_hole_dia = 2.4;
// Flat-to-flat width of the M2 nut (4.0mm standard + 0.2mm clearance)
m2_nut_flat_to_flat = 4.2;
// Depth of the M2 nut recession
m2_nut_depth = 1.8;
// Diameter of the M2 bolt head recession
m2_head_dia = 4.2;
// Depth of the M2 bolt head recession
m2_head_depth = 2.0;
// Thickness of the sacrificial bridge layer to support the nut recession overhang (typically 1 layer height)
bridge_layer_thickness = 0.2;

// --- Implementation ---
$fn = 64;

// Calculate Z wall thickness to perfectly center the cavity
wall_z = (cover_total_thickness - jaw_thickness) / 2;

// --- Math for exact perpendicular offsets of the slanted outer walls ---
// Main Slant
m_main = (jaw_tip_slant_width - jaw_base_width) / (jaw_length - jaw_tip_slant_height);
b_main = -jaw_tip_slant_width - m_main * jaw_tip_slant_height;
function outer_main_x(y) = m_main * y + b_main - wall_outer_face * sqrt(1 + m_main*m_main);

// Bottom Cutback Slant
m_cut = -jaw_tip_slant_width / jaw_tip_slant_height;
b_cut = 0;
function outer_cut_x(y) = m_cut * y + b_cut - wall_outer_face * sqrt(1 + m_cut*m_cut);

// Intersection corner of the two perfectly offset outer walls
m_diff = m_main - m_cut;
y_int = abs(m_diff) > 0.0001 ? (b_cut - b_main + wall_outer_face * (sqrt(1 + m_main*m_main) - sqrt(1 + m_cut*m_cut))) / m_diff : jaw_tip_slant_height;
x_int = outer_main_x(y_int);


// Function to calculate the internal metal jaw width at any Y coordinate (linear interpolation along the main slant)
function get_jaw_width(y) = jaw_tip_slant_width + (jaw_base_width - jaw_tip_slant_width) * ((y - jaw_tip_slant_height) / (jaw_length - jaw_tip_slant_height));

// Functions to get exact X coordinates of inner/outer walls at any given Y
function get_inner_x(y) = (y > jaw_tip_slant_height) ? -get_jaw_width(y) : -jaw_tip_slant_width * (y / jaw_tip_slant_height);
function get_outer_x(y) = (y > y_int) ? outer_main_x(y) : outer_cut_x(y);

module jaw_cover_2d_profile() {
    // Outer Shell Polygon
    p_outer = [
        // Bottom right (tip of measuring face)
        [wall_measuring_face, -wall_tip],

        // Notch bottom
        [wall_measuring_face, notch_distance_from_tip - notch_height/2],
        // Notch inner point
        [wall_measuring_face - notch_depth, notch_distance_from_tip],
        // Notch top
        [wall_measuring_face, notch_distance_from_tip + notch_height/2],

        // Top right of tab
        [wall_measuring_face, jaw_length],
        // Top left of tab (aligns with straight edge of cavity)
        [0, jaw_length],
        // Inner corner of cutout
        [0, jaw_length - cutout_length],

        // Top left of main body (calculated to stay perfectly parallel to the cavity at exact perpendicular distance)
        [outer_main_x(jaw_length - cutout_length), jaw_length - cutout_length],
        // Corner where the main slant meets the bottom cutback
        [x_int, y_int],
        // Bottom left (calculated to stay perfectly parallel to the bottom cutback cavity)
        [outer_cut_x(-wall_tip), -wall_tip]
    ];

    polygon(p_outer);
}

module cavity_2d_profile() {
    // Extended slightly in Y at the top for a clean boolean difference
    p_cavity = [
        [0, 0], // Bottom right "Tip"
        [-jaw_tip_slant_width, jaw_tip_slant_height], // Bottom left cutback point
        [-get_jaw_width(jaw_length + 1.0), jaw_length + 1.0], // Top left
        [0, jaw_length + 1.0] // Top right
    ];
    polygon(p_cavity);
}

module m2_bolt_hole(x, y) {
    translate([x, y, 0]) {
        // Main shaft
        // Starts above the nut bridge layer and ends below the bolt head bridge layer
        // This leaves exactly a 1-layer solid bridge at both ends for support-free printing
        translate([0, 0, m2_nut_depth + bridge_layer_thickness])
            cylinder(h = cover_total_thickness - m2_head_depth - m2_nut_depth - 2 * bridge_layer_thickness, d = m2_hole_dia, $fn=32);

        // Nut recession (bottom)
        translate([0, 0, -0.01])
            rotate([0, 0, 30])
                cylinder(h = m2_nut_depth + 0.01, d = m2_nut_flat_to_flat / cos(30), $fn=6);

        // Bolt head recession (top)
        translate([0, 0, cover_total_thickness - m2_head_depth])
            cylinder(h = m2_head_depth + 0.01, d = m2_head_dia, $fn=32);
    }
}

module single_jaw_cover() {
    difference() {
        // Main body extrusion
        linear_extrude(height = cover_total_thickness)
            jaw_cover_2d_profile();

        // Hollow cavity subtraction for the metal jaw
        translate([0, 0, wall_z])
            linear_extrude(height = jaw_thickness)
                cavity_2d_profile();

        // Bolt Holes
        if (enable_bolt_holes) {
            // --- Top Pair ---
            // Right hole (measuring face side)
            m2_bolt_hole(wall_measuring_face / 2, bolt_hole_top_y);
            // Left hole (outer slanted face side)
            m2_bolt_hole((get_inner_x(bolt_hole_top_y) + get_outer_x(bolt_hole_top_y)) / 2, bolt_hole_top_y);

            // --- Bottom Pair ---
            // Right hole (measuring face side)
            m2_bolt_hole(wall_measuring_face / 2, bolt_hole_bottom_y);
            // Left hole (outer slanted face side)
            m2_bolt_hole((get_inner_x(bolt_hole_bottom_y) + get_outer_x(bolt_hole_bottom_y)) / 2, bolt_hole_bottom_y);
        }
    }
}

// --- Render Logic ---
// The base model represents the Left (Fixed) Jaw.
// It is oriented flat on the XY plane for easy FDM 3D printing (bridging the cavity).

if (part == "both") {
    // Left fixed jaw
    translate([-10, 0, 0])
        single_jaw_cover();

    // Right sliding jaw (mirrored to face the left jaw)
    translate([10, 0, 0])
        mirror([1, 0, 0])
            single_jaw_cover();

} else if (part == "left_fixed") {
    single_jaw_cover();

} else if (part == "right_sliding") {
    mirror([1, 0, 0])
        single_jaw_cover();

} else if (part == "cutaway") {
    // Render an inspection view with the top half sliced off and the metal jaw rendered inside
    difference() {
        color("SteelBlue", 0.8)
            single_jaw_cover();

        // Cutaway bounding box bisecting the total thickness
        translate([-50, -50, cover_total_thickness / 2])
            cube([100, 100, 50]);
    }

} else if (part == "split_halves") {
    // Render the jaw split exactly down the middle so the two clam-shell halves can be printed

    // Bottom Half (contains nut recessions)
    intersection() {
        single_jaw_cover();
        translate([-50, -50, 0])
            cube([100, 100, cover_total_thickness / 2]);
    }

    // Top Half (contains bolt head recessions)
    // Flipped 180 degrees so the outer flat face sits perfectly on the build plate
    // and the internal cavity cutout faces UP
    translate([35, 0, 0])
        rotate([0, 180, 0])
        translate([0, 0, -cover_total_thickness])
        intersection() {
            single_jaw_cover();
            translate([-50, -50, cover_total_thickness / 2])
                cube([100, 100, cover_total_thickness / 2]);
        }
}
