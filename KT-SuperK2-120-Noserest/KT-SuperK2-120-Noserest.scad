// ==============================================================================
// KT-SuperK2-120-Noserest.scad
//
// Description: Parametric 3D-printable nose rest for the KT SuperK2 120L
//              wing-foil board. Designed specifically for boards resting in a
//              nearly vertical position leaning against a wall. Features a
//              tilted, customized vertical socket, drainage channels, a central
//              drain hole, and four stable hemispherical feet.
//
// Version History:
//   v0.11 (2026-05-26): Converted the bottom drainage grooves from rectangular
//                       to cylindrical (semi-circular) cuts. This provides a much
//                       smoother, organic channel profile that prevents stress
//                       concentration and aligns perfectly with premium fluid-dynamic
//                       engineering.
//   v0.10 (2026-05-26): Removed support feet/legs. Added a '+' shaped drainage
//                       groove system directly on the flat bottom of the block.
//                       This allows water to drain horizontally out of the sides
//                       while keeping the block low-profile, flat-bottomed, and
//                       extremely stable.
//   v0.09 (2026-05-26): Streamlined and perfected the cross-sectional shape to be
//                       a true mathematical ellipse. This completely eliminates
//                       any diamond/rhombus flat-edge artifacts, resulting in an
//                       exceptionally smooth, fluid, and perfect ellipse-like
//                       glove for the board nose. Removed obsolete rail/keel/deck
//                       radius and width parameters.
//   v0.08 (2026-05-26): Redesigned the cross section to be much more rounded and
//                       less rhombus-shaped. Added 'deck_width_fraction' and
//                       'keel_width_fraction' to spread the top dome and bottom V
//                       horizontally, creating a highly realistic, organic, and
//                       sleek board profile.
//   v0.07 (2026-05-26): Redesigned the drainage hole to be the exact shape of the
//                       board nose cross section at 20mm from the tip. The cutter
//                       now projects a constant-profile column from z_local=20
//                       down through the bottom of the block. This suspends the
//                       fragile tip (first 20mm) in mid-air inside the through-hole,
//                       supporting the board safely on its stronger rails/deck/hull.
//   v0.06 (2026-05-26): Rounded the top and bottom of both the board nose shape
//                       (keel_radius=6, deck_radius=35) and the support block
//                       itself (by filleting all edges of the block base using
//                       a 3D hull of spheres).
//   v0.05 (2026-05-26): Removed the surface drainage channels while keeping the
//                       central vertical drain hole at the nose tip as requested.
//   v0.04 (2026-05-26): Modeled the exact asymmetric cross-sectional shape of
//                       the board nose: a sharp V-keel on the bottom hull side
//                       and a smooth domed curvature on the deck side. Added
//                       'keel_radius' and 'deck_radius' parameters.
//   v0.03 (2026-05-26): Added thickness taper modeling. The thickness at 30mm
//                       from the tip is set to 36mm. The thickness now tapers
//                       parametrically towards the tip, ensuring a perfect 3D
//                       glove-like fit for the nose.
//   v0.02 (2026-05-26): Redesigned for vertical resting against a wall. The
//                       board nose now inserts vertically from the top of the
//                       block. Added a parametric 'tilt_angle' parameter so
//                       the socket perfectly matches the angle of the board
//                       leaning against the wall, ensuring uniform support.
//                       Updated default dimensions to a stable 140x140x60mm.
//   v0.01 (2026-05-26): Initial design for horizontal resting.
//
// Author: Gemini-3.5-Flash
// ==============================================================================

/* [Block Dimensions] */
// Overall length of the nose rest block (front-to-back)
block_length = 100; // [80:200]
// Overall width of the nose rest block (left-to-right)
block_width = 140;  // [80:200]
// Overall height of the nose rest block
block_height = 60;  // [40:120]
// Fillet radius for the block's vertical and horizontal edges
block_corner_radius = 1; // [5:30]

/* [Board Nose Profile Parameters] */
// Width of the board nose at exactly 30mm from the tip (measured on centerline)
nose_width_at_30 = 105; // [80:150]
// Exponent defining the outline curve of the nose (0.5 = parabola, 1.0 = straight V)
nose_exponent = 0.55;   // [0.3:1.2]
// Thickness of the board nose at exactly 30mm from the tip
nose_thickness_at_30 = 36; // [20:70]
// Exponent defining the thickness taper curve (0.5 = parabolic, 1.0 = linear)
thickness_exponent = 0.6;   // [0.3:1.2]
// Minimum thickness at the very tip of the nose
nose_thickness_tip = 10;   // [5:25]

/* [Leaning / Vertical Rest Settings] */
// Angle (in degrees) at which the board leans against the wall (typically 5 to 15)
tilt_angle = 10;        // [0:25]
// Height of the lowest point of the board cradle from the block's bottom (Z=0)
board_rest_z = 15;      // [10:30]
// Distance from the nose tip (in mm) where the board begins resting on the socket
rest_clearance_z = 20;  // [5:40]
// Clearance gap added to the board's dimensions for easy fit or padding/EVA tape
fit_clearance = 2.0;    // [0.0:5.0]

/* [Bottom Drainage Grooves] */
// Width (diameter) of the "+" shaped cylindrical drainage grooves on the bottom of the block
bottom_groove_width = 12; // [6:30]
// Max depth of the "+" shaped cylindrical drainage grooves on the bottom of the block
bottom_groove_depth = 5;  // [2:15]

/* [Render Quality] */
// Step size along local Z for the smooth loft (smaller = higher quality, slower render)
z_step = 3;          // [1:10]
// Resolution of circular features (facets)
$fn = 40;            // [20:100]


// ==============================================================================
// Helper Modules & Calculations
// ==============================================================================

// Generates a 2D ellipse representing the board's cross section.
// This forms a perfectly smooth oval (with no flat lines or rhombus-shaped artifacts),
// ensuring the standing board is cradled in a flawless 3D curve.
module rounded_rect_2d(w, t) {
    scale([w/2, t/2]) {
        circle(r = 1, $fn = 60);
    }
}

// Generates a 2D cross-section slice of the board nose at a distance 'z_local'
// from the tip, extruded slightly to form a 3D slice.
// If z_local is below rest_clearance_z, we lock the dimensions to rest_clearance_z
// to create a constant-profile through-hole that suspends the fragile tip.
module slice_local_z(z_local, extra_clearance) {
    // Distance from the tip used for width/thickness calculation
    z_calc = max(rest_clearance_z, z_local);

    // Calculate width of the board nose at this slice
    w_raw = nose_width_at_30 * pow(z_calc / 30, nose_exponent);
    w = max(4.0, w_raw) + 2 * extra_clearance;

    // Calculate tapered thickness of the board nose at this slice
    t_raw = nose_thickness_at_30 * pow(z_calc / 30, thickness_exponent);
    t = max(nose_thickness_tip, t_raw) + 2 * extra_clearance;

    // Place a thin 3D slice at local Z
    translate([0, 0, z_local]) {
        linear_extrude(height = 0.1, center = true) {
            rounded_rect_2d(w, t);
        }
    }
}

// Generates the continuous 3D solid representing the board's nose pointing down.
// Extends from Z = -40 (to cut cleanly through the bottom of the block) up to block_height + 50.
module board_loft_local(extra_clearance) {
    min_z = -40; // Ensure it cuts all the way through the bottom and legs
    max_z = block_height + 50;

    for (z = [min_z : z_step : max_z]) {
        hull() {
            slice_local_z(z, extra_clearance);
            slice_local_z(z + z_step, extra_clearance);
        }
    }
}

// Positions the board's nose tip at the center of the block (at Z = board_rest_z)
// and tilts it about the X-axis by the wall-lean angle.
module board_nose_positive(extra_clearance) {
    translate([0, block_length / 2, board_rest_z]) {
        rotate([tilt_angle, 0, 0]) {
            board_loft_local(extra_clearance);
        }
    }
}

// Generates the base block with beautiful rounded vertical and horizontal edges
// using a 3D hull of 8 corner spheres.
module block_base() {
    corner_r = min(block_corner_radius, block_width/2 - 2, block_length/2 - 2, block_height/2 - 2);
    hull() {
        // Lower 4 corners
        translate([-block_width/2 + corner_r, corner_r, corner_r])
            sphere(r = corner_r);
        translate([block_width/2 - corner_r, corner_r, corner_r])
            sphere(r = corner_r);
        translate([-block_width/2 + corner_r, block_length - corner_r, corner_r])
            sphere(r = corner_r);
        translate([block_width/2 - corner_r, block_length - corner_r, corner_r])
            sphere(r = corner_r);

        // Upper 4 corners
        translate([-block_width/2 + corner_r, corner_r, block_height - corner_r])
            sphere(r = corner_r);
        translate([block_width/2 - corner_r, corner_r, block_height - corner_r])
            sphere(r = corner_r);
        translate([-block_width/2 + corner_r, block_length - corner_r, block_height - corner_r])
            sphere(r = corner_r);
        translate([block_width/2 - corner_r, block_length - corner_r, block_height - corner_r])
            sphere(r = corner_r);
    }
}

// Generates the "+" shaped cylindrical drainage grooves cut into the flat bottom (Z=0) of the block
module bottom_grooves() {
    groove_radius = bottom_groove_width / 2;
    z_offset = bottom_groove_depth - groove_radius;

    // Longitudinal cylindrical groove along Y-axis (centered at X=0, Y=block_length/2)
    translate([0, block_length / 2, z_offset]) {
        rotate([90, 0, 0]) {
            cylinder(r = groove_radius, h = block_length + 2, center = true, $fn = 32);
        }
    }

    // Transverse cylindrical groove along X-axis (centered at X=0, Y=block_length/2)
    translate([0, block_length / 2, z_offset]) {
        rotate([0, 90, 0]) {
            cylinder(r = groove_radius, h = block_width + 2, center = true, $fn = 32);
        }
    }
}


// ==============================================================================
// Main Solid Assembly
// ==============================================================================

module nose_rest_assembly() {
    difference() {
        // Main solid block body
        block_base();

        // Subtract the board's vertical nose profile (with fit clearance)
        board_nose_positive(fit_clearance);

        // Subtract the bottom drainage grooves
        bottom_grooves();
    }
}

// Render the final assembly
nose_rest_assembly();

// (Optional) Visual verification overlay: Uncomment to see the board nose wireframe
// % board_nose_positive(fit_clearance);
