//====================================================================
// Home Assistant ZBT-2 Zigbee/Matter Device Wall Mount
// File: ZBT-2-Wall-Mount.scad
// Version: v0.14 (Updated for 4mm Screw / 8mm Head Keyhole slots)
// Date: 2026-07-06
// License: MIT
// Description: A sleek, parametric wall-mount bracket for the Home Assistant
//              Connect ZBT-2 device, featuring its 83x83mm square base,
//              160mm antenna, and a smooth 23mm fillet transition.
//              Supports high-back wall plate with diagonal side walls for maximum strength.
//              Includes USB-C cutouts on left and right side walls.
//              Device has 1mm high feet on bottom and flat-topped antenna.
//              Bottom slot is 26mm and bottom hole is 71mm to allow flat-base resting.
//              Bottom shelf is reinforced with a 4.0mm thickness.
//              Back wall has keyhole hangers spaced 60mm apart for removable mounting.
//              Side USB-C slots are adjusted to 11mm center and 10mm height for dual-orientation support.
//              Keyholes are updated for 4mm screw shafts with 8mm diameter, 3mm thick flat heads, and the high-back wall is thickened to 4.5mm.
//              Bottom slot is widened to 26mm to support upside-down mounting.
//====================================================================

/* [Render Options] */
// Select what to render in the viewport
render_mode = "bracket"; // [bracket:Wall Mount Bracket Only, device:ZBT-2 Device Mock Only, assembly:Assembly View (Bracket + Semi-transparent Device)]

// Vertical lift of the device in assembly mode to visualize insertion (mm)
assembly_device_lift = 0.0; // [0.0:1.0:100.0]

/* [Common Bracket Options] */
// Wall thickness around the pocket (mm)
wall_thickness = 4.0;
// Tolerance around the device for a perfect slide-in fit (mm)
fit_tolerance = 0.3;
// Thickness of the bottom shelf (supports the bottom of the device) (mm)
bottom_shelf_thickness = 4.0;

/* [ZBT-2 Device Dimensions] */
// Width of the ZBT-2 square base (mm)
base_width = 83.0;
// Length/depth of the ZBT-2 square base (mm)
base_length = 83.0;
// Thickness/height of the ZBT-2 square base (mm)
base_thickness = 20.0;
// Length of the antenna from the base top (mm)
antenna_length = 160.0;
// Diameter of the antenna cylinder (mm)
antenna_diameter = 24.0;
// Radius of the smooth fillet connection (mm)
fillet_radius = 23.0;
// Radius of the base plate corners (mm)
base_corner_radius = 20.0;

/* [Bracket Cutouts & Openings] */
// Height of the holding pocket walls (mm)
bracket_height = 18.0;
// Width of the front U-slot cutout to clear the fillet (mm)
front_cutout_width = 74.0;
// Diameter of the bottom shelf central hole (mm) - Set to 71.0mm so the 70.0mm fillet passes through, letting the flat base rest on the shelf
bottom_hole_diameter = 71.0;
// Width of the slot from the center hole to the front (mm)
bottom_slot_width = 26.0;

// Enable USB-C socket cutouts on the side walls
enable_side_usbc_cutouts = true;
// Height of the USB-C socket center from the base bottom (mm)
usbc_center_z = 11.0;
// Width of the USB-C cable connector cutout (along Y-axis) (mm)
usbc_cutout_width = 14.0;
// Height of the USB-C cable connector cutout (along Z-axis) (mm)
usbc_cutout_height = 10.0;

/* [Mounting Options] */
// Type of mounting bracket ears
mount_style = "high_back"; // [high_back:High Back Wall (Very Strong), ears_sides:Side Mounting Tabs, ears_top_bottom:Top & Bottom Mounting Tabs, flat:Flat Back (for Double-sided Tape)]
// Screw hole style for the high_back mounting option
high_back_hole_type = "keyhole"; // [keyhole:Keyhole Hanger (Removable), countersink:Standard Countersunk Screws]
// Horizontal spacing of back wall screw holes (mm)
back_screw_spacing = 60.0;
// Thickness of the mounting tabs (mm)
tab_thickness = 2.4;
// Width/diameter of the mounting tabs (mm)
tab_width = 14.0;
// Diameter of the screw hole shaft (mm)
screw_diameter = 3.5;
// Diameter of the screw head countersink (mm)
screw_head_diameter = 6.5;
// Depth of the screw head countersink (mm)
screw_head_depth = 1.8;

/* [Printer Options] */
// Circle smoothness (facets number)
$fn = 64; // [32, 64, 128]


//====================================================================
// HELPER MODULES & FUNCTIONS
//====================================================================

// Creates a 2D rounded rectangle profile centered at (0,0)
module rounded_rect_profile(w, t, r) {
    // Prevent degenerate geometries by capping radius safely
    real_r = min(r, t/2 - 0.01, w/2 - 0.01);
    if (real_r <= 0) {
        square([w, t], center=true);
    } else {
        hull() {
            translate([-(w/2 - real_r), -(t/2 - real_r)]) circle(r=real_r);
            translate([ (w/2 - real_r), -(t/2 - real_r)]) circle(r=real_r);
            translate([-(w/2 - real_r),  (t/2 - real_r)]) circle(r=real_r);
            translate([ (w/2 - real_r),  (t/2 - real_r)]) circle(r=real_r);
        }
    }
}

// Creates a 3D countersunk screw hole along the +Z axis
module countersunk_hole(d, head_d, head_h, total_depth) {
    // Shaft
    translate([0, 0, -0.1])
        cylinder(d=d, h=total_depth + 0.2, $fn=32);
    // Countersink cone
    translate([0, 0, total_depth - head_h])
        cylinder(d1=d, d2=head_d, h=head_h + 0.1, $fn=32);
    // Over-travel for countersink
    translate([0, 0, total_depth])
        cylinder(d=head_d, h=10, $fn=32);
}

// Mathematically perfect 3D concave fillet generator
// Traces a circular arc of radius r_fill from outer base to inner cylinder
module transition_fillet(r_ant, r_fill, steps=24) {
    r_c = r_ant + r_fill;

    // Generate the arc points from outer base (r_c) to inner cylinder (r_ant)
    arc_points = [
        for (i = [0 : steps])
            let (
                x = r_c - (r_fill * i / steps),
                y = r_fill - sqrt(max(0, r_fill*r_fill - (x - r_c)*(x - r_c)))
            )
            [x, y]
    ];

    // Complete the 2D polygon: (0,0) -> (r_c,0) -> arc -> (0, r_fill)
    all_points = concat(
        [[0, 0]],
        arc_points,
        [[0, r_fill]]
    );

    rotate_extrude($fn=64)
        polygon(all_points);
}

// Outer profile of the bracket 2D shape (flat back, rounded front)
module bracket_outer_profile(wt = wall_thickness, back_wt = wall_thickness) {
    w = base_width;
    t = base_length;
    tol = fit_tolerance;
    r = base_corner_radius;

    ow = w + 2*tol + 2*wt;
    ot = t + 2*tol + 2*wt;

    hull() {
        // Flat back plate (with back_wt thickness)
        translate([-ow/2, -(t/2 + tol + back_wt)])
            square([ow, back_wt]);

        // Front rounded profile (matches the rounded square with added wall thickness)
        rounded_rect_profile(ow, ot, r + wt + tol);
    }
}


//====================================================================
// MAIN MODULES
//====================================================================

// Visual mock for the ZBT-2 device (Base + smooth fillet transition + Antenna)
module zbt2_device_mock() {
    w = base_width;
    t = base_length;
    h_base = base_thickness;
    r_base = base_corner_radius;
    r_ant = antenna_diameter / 2;
    r_fill = fillet_radius;

    // 1. Four silicone feet at the bottom (resting on the bracket bottom shelf)
    color([0.22, 0.22, 0.25, 0.95]) { // Dark grey silicone
        // Top-left foot
        translate([-22.0, 22.0, 0]) cylinder(d=10.0, h=1.0, $fn=32);
        // Top-right foot
        translate([22.0, 22.0, 0]) cylinder(d=10.0, h=1.0, $fn=32);
        // Bottom-left foot
        translate([-22.0, -22.0, 0]) cylinder(d=10.0, h=1.0, $fn=32);
        // Bottom-right foot
        translate([22.0, -22.0, 0]) cylinder(d=10.0, h=1.0, $fn=32);
    }

    // 2. Main device body (translated up by 1mm feet height)
    translate([0, 0, 1.0]) {
        // Enclosure Base (elegant off-white body)
        color([0.95, 0.95, 0.96, 0.85]) {
            linear_extrude(height = h_base)
                rounded_rect_profile(w, t, r_base);
        }

        // Smooth curved fillet connection
        color([0.95, 0.95, 0.96, 0.85]) {
            translate([0, 0, h_base])
                transition_fillet(r_ant, r_fill, steps=24);
        }

        // Antenna shaft (cylindrical tower with flat top)
        color([0.90, 0.90, 0.92, 0.85]) {
            translate([0, 0, h_base + r_fill])
                cylinder(r = r_ant, h = antenna_length - r_fill, $fn = 64);
        }
    }

    // 3. Side USB-C Sockets (silver port rims with dark centers)
    // (remains aligned precisely with the bracket cutouts at usbc_center_z)
    if (enable_side_usbc_cutouts) {
        // Silver port rims
        color([0.78, 0.78, 0.80]) {
            // Left socket rim
            translate([-w/2, 0, usbc_center_z])
                cube([0.5, 9.2, 3.2], center=true);
            // Right socket rim
            translate([w/2, 0, usbc_center_z])
                cube([0.5, 9.2, 3.2], center=true);
        }
        // Dark port inner contacts
        color([0.15, 0.15, 0.15]) {
            // Left socket slot
            translate([-w/2 - 0.1, 0, usbc_center_z])
                cube([0.5, 8.2, 2.2], center=true);
            // Right socket slot
            translate([w/2 + 0.1, 0, usbc_center_z])
                cube([0.5, 8.2, 2.2], center=true);
        }
    }
}

// Parametric Wall Mount Bracket (Dedicated ZBT-2 Design)
module bracket() {
    w = base_width;
    t = base_length;
    tol = fit_tolerance;
    wt = wall_thickness;
    r = base_corner_radius;

    ow = w + 2*tol + 2*wt;
    ot = t + 2*tol + 2*wt;

    // Determine the back wall thickness (thickened to 4.5mm for high_back to house the 3mm deep screw head recess)
    back_wt = (mount_style == "high_back") ? 4.5 : wt;
    y_back = -(t/2 + tol + back_wt);

    // Determine the height of the back wall (twice as high for high_back style)
    back_wall_height = (mount_style == "high_back") ? (2 * bracket_height) : bracket_height;

    difference() {
        // 1. Main solid outer body of the bracket
        translate([0, 0, -bottom_shelf_thickness])
            linear_extrude(height = back_wall_height + bottom_shelf_thickness)
                bracket_outer_profile(wt, back_wt);

        // 2. Inner pocket cavity for the device base to slide in
        // (we extrude it all the way up to back_wall_height + 1.0 to ensure a clean cutout)
        translate([0, 0, 0])
            linear_extrude(height = back_wall_height + 1.0)
                rounded_rect_profile(w + 2*tol, t + 2*tol, r + tol);

        // 3. Central bottom shelf hole (for routing power cables, mounting screws, or air)
        translate([0, 0, -bottom_shelf_thickness - 0.1])
            cylinder(d = bottom_hole_diameter, h = bottom_shelf_thickness + 0.2, $fn = 64);

        // 4. Bottom slot from the central hole to the front of the shelf
        translate([-bottom_slot_width/2, 0, -bottom_shelf_thickness - 0.1])
            cube([bottom_slot_width, 100.0, bottom_shelf_thickness + 0.2]);

        // 5. Front U-slot cutout to clear the antenna & curved fillet transition (open top)
        translate([-front_cutout_width/2, 0, 0])
            cube([front_cutout_width, 100.0, back_wall_height + 1.0]);

        // 6. Side USB-C socket cutouts (left and right walls, centered at usbc_center_z)
        if (enable_side_usbc_cutouts) {
            translate([0, 0, usbc_center_z])
                rotate([0, 90, 0])
                    linear_extrude(height = ow + 10.0, center = true)
                        rounded_rect_profile(usbc_cutout_height, usbc_cutout_width, 2.0);
        }

        // 7. Apply diagonal cut to side/front walls if "high_back" is enabled
        // (starts at back-wall front face and slopes down to bracket_height at the frontmost point)
        if (mount_style == "high_back") {
            Ly = t + 2*tol + wt;
            dz = back_wall_height - bracket_height;
            slope_angle = atan(dz / Ly);

            translate([0, -(t/2 + tol), back_wall_height])
                rotate([-slope_angle, 0, 0])
                    translate([-200, 0, 0]) // wide enough to cover the device width
                        cube([400, 400, 400]);
        }

        // 8. Subtract screw holes in the extended back wall if "high_back" is selected
        if (mount_style == "high_back") {
            z_seated = bracket_height + (back_wall_height - bracket_height) / 2;

            if (high_back_hole_type == "countersink") {
                // Two standard spaced countersunk screw holes
                translate([-back_screw_spacing/2, y_back, z_seated])
                    rotate([-90, 0, 0])
                        countersunk_hole(screw_diameter, screw_head_diameter, screw_head_depth, back_wt);

                translate([back_screw_spacing/2, y_back, z_seated])
                    rotate([-90, 0, 0])
                        countersunk_hole(screw_diameter, screw_head_diameter, screw_head_depth, back_wt);
            } else if (high_back_hole_type == "keyhole") {
                // Keyhole slots spaced 60mm apart (optimized for 4mm screw shafts and 8mm flat screw heads, 3mm thick)
                slot_len = 8.0;
                z_entry = z_seated - slot_len/2; // center the slide vertical travel on the plate

                // Clearance tolerances added for 3D printing accuracy
                shaft_d = 4.4;   // 4.0mm shaft + 0.4mm clearance
                head_d = 8.8;    // 8.0mm head + 0.8mm clearance
                head_h = 3.2;    // 3.2mm deep recess inside the 4.5mm back wall (leaves 1.3mm solid holding tab)
                recess_w = head_d + 0.8; // 9.6mm wide clearance track

                // Left keyhole
                // entry hole (bottom)
                translate([-back_screw_spacing/2, y_back - 0.1, z_entry])
                    rotate([-90, 0, 0])
                        cylinder(d = head_d, h = back_wt + 0.2, $fn = 32);
                // shaft slot (vertical body)
                translate([-back_screw_spacing/2 - shaft_d/2, y_back - 0.1, z_entry])
                    cube([shaft_d, back_wt + 0.2, slot_len]);
                // rounded slot top
                translate([-back_screw_spacing/2, y_back - 0.1, z_entry + slot_len])
                    rotate([-90, 0, 0])
                        cylinder(d = shaft_d, h = back_wt + 0.2, $fn = 32);
                // head recess track (on the front/pocket-facing side of the back wall)
                translate([-back_screw_spacing/2 - recess_w/2, y_back + back_wt - head_h, z_entry])
                    cube([recess_w, head_h + 0.1, slot_len]);
                // rounded recess top
                translate([-back_screw_spacing/2, y_back + back_wt - head_h, z_entry + slot_len])
                    rotate([-90, 0, 0])
                        cylinder(d = recess_w, h = head_h + 0.1, $fn = 32);

                // Right keyhole
                // entry hole (bottom)
                translate([back_screw_spacing/2, y_back - 0.1, z_entry])
                    rotate([-90, 0, 0])
                        cylinder(d = head_d, h = back_wt + 0.2, $fn = 32);
                // shaft slot (vertical body)
                translate([back_screw_spacing/2 - shaft_d/2, y_back - 0.1, z_entry])
                    cube([shaft_d, back_wt + 0.2, slot_len]);
                // rounded slot top
                translate([back_screw_spacing/2, y_back - 0.1, z_entry + slot_len])
                    rotate([-90, 0, 0])
                        cylinder(d = shaft_d, h = back_wt + 0.2, $fn = 32);
                // head recess track (on the front/pocket-facing side of the back wall)
                translate([back_screw_spacing/2 - recess_w/2, y_back + back_wt - head_h, z_entry])
                    cube([recess_w, head_h + 0.1, slot_len]);
                // rounded recess top
                translate([back_screw_spacing/2, y_back + back_wt - head_h, z_entry + slot_len])
                    rotate([-90, 0, 0])
                        cylinder(d = recess_w, h = head_h + 0.1, $fn = 32);
            }
        }
    }

    // 9. Add mounting tabs based on selected style (only for non-high_back styles)
    if (mount_style == "ears_sides") {
        x_offset = w/2 + tol + wt + tab_width/2;
        z_center = (bracket_height - bottom_shelf_thickness)/2;
        x_attach = w/2 + tol + wt;

        // Left side tab
        difference() {
            hull() {
                translate([-x_offset, y_back, z_center])
                    rotate([-90, 0, 0])
                        cylinder(d=tab_width, h=tab_thickness, $fn=32);
                translate([-x_attach, y_back, z_center - tab_width/2])
                    cube([x_attach, tab_thickness, tab_width]);
            }
            translate([-x_offset, y_back, z_center])
                rotate([-90, 0, 0])
                    countersunk_hole(screw_diameter, screw_head_diameter, screw_head_depth, tab_thickness);
        }

        // Right side tab
        difference() {
            hull() {
                translate([x_offset, y_back, z_center])
                    rotate([-90, 0, 0])
                        cylinder(d=tab_width, h=tab_thickness, $fn=32);
                translate([0, y_back, z_center - tab_width/2])
                    cube([x_attach, tab_thickness, tab_width]);
            }
            translate([x_offset, y_back, z_center])
                rotate([-90, 0, 0])
                    countersunk_hole(screw_diameter, screw_head_diameter, screw_head_depth, tab_thickness);
        }
    } else if (mount_style == "ears_top_bottom") {
        // Top mounting tab
        difference() {
            hull() {
                translate([0, y_back, bracket_height + tab_width/2])
                    rotate([-90, 0, 0])
                        cylinder(d=tab_width, h=tab_thickness, $fn=32);
                translate([-ow/2, y_back, bracket_height - 2.0])
                    cube([ow, tab_thickness, 2.0]);
            }
            translate([0, y_back, bracket_height + tab_width/2])
                rotate([-90, 0, 0])
                    countersunk_hole(screw_diameter, screw_head_diameter, screw_head_depth, tab_thickness);
        }

        // Bottom mounting tab
        difference() {
            hull() {
                translate([0, y_back, -bottom_shelf_thickness - tab_width/2])
                    rotate([-90, 0, 0])
                        cylinder(d=tab_width, h=tab_thickness, $fn=32);
                translate([-ow/2, y_back, -bottom_shelf_thickness])
                    cube([ow, tab_thickness, 2.0]);
            }
            translate([0, y_back, -bottom_shelf_thickness - tab_width/2])
                rotate([-90, 0, 0])
                    countersunk_hole(screw_diameter, screw_head_diameter, screw_head_depth, tab_thickness);
        }
    }
}


//====================================================================
// VIEWPORT RENDER SELECTION
//====================================================================

if (render_mode == "bracket") {
    bracket();
} else if (render_mode == "device") {
    zbt2_device_mock();
} else if (render_mode == "assembly") {
    bracket();

    // Render the device nested inside the bracket with standard visualization lift
    translate([0, 0, assembly_device_lift])
        zbt2_device_mock();
}
