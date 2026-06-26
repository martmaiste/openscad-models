// ============================================================================
// IKEA BROGRUND Battery Wall Mount Holder
// File: IKEA-BROGRUND-Battery-Holder.scad
// Version: v0.07
// Date: 2026-06-24
// Description: A fully parametric, customizer-ready wall mount holder for the
//              IKEA BROGRUND automatic sensor tap battery box.
//              Optimized for 3D printing without supports.
// Changelog:
//   - v0.01: Initial release with internal/flange mounts & front cutouts.
//   - v0.02: Intelligent screwdriver access holes (automatically omitted if
//            the front cutout slot/window already exposes the screw).
//   - v0.03: Added customizable chamfer/flare at the top inner rim to make
//            inserting the battery box extremely smooth and easy.
//   - v0.04: Changed internal screw parameterization from "offset from edge"
//            to direct "screw spacing" (default 20.0mm centers) for exact fit.
//   - v0.05: Added complete 3D tapering (draft angle) support for the battery
//            box (e.g. bottom 35x33mm, top 36.5x34.5mm at 48mm height) and
//            adapted the mounting screws and walls to match this taper perfectly.
//   - v0.06: Updated default battery box corner radius to 8.5mm per measurements.
//   - v0.07: Added customizable screw recess depth (default 1.0mm) to prevent
//            the screw heads from scratching the battery box during insertion.
// ============================================================================

/* [Battery Box Dimensions] */
// Width of the battery box at the bottom (longer side) (mm)
battery_bottom_width = 35.0; // [20:100]
// Depth of the battery box at the bottom (shorter side) (mm)
battery_bottom_depth = 33.0; // [10:80]
// Width of the battery box at the measured height (mm)
battery_top_width = 36.5; // [20:100]
// Depth of the battery box at the measured height (mm)
battery_top_depth = 34.5; // [10:80]
// Vertical height at which the top width and depth were measured (mm)
battery_measured_height = 48.0; // [15:150]
// Corner radius of the battery box (mm)
battery_corner_radius = 9.0; // [0:20]
// Clearance around the battery box for a perfect fit (mm)
clearance = 0.15; // [0:0.1:2]
// 0.1 - tight fit to mount horizontally
// 0.2 - loose fit to mount vertically

/* [Holder Dimensions] */
// Wall thickness of the holder (mm)
wall_thickness = 3.0; // [1.5:0.5:6]
// Height of the sleeve pocket (mm)
holder_height = 35.0; // [15:100]
// Thickness of the bottom floor (mm)
bottom_thickness = 3.0; // [1:6]
// Width of the inner lip at the bottom to support the box (mm)
bottom_lip_width = 4.0; // [1:10]
// Chamfer size at the top inner rim to make inserting the box easier (mm)
inner_chamfer_size = 1.5; // [0:0.5:5]

/* [Mounting Options] */
// Mounting type: "internal" for hidden screws, "flanges" for top/bottom tabs, "side_flanges" for left/right tabs
mount_type = "internal"; // [internal, flanges, side_flanges]
// Height of top/bottom mounting flanges (mm) - only for "flanges" mount
flange_height = 12.0; // [8:30]
// Width of side flanges (mm) - only for "side_flanges" mount
side_flange_width = 12.0; // [8:30]
// Corner radius for mounting flanges (mm)
backplate_corner_radius = 4.0; // [1:10]
// Vertical spacing between the two screw holes (mm) - only for "internal" mount
screw_spacing = 20.0; // [10:80]

/* [Screw Dimensions] */
// Screw shank diameter (mm) - 3.2mm is ideal for a 3mm wood screw
screw_shank_dia = 3.2; // [1.5:0.1:6]
// Screw head diameter for countersink (mm) - typically 6.0mm for a 3mm screw
screw_head_dia = 6.0; // [3:0.1:12]
// Screw countersink head height (mm) - typically 1.5mm
screw_head_height = 1.5; // [0.5:0.1:4]
// Screw head recess depth inside the pocket to avoid scratching the battery box (mm)
screw_recess_depth = 1.0; // [0:0.5:3]
// Screwdriver access hole diameter in front wall (mm) - only for "internal" mount
access_hole_dia = 8.0; // [5:15]

/* [Front Cutout Options] */
// Front cutout style: "none" for solid front, "slot" for vertical slot, "window" for rounded window
front_cutout_type = "slot"; // [none, slot, window]
// Width of the front slot or window (mm)
front_cutout_width = 15.0; // [5:30]
// Vertical depth of the front slot from top (mm)
front_slot_depth = 32.0; // [5:100]
// Height of the front window (mm)
front_window_height = 15.0; // [5:50]
// Vertical position (Z center) of the front window (mm)
front_window_z = 10.0; // [0:100]

/* [Rendering Quality] */
// Number of fragments for circles/cylinders
$fn = 64; // [16:128]


// ============================================================================
// Derived Parameters
// ============================================================================

// Taper rate (increase in size per mm of height)
taper_w = (battery_top_width - battery_bottom_width) / battery_measured_height;
taper_d = (battery_top_depth - battery_bottom_depth) / battery_measured_height;

// Pocket cavity top Z level (relative to the box bottom sitting on the floor)
z_cavity_top = holder_height - bottom_thickness;

// Inner dimensions at the bottom floor
inner_w_bottom = battery_bottom_width + 2 * clearance;
inner_d_bottom = battery_bottom_depth + 2 * clearance;
inner_r = battery_corner_radius + clearance;

// Inner dimensions at the top rim of the pocket (pre-chamfer)
inner_w_top = battery_bottom_width + taper_w * z_cavity_top + 2 * clearance;
inner_d_top = battery_bottom_depth + taper_d * z_cavity_top + 2 * clearance;

// Inner dimensions at the start of the chamfer
z_pre_chamfer = z_cavity_top - inner_chamfer_size;
inner_w_top_pre = battery_bottom_width + taper_w * z_pre_chamfer + 2 * clearance;
inner_d_top_pre = battery_bottom_depth + taper_d * z_pre_chamfer + 2 * clearance;

// Flared chamfer dimensions at the very top of the pocket
inner_w_flare = inner_w_top + 2 * inner_chamfer_size;
inner_d_flare = inner_d_top + 2 * inner_chamfer_size;
inner_r_flare = inner_r + inner_chamfer_size;

// Outer pocket is a straight column based on the top inner width/depth
// (ensures at least wall_thickness everywhere, with a flat mounting back)
outer_w = inner_w_top + 2 * wall_thickness;
outer_d = inner_d_top + 2 * wall_thickness;
outer_r = inner_r + wall_thickness;


// ============================================================================
// Main Assembly
// ============================================================================

full_assembled_model();


// ============================================================================
// Modules and Helpers
// ============================================================================

// Draws the fully assembled model
module full_assembled_model() {
    difference() {
        union() {
            // 1. Main outer pocket
            pocket_outer_body();

            // 2. Add backplate (size and position adapt to mount_type)
            translate([0, -outer_d/2 + wall_thickness, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = wall_thickness)
                        backplate_profile_2d();
        }

        // 3. Inner pocket cavity (the cutout for the tapered battery box with insertion chamfer)
        translate([0, 0, 0]) {
            // Main tapered body of the cavity (from floor up to the start of the chamfer)
            hull() {
                translate([0, 0, bottom_thickness])
                    linear_extrude(height = 0.05)
                        rounded_rectangle(inner_w_bottom, inner_d_bottom, inner_r);

                translate([0, 0, holder_height - inner_chamfer_size])
                    linear_extrude(height = 0.05)
                        rounded_rectangle(inner_w_top_pre, inner_d_top_pre, inner_r);
            }

            if (inner_chamfer_size > 0) {
                // Lofted chamfer transition at the top rim
                hull() {
                    translate([0, 0, holder_height - inner_chamfer_size])
                        linear_extrude(height = 0.05)
                            rounded_rectangle(inner_w_top_pre, inner_d_top_pre, inner_r);

                    translate([0, 0, holder_height])
                        linear_extrude(height = 0.05)
                            rounded_rectangle(inner_w_flare, inner_d_flare, inner_r_flare);
                }

                // Clear the exit above the top edge
                translate([0, 0, holder_height])
                    linear_extrude(height = 3)
                        rounded_rectangle(inner_w_flare, inner_d_flare, inner_r_flare);
            } else {
                // If chamfer is disabled, just clear the exit straight up from the top of the tapered cavity
                translate([0, 0, holder_height - 0.1])
                    linear_extrude(height = 3.1)
                        rounded_rectangle(inner_w_top, inner_d_top, inner_r);
            }
        }

        // 4. Bottom cable/finger hole
        translate([0, 0, -1])
            linear_extrude(height = bottom_thickness + 2)
                rounded_rectangle(
                    max(2, inner_w_bottom - 2 * bottom_lip_width),
                    max(2, inner_d_bottom - 2 * bottom_lip_width),
                    max(0.1, inner_r - bottom_lip_width)
                );

        // 5. Front Cutouts (slot or window)
        apply_front_cutouts();

        // 6. Screw and Access Holes
        apply_screw_holes();
    }
}

// 2D Rounded Rectangle helper centered at [0,0]
module rounded_rectangle(w, d, r) {
    x = w/2 - r;
    y = d/2 - r;
    hull() {
        translate([x, y]) circle(r = r);
        translate([-x, y]) circle(r = r);
        translate([x, -y]) circle(r = r);
        translate([-x, -y]) circle(r = r);
    }
}

// Main outer pocket body (extruded sleeve and a flat back extension)
module pocket_outer_body() {
    union() {
        // Rounded outer sleeve
        linear_extrude(height = holder_height)
            rounded_rectangle(outer_w, outer_d, outer_r);

        // Flat back section (fills the curved gap at the back to touch the wall)
        translate([-outer_w/2, -outer_d/2, 0])
            cube([outer_w, outer_d/2, holder_height]);
    }
}

// 2D Profile of the Backplate/Flanges
module backplate_profile_2d() {
    w = (mount_type == "side_flanges") ? (outer_w + 2 * side_flange_width) : outer_w;
    h = (mount_type == "flanges") ? (holder_height + 2 * flange_height) : holder_height;
    r = backplate_corner_radius;

    x = w/2 - r;
    y = h/2 - r;

    // Center of the backplate matches holder_height/2 vertically
    translate([0, holder_height / 2]) {
        hull() {
            translate([x, y]) circle(r = r);
            translate([-x, y]) circle(r = r);
            translate([x, -y]) circle(r = r);
            translate([-x, -y]) circle(r = r);
        }
    }
}

// 2D profile for a front slot with a rounded bottom
module rounded_slot_2d(w, depth) {
    r = w / 2;
    hull() {
        // Bottom round part
        translate([0, holder_height - depth + r])
            circle(r = r);
        // Top square part (extending slightly above holder_height for a clean cut)
        translate([-r, holder_height - r])
            square([w, r + 1]);
    }
}

// 2D profile for a front rounded window
module front_window_2d(w, h, r) {
    translate([0, front_window_z + h/2])
        rounded_rectangle(w, h, r);
}

// Applies front cutouts (slot/window) if configured
module apply_front_cutouts() {
    if (front_cutout_type == "slot") {
        translate([0, outer_d/2 + 1, 0])
            rotate([90, 0, 0])
                linear_extrude(height = outer_d/2 + 2)
                    rounded_slot_2d(front_cutout_width, front_slot_depth);
    } else if (front_cutout_type == "window") {
        translate([0, outer_d/2 + 1, 0])
            rotate([90, 0, 0])
                linear_extrude(height = outer_d/2 + 2)
                    front_window_2d(front_cutout_width, front_window_height, 3.0);
    }
}

// A reusable screw hole module with countersink and head clearance
// Screw points in -Y direction (towards the flat mounting surface)
module screw_hole_y(shank_dia, head_dia, head_height, thickness) {
    union() {
        // 1. Countersink head cone
        translate([0, -head_height, 0])
            rotate([-90, 0, 0])
                cylinder(d1 = shank_dia, d2 = head_dia, h = head_height);

        // 2. Screw shank
        translate([0, -thickness - 1, 0])
            rotate([-90, 0, 0])
                cylinder(d = shank_dia, h = thickness - head_height + 1.1);

        // 3. Head clearance extending in front (+Y direction)
        translate([0, 0, 0])
            rotate([-90, 0, 0])
                cylinder(d = head_dia, h = 100);
    }
}

// Cuts the screw holes and access holes based on mount_type
module apply_screw_holes() {
    if (mount_type == "internal") {
        // Calculate exact screw positions based on center spacing
        screw_z_bottom = (holder_height - screw_spacing) / 2;
        screw_z_top = (holder_height + screw_spacing) / 2;

        // Calculate exact pocket depths at screw heights to match slanted wall
        inner_d_bottom_screw = battery_bottom_depth + taper_d * screw_z_bottom + 2 * clearance;
        inner_d_top_screw = battery_bottom_depth + taper_d * screw_z_top + 2 * clearance;

        thickness_bottom_screw = outer_d/2 - inner_d_bottom_screw/2;
        thickness_top_screw = outer_d/2 - inner_d_top_screw/2;

        // Screws inside the pocket (positioned on slanted back wall, recessed deep inside)
        // Bottom Screw
        translate([0, -inner_d_bottom_screw/2 - screw_recess_depth, screw_z_bottom])
            screw_hole_y(screw_shank_dia, screw_head_dia, screw_head_height, max(0.5, thickness_bottom_screw - screw_recess_depth));

        // Top Screw
        translate([0, -inner_d_top_screw/2 - screw_recess_depth, screw_z_top])
            screw_hole_y(screw_shank_dia, screw_head_dia, screw_head_height, max(0.5, thickness_top_screw - screw_recess_depth));

        // Helper to check if the front wall is already cut out at a given height (z)
        // If the front cutout (slot or window) covers this Z level, no access hole is needed!
        is_cutout_bottom = (front_cutout_type == "slot" && screw_z_bottom >= holder_height - front_slot_depth) ||
                           (front_cutout_type == "window" && screw_z_bottom >= front_window_z && screw_z_bottom <= front_window_z + front_window_height);

        is_cutout_top = (front_cutout_type == "slot" && screw_z_top >= holder_height - front_slot_depth) ||
                        (front_cutout_type == "window" && screw_z_top >= front_window_z && screw_z_top <= front_window_z + front_window_height);

        // Screwdriver access holes in the front wall (only cut if not already open)
        // Bottom Access Hole
        if (!is_cutout_bottom) {
            translate([0, inner_d_bottom_screw/2 - 1, screw_z_bottom])
                rotate([-90, 0, 0])
                    cylinder(d = access_hole_dia, h = thickness_bottom_screw + 2);
        }

        // Top Access Hole
        if (!is_cutout_top) {
            translate([0, inner_d_top_screw/2 - 1, screw_z_top])
                rotate([-90, 0, 0])
                    cylinder(d = access_hole_dia, h = thickness_top_screw + 2);
        }

    } else if (mount_type == "flanges") {
        // Screws on top and bottom flanges
        // Bottom Screw (on bottom flange)
        translate([0, -outer_d/2 + wall_thickness, -flange_height / 2])
            screw_hole_y(screw_shank_dia, screw_head_dia, screw_head_height, wall_thickness);

        // Top Screw (on top flange)
        translate([0, -outer_d/2 + wall_thickness, holder_height + flange_height / 2])
            screw_hole_y(screw_shank_dia, screw_head_dia, screw_head_height, wall_thickness);

    } else if (mount_type == "side_flanges") {
        // Screws on left and right flanges
        offset_x = outer_w/2 + side_flange_width / 2;
        // Left Screw
        translate([-offset_x, -outer_d/2 + wall_thickness, holder_height / 2])
            screw_hole_y(screw_shank_dia, screw_head_dia, screw_head_height, wall_thickness);

        // Right Screw
        translate([offset_x, -outer_d/2 + wall_thickness, holder_height / 2])
            screw_hole_y(screw_shank_dia, screw_head_dia, screw_head_height, wall_thickness);
    }
}
