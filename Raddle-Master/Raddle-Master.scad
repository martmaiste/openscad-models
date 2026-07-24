/*
================================================================================
File Name:     Raddle-Master.scad
Description:   Parametric anti-rattle clamp for a foldable camper door bug net.
Version:       v0.10
Date:          2026-07-23
Author:        Zed Coding Agent
License:       Creative Commons - Attribution - ShareAlike

Description:
  This is a fully parametric, heavy-duty clamp designed to prevent the bug-net
  assembly on a camper door from rattling or vibrating while driving.

  One end of the clamp features a straight "L" shaped leg to wrap around the frame,
  while the other features a hook "J" shaped leg with a return lip to capture and
  clamp down onto the assembly securely. It includes flared entry ramps on both
  legs to make it easy to slide on/off without scratching the frame.

Features:
  - Highly parametric (customizer friendly)
  - Filleted inner and outer corners to eliminate stress concentration and prevent snapping
  - Integrated flared entry ramps for smooth installation
  - Optional built-in tether eyelet to attach a leash/lanyard so you don't lose it

3D Printing Recommendations:
  - Material: PETG or ABS/ASA (highly recommended for outdoor/automotive heat resistance and springiness)
  - Perimeters (Walls): 4-6 lines (allows the flex arms to be solid and springy)
  - Infill: 30% - 50% Gyroid or Grid (if needed, but perimeters should do most of the work)
  - Orientation: Print flat on its side (Z-axis height of 15mm on the print bed) for optimal layer strength
================================================================================
*/

/* [Main Clamp Dimensions] */

// Internal width of the bug-net frame assembly to be clamped (mm)
assembly_width = 71.0; // [40.0:150.0]

// Thickness of the clamp walls (mm) for the L-leg and main span.
thickness = 10.0; // [3.0:20.0]

// Thickness of the J-leg and J-lip (mm) to avoid door interference.
j_thickness = 5.0; // [3.0:15.0]

// Height of the clamp (extrusion depth in Z axis) (mm)
height = 25.0; // [5.0:50.0]

// Length of the flat L-shaped leg (mm)
l_leg_length = 30.0; // [10.0:50.0]

// Length of the perpendicular portion of the J-shaped leg (mm)
j_leg_length = 17.0; // [10.0:40.0]

// Length of the return lip on the J-shaped leg (mm)
j_lip_length = 7.0; // [3.0:20.0]


/* [Flares & Comfort Settings] */

// Size of the entry bevel/flare to guide the clamp smoothly onto the frame (mm)
flare_size = 2.0; // [0.0:5.0]

// Radius for rounding inner and outer corners for strength and aesthetics (mm)
round_radius = 3.0; // [0.0:8.0]

// Size of the chamfer (phase/Fase) on the top and bottom outer edges and leg tips (mm)
chamfer_size = 1.0; // [0.0:3.0]


/* [Tether Hole Settings] */

// Enable a tether hole directly inside the solid corner of the clamp body
tether_hole_enabled = true;

// Diameter of the tether hole (mm)
tether_hole_diameter = 3.0; // [1.0:8.0]

// Size of the 45-degree chamfer at the top and bottom entry of the tether hole (mm)
hole_chamfer = 1.0; // [0.0:3.0]


/* [Resolution] */

// Curve resolution (higher = smoother, but slower rendering)
$fn = 128; // [16, 32, 64, 128, 256]


// --- Safety Calculations ---
// Prevent geometric errors if round_radius or flare_size is set too high
safe_l_flare = min(flare_size, thickness - 1.0);
safe_j_flare = min(flare_size, j_thickness - 1.0);

// Prevent the hole from being larger than the wall thickness allows (at least 1mm wall remains)
safe_hole_radius = min(tether_hole_diameter / 2.0, (thickness / 2.0) - 1.0);

// Prevent the hole chamfer from exceeding the outer wall boundaries (at least 1mm wall remains at chamfer edge)
safe_hole_chamfer = min(hole_chamfer, max(0, (thickness / 2.0) - safe_hole_radius - 1.0));

// Prevent the outer chamfer from exceeding physical boundaries (less than half of height and thinnest wall thickness)
safe_chamfer = min(chamfer_size, min(height / 2.0 - 0.1, j_thickness / 2.0 - 0.5));

// Prevent the fillet radius from causing self-intersections on small features (like the J-lip tip face when chamfered)
safe_radius_limit = (j_thickness - safe_j_flare - safe_chamfer) / 2.0 - 0.1;
safe_radius = max(0.2, min(round_radius, min((j_thickness / 2.0) - 0.2, safe_radius_limit)));

// Let's print out the parameters to the console for user visibility
echo("--- Raddle-Master Clamp Profile Configuration ---");
echo("Assembly Clamping Width:", assembly_width, "mm");
echo("Wall Thickness:", thickness, "mm");
echo("Clamp Height:", height, "mm");
echo("L-Leg Length:", l_leg_length, "mm");
echo("J-Leg Length:", j_leg_length, "mm");
echo("J-Lip Length:", j_lip_length, "mm");
echo("Entry Flare Size (L-leg):", safe_l_flare, "mm (requested:", flare_size, "mm)");
echo("Entry Flare Size (J-leg):", safe_j_flare, "mm (requested:", flare_size, "mm)");
echo("Fillet Radius:", safe_radius, "mm (requested:", round_radius, "mm)");
echo("Top/Bottom Outer Chamfer Size:", safe_chamfer, "mm (requested:", chamfer_size, "mm)");
echo("Tether Hole Chamfer Size:", safe_hole_chamfer, "mm (requested:", hole_chamfer, "mm)");


/*
  Polygon Coordinates Construction
  --------------------------------
  We generate the 2D profile using a function. This allows us to shift
  ONLY the outer walls and leg tips for the top/bottom chamfers (phases),
  keeping the inner clamping faces 100% vertical and flat.
  The coordinate system starts with the internal corner of the L-leg at [0,0].
*/
function get_points(offset_outer = 0) = [
    [-safe_l_flare, l_leg_length - offset_outer],                                    // p1: L-leg flared inner tip
    [0, l_leg_length - safe_l_flare],                                                // p2: L-leg inner flat start (constant)
    [0, 0],                                                                          // p3: Inner corner: L-leg & Main Span (constant)
    [assembly_width, 0],                                                             // p4: Inner corner: Main Span & J-leg (constant)
    [assembly_width, j_leg_length],                                                  // p5: Inner corner: J-leg & J-lip (constant)
    [assembly_width - j_lip_length + safe_j_flare, j_leg_length],                    // p6: J-lip inner flat start (constant)
    [assembly_width - j_lip_length + offset_outer, j_leg_length + safe_j_flare],      // p7: J-lip flared inner tip
    [assembly_width - j_lip_length + offset_outer, j_leg_length + j_thickness - offset_outer], // p8: J-lip outer tip
    [assembly_width + j_thickness - offset_outer, j_leg_length + j_thickness - offset_outer], // p9: Outer corner: J-lip & J-leg
    [assembly_width + j_thickness - offset_outer, -thickness + offset_outer],         // p10: Outer corner: J-leg & Main Span
    [-thickness + offset_outer, -thickness + offset_outer],                          // p11: Outer corner: Main Span & L-leg
    [-thickness + offset_outer, l_leg_length - offset_outer]                         // p12: L-leg outer tip
];


module clamp_profile(offset_outer = 0) {
    points = get_points(offset_outer);
    if (safe_radius > 0) {
        // High-quality triple-offset fillet trick to round both internal and external corners smoothly
        offset(r = safe_radius)
        offset(r = -2 * safe_radius)
        offset(r = safe_radius)
        polygon(points);
    } else {
        // Fallback to sharp corners if radius is 0
        polygon(points);
    }
}


// Assemble the 3D Model
difference() {
    // 1. Build the 3D clamp body with stacked slices for top/bottom outer chamfers
    union() {
        if (safe_chamfer > 0) {
            num_slices = 10; // Number of slices to approximate the chamfer slope smoothly
            slice_height = safe_chamfer / num_slices;

            // Bottom edge chamfer slices (stepped outer walls, perfectly hollow slot)
            for (i = [0 : num_slices - 1]) {
                translate([0, 0, i * slice_height])
                linear_extrude(height = slice_height)
                clamp_profile(safe_chamfer * (1 - (i / num_slices)));
            }

            // Middle straight segment (normal full thickness, vertical walls)
            translate([0, 0, safe_chamfer])
            linear_extrude(height = height - 2 * safe_chamfer, convexity = 10)
            clamp_profile(0);

            // Top edge chamfer slices (stepped outer walls, perfectly hollow slot)
            for (i = [0 : num_slices - 1]) {
                translate([0, 0, height - safe_chamfer + i * slice_height])
                linear_extrude(height = slice_height)
                clamp_profile(safe_chamfer * (i / num_slices));
            }
        } else {
            // Fallback: standard straight extrusion if chamfer is 0
            linear_extrude(height = height, convexity = 10)
            clamp_profile(0);
        }
    }

    // 2. Subtract Tether Hole and chamfers if enabled (centered directly inside the L-leg / Main Span corner)
    if (tether_hole_enabled && safe_hole_radius > 0) {
        // Main cylindrical hole
        translate([-thickness / 2.0, -thickness / 2.0, height / 2.0])
        cylinder(r = safe_hole_radius, h = height + 2.0, center = true);

        // Chamfer top and bottom entries of the hole using conical cylinders
        if (safe_hole_chamfer > 0) {
            // Bottom hole chamfer cone
            translate([-thickness / 2.0, -thickness / 2.0, -0.01])
            cylinder(r1 = safe_hole_radius + safe_hole_chamfer, r2 = safe_hole_radius, h = safe_hole_chamfer + 0.01);

            // Top hole chamfer cone
            translate([-thickness / 2.0, -thickness / 2.0, height - safe_hole_chamfer])
            cylinder(r1 = safe_hole_radius, r2 = safe_hole_radius + safe_hole_chamfer, h = safe_hole_chamfer + 0.01);
        }
    }
}
