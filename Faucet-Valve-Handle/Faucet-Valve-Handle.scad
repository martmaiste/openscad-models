/*
=================================================================================
File: Faucet-Valve-Handle.scad
Version: v0.07
Date: 2026-06-14
Description:
    A fully parametric, highly ergonomic faucet valve handle designed to slip
    over an existing 21.5mm hexagonal valve knob that is too hard to turn by
    hand. It expands the grip diameter to 50mm and provides comfortable,
    high-leverage finger lobes.

    The design features:
    - A smooth, flat top with parametric edge chamfering on both the top and
      bottom outer edges (v0.07 default) for extremely easy 3D printing,
      elimination of elephant's foot, and smooth-to-the-touch handling.
    - Optional spherical dome top (v0.01 default) if dome_drop > 0.
    - Fully rounded lobes for maximum grip comfort without sharp edges.
    - A single, clean, large central through-hole to hold colored hot/cold
      indicator label caps (red/blue inserts), making them easy to pop in or
      push out from the bottom if disassembly is needed.
    - Parametric chamfers on both the inside (hex socket ceiling) and outside
      (top face) entrances of the central through-hole (v0.06 default) to
      facilitate smooth assembly and support-free bridging.
    - An optional side set screw (grub screw) hole aligned perpendicular to
      one of the flat faces of the hex socket for secure mounting.
    - 100% support-free 3D printing (prints flat bottom face down or flat top
      face down!).

Changelog:
    - v0.01 (2026-06-14): Initial release with 5-lobe grip and domed top.
    - v0.02 (2026-06-14): Added parametric chamfering and flattened top by
      default to facilitate very easy 3D printing.
    - v0.03 (2026-06-14): Disabled the central screw hole and counterbore recess
      by default.
    - v0.04 (2026-06-14): Re-enabled and enlarged the central hole and counterbore
      recess to serve as an inlay for the colored hot/cold indicator label (cap).
    - v0.05 (2026-06-14): Simplified the design to have a single, clean, large
      through-hole for snap-in indicator label caps as requested.
    - v0.06 (2026-06-14): Added parametric chamfers on both the inside (ceiling
      of hex socket) and outside (top face) of the central through-hole.
    - v0.07 (2026-06-14): Added a matching bottom chamfer to the outer handle
      shape to make it smooth to grip from underneath and print cleanly.
=================================================================================
*/

/* [Handle Dimensions] */
// Target outer diameter of the handle (mm)
outer_diameter   = 50.0; // [30.0:100.0]

// Maximum height of the handle at the center (mm)
handle_height    = 20.0; // [10.0:50.0]

// Vertical drop of the dome from center to edge (mm). Set to 0.0 for a flat top with chamfered edges.
dome_drop        = 0.0;  // [0.0:15.0]

// Vertical height of the outer top & bottom edge chamfers (mm). Active only when dome_drop is 0.
chamfer_height   = 1.5;  // [0.0:5.0]

// Horizontal width of the outer top & bottom edge chamfers (mm). Active only when dome_drop is 0.
chamfer_width    = 1.5;  // [0.0:5.0]

/* [Grip Shape] */
// Number of ergonomic grip lobes (5 or 6 are ideal)
num_lobes        = 5;    // [3:12]

// Lobe diameter as a fraction of outer diameter (e.g., 0.32 = 32%)
lobe_ratio       = 0.32; // [0.1:0.5]

// Radius of inner corner fillets (valleys between lobes) (mm)
fillet_inner     = 3.5;  // [0.0:10.0]

// Radius of outer corner fillets (peaks of lobes) (mm)
fillet_outer     = 2.0;  // [0.0:10.0]

/* [Valve Interface (Hex Socket)] */
// Hexagon distance between parallel faces (flat-to-flat) of the original knob (mm)
hex_flat_to_flat = 21.5;

// Socket depth from the bottom of the handle (mm)
socket_depth     = 14.0; // [5.0:45.0]

// Print clearance/tolerance added to the hex socket size (mm)
socket_clearance = 0.3;  // [0.0:1.0]

/* [Central Access Hole / Indicator Cap] */
// Diameter of the central hole (mm). Goes all the way through the handle to accommodate snap-in colored labels or screw access. Set to 0 to disable.
center_hole_dia  = 12.0; // [0.0:25.0]

// Size of the chamfer for the central hole on both the inside and outside (mm). Set to 0 to disable.
hole_chamfer     = 1.0;  // [0.0:3.0]

// Side set screw (grub screw) hole diameter (mm). Set to 0 to disable.
set_screw_dia    = 0.0;

// Height of the side set screw from the bottom face (mm)
set_screw_height = 7.0;

/* [Rendering Quality] */
// Circle/Sphere fragment resolution ($fn)
resolution       = 64;   // [16:128]


// =================================================================================
// --- Derived Parameters (Do Not Modify) ---
// =================================================================================
outer_radius  = outer_diameter / 2;
lobe_diameter = outer_diameter * lobe_ratio;
lobe_radius   = lobe_diameter / 2;
lobe_offset   = outer_radius - lobe_radius;
core_radius   = lobe_offset; // Core circle meets the lobe centers to ensure solid center

// Set the global resolution for all curved surfaces
$fn = resolution;


// =================================================================================
// --- Modules ---
// =================================================================================

/**
 * Creates a 2D regular hexagon with a flat-to-flat distance.
 * The hexagon is rotated by 30 degrees to orient a flat face perpendicular
 * to the X-axis, allowing a horizontal set screw to press flat against it.
 */
module hexagon(flat_to_flat) {
    R = flat_to_flat / sqrt(3);
    rotate([0, 0, 30]) {
        circle(r = R, $fn = 6);
    }
}

/**
 * Creates the raw 2D lobed shape (core cylinder + outer lobes).
 */
module raw_lobed_shape() {
    union() {
        // Central core cylinder
        circle(r = core_radius);

        // Circular grip lobes distributed symmetrically
        for (i = [0 : num_lobes - 1]) {
            rotate(i * 360 / num_lobes)
            translate([lobe_offset, 0, 0])
            circle(d = lobe_diameter);
        }
    }
}

/**
 * Creates the smoothed 2D profile of the handle using the dual-offset fillet method.
 */
module handle_2d_profile() {
    if (fillet_inner > 0 || fillet_outer > 0) {
        offset(r = fillet_outer)
        offset(r = -fillet_outer - fillet_inner)
        offset(r = fillet_inner) {
            raw_lobed_shape();
        }
    } else {
        raw_lobed_shape();
    }
}

/**
 * Creates the 3D body of the handle, incorporating either a top dome shape (if dome_drop > 0)
 * or a flat top with smooth top and bottom edge chamfers (if dome_drop is 0 and chamfers are enabled).
 */
module handle_body_3d() {
    if (dome_drop > 0) {
        // Calculate the exact radius and center of a sphere that passes through the
        // center at handle_height and the outer edge at (handle_height - dome_drop).
        // Equation derived from: outer_radius^2 + (z_center - (handle_height - dome_drop))^2 = R_dome^2
        // and: R_dome = handle_height - z_center
        let (
            r = outer_radius,
            h = dome_drop,
            R_dome = (r * r + h * h) / (2 * h),
            z_center = handle_height - R_dome
        ) {
            intersection() {
                // Main extruded profile
                linear_extrude(height = handle_height, convexity = 10) {
                    handle_2d_profile();
                }
                // Subtracting sphere complement / Intersecting with sphere
                translate([0, 0, z_center]) {
                    sphere(r = R_dome);
                }
            }
        }
    } else {
        // Flat-topped handle with top and bottom chamfers (makes top-down or bottom-down printing easy and smooth)
        if (chamfer_height > 0 && chamfer_width > 0) {
            // Clamp chamfer_height to a maximum of 40% of the total height to prevent geometry overlap
            let (
                c_h = min(chamfer_height, handle_height * 0.4)
            ) {
                union() {
                    // 1. Bottom Chamfer (lofted expanding extrusion)
                    // We mirror a standard tapering extrusion to make it expand as it goes up
                    translate([0, 0, c_h]) {
                        mirror([0, 0, 1]) {
                            linear_extrude(
                                height = c_h,
                                scale = (outer_radius - chamfer_width) / outer_radius,
                                convexity = 10
                            ) {
                                handle_2d_profile();
                            }
                        }
                    }

                    // 2. Main cylindrical middle section
                    translate([0, 0, c_h]) {
                        linear_extrude(height = handle_height - 2 * c_h, convexity = 10) {
                            handle_2d_profile();
                        }
                    }

                    // 3. Top Chamfer (lofted tapering extrusion)
                    translate([0, 0, handle_height - c_h]) {
                        linear_extrude(
                            height = c_h,
                            scale = (outer_radius - chamfer_width) / outer_radius,
                            convexity = 10
                        ) {
                            handle_2d_profile();
                        }
                    }
                }
            }
        } else {
            // Flat-topped handle with no chamfer
            linear_extrude(height = handle_height, convexity = 10) {
                handle_2d_profile();
            }
        }
    }
}


// =================================================================================
// --- Main Assembly ---
// =================================================================================

difference() {
    // 1. Start with the solid 3D handle body
    handle_body_3d();

    // 2. Subtract the hexagonal socket on the bottom
    translate([0, 0, -0.1]) { // Offset slightly to prevent Z-fighting at the bottom face
        linear_extrude(height = socket_depth + 0.1, convexity = 10) {
            hexagon(hex_flat_to_flat + socket_clearance);
        }
    }

    // 3. Subtract central through-hole and its inside/outside chamfers (if enabled)
    if (center_hole_dia > 0) {
        // Main cylinder going through
        translate([0, 0, -1]) {
            cylinder(d = center_hole_dia, h = handle_height + 2);
        }

        // Chamfers for the central hole
        if (hole_chamfer > 0) {
            // Outside chamfer (at the flat top face)
            translate([0, 0, handle_height - hole_chamfer]) {
                cylinder(d1 = center_hole_dia, d2 = center_hole_dia + 2 * hole_chamfer, h = hole_chamfer + 0.1);
            }

            // Inside chamfer (at the ceiling of the hex socket)
            translate([0, 0, socket_depth - 0.1]) {
                cylinder(d1 = center_hole_dia + 2 * hole_chamfer, d2 = center_hole_dia, h = hole_chamfer + 0.1);
            }
        }
    }

    // 4. Subtract side set screw hole (if enabled)
    // Points along the X-axis, hitting the hex flat perpendicularly
    if (set_screw_dia > 0) {
        translate([0, 0, set_screw_height]) {
            rotate([0, 90, 0]) {
                cylinder(d = set_screw_dia, h = outer_radius + 5);
            }
        }
    }
}
