// Makita-2xLXT-Carry-Handle.scad
// v0.01

/* [General Settings] */
// Gap/tolerance for easy sliding (increase if too tight)
tolerance = 0.5;

/* [Base Settings] */
// Width of the base (left to right)
base_x = 85;
// Depth of the base (front to back) - must fit two batteries back-to-back
base_y = 160;
// Thickness of the base
base_z = 6;
// Corner radius of the base
base_radius = 8;

/* [Pillar Settings] */
// Width of the central pillar
pillar_x = 55;
// Thickness of the central pillar wall separating the batteries
wall_y = 14;
// Height to clear the batteries before the handle starts
battery_clearance_z = 120;

/* [Handle Settings] */
// Outer width of the top handle part
handle_x = 100;
// Total height of the handle section
handle_z = 45;
// Width of the finger cutout
handle_hole_x = 75;
// Height of the finger cutout
handle_hole_z = 22;
// Rounding radius for the handle and hole
handle_radius = 8;

/* [Makita Slide Settings] */
// Length of the sliding rails
slide_length = 75;
// Standard stem width before tolerance
stem_w_base = 31.0;
// Standard stem depth before tolerance
stem_h_base = 4.0;
// Standard rail width before tolerance
rail_w_base = 52.0;
// Standard rail thickness before tolerance
rail_h_base = 3.0;

/* [Hidden] */
$fn = 64;

// Calculated rail dimensions with tolerances
stem_w = stem_w_base - tolerance;
stem_h = stem_h_base + tolerance;
rail_w = rail_w_base - tolerance;
rail_h = rail_h_base - tolerance/2;

// Total height of the model
total_z = base_z + battery_clearance_z + handle_z;


// --- Helper Modules ---

module rounded_rect(w, h, r) {
    hull() {
        translate([-w/2 + r, -h/2 + r]) circle(r);
        translate([w/2 - r, -h/2 + r]) circle(r);
        translate([-w/2 + r, h/2 - r]) circle(r);
        translate([w/2 - r, h/2 - r]) circle(r);
    }
}

module rounded_box(w, d, h, r) {
    linear_extrude(h, center=true)
    rounded_rect(w, d, r);
}


// --- Main Components ---

module t_track_profile() {
    union() {
        // Stem (goes deep to cleanly overlap the central wall)
        translate([-stem_w/2, -3]) square([stem_w, stem_h + 3]);
        // Top cross rail
        translate([-rail_w/2, stem_h]) square([rail_w, rail_h]);
    }
}

module makita_slide_single() {
    // Extrude main slide body
    linear_extrude(slide_length - 4)
    t_track_profile();

    // Extrude smoothly tapered top for easy insertion
    translate([0, 0, slide_length - 4])
    hull() {
        linear_extrude(0.1)
        t_track_profile();

        translate([0, 0, 4])
        linear_extrude(0.1)
        offset(delta=-1.5, chamfer=true)
        t_track_profile();
    }
}

module makita_slides() {
    // Front slide (+Y side)
    translate([0, wall_y/2, base_z])
    makita_slide_single();

    // Back slide (-Y side)
    translate([0, -wall_y/2, base_z])
    rotate([0, 0, 180])
    makita_slide_single();
}

module handle_profile() {
    hull() {
        // Base footprint (wider to create a fillet for strength)
        translate([-pillar_x/2 - 5, base_z - 0.1]) square([pillar_x + 10, 1.1]);

        // Main central pillar body
        translate([-pillar_x/2, base_z + 1]) square([pillar_x, battery_clearance_z - 1]);

        // Handle widened top
        translate([-handle_x/2 + handle_radius, total_z - handle_radius])
        circle(handle_radius);

        translate([handle_x/2 - handle_radius, total_z - handle_radius])
        circle(handle_radius);
    }
}

module central_body() {
    rotate([90, 0, 0])
    linear_extrude(wall_y, center=true)
    handle_profile();
}

module handle_hole() {
    // Calculate the Z-center of the hole to leave a strong top bridge
    meat_above_hole = handle_radius + 5;
    hole_z = total_z - meat_above_hole - handle_hole_z/2;

    translate([0, 0, hole_z])
    rotate([90, 0, 0])
    // Make the cutout slightly wider than the wall to ensure clean intersection
    linear_extrude(wall_y + 2, center=true)
    rounded_rect(handle_hole_x, handle_hole_z, handle_radius);
}

// --- Assembly ---

module main() {
    difference() {
        union() {
            // Flat base for standing on the floor
            translate([0, 0, base_z/2])
            rounded_box(base_x, base_y, base_z, base_radius);

            // The central wall and top handle
            central_body();

            // The slide rails for the batteries
            makita_slides();
        }

        // Subtract the finger grip cutout
        handle_hole();
    }
}

// Render everything
main();
