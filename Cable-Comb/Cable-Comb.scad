/**
 * Cable-Comb.scad
 *
 * A highly parametric, circular cable comb / dresser / organizer.
 * Designed to cleanly route and organize various computer, monitor, network,
 * and power supply cables from the wall socket to your desk setup.
 *
 * Features:
 *  - Fully parametric circular design with custom-sized slots.
 *  - Supports individual cable diameters (e.g. PSU, HDMI, Ethernet, USB).
 *  - Secure "snap-in" retention slots with customizable entry gaps.
 *  - Ultra-smooth, mathematically generated circular fillet entries to slide cables in effortlessly.
 *  - Fully chamfered top/bottom outer edges and cable holes to protect cables.
 *  - Highly print-optimized (no support required!).
 *
 * Version: v0.03 (Symmetrical filleted entry slots, zip groove removed)
 * Date: 2026-07-28
 * License: MIT License
 */

// ==========================================
//               USER PARAMETERS
// ==========================================

/* [Cable Setup] */

// Choose whether to use a custom list of varying diameters (true), or a uniform array of identical holes (false).
use_custom_list = true;

// If 'use_custom_list' is false (default), how many uniform cables do you want?
uniform_cable_count = 3; // [2:30]

// If 'use_custom_list' is false (default), what is the diameter of each cable hole (in mm)?
uniform_cable_diameter = 7.0; // [2.0:0.1:25.0]

// Custom cable diameters in mm. Used ONLY when 'use_custom_list = true'.
// Standard references:
// - Power supply / Wall socket cable: 8.5mm - 10.0mm
// - HDMI / DisplayPort / DVI cable: 6.5mm - 8.0mm
// - Cat6/Cat6a Ethernet cable: 6.0mm - 7.0mm
// - Cat5e Ethernet cable: 5.0mm - 5.5mm
// - USB Keyboard / Mouse / Charging cable: 3.5mm - 4.5mm
// Order: arranged clockwise starting from 0 degrees.
custom_cable_diameters = [7, 7, 7, 5];

/* [Main Dimensions] */

// Height (thickness) of the comb in mm.
comb_height = 5.0; // [5.0:0.5:40.0]

// Minimum wall thickness between adjacent cable holes (in mm).
wall_thickness = 3; // [1.0:0.1:8.0]

// Wall thickness of the outer ring surrounding the cable holes (in mm).
outer_wall_thickness = 0.5; // [1.5:0.1:10.0]

// Size of the chamfer/bevel on the top and bottom edges (in mm).
// Smooths the edges to protect cables and makes the 3D print look highly professional.
chamfer_size = 0.5; // [0.0:0.1:5.0]

/* [Retention Slots & Entry] */

// Ratio of the entry slot width to the cable diameter.
// E.g., 0.75 means a 10mm cable snaps into a 7.5mm slot. Set to 1.0 for a loose, completely open slot.
entry_gap_ratio = 0.75; // [0.5:0.05:1.0]

// Radius of the entry flare circular curve (in mm).
// Higher values create a larger, smoother, funnel-like opening to easily guide cables into the slots.
entry_flare_radius = 1.8; // [0.0:0.1:8.0]



/* [Render Quality] */

// Circle detail factor. Higher values make circles smoother but slow down rendering.
// A value of 50-80 is excellent for 3D printing.
$fn = 60; // [20:120]


// ==========================================
//               HELPER FUNCTIONS
// ==========================================

// Recursively sum elements of a list from index 0 up to index n-1
function sum_list(list, n) =
    (n <= 0) ? 0 : list[n-1] + sum_list(list, n-1);

// Recursively find the maximum value in a list of size n
function max_list(list, n) =
    (n <= 1) ? list[0] : max(list[n-1], max_list(list, n-1));


// ==========================================
//          DERIVED PARAMETERS & CALCULATIONS
// ==========================================

// 1. Resolve cable diameters list
cable_diameters = use_custom_list ? custom_cable_diameters : [ for (i = [0 : uniform_cable_count - 1]) uniform_cable_diameter ];
N = len(cable_diameters);

// Ensure we have at least one cable hole
assert(N > 0, "Error: Cable count must be greater than zero!");

// 2. Compute minimum spacing required between holes
// S_list[i] is the spacing (distance between centers) from hole i to hole i+1
S_list = [ for (i = [0 : N - 1]) (cable_diameters[i] + cable_diameters[(i + 1) % N]) / 2 + wall_thickness ];
S_total = sum_list(S_list, N);

// 3. Compute angles for each hole
// Angle spacing is proportional to the size of the holes and spacing between them
A_list = [ for (i = [0 : N - 1]) 360 * S_list[i] / S_total ];
phi_list = [ for (i = [0 : N - 1]) sum_list(A_list, i) ];

// 4. Compute center circle radius for hole placement
// We estimate R_centers based on required circumference
R_centers = S_total / (2 * PI);

// 5. Compute outer radius of the comb
max_cable_dia = max_list(cable_diameters, N);
R_outer = R_centers + (max_cable_dia / 2) + outer_wall_thickness;

// 6. Safe limits for chamfers and fillets
actual_chamfer = chamfer_size > 0.05 ? min(chamfer_size, comb_height/3, outer_wall_thickness - 0.2) : 0;

// The flare radius must not cross the center of the cable holes to remain geometrically sound
actual_flare_radius = entry_flare_radius > 0.05 ? min(entry_flare_radius, R_outer - R_centers - 0.2) : 0;


// ==========================================
//             GEOMETRY GENERATION
// ==========================================

// Render the 3D model
cable_comb();

module cable_comb() {
    difference() {
        // Step 1: Base Body (with top and bottom chamfers)
        base_body();

        // Step 2: Cable Holes (with individual top/bottom chamfers)
        cable_holes();

        // Step 3: Radial Entry Slots (with ultra-smooth circular fillets)
        entry_slots();
    }
}

module base_body() {
    rotate_extrude($fn=$fn * 2) {
        if (actual_chamfer > 0.05) {
            // Profile of a solid disk with chamfered top and bottom outer corners
            polygon(points=[
                [0, 0],
                [R_outer - actual_chamfer, 0],
                [R_outer, actual_chamfer],
                [R_outer, comb_height - actual_chamfer],
                [R_outer - actual_chamfer, comb_height],
                [0, comb_height]
            ]);
        } else {
            // Simple rectangular solid disk profile
            polygon(points=[
                [0, 0],
                [R_outer, 0],
                [R_outer, comb_height],
                [0, comb_height]
            ]);
        }
    }
}

module cable_holes() {
    for (i = [0 : N - 1]) {
        phi = phi_list[i];
        dia = cable_diameters[i];
        rad = dia / 2;

        // Place each hole at its respective position
        rotate([0, 0, phi]) {
            translate([R_centers, 0, 0]) {
                chamfered_hole(r=rad, h=comb_height, c=actual_chamfer);
            }
        }
    }
}

module chamfered_hole(r, h, c) {
    // Main hole passing all the way through (with a bit of extra height for clean subtraction)
    translate([0, 0, -1]) {
        cylinder(r=r, h=h + 2, $fn=$fn);
    }

    // If chamfers are enabled, subtract the chamfer cones at top and bottom
    if (c > 0.05) {
        // Bottom chamfer cone (opens downwards)
        translate([0, 0, -0.01]) {
            cylinder(r1=r + c, r2=r, h=c + 0.01, $fn=$fn);
        }

        // Top chamfer cone (opens upwards)
        translate([0, 0, h - c]) {
            cylinder(r1=r, r2=r + c, h=c + 0.01, $fn=$fn);
        }
    }
}

module entry_slots() {
    for (i = [0 : N - 1]) {
        phi = phi_list[i];
        dia = cable_diameters[i];
        w_slot = dia * entry_gap_ratio;

        rotate([0, 0, phi]) {
            translate([0, 0, -1]) {
                linear_extrude(height = comb_height + 2) {
                    flared_slot_profile(w_slot);
                }
            }
        }
    }
}

module flared_slot_profile(w_slot) {
    if (actual_flare_radius > 0.05) {
        // Upper arc points (concave fillet rounding from slot wall to outer edge)
        // a goes from -90 (tangent to slot wall) to 0 (tangent to outer face)
        upper_arc = [ for (a = [-90 : 10 : 0]) [
            (R_outer - actual_flare_radius) + actual_flare_radius * cos(a),
            (w_slot/2 + actual_flare_radius) + actual_flare_radius * sin(a)
        ] ];

        // Lower arc points (concave fillet rounding from outer edge back to slot wall)
        // b goes from 0 to -90 to mirror the upper arc perfectly across the X-axis
        lower_arc = [ for (b = [0 : -10 : -90]) [
            (R_outer - actual_flare_radius) + actual_flare_radius * cos(b),
            -((w_slot/2 + actual_flare_radius) + actual_flare_radius * sin(b))
        ] ];

        // Generate the combined smooth polygon path
        polygon(concat(
            [[R_centers, w_slot/2]],
            upper_arc,
            [[R_outer + 5, w_slot/2 + actual_flare_radius]],
            [[R_outer + 5, -(w_slot/2 + actual_flare_radius)]],
            lower_arc,
            [[R_centers, -w_slot/2]]
        ));
    } else {
        // Simple straight slot path if flare radius is 0
        polygon(points=[
            [R_centers, -w_slot/2],
            [R_outer + 5, -w_slot/2],
            [R_outer + 5, w_slot/2],
            [R_centers, w_slot/2]
        ]);
    }
}
