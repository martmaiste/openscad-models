// ============================================================================
// File: file_handle.scad
// Version: 0.26
// Description: Parametric ergonomic file handle with simplified profile.
//              Features a flared 5mm chamfered base, a continuous smooth body 
//              taper, and a unified rounded top dome (no upper neck groove).
// ============================================================================

$fn = 64; // High-resolution rendering

/* [Handle Main Dimensions] */
handle_length      = 115; // Total length of the handle (mm)

/* [Bottom Cylindrical End Settings] */
front_flare_dia    = 30.0;// Bottom collar diameter (mm)
front_cyl_height   = 5.0; // Height of straight cylindrical base section (mm)
bottom_chamfer     = 1.5; // Bottom outer edge chamfer size (mm)

/* [Front Fingertip Pinch Waist] */
front_waist_dia    = 18.0;// Thinnest front pinch waist diameter (mm)
front_waist_pos    = 20.0;// Position from front face (mm)

/* [Upper Body & Shoulder] */
upper_shoulder_dia = 31.5;// Diameter at upper shoulder before dome cap (mm)
upper_shoulder_z   = 92.0;// Z position where upper dome cap begins (mm)

/* [File Tang Base Dimensions (Original 50mm Spec)] */
orig_tang_length   = 50.0;// Original tang length reference (mm)
tang_width_top     = 4.9; // Base width at entry opening (mm)
orig_width_bottom  = 2.5; // Base width at original 50mm depth (mm)
tang_thickness_top = 4.9; // Base thickness at entry opening (mm)
orig_thick_bottom  = 2.5; // Base thickness at original 50mm depth (mm)

/* [Extended Cavity Settings - 10% Extra Length] */
length_extension   = 1.10;// 10% length increase
tang_length        = orig_tang_length * length_extension; // Extended depth: 55.0 mm

// Linear interpolation for taper slope over extra depth
tang_width_bottom  = tang_width_top + (orig_width_bottom - tang_width_top) * length_extension;
tang_thickness_bot = tang_thickness_top + (orig_thick_bottom - tang_thickness_top) * length_extension;

/* [Tolerance & Sacrificial Ribs] */
tang_tolerance     = 0.6; // Cavity expansion clearance for tolerance (mm)
rib_radius_top     = 1.2; // Radius of arch rib cylinder at entry (mm)
rib_radius_bot     = 0.7; // Radius of arch rib cylinder at deep end (mm)

/* [Lanyard Hole] */
enable_lanyard     = true;// Add transverse lanyard hole
lanyard_diameter   = 6.0; // Lanyard hole diameter (mm)
lanyard_offset     = 16;  // Distance from top dome cap (mm)

/* [Assembly Render] */
show_cutaway       = false; // Set to true to inspect internal cavity and ribs

// ============================================================================
// PROFILE GENERATOR
// ============================================================================

// 2D Catmull-Rom Spline point calculation helper
function catmull_rom_2d(p0, p1, p2, p3, t) = 
    0.5 * (
        (p1 * 2) +
        (-p0 + p2) * t +
        (p0 * 2 - p1 * 5 + p2 * 4 - p3) * (t * t) +
        (-p0 + p1 * 3 - p2 * 3 + p3) * (t * t * t)
    );

// Simplified continuous profile generator
function generate_handle_profile(steps = 20, dome_steps = 16) =
    let (
        // 1. Bottom 5mm cylindrical base with edge chamfer
        cyl_pts = [
            [ 0, 0 ],
            [ front_flare_dia / 2 - bottom_chamfer, 0 ],
            [ front_flare_dia / 2, bottom_chamfer ],
            [ front_flare_dia / 2, front_cyl_height ]
        ],

        // 2. Control points for smooth lower waist swoop and main body taper
        ctrl = [
            [ 0,                  front_flare_dia / 2 ],
            [ front_cyl_height,  front_flare_dia / 2 ],
            [ front_waist_pos,   front_waist_dia / 2 ],
            [ upper_shoulder_z,  upper_shoulder_dia / 2 ],
            [ handle_length + 5, upper_shoulder_dia / 2 ]
        ],

        // 3. Smooth main body curve (Waist to Upper Shoulder)
        body_pts = [
            for (i = [1 : 2])
                for (s = [1 : steps])
                    let (pt = catmull_rom_2d(ctrl[i-1], ctrl[i], ctrl[i+1], ctrl[i+2], s / steps))
                    [ max(0, pt[1]), pt[0] ]
        ],

        // 4. Smooth top dome cap rounding off to the apex
        dome_r = upper_shoulder_dia / 2,
        dome_pts = [
            for (a = [1 : dome_steps])
                let (
                    ang = a * (90 / dome_steps),
                    r   = dome_r * cos(ang),
                    z   = upper_shoulder_z + (handle_length - upper_shoulder_z) * sin(ang)
                )
                [ max(0, r), z ]
        ]
    )
    concat(cyl_pts, body_pts, dome_pts, [[0, handle_length]]);

// Continuous revolved handle body
module handle_body() {
    poly_pts = generate_handle_profile(20, 16);

    rotate_extrude($fn = $fn) {
        polygon(poly_pts);
    }
}

// ============================================================================
// CAVITIES & ASSEMBLY
// ============================================================================

// Expanded main cavity (without ribs)
module base_cavity() {
    w_top = tang_width_top + tang_tolerance;
    w_bot = tang_width_bottom + tang_tolerance;
    t_top = tang_thickness_top + tang_tolerance;
    t_bot = tang_thickness_bot + tang_tolerance;

    translate([0, 0, -0.1])
    hull() {
        translate([0, 0, 0])
            cube([w_top, t_top, 0.2], center = true);
        translate([0, 0, tang_length])
            cube([w_bot, t_bot, 0.2], center = true);
    }
}

// Sacrificial arch ribs positioned so 1/3 radius sticks out into cavity
module arch_ribs() {
    w_top = tang_width_top + tang_tolerance;
    w_bot = tang_width_bottom + tang_tolerance;

    pos_top = (w_top / 2) + (rib_radius_top * 2 / 3);
    pos_bot = (w_bot / 2) + (rib_radius_bot * 2 / 3);

    for (r = [0:90:270]) {
        rotate([0, 0, r]) {
            hull() {
                translate([pos_top, 0, 0])
                    cylinder(r = rib_radius_top, h = 0.2, center = true);
                
                translate([pos_bot, 0, tang_length])
                    cylinder(r = rib_radius_bot, h = 0.2, center = true);
            }
        }
    }
}

// Combined internal hollow
module final_tang_cavity() {
    difference() {
        base_cavity();
        arch_ribs();
    }
}

// Transverse lanyard hole with rounded chamfered openings
module lanyard_cavity() {
    if (enable_lanyard) {
        translate([0, 0, handle_length - lanyard_offset])
            rotate([0, 90, 0]) {
                cylinder(h = upper_shoulder_dia * 2, d = lanyard_diameter, center = true);
                translate([0, 0, upper_shoulder_dia * 0.3])
                    cylinder(h = upper_shoulder_dia, d1 = lanyard_diameter, d2 = lanyard_diameter + 5, center = false);
                translate([0, 0, -upper_shoulder_dia * 0.3 - upper_shoulder_dia])
                    cylinder(h = upper_shoulder_dia, d1 = lanyard_diameter + 5, d2 = lanyard_diameter, center = false);
            }
    }
}

// Modular assembly
module file_handle_assembly() {
    difference() {
        handle_body();
        final_tang_cavity();
        lanyard_cavity();
        
        if (show_cutaway) {
            translate([0, -upper_shoulder_dia, -5])
                cube([upper_shoulder_dia * 2, upper_shoulder_dia * 2, handle_length + 10]);
        }
    }
}

// ============================================================================
// MAIN RENDER
// ============================================================================

file_handle_assembly();