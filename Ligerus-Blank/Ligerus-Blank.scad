// Ligerus-Blank.scad
// Version: v3.00
// Date: 2026-06-25
// Description: Parametric Blank Cover Plate for Liregus Epsilon "Slim Line" frames.
// Revised design: Independent flexible snap tabs sprout from the face plate.
// The main cover skirt is shallow and does not pass through the frame opening.

// ========================
// PARAMETERS
// ========================

/* [Display Mode] */
// Select which part to render
mode = "print"; // [print: Print Mode (Face Down), assembly: Assembly View (Inside Frame), solid: Solid Blank Plate with No Tabs]

/* [Epsilon Frame Dimensions] */
// Outer size of the blank cover cap (standard is 55.2mm to fit Epsilon's 55.8mm opening)
cover_size = 56; // [50:60]
// Total depth/thickness of the Epsilon Slim Line frame (standard is 9.5mm)
frame_depth = 9.5; // [5:15]
// Corner radius of the cover cap
corner_radius = 2.0; // [0.5:5]
// Bevel/chamfer size on the front edges of the cover cap
front_chamfer = 1.5; // [0:3]

/* [Frame Mounting Tabs (Notch Specs)] */
// Thickness of the frame's flat sections (standard is 1.0mm)
frame_tab_thickness = 1.0; // [0.5:2.5]
// Width of the frame's flat sections (standard is 20.0mm)
frame_tab_width = 20.0; // [10:30]
// Inner opening size between opposite flat sections (standard is 52.0mm)
frame_tab_opening = 52.0; // [45:55]

/* [Cover Shell] */
// Depth of the cover's outer skirt (must be less than frame_depth - frame_tab_thickness)
skirt_depth = 8.0; // [4.0:9.0]
// Thickness of the cover cap's outer wall (skirt)
wall_thickness = 1.2; // [0.8:3.0]
// Thickness of the cover cap's front face
face_thickness = 2.0; // [1.2:4.0]
// Enable a small pry notch on the bottom edge for easy removal
pry_notch = false;

/* [Snap-Fit Tabs] */
// Width of the snap tabs (fits easily inside the 20mm frame tabs)
tab_width = 18.0; // [10:25]
// Thickness of the snap tab cantilever wall
tab_thickness = 1.8; // [1.0:3.0]
// Radial clearance between snap tab and frame opening
tab_clearance = 0.1; // [0.0:0.5]
// How far the hook lip overlaps the frame tab radially
hook_overlap = 0.8; // [0.3:1.5]
// Axial play to ensure the hook easily snaps behind the frame tab
hook_play = 0.0; // [0.0:0.5]
// Angle of the hook's bottom ramp (allows support-free printing & pull-to-release)
release_angle = 45; // [30:60]
// How far the tab extends past the hook (tapered lead-in for easy insertion)
tab_extension = 1.5; // [1.0:3.0]
// Width of the inner reinforcement gusset to prevent breaking off
gusset_width = 2.0; // [0.0:5.0]
// Height of the inner reinforcement gusset to prevent breaking off
gusset_height = 2.0; // [0.0:8.0]

/* [Rendering Quality] */
// Number of segments for circles ($fn)
render_segments = 64; // [32, 64, 128]


// ========================
// INTERNAL CALCULATIONS
// ========================

$fn = render_segments;
delta = 0.05;

// Radial boundaries (from center of blank)
recess_radius = frame_tab_opening / 2;                // ~ 26.0mm
tab_outer_r = recess_radius - tab_clearance;          // ~ 25.8mm
tab_inner_r = tab_outer_r - tab_thickness;            // ~ 24.0mm
hook_peak_r = recess_radius + hook_overlap;           // ~ 26.8mm
lead_in_r = tab_outer_r - 0.8;                        // ~ 25.0mm

// Height boundaries (from front face at Z=0)
z_base = face_thickness - 0.1;                        // Sink into face plate slightly for manifold union
z_hook = frame_depth + hook_play;                     // ~ 9.7mm (Hooks behind the 9.5mm frame)

// Calculate ramp start based on angle (tan(angle) = radius_diff / height_diff)
ramp_h = (hook_peak_r - tab_outer_r) / tan(release_angle);
z_ramp_start = z_hook - ramp_h;

z_top = z_hook + tab_extension;                       // ~ 11.2mm


// ========================
// PROFILE POLYGON FOR SNAP TABS
// ========================

// 2D profile [Radius, Z-height] of the snap tab
// Designed with a release ramp to allow pulling out and support-free printing
profile_points = [
    [tab_inner_r - gusset_width, z_base], // 1. Extended inner base for reinforcing gusset
    [tab_inner_r, z_base + gusset_height], // 2. Top of inner gusset (angles up into the wall)
    [tab_inner_r, z_top],                  // 3. Top-inner corner (tip of the tab in wall)
    [lead_in_r,   z_top],                  // 4. Tip outer edge (tapered lead-in)
    [hook_peak_r, z_hook],                 // 5. Snap lip peak (hooks behind frame tab)
    [tab_outer_r, z_ramp_start],           // 6. Base of the hook ramp (release cam)
    [tab_outer_r, z_base]                  // 7. Bottom-outer corner (at face plate)
];


// ========================
// HELPER MODULES
// ========================

module rounded_box(x, y, z, radius) {
    hull() {
        for(ix = [-1, 1], iy = [-1, 1]) {
            translate([ix * (x/2 - radius), iy * (y/2 - radius), 0])
            cylinder(r = radius, h = z);
        }
    }
}

module rounded_front_box(x, y, z, r_xy, r_z) {
    hull() {
        for(ix = [-1, 1], iy = [-1, 1]) {
            translate([ix * (x/2 - r_xy), iy * (y/2 - r_xy), 0]) {
                cylinder(r1 = r_xy - r_z, r2 = r_xy, h = r_z);
                translate([0, 0, r_z])
                cylinder(r = r_xy, h = z - r_z);
            }
        }
    }
}


// ========================
// COMPONENT MODULES
// ========================

module blank_plate() {
    union() {
        // 1. Main Cover Shell (Skirt)
        difference() {
            // Outer shell with rounded corners and beveled front
            rounded_front_box(cover_size, cover_size, skirt_depth, corner_radius, front_chamfer);

            // Hollow out the interior
            translate([0, 0, face_thickness])
            rounded_box(cover_size - wall_thickness * 2, cover_size - wall_thickness * 2, skirt_depth, max(0.1, corner_radius - wall_thickness));

            // Optional pry notch on bottom edge (Y- side, at the back of the skirt)
            if (pry_notch) {
                translate([0, -cover_size/2, skirt_depth])
                rotate([45, 0, 0])
                translate([-1.5, -1.0, -1.0])
                cube([3.0, 2.0, 2.0]);
            }
        }

        // 2. The 4 Free-Standing Snap Tabs
        for(r = [0, 90, 180, 270]) {
            rotate([0, 0, r])
            // Orient for X-axis extrusion
            rotate([90, 0, 90])
            linear_extrude(height = tab_width, center = true)
            polygon(points = profile_points);
        }
    }
}

module mock_frame() {
    color([0.7, 0.7, 0.7, 0.4]) // Semi-transparent gray
    difference() {
        // Main frame outer body
        rounded_box(82.0, 82.0, frame_depth, 5.0);

        // Frame main front opening (55.8 x 55.8mm)
        translate([0, 0, -delta])
        rounded_box(55.8, 55.8, frame_depth + delta * 2, corner_radius);
    }

    // Render the 4 orange frame tabs/flat sections at the very back
    color([1.0, 0.5, 0.0, 0.7]) // Semi-transparent bright amber
    for(r = [0, 90, 180, 270]) {
        rotate([0, 0, r])
        translate([-frame_tab_width/2, frame_tab_opening/2, frame_depth - frame_tab_thickness])
        cube([frame_tab_width, (55.8 - frame_tab_opening)/2 + delta, frame_tab_thickness]);
    }
}

module solid_blank() {
    difference() {
        rounded_front_box(cover_size, cover_size, skirt_depth, corner_radius, front_chamfer);

        translate([0, 0, face_thickness])
        rounded_box(cover_size - wall_thickness * 2, cover_size - wall_thickness * 2, skirt_depth, max(0.1, corner_radius - wall_thickness));
    }
}


// ========================
// MAIN RENDER LOGIC
// ========================

if (mode == "print") {
    // Print Mode: Face-down on the Z=0 plane (already properly oriented)
    blank_plate();
} else if (mode == "assembly") {
    mock_frame();

    color("White")
    blank_plate();
} else if (mode == "solid") {
    solid_blank();
}
