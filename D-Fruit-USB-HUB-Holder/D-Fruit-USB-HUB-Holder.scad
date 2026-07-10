// =================================================================================================
// Title:       Vertical D-Fruit USB HUB Holder / Wall Mount
// File Name:   D-Fruit-USB-HUB-Holder.scad
// Version:     v0.12 (2026-07-10)
// License:     Creative Commons - Attribution - ShareAlike
// Description: A fully parametric, two-part vertical wall mount for the D-Fruit USB Hub.
//              Optimized with a completely hidden screw mount design (no external ears/tabs).
//              Features a seamless outer profile with flat sides and rounded front.
//              Uses an elegant dual-shelf design at the bottom to hold the hub.
//              Flips the top part upside-down in print renders so the chamfered opening
//              prints at the top, offering perfect bed adhesion and clean, support-free overhangs.
//              Pre-configures the camera to display the front-face of the assembly fully on load.
// =================================================================================================

// Special OpenSCAD camera viewport parameters to instantly show the front side of the mount
// (cable slot, front access hole, USB ports) with the wall behind it.
$vpt = [0, 0, 75];     // Target coordinate (centered vertically on the 145mm hub)
$vpr = [75, 0, 215];   // Rotation angle (angled looking from front-right-above)
$vpd = 450;            // Camera distance (pulled back so the entire vertical assembly fits in view)

/* [Render Options] */
// Choose which part to display in OpenSCAD
part = "preview"; // [bottom: Bottom Holder Cup, top: Top Guide Collar (Flipped for Print), both: Both Parts for Printing, preview: Complete Assembly Preview]

/* [Hub Dimensions] */
// Width of the USB hub extrusion (larger dimension of symmetrical cross section, in mm)
hub_width = 15.8;
// Thickness of the USB hub extrusion (smaller dimension in the center, in mm)
hub_thickness = 8.4;
// Curvature radius of the wider 15.8mm faces (in mm)
hub_face_radius = 50.0;
// Corner/edge radius of the outer thin ends of the profile (in mm)
hub_corner_radius = 2.0;
// Total length of the USB hub housing (in mm, used for assembly preview)
hub_length = 145.0;
// Profile geometry style
profile_type = "curved_lens"; // [curved_lens: Curved Lens (50mm Radius Face), rounded_rectangle: Rounded Rectangle, capsule: Full Oval/Capsule]

/* [Fit Clearances] */
// Tolerance around the hub in the bottom part (in mm, for a snug rest)
clearance_bottom = 0.3;
// Tolerance around the hub in the top part (in mm, slightly larger to allow easy insertion/tilting)
clearance_top = 0.8;

/* [Bottom Part Options] */
// Depth of the bottom pocket holding the hub (in mm)
bottom_depth = 15.0;
// Thickness of the bottom floor shelves of the cup (in mm)
bottom_wall_thickness = 4.0;
// Width of the center U-shaped channel for sliding the cable/strain-relief through (in mm)
cable_slot_width = 8.5;

/* [Top Part Options] */
// Height of the top guide collar (in mm)
top_height = 20.0;
// Height of the flared bevel at the bottom entry of the top part to guide insertion (in mm)
top_entry_flare = 2.5;

/* [Hidden Screw & Back-Wall Geometry] */
// Screw shaft diameter (in mm, e.g., 3.5 for standard wall screws)
screw_diameter = 3.5;
// Screw head diameter (in mm, for recess)
screw_head_diameter = 7.5;
// Recess/countersink depth for the screw head (in mm, must be less than back_wall_thickness)
screw_head_depth = 3.0;
// Type of screw head pocket
screw_head_type = "countersink"; // [countersink: Conical (Countersunk), counterbore: Flat Cylindrical (Button/Pan Head)]
// Total thickness of the back wall behind the pocket (in mm, provides strength under screw head)
back_wall_thickness = 6.0;

/* [Holder Wall Geometry] */
// Wall thickness around the sides and front of the hub pocket (in mm)
shell_wall_thickness = 3.0;

/* [Curve Resolution] */
// Number of fragments for circular elements
$fn = 64;


// =================================================================================================
// 2D Profile Generation
// =================================================================================================

// Generates the 2D cross section of the hub with an optional clearance offset
module hub_shape(clearance) {
    w = hub_width + clearance;
    t = hub_thickness + clearance;

    if (profile_type == "rounded_rectangle") {
        // Standard rounded rectangle
        r_val = hub_corner_radius;
        r = max(0.1, min(r_val, t / 2 - 0.05, w / 2 - 0.05));
        hull() {
            translate([-w/2 + r, -t/2 + r]) circle(r = r);
            translate([w/2 - r, -t/2 + r])  circle(r = r);
            translate([w/2 - r, t/2 - r])   circle(r = r);
            translate([-w/2 + r, t/2 - r])  circle(r = r);
        }
    } else if (profile_type == "capsule") {
        // Capsule shape (ends fully rounded)
        r_capsule = t / 2;
        hull() {
            translate([-w/2 + r_capsule, 0]) circle(r = r_capsule);
            translate([w/2 - r_capsule, 0])  circle(r = r_capsule);
        }
    } else if (profile_type == "curved_lens") {
        // Curved lens shape (50mm radius face + rounded ends)
        R = hub_face_radius + clearance / 2;
        r_val = hub_corner_radius;
        r = max(0.1, min(r_val, t / 2 - 0.1, w / 2 - 0.1));

        // Double offset filleting (round sharp edge transitions while keeping flat-face curves)
        offset(r = r) {
            offset(r = -r) {
                intersection() {
                    // Front bulging curve
                    translate([0, t/2 - R]) {
                        circle(r = R, $fn = 120);
                    }
                    // Back bulging curve
                    translate([0, -t/2 + R]) {
                        circle(r = R, $fn = 120);
                    }
                    // Bounding box for exact width
                    square([w, t + 20], center = true);
                }
            }
        }
    }
}

// Generates the 2D cross section of the outer shell (walls)
module shell_shape(clearance, wall_thickness) {
    offset(r = wall_thickness) hub_shape(clearance);
}

// Generates a seamless, monolithic outer 2D profile for the holder body.
// Uses a 2D hull to bridge the flat back wall and the rounded front sleeve,
// ensuring perfectly flat, smooth sides with no grooves or notches.
module outer_body_shape(clearance, shell_wall, back_wall, y_wall) {
    back_width = hub_width + clearance + 2 * shell_wall;

    hull() {
        // 1. Rounded front sleeve outer profile
        shell_shape(clearance, shell_wall);

        // 2. Flat back line representing the wall mounting face
        translate([-back_width/2, y_wall]) {
            square([back_width, 0.1]);
        }
    }
}


// =================================================================================================
// Sub-components
// =================================================================================================

// Generates a parametric screw hole aligned along the Y-axis.
// Assumes the back face of the mounting plate is at y = 0, and the front face is at y = plate_thickness.
module screw_hole(plate_thickness) {
    rotate([-90, 0, 0]) {
        // Main screw shaft (extends beyond the plate boundaries to ensure clean cut)
        translate([0, 0, -5]) {
            cylinder(d = screw_diameter, h = plate_thickness + 10);
        }

        // Screw head pocket/recess
        if (screw_head_type == "counterbore") {
            translate([0, 0, plate_thickness - screw_head_depth]) {
                cylinder(d = screw_head_diameter, h = screw_head_depth + 1);
            }
        } else { // countersink
            translate([0, 0, plate_thickness - screw_head_depth - 0.01]) {
                cylinder(d1 = screw_diameter, d2 = screw_head_diameter, h = screw_head_depth + 0.02);
            }
        }

        // Breakout extension to clear the curved inner pocket wall
        // This ensures the countersink/counterbore is fully open and doesn't get buried on the sides of the curved wall
        translate([0, 0, plate_thickness - 0.01]) {
            cylinder(d = screw_head_diameter, h = 10);
        }
    }
}


// =================================================================================================
// Main Part: Bottom Holder Cup
// =================================================================================================

module bottom_part() {
    // Coordinate offsets and dimensions
    y_wall = -hub_thickness/2 - clearance_bottom/2 - back_wall_thickness;
    total_height = bottom_depth + bottom_wall_thickness;

    difference() {
        // 1. Extrude the seamless 2D outer shape (flat back/sides, rounded front)
        linear_extrude(height = total_height) {
            outer_body_shape(clearance_bottom, shell_wall_thickness, back_wall_thickness, y_wall);
        }

        // 2. Inner pocket for the hub
        translate([0, 0, bottom_wall_thickness]) {
            linear_extrude(height = bottom_depth + 1) {
                hub_shape(clearance_bottom);
            }
        }

        // 3. Rounded U-shaped Cable and Strain Relief Channel
        // Cuts completely through the floor and front wall, rounded at the center point (0,0)
        // to match the cable position perfectly, preventing any cuts into the curved back wall.
        translate([0, 0, -1]) {
            linear_extrude(height = total_height + 2) {
                hull() {
                    // Rounded back centered at the cable exit (0,0)
                    circle(d = cable_slot_width);

                    // Box extending to the front face
                    translate([-cable_slot_width/2, 0]) {
                        square([cable_slot_width, hub_thickness/2 + clearance_bottom/2 + shell_wall_thickness + 10]);
                    }
                }
            }
        }

        // 4. Hidden screw hole inside the back wall of the pocket
        // Placed centered vertically in the hub-holding pocket
        translate([0, y_wall, bottom_wall_thickness + (bottom_depth / 2)]) {
            screw_hole(back_wall_thickness);
        }
    }
}


// =================================================================================================
// Main Part: Top Guide Collar
// =================================================================================================

module top_part() {
    // Coordinate offsets and dimensions
    y_wall = -hub_thickness/2 - clearance_top/2 - back_wall_thickness;

    // Front wall of the outer shell coordinate
    y_front_outer = hub_thickness/2 + clearance_top/2 + shell_wall_thickness;

    // Access hole diameter (slightly larger than screw head for screwdriver clearance)
    access_hole_dia = screw_head_diameter + 1.2;

    difference() {
        // 1. Extrude the seamless 2D outer shape (flat back/sides, rounded front)
        linear_extrude(height = top_height) {
            outer_body_shape(clearance_top, shell_wall_thickness, back_wall_thickness, y_wall);
        }

        // 2. Through-hole for sliding the hub in
        translate([0, 0, -1]) {
            linear_extrude(height = top_height + 2) {
                hub_shape(clearance_top);
            }
        }

        // 3. Flare/bevel at the bottom entry of the collar to ease insertion
        if (top_entry_flare > 0) {
            hull() {
                translate([0, 0, -0.01]) {
                    linear_extrude(height = 0.01) {
                        hub_shape(clearance_top + 2 * top_entry_flare);
                    }
                }
                translate([0, 0, top_entry_flare]) {
                    linear_extrude(height = 0.01) {
                        hub_shape(clearance_top);
                    }
                }
            }
        }

        // 4. Hidden screw hole inside the back wall of the collar
        // Placed centered vertically on the collar
        translate([0, y_wall, top_height / 2]) {
            screw_hole(back_wall_thickness);
        }

        // 5. Front access hole coaxial with the screw hole
        // Cuts through the front wall of the collar to allow screw and driver insertion
        translate([0, y_front_outer - shell_wall_thickness - 0.1, top_height / 2]) {
            rotate([-90, 0, 0]) {
                cylinder(d = access_hole_dia, h = shell_wall_thickness + 1);
            }
        }
    }
}


// =================================================================================================
// 3D Preview: USB Hub and Cable
// =================================================================================================

module usb_hub_preview() {
    // Hub Aluminium Extrusion Body
    color([0.65, 0.70, 0.75, 0.6]) {
        translate([0, 0, bottom_wall_thickness]) {
            linear_extrude(height = hub_length) {
                hub_shape(0);
            }
        }
    }

    // Top-end USB-A Port (recess representation)
    color([0.3, 0.3, 0.3, 1.0]) {
        translate([-6, -2.25, bottom_wall_thickness + hub_length - 4.5]) {
            cube([12, 4.5, 5]);
        }
    }

    // Side USB Ports (placed along the front face of the device)
    color([0.1, 0.1, 0.1, 1.0]) {
        for (z_offset = [40, 70, 100]) {
            translate([-6, hub_thickness/2 - 1.5, bottom_wall_thickness + z_offset]) {
                cube([12, 2.0, 6]);
            }
        }
    }

    // Cable and Strain Relief exiting from the bottom
    color([0.15, 0.15, 0.15, 0.9]) {
        // 45-degree, 5mm conical strain relief
        translate([0, 0, bottom_wall_thickness - 5]) {
            cylinder(d1 = 5.0, d2 = 8.5, h = 5);
        }
        // Continuing cable going downwards
        translate([0, 0, bottom_wall_thickness - 5 - 30]) {
            cylinder(d = 5.0, h = 30);
        }
    }
}


// =================================================================================================
// Render Controller
// =================================================================================================

if (part == "bottom") {
    bottom_part();
} else if (part == "top") {
    // Oriented for direct, optimal 3D printing (flipped upside-down)
    translate([0, 0, top_height]) {
        rotate([0, 180, 0]) {
            top_part();
        }
    }
} else if (part == "both") {
    // Print layout: lay both parts side-by-side flat on the print bed
    spacing = hub_width + clearance_top + 2 * shell_wall_thickness + 15;

    // Bottom Cup sits flat in normal orientation
    translate([-spacing/2, 0, 0]) {
        bottom_part();
    }

    // Top Collar is rotated 180 degrees around Y so the chamfered opening is at the top
    translate([spacing/2, 0, top_height]) {
        rotate([0, 180, 0]) {
            top_part();
        }
    }
} else if (part == "preview") {
    // 3D Assembly Preview: Shows both parts and the USB hub positioned as in real use.
    // Bottom part sits at the origin (z = 0)
    bottom_part();

    // Top part sits near the top of the hub, aligned flush to the back wall (not flipped in preview)
    top_z = bottom_wall_thickness + hub_length - top_height;
    y_shift = (clearance_top - clearance_bottom) / 2;
    translate([0, y_shift, top_z]) {
        top_part();
    }

    // Show the semi-transparent hub resting perfectly against the back pockets of both parts
    translate([0, -clearance_bottom / 2, 0]) {
        usb_hub_preview();
    }

    // Grid/Wall indicator
    color([0.9, 0.9, 0.9, 0.15]) {
        wall_y = -hub_thickness/2 - clearance_bottom/2 - back_wall_thickness;
        translate([0, wall_y - 1, (bottom_wall_thickness + hub_length) / 2]) {
            rotate([90, 0, 0]) {
                cube([hub_width + 40, bottom_wall_thickness + hub_length + 60, 2], center = true);
            }
        }
    }
}
