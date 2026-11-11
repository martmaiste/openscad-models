/*
 * Universal DIN Rail Mount
 * Version: 0.27
 */

/* [Base Parameters] */
// Width of the DIN rail (mm)
rail_width = 34.8;
// Thickness of the DIN rail (mm)
rail_thick = 0.9;
// Fit tolerance (mm)
tolerance = 0.1;

// Width of the mount base (mm)
base_w = 40.0;
// Depth of the mount base (mm)
base_d = 15.0;
// Height of the mount base (mm)
base_h = 25.0;

// Distance of the rail slot from the bottom (mm)
dist_from_bottom = 3.0;

/* [Tension Slit] */
// Width of the vertical tension slit (mm)
slit_width = 1.0;
// Length of the vertical tension slit (mm)
slit_length = 15.0;

/* [Hook Parameters] */
// Size of the holding hook (mm)
hook_size = 3.0;

/* [Release Lever (L-Hook)] */
// Lever extension width (mm)
lever_ext = 4.0;
// Lever height (mm)
lever_h = 5.0;
// Lever wall thickness (mm)
lever_wall_t = 2.0;
// Lever base height (mm) - should match dist_from_bottom for standard fit
lever_base_h = 3.0;

/* [Mounting Screws & Nuts] */
// Diameter of the mounting screw (mm)
screw_d = 3.0;
// Diameter of the nut pocket flat-to-flat (mm)
nut_d = 6.5;
// Height of the nut (mm) (unused, kept for reference)
nut_h = 3.0;
// Distance of the screw head/pocket from the top face (mm)
dist_from_top = 4.0;
// Distance of the side screws from the center (mm)
screw_dist_from_center = 10.0;
// Enable the two side mounting screws
enable_side_screws = false;
// Enable the center mounting screw
enable_center_screw = true;
// Offset of the center screw along the X-axis (mm)
center_screw_offset = -6.0;
// Use threaded holes directly in plastic (removes the hex nut pockets)
use_threaded_holes = true;
// Enable 3-point self-tapping flat facets inside screw holes (easier to print horizontally)
use_easy_tapping = true;
// Depth of the self-tapping flat facets (mm)
tapping_facet_depth = 0.3;

/* [Mounting Ears] */
// Enable side mounting ears
enable_ears = false;
// Length of the mounting ears (mm)
ear_l = 10.0;
// Height of the mounting ears (mm)
ear_h = 6.0;

/* [Hidden] */
// --- Calculated values ---
rail_x_center = base_w / 2;
rail_x_start = (base_w - (rail_width + tolerance)) / 2;
rail_x_end = rail_x_start + (rail_width + tolerance);
trap_top_width = (rail_width + tolerance) - hook_size;
trap_bot_width = (rail_width + tolerance);

$fn = 64;

module screw_and_nut(x, y, z_total_h) {
    translate([x, y, -1]) {
        difference() {
            cylinder(d = screw_d, h = z_total_h + 2);
            if (use_easy_tapping) {
                // Three flat facets positioned for support-free horizontal printing ([30, 150, 270] degrees)
                for (a = [30, 150, 270]) {
                    rotate([0, 0, a])
                    translate([screw_d / 2 - tapping_facet_depth, -screw_d, 0])
                    cube([screw_d, screw_d * 2, z_total_h + 2]);
                }
            }
        }
        if (!use_threaded_holes) {
            nut_pocket_h = max(0, z_total_h - dist_from_top + 1);
            cylinder(d = nut_d, h = nut_pocket_h, $fn=6);
        }
    }
}

module din_mount() {
    union() {
        // 1. MAIN BODY
        difference() {
            cube([base_w, base_d, base_h]);

            translate([rail_x_start, -1, dist_from_bottom])
                cube([rail_width + tolerance, base_d + 2, rail_thick + tolerance]);

            translate([rail_x_center, -1, 0])
            hull() {
                translate([-trap_bot_width / 2, 0, -0.1]) cube([trap_bot_width, base_d + 2, 0.1]);
                translate([-trap_top_width / 2, 0, dist_from_bottom]) cube([trap_top_width, base_d + 2, 0.1]);
            }

            translate([rail_x_end - slit_width, -1, dist_from_bottom])
                cube([slit_width, base_d + 2, slit_length]);
            translate([rail_x_end - slit_width/2, -1, dist_from_bottom + slit_length])
                rotate([-90, 0, 0]) cylinder(d = slit_width, h = base_d + 2);

            if (enable_side_screws) {
                for (x_offset = [-screw_dist_from_center, screw_dist_from_center]) {
                    screw_and_nut(rail_x_center + x_offset, base_d / 2, base_h);
                }
            }

            if (enable_center_screw) {
                screw_and_nut(rail_x_center + center_screw_offset, base_d / 2, base_h);
            }
        }

        // 2. L-HOOK (RELEASE LEVER)
        translate([base_w, 0, 0]) {
            cube([lever_ext, base_d, lever_base_h]);
            translate([lever_ext - lever_wall_t, 0, lever_base_h])
                cube([lever_wall_t, base_d, lever_h - lever_base_h]);
        }

        // 3. MOUNTING EARS
        if (enable_ears) {
            difference() {
                translate([-ear_l, 0, base_h - ear_h]) cube([ear_l, base_d, ear_h]);
                screw_and_nut(-ear_l/2, base_d/2, base_h);
            }
            difference() {
                translate([base_w, 0, base_h - ear_h]) cube([ear_l, base_d, ear_h]);
                screw_and_nut(base_w + ear_l/2, base_d/2, base_h);
            }
        }
    }
}

din_mount();
