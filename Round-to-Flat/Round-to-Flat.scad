// =========================================================================
// DESIGN: Parametric Round-to-Flat Adapter Plate
// FILE: Round-to-Flat.scad
// VERSION: v0.12
// DATE: 2026-06-30
// AUTHOR: Zed Coding Agent
// DESCRIPTION:
//   An elegant, fully parametric OpenSCAD adapter plate designed to bridge
//   the curved surface of a round mast (default 220mm diameter) and a
//   flat-backed plate (default 100x150mm with 20mm corner radiuses).
//
//   Includes options for:
//   - Configurable mast diameter and orientation (parallel to X or Y axis).
//   - Parametric flat plate dimensions and corner roundedness.
//   - Custom flat-plate mounting holes with round or hex pockets (for nuts/bolt heads).
//   - Built-in curved hose clamp/steel banding slots for securing the adapter to the mast.
//   - Auto-visualizer for inspection of the complete assembly.
//
// PRINTING TIPS:
//   - Material: PETG, ASA, or ABS are highly recommended for outdoor mast installations
//     due to UV resistance and temperature stability.
//   - Orientation:
//     1. Flat on Bed (Default): Easy to print, minimal support required, great for
//        the flat plate mounting surface. The hose clamp slots will print as small bridges.
//     2. On Side (Y-Z or X-Z plane): Maximum layer-bonding strength against clamp tension.
//        Requires a brim or supports depending on the orientation, but yields high accuracy
//        for the curved contact surfaces.
//   - Infill: 30% - 50% Gyroid or Grid infill with 4+ walls for structural strength.
// =========================================================================

/* [Mast Parameters] */
// Diameter of the round metal mast (default: 220mm)
mast_diameter = 220; // [50:500]

// Orientation of the mast axis relative to the adapter plate
mast_axis = "Y"; // ["X", "Y"]

/* [Flat Plate Parameters] */
// Width of the flat plate (X axis)
flat_width = 120; // [20:300]

// Length of the flat plate (Y axis)
flat_length = 145; // [20:450]

// Corner radius of the flat plate (default: 20mm)
flat_corner_radius = 6; // [0:100]

/* [Adapter Thickness Parameters] */
// Minimum solid material thickness of the adapter at its thinnest point (default: 10mm)
min_thickness = 10; // [4:40]

/* [Metal Plate Recess Parameters] */
// Enable a recessed captive pocket on the flat side to hold the metal plate
recess_enabled = false;

// Thickness of the metal plate (depth of the recess pocket)
recess_depth = 2.5;

// Tolerance/clearance around the metal plate edges for an easy fit
recess_clearance = 0.3;

// Outer wall thickness around the recessed pocket (set to 0 for a simple flat mount with no captive pocket)
recess_wall_thickness = 3;

/* [Mounting Holes (Flat Plate to Adapter)] */
// Enable mounting holes for attaching the flat plate
mount_holes_enabled = false;

// Diameter of the mounting screws (e.g., 5.5 for M5 clearance)
mount_hole_diameter = 8.5;

// Distance between mounting holes along the X axis (concentric with 20mm corners: 100 - 2*20 = 60)
mount_hole_spacing_x = 88;

// Distance between mounting holes along the Y axis (concentric with 20mm corners: 150 - 2*20 = 110)
mount_hole_spacing_y = 118;

// Remaining material thickness for bolt heads or nuts to clamp against (flat shoulder)
bolt_clamp_thickness = 5;

// Enable hex/round recess pockets on the curved mast side (prevents screws from touching the mast)
pocket_enabled = true;

// Shape of the recessed pockets
pocket_shape = "hex"; // ["round", "hex"]

// Size of the pocket (diameter for round, flat-to-flat width of 13.0mm for M8 hex + 0.6mm tolerance = 13.6mm)
pocket_size = 13.6;

/* [Hose Clamp Slots (Adapter to Mast)] */
// Enable slots for steel hose clamps or banding
clamp_slots_enabled = true;

// Route the clamp bands through the flat plate holes (enter flat face, exit sides!)
clamp_through_holes_enabled = true;

// Width of the hose clamp band slot (along the Y/X axis)
clamp_width = 9;

// Thickness of the hose clamp band slot (radial clearance)
clamp_thickness = 0.6;

// Remaining wall thickness between the slot ceiling and the flat plate face (default: 3mm)
// Lower values make the plastic under the mast thicker and stronger, but the slot will open on the flat side in the center.
clamp_ceiling_margin = 3; // [0.5:15]

// Automatically calculate clamp_offset to make the plastic under the mast as thick as possible.
// If clamp_ceiling_margin is small, the slot will naturally open on the flat side in the center.
clamp_offset = min_thickness + clamp_thickness/2 - clamp_ceiling_margin;

// Positions of the clamp slots along the mast axis relative to center
clamp_positions = [-40, 40];

/* [Design Precision] */
// Curve resolution (higher = smoother, but slower rendering)
precision = 100; // [30:200]

/* [Visualization Options] */
// Show translucent mast and flat plate in preview (automatically hidden in STL renders)
show_visualization = true;


// =========================================================================
// INTERNAL GEOMETRICAL CALCULATIONS
// =========================================================================

$fn = precision;

// Mast radius
R_mast = mast_diameter / 2;

// Depth of the recess if enabled
r_depth = (recess_enabled && recess_depth > 0) ? recess_depth : 0;

// Sizing of the outer adapter plate based on the recess settings
adapter_width = flat_width + (recess_enabled ? 2 * (recess_clearance + recess_wall_thickness) : 0);
adapter_length = flat_length + (recess_enabled ? 2 * (recess_clearance + recess_wall_thickness) : 0);
adapter_corner_radius = flat_corner_radius + (recess_enabled ? (recess_clearance + recess_wall_thickness) : 0);

// Chord width is the width of the adapter perpendicular to the mast axis
chord_width = (mast_axis == "Y") ? adapter_width : adapter_length;

// Sagitta is the depth of the circular arc carved into the adapter: s = R - sqrt(R^2 - (W/2)^2)
// Safe guard prevents square root of negative numbers if flat plate is wider than the mast diameter
sagitta = (R_mast > chord_width/2) ? (R_mast - sqrt(pow(R_mast, 2) - pow(chord_width/2, 2))) : R_mast;

// The total thickness of the adapter at its thickest edge points
total_thickness = r_depth + min_thickness + sagitta;

// Determine clamp positions along the mast axis.
// If routing through plate holes, they must align exactly with the mounting holes.
clamp_positions_calculated = clamp_through_holes_enabled ? (
    (mast_axis == "Y") ? [-mount_hole_spacing_y / 2, mount_hole_spacing_y / 2] : [-mount_hole_spacing_x / 2, mount_hole_spacing_x / 2]
) : clamp_positions;


// =========================================================================
// MAIN ASSEMBLY
// =========================================================================

// Render the final adapter plate
adapter_plate();

// Render visualization objects if enabled and in preview mode
if (show_visualization && $preview) {
    visualize_assembly();
}


// =========================================================================
// MODULES & GEOMETRY
// =========================================================================

// --- Main Adapter Plate ---
module adapter_plate() {
    difference() {
        // 1. Base solid block with rounded corners
        rounded_rectangle(adapter_width, adapter_length, adapter_corner_radius, total_thickness);

        // 2. Subtract the recessed captive pocket for the flat plate (if enabled)
        if (recess_enabled && recess_depth > 0) {
            // Cut from slightly below z=0 to the recess depth to ensure clean manifold subtraction
            translate([0, 0, -0.5])
            rounded_rectangle(
                flat_width + 2 * recess_clearance,
                flat_length + 2 * recess_clearance,
                flat_corner_radius + recess_clearance,
                recess_depth + 0.5
            );
        }

        // 3. Subtract the curved mast surface
        mast_cylinder_cutout();

        // 4. Subtract mounting holes (if enabled and not using clamp routing)
        if (mount_holes_enabled && !clamp_through_holes_enabled) {
            mounting_holes_cutout();
        }

        // 5. Subtract hose clamp slots (if enabled)
        if (clamp_slots_enabled) {
            for (pos = clamp_positions_calculated) {
                if (clamp_through_holes_enabled) {
                    routed_clamp_slot(pos);
                } else {
                    clamp_slot_cutout(pos);
                }
            }
        }
    }
}

// --- Rounded Rectangle Base ---
module rounded_rectangle(w, l, r, h) {
    if (r <= 0) {
        // Fallback to a perfect rectangle if radius is 0
        translate([0, 0, h/2])
        cube([w, l, h], center = true);
    } else {
        // Clamp corner radius so it doesn't exceed half the width or length
        r_clamped = min(r, min(w/2, l/2));

        translate([0, 0, h/2])
        hull() {
            translate([-w/2 + r_clamped, -l/2 + r_clamped, 0]) cylinder(r = r_clamped, h = h, center = true);
            translate([ w/2 - r_clamped, -l/2 + r_clamped, 0]) cylinder(r = r_clamped, h = h, center = true);
            translate([-w/2 + r_clamped,  l/2 - r_clamped, 0]) cylinder(r = r_clamped, h = h, center = true);
            translate([ w/2 - r_clamped,  l/2 - r_clamped, 0]) cylinder(r = r_clamped, h = h, center = true);
        }
    }
}

// --- Mast Cylinder Cutout ---
module mast_cylinder_cutout() {
    if (mast_axis == "Y") {
        // Mast runs along the Y axis, centered at X=0, Z = r_depth + min_thickness + R_mast
        translate([0, 0, r_depth + min_thickness + R_mast])
        rotate([90, 0, 0])
        cylinder(r = R_mast, h = adapter_length + 10, center = true);
    } else {
        // Mast runs along the X axis, centered at Y=0, Z = r_depth + min_thickness + R_mast
        translate([0, 0, r_depth + min_thickness + R_mast])
        rotate([0, 90, 0])
        cylinder(r = R_mast, h = adapter_width + 10, center = true);
    }
}

// --- Hose Clamp Slot Cutout ---
module clamp_slot_cutout(pos) {
    // Radii of the curved slot
    R_slot_outer = R_mast + clamp_offset + clamp_thickness/2;
    R_slot_inner = R_mast + clamp_offset - clamp_thickness/2;

    // Check if the slot height breaches the bottom face (which is r_depth at the thinnest central part)
    // Bottom of slot at x=0 is z = r_depth + min_thickness - clamp_offset - clamp_thickness/2
    // If this is <= r_depth, the slot would open into the recess pocket!
    if (min_thickness <= (clamp_offset + clamp_thickness/2)) {
        echo("<font color='blue'><b>INFO:</b> The clamp slot is open on the flat front face in the center (optimized for maximum structural thickness).</font>");
    } else {
        echo("<font color='green'><b>INFO:</b> The clamp slot is fully enclosed inside the adapter body.</font>");
    }

    difference() {
        // Full curved slot
        if (mast_axis == "Y") {
            // Slot is perpendicular to the Y axis (wraps around Y-mast in X-Z plane)
            translate([0, pos, r_depth + min_thickness + R_mast])
            rotate([90, 0, 0])
            difference() {
                cylinder(r = R_slot_outer, h = clamp_width, center = true);
                // Extra length in Z to ensure clean subtraction
                cylinder(r = R_slot_inner, h = clamp_width + 2, center = true);
            }
        } else {
            // Slot is perpendicular to the X axis (wraps around X-mast in Y-Z plane)
            translate([pos, 0, r_depth + min_thickness + R_mast])
            rotate([0, 90, 0])
            difference() {
                cylinder(r = R_slot_outer, h = clamp_width, center = true);
                cylinder(r = R_slot_inner, h = clamp_width + 2, center = true);
            }
        }

        // If routing through holes, subtract the center section so the slot doesn't exist between the holes
        if (clamp_through_holes_enabled) {
            // Subtract a box covering the center portion
            // We leave an overlap of 5mm past the hole centers to make threading easier
            overlap = 5;
            center_w = (mast_axis == "Y") ?
                (mount_hole_spacing_x - 2 * overlap) :
                (mount_hole_spacing_y - 2 * overlap);

            if (mast_axis == "Y") {
                translate([0, pos, total_thickness/2])
                cube([center_w, clamp_width + 2, total_thickness + 2], center = true);
            } else {
                translate([pos, 0, total_thickness/2])
                cube([clamp_width + 2, center_w, total_thickness + 2], center = true);
            }
        }
    }
}

// --- Routed Clamp Slot (Straight Diagonal) ---
module routed_clamp_slot(pos) {
    hole_dist = (mast_axis == "Y") ? abs(mount_hole_spacing_x / 2) : abs(mount_hole_spacing_y / 2);
    block_dist = (mast_axis == "Y") ? (adapter_width / 2) : (adapter_length / 2);

    // In OpenSCAD coordinate space for this model:
    // Z = 0 is the FLAT face (underneath the metal plate).
    // Z = total_thickness is the CURVED face (against the mast).
    // We want the tunnel to go from the flat face (Z=0) at the hole position,
    // to the vertical side face of the block, exiting near the curved back.
    Z_side = total_thickness - clamp_width/2 - 2;

    w = clamp_width + 1.5;
    t = clamp_thickness + 1.2;

    module cut_shape() {
        if (mast_axis == "Y") {
            rotate([90, 0, 0]) cylinder(d=t, h=w, center=true);
        } else {
            rotate([0, 90, 0]) cylinder(d=t, h=w, center=true);
        }
    }

    module single_tunnel(is_right) {
        sign = is_right ? 1 : -1;

        dx = block_dist - hole_dist;
        dz = Z_side - 0;

        // Normalize vector
        len = sqrt(dx*dx + dz*dz);
        dir_x = dx / len;
        dir_z = dz / len;

        // Extend to ensure clean cuts through the faces
        ext_hole_x = hole_dist - dir_x * 5;
        ext_hole_z = 0 - dir_z * 5;

        ext_side_x = block_dist + dir_x * 5;
        ext_side_z = Z_side + dir_z * 5;

        hull() {
            if (mast_axis == "Y") {
                translate([sign * ext_hole_x, 0, ext_hole_z]) cut_shape();
                translate([sign * ext_side_x, 0, ext_side_z]) cut_shape();
            } else {
                translate([0, sign * ext_hole_x, ext_hole_z]) cut_shape();
                translate([0, sign * ext_side_x, ext_side_z]) cut_shape();
            }
        }
    }

    if (mast_axis == "Y") {
        translate([0, pos, 0]) {
            single_tunnel(true);
            single_tunnel(false);
        }
    } else {
        translate([pos, 0, 0]) {
            single_tunnel(true);
            single_tunnel(false);
        }
    }
}

// --- Mounting Holes and Pockets ---
module mounting_holes_cutout() {
    x_positions = [-mount_hole_spacing_x / 2, mount_hole_spacing_x / 2];
    y_positions = [-mount_hole_spacing_y / 2, mount_hole_spacing_y / 2];

    // Compute local thickness at the mounting hole location to clamp the pocket depth safely
    hole_dist = (mast_axis == "Y") ? abs(mount_hole_spacing_x / 2) : abs(mount_hole_spacing_y / 2);
    local_thick = (R_mast > hole_dist) ?
        (min_thickness + R_mast - sqrt(pow(R_mast, 2) - pow(hole_dist, 2))) :
        min_thickness;

    // Ensure we leave at least 2.5mm of physical material for the screw shoulder to clamp against
    clamped_clamp_thickness = r_depth + max(2.5, min(bolt_clamp_thickness, local_thick - 2.5));

    for (x = x_positions) {
        for (y = y_positions) {
            // 1. Through-hole for screw shank (runs through entire adapter thickness)
            translate([x, y, -1])
            cylinder(d = mount_hole_diameter, h = total_thickness + 2);

            // 2. Nut/Bolt pocket on the curved mast side
            if (pocket_enabled) {
                // Starts at clamped_clamp_thickness and cuts up through the curved surface
                translate([x, y, clamped_clamp_thickness])
                pocket_volume(pocket_size, total_thickness - clamped_clamp_thickness + 1, pocket_shape);
            }
        }
    }
}

// --- Bolt/Nut Pocket Volume Helper ---
module pocket_volume(size, depth, shape) {
    if (shape == "hex") {
        // In OpenSCAD, a cylinder with $fn=6 is sized by outer radius (corner-to-center).
        // Flat-to-flat width (size) requires: Radius = size / sqrt(3)
        rotate([0, 0, 30]) // Align flat edge of hex parallel to plate edge
        cylinder(r = size / sqrt(3), h = depth, $fn = 6);
    } else {
        // Default to circular pocket
        cylinder(d = size, h = depth);
    }
}


// =========================================================================
// VISUALIZATION MODULE (PREVIEW ONLY)
// =========================================================================

module visualize_assembly() {
    // 1. Render Mast (Translucent Steel Blue)
    color([0.65, 0.72, 0.8, 0.35]) {
        if (mast_axis == "Y") {
            translate([0, 0, r_depth + min_thickness + R_mast])
            rotate([90, 0, 0])
            cylinder(r = R_mast, h = adapter_length + 60, center = true);
        } else {
            translate([0, 0, r_depth + min_thickness + R_mast])
            rotate([0, 90, 0])
            cylinder(r = R_mast, h = adapter_width + 60, center = true);
        }
    }

    // 2. Render Mock Flat Metal Plate (Translucent Orange)
    color([1.0, 0.45, 0.1, 0.5]) {
        // If recess is enabled, plate sits inside the pocket. If disabled, it sits below with a 2mm assembly gap.
        z_plate = recess_enabled ? 0.05 : -recess_depth - 2;
        h_plate = recess_enabled ? recess_depth - 0.05 : recess_depth;

        translate([0, 0, z_plate])
        difference() {
            // Footprint matching the requested flat plate
            rounded_rectangle(flat_width, flat_length, flat_corner_radius, h_plate);

            // Subtract holes to verify alignment visually
            if (mount_holes_enabled || clamp_through_holes_enabled) {
                x_positions = [-mount_hole_spacing_x / 2, mount_hole_spacing_x / 2];
                y_positions = [-mount_hole_spacing_y / 2, mount_hole_spacing_y / 2];
                for (x = x_positions) {
                    for (y = y_positions) {
                        if (clamp_through_holes_enabled) {
                            // Render matching rectangular slots on the flat plate
                            translate([x, y, h_plate/2])
                            if (mast_axis == "Y") {
                                cube([clamp_thickness + 1.2, clamp_width + 1.5, h_plate + 2], center = true);
                            } else {
                                cube([clamp_width + 1.5, clamp_thickness + 1.2, h_plate + 2], center = true);
                            }
                        } else {
                            translate([x, y, -1])
                            cylinder(d = mount_hole_diameter, h = h_plate + 2);
                        }
                    }
                }
            }
        }
    }
}
