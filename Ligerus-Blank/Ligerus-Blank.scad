// Ligerus-Blank.scad
// Version: v1.00
// Date: 2026-06-25
// Description: Parametric Blank Cover Plate for Liregus Epsilon "Slim Line" frames.
// Supports a highly elegant two-piece snap-on design (screwless front)
// as well as a single-piece design with a central screw.

// ========================
// PARAMETERS
// ========================

/* [Display Mode] */
// Select which part to render
mode = "print"; // [print: Print Mode (Base + Cover), base: Base Bracket only, cover: Cover Cap only, assembly: Assembled View, center_screw: Single Piece with Central Screw, solid: Solid Blank Plate with Flange]

/* [Epsilon Frame Dimensions] */
// Outer size of the blank cover cap (standard is 55.2mm to fit Epsilon's 55.8mm opening with 0.3mm clearance on all sides)
cover_size = 55.2; // [50:60]
// Depth/thickness of the Epsilon Slim Line frame (standard is 9.5mm)
frame_depth = 9.5; // [5:15]
// Corner radius of the cover cap (matches frame opening)
corner_radius = 2.0; // [0.5:5]
// Bevel/chamfer size on the front edges of the cover cap (for a premium Epsilon match)
front_chamfer = 1.5; // [0:3]

/* [Base Bracket Dimensions] */
// Size of the base bracket flange (70mm fits within 71mm spacing of multi-gang frames)
bracket_size = 70.0; // [60:80]
// Thickness of the base bracket flange
bracket_thickness = 1.6; // [1.0:3.0]
// Distance between mounting holes/slots (standard EU box is 60mm)
mounting_spacing = 60.0; // [50:70]
// Width of the mounting slots for box screws (M3/M3.5 screws)
slot_width = 4.0; // [3:6]
// Length of the mounting slots to allow rotational adjustment
slot_length = 8.0; // [4:12]

/* [Snap-Fit & Print Tolerances] */
// Clearance on each side between the snap post and the socket (adjust for printer tightness)
fit_clearance = 0.25; // [0.1:0.5]
// Height of the snap-lock ridge (larger = tighter click)
snap_ridge_height = 0.40; // [0.2:0.8]
// Thickness of the cover cap's outer wall (skirt)
wall_thickness = 1.8; // [1.2:3.0]
// Thickness of the cover cap's front face
face_thickness = 2.0; // [1.2:4.0]
// Enable a small pry notch on the bottom edge for easy removal
pry_notch = true;

/* [Rendering Quality] */
// Number of segments for circles ($fn)
render_segments = 64; // [32, 64, 128]


// ========================
// INTERNAL CALCULATIONS
// ========================

$fn = render_segments;
delta = 0.05; // Small offset to avoid Z-fighting in previews

// Post and socket dimensions
post_w = 18;
post_t = 10;
// Depth available for the cover cap inside the frame
cap_depth = frame_depth - bracket_thickness;
// Height of the central snap post
post_h = cap_depth - face_thickness;

// Socket dimensions (including print clearance)
sock_in_w = post_w + fit_clearance * 2;
sock_in_t = post_t + fit_clearance * 2;
sock_wall = 2.4;
sock_out_w = sock_in_w + sock_wall * 2;
sock_out_t = sock_in_t + sock_wall * 2;
sock_h = post_h - 0.4; // 0.4mm clearance so cap is stopped by base flange, not the socket


// ========================
// HELPER MODULES
// ========================

// 3D Box with rounded corners along Z-axis (flat top and bottom)
module rounded_box(x, y, z, radius) {
    hull() {
        for(ix = [-1, 1], iy = [-1, 1]) {
            translate([ix * (x/2 - radius), iy * (y/2 - radius), 0])
            cylinder(r = radius, h = z);
        }
    }
}

// 3D Box with rounded corners and a bevel/chamfer on the top face
module rounded_top_box(x, y, z, r_xy, r_z) {
    hull() {
        for(ix = [-1, 1], iy = [-1, 1]) {
            translate([ix * (x/2 - r_xy), iy * (y/2 - r_xy), 0]) {
                // Bottom vertical cylinder segment
                cylinder(r = r_xy, h = z - r_z);
                // Top tapered cylinder segment to create the chamfer
                translate([0, 0, z - r_z])
                cylinder(r1 = r_xy, r2 = r_xy - r_z, h = r_z);
            }
        }
    }
}


// ========================
// COMPONENT MODULES
// ========================

// 1. THE BASE BRACKET (Screws to wall box, holds the frame)
module base_bracket() {
    difference() {
        union() {
            // Main flange (rounded rectangular plate)
            rounded_box(bracket_size, bracket_size, bracket_thickness, 5.0);

            // Central snap-fit socket collar
            translate([0, 0, bracket_thickness]) {
                difference() {
                    // Outer collar shape
                    translate([-sock_out_w/2, -sock_out_t/2, 0])
                    cube([sock_out_w, sock_out_t, sock_h]);

                    // Inner socket pocket (goes all the way through the bracket for wire space and flexibility)
                    translate([-sock_in_w/2, -sock_in_t/2, -bracket_thickness - delta])
                    cube([sock_in_w, sock_in_t, sock_h + bracket_thickness + delta * 2]);

                    // Internal grooves for the snap ridges (angled at 45deg for 3D printability)
                    // Located precisely where the post ridges sit when cover is flush
                    // Ridge is 3.5mm from face_thickness. Post_h is the height of post from face_thickness.
                    // Distance of ridge from post base is post_h - 3.5.
                    // Since socket is shorter by 0.4mm, the height of the groove from the flange surface is post_h - 3.5.
                    groove_z = post_h - 3.5;
                    for(sy = [-1, 1]) {
                        translate([0, sy * (sock_in_t/2), groove_z]) {
                            rotate([45, 0, 0])
                            translate([-sock_in_w/2 - delta, -snap_ridge_height/2 - delta, -snap_ridge_height/2 - delta])
                            cube([sock_in_w + delta * 2, (snap_ridge_height + 0.1) * sqrt(2), (snap_ridge_height + 0.1) * sqrt(2)]);
                        }
                    }
                }
            }
        }

        // 4 Box Mounting Slots (Horizontal and Vertical to fit any box installation)
        for(r = [0, 90, 180, 270]) {
            rotate([0, 0, r])
            translate([mounting_spacing/2, 0, 0]) {
                // Thru-hole slot
                hull() {
                    translate([-slot_length/2 + slot_width/2, 0, -delta])
                    cylinder(d = slot_width, h = bracket_thickness + delta * 2);
                    translate([slot_length/2 - slot_width/2, 0, -delta])
                    cylinder(d = slot_width, h = bracket_thickness + delta * 2);
                }

                // Recess/counterbore for flush screw heads (0.8mm deep)
                translate([0, 0, bracket_thickness - 0.8])
                hull() {
                    translate([-slot_length/2 + slot_width/2, 0, 0])
                    cylinder(d = 7.0, h = 1.0);
                    translate([slot_length/2 - slot_width/2, 0, 0])
                    cylinder(d = 7.0, h = 1.0);
                }
            }
        }
    }
}

// 2. THE COVER CAP (Snaps onto the base bracket, flush with Epsilon frame)
module cover_cap() {
    difference() {
        // Outer aesthetic cover shell
        rounded_top_box(cover_size, cover_size, cap_depth, corner_radius, front_chamfer);

        // Hollow interior pocket
        translate([0, 0, -delta])
        rounded_box(cover_size - wall_thickness * 2, cover_size - wall_thickness * 2, cap_depth - face_thickness + delta, max(0.1, corner_radius - wall_thickness));

        // Optional pry notch on bottom edge (Y- side, front face Z = cap_depth)
        if (pry_notch) {
            translate([0, -cover_size/2, cap_depth])
            rotate([45, 0, 0])
            translate([-1.5, -1.0, -1.0])
            cube([3.0, 2.0, 2.0]);
        }
    }

    // Central snap-lock post (solid base, hollow core for flexibility and printability)
    translate([0, 0, face_thickness]) {
        difference() {
            union() {
                // Main post block
                translate([-post_w/2, -post_t/2, 0])
                cube([post_w, post_t, post_h]);

                // Outer snap-fit ridges (angled at 45deg for smooth snap and support-free printing)
                // Positioned 3.5mm down from the post tip
                ridge_z = post_h - 3.5;
                for(sy = [-1, 1]) {
                    translate([0, sy * (post_t/2), ridge_z]) {
                        rotate([45, 0, 0])
                        translate([-post_w/2, -snap_ridge_height, -snap_ridge_height])
                        cube([post_w, snap_ridge_height * 2, snap_ridge_height * 2]);
                    }
                }
            }

            // Hollow inner core of the post (enables walls to flex slightly and saves filament)
            translate([-post_w/2 + 1.8, -post_t/2 + 1.8, -delta])
            cube([post_w - 3.6, post_t - 3.6, post_h + delta * 2]);
        }
    }
}

// 3. SINGLE PIECE WITH CENTRAL SCREW (For mounting to existing metal yokes/supporting frames)
module center_screw_cover() {
    difference() {
        // Outer cover shell (same flush style)
        rounded_top_box(cover_size, cover_size, frame_depth, corner_radius, front_chamfer);

        // Hollow interior to save material
        difference() {
            translate([0, 0, -delta])
            rounded_box(cover_size - wall_thickness * 2, cover_size - wall_thickness * 2, frame_depth - face_thickness + delta, max(0.1, corner_radius - wall_thickness));

            // Central solid pillar for the screw (10mm diameter)
            cylinder(d = 10.0, h = frame_depth);
        }

        // Screw thru-hole (3.2mm for standard M3 switch screws)
        translate([0, 0, -delta])
        cylinder(d = 3.2, h = frame_depth + delta * 2);

        // Countersink on the front face (90-degree flathead screw pocket, 2.5mm deep)
        translate([0, 0, frame_depth - 2.5])
        cylinder(d1 = 3.2, d2 = 6.5, h = 2.5 + delta);

        // Optional pry notch on bottom edge (Y- side, front face Z = frame_depth)
        if (pry_notch) {
            translate([0, -cover_size/2, frame_depth])
            rotate([45, 0, 0])
            translate([-1.5, -1.0, -1.0])
            cube([3.0, 2.0, 2.0]);
        }
    }
}

// 4. SOLID BLANK PLATE WITH FLANGE (For custom modifications or mockups)
module solid_blank() {
    union() {
        // Back flange
        rounded_box(bracket_size, bracket_size, bracket_thickness, 5.0);

        // Front cover insert
        translate([0, 0, bracket_thickness])
        rounded_top_box(cover_size, cover_size, frame_depth - bracket_thickness, corner_radius, front_chamfer);
    }
}


// ========================
// MAIN RENDER LOGIC
// ========================

if (mode == "base") {
    base_bracket();
} else if (mode == "cover") {
    cover_cap();
} else if (mode == "assembly") {
    // Show how they fit together in 3D
    color("LightSeaGreen")
    base_bracket();

    color("White")
    translate([0, 0, bracket_thickness])
    cover_cap();
} else if (mode == "print") {
    // Side-by-side on Z=0 plane, perfectly oriented for support-free 3D printing
    // Note: Cover cap is automatically flipped face-down for a perfect textured or smooth bed finish!
    translate([-bracket_size/2 - 4, 0, 0])
    base_bracket();

    translate([cover_size/2 + 4, 0, cap_depth])
    rotate([180, 0, 0])
    cover_cap();
} else if (mode == "center_screw") {
    center_screw_cover();
} else if (mode == "solid") {
    solid_blank();
}
