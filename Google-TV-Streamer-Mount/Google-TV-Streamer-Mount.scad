// ============================================================
// Google TV Streamer Wall Mount Holder (Bottom Half, Upside Down)
// Version: 0.45
// Description: Parametric bottom-half holder with 200mm hole spacing,
//              vertically standing ears with 45-degree top/bottom chamfers,
//              M6 rear nut socket bosses with longitudinal axis rotation for 
//              support-free flat-top bridging, centered bottom cooling grid,
//              90-degree rotated cooling tunnels, and 5mm 45-degree corner reinforcements.
// ============================================================

version = "0.45";
echo(str("Google TV Streamer Holder - Version: ", version));

// --- PARAMETERS (Adjustable) ---
body_width         = 160;  // Approximate width of the device body (mm)
body_height        = 100;  // Approximate total height of the device body (mm)
thickness_bottom   = 12;   // Thickness at the bottom end (mm)
thickness_middle   = 20;   // Thickness at the center height / 40mm mark (mm)
thickness_top      = 25;   // Thickness at the wider top rim (mm)

tolerance          = 1.0;  // Extra clearance for easy sliding/fit (mm)
wall_thickness     = 3.5;  // Structural wall thickness (mm)
cradle_height      = 40;   // Height of the bottom-half shell and full-height ears (mm)

// Side Mounting Ears, Spacing & M6 Hardware
hole_spacing       = 200;  // Exact distance between mounting screw hole centers (mm)
ear_width          = 24;   // Width of the mounting ear tabs (mm)
ear_thickness      = wall_thickness; // Thin ears matching wall thickness (3.5mm)
ear_y_offset       = 10.0; // Offset of the mounting ears from the back wall (mm)
ear_chamfer        = 12.0; // 45-degree angle cut size for top/bottom of ears (mm)
reinforcement_size = 5.0;  // Size of the 5mm 45-degree corner gussets

// M6 Nut Socket & Conical Boss Parameters
screw_dia          = 6.6;  // Clearance hole for M6 screw (mm)
nut_across_flats   = 10.6; // Width across flats for M6 hex nut with print tolerance (mm)
nut_depth          = 5.5;  // Depth of the M6 nut socket (mm)
boss_ext           = 5.0;  // How far the boss extends backward from the ear (mm)
boss_dia_ear       = 20.0; // Diameter where it meets the ear (large base)
boss_dia_rear      = 14.0; // Diameter at the rear tip (smaller tip, 45° taper)

// Cooling Ventilation Parameters
enable_cooling     = true; // Set to false to remove cooling holes
hex_size           = 8.0;  // Size (diameter) of the cooling hex holes (mm)
hex_spacing        = 11.0; // Distance between cooling hole centers (mm)

// Rendering resolution
$fn = 64;

// --- DERIVED DIMENSIONS ---
inner_w = body_width + (tolerance * 2);
body_outer_x = inner_w / 2 + wall_thickness;

// Function to calculate thickness profile dynamically along the height
function get_thickness(h) = 
    (h <= 40) ? (thickness_bottom + (thickness_middle - thickness_bottom) * (h / 40))
              : (thickness_middle + (thickness_top - thickness_middle) * ((h - 40) / (body_height - 40)));

t_cradle = get_thickness(cradle_height);

module streamer_holder_bottom() {
    difference() {
        union() {
            // --- MAIN BOTTOM SHELL (Multi-stage Wedge Profile) ---
            hull() {
                // Bottom base profile
                translate([-body_outer_x, 0, 0])
                    cube([body_outer_x * 2, thickness_bottom + wall_thickness*2, wall_thickness]);
                
                // Mid-point profile
                translate([-body_outer_x, 0, cradle_height/2])
                    cube([body_outer_x * 2, get_thickness(cradle_height/2) + wall_thickness*2, wall_thickness]);

                // Upper cut-off profile (at 40mm cradle height)
                translate([-body_outer_x, 0, cradle_height])
                    cube([body_outer_x * 2, t_cradle + wall_thickness*2, wall_thickness]);
            }
            
            // --- SIDE MOUNTING EARS (Standing vertically with 45-degree top/bottom chamfers) ---
            // Left Ear
            translate([0, ear_y_offset + ear_thickness, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = ear_thickness)
                        polygon([
                            [-body_outer_x + 2, 0],
                            [-hole_spacing/2 - ear_width/2 + ear_chamfer, 0],
                            [-hole_spacing/2 - ear_width/2, ear_chamfer],
                            [-hole_spacing/2 - ear_width/2, cradle_height - ear_chamfer],
                            [-hole_spacing/2 - ear_width/2 + ear_chamfer, cradle_height],
                            [-body_outer_x + 2, cradle_height]
                        ]);
            
            // Right Ear
            translate([0, ear_y_offset + ear_thickness, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = ear_thickness)
                        polygon([
                            [body_outer_x - 2, 0],
                            [hole_spacing/2 + ear_width/2 - ear_chamfer, 0],
                            [hole_spacing/2 + ear_width/2, ear_chamfer],
                            [hole_spacing/2 + ear_width/2, cradle_height - ear_chamfer],
                            [hole_spacing/2 + ear_width/2 - ear_chamfer, cradle_height],
                            [body_outer_x - 2, cradle_height]
                        ]);

            // --- VERTICAL 5MM 45-DEGREE ANGLE CORNER REINFORCEMENTS ---
            // Left Ear - Rear Corner Transition
            linear_extrude(height = cradle_height)
                polygon([
                    [-body_outer_x, ear_y_offset],
                    [-body_outer_x - reinforcement_size, ear_y_offset],
                    [-body_outer_x, ear_y_offset + reinforcement_size]
                ]);

            // Left Ear - Front Corner Transition
            linear_extrude(height = cradle_height)
                polygon([
                    [-body_outer_x, ear_y_offset + ear_thickness],
                    [-body_outer_x - reinforcement_size, ear_y_offset + ear_thickness],
                    [-body_outer_x, ear_y_offset + ear_thickness - reinforcement_size]
                ]);

            // Right Ear - Rear Corner Transition
            linear_extrude(height = cradle_height)
                polygon([
                    [body_outer_x, ear_y_offset],
                    [body_outer_x + reinforcement_size, ear_y_offset],
                    [body_outer_x, ear_y_offset + reinforcement_size]
                ]);

            // Right Ear - Front Corner Transition
            linear_extrude(height = cradle_height)
                polygon([
                    [body_outer_x, ear_y_offset + ear_thickness],
                    [body_outer_x + reinforcement_size, ear_y_offset + ear_thickness],
                    [body_outer_x, ear_y_offset + ear_thickness - reinforcement_size]
                ]);

            // --- REINFORCEMENT BOSSES (Correctly tapered: wide at ear, narrow at rear tip) ---
            // Left Boss
            translate([-hole_spacing/2, ear_y_offset, cradle_height/2])
                rotate([90, 0, 0])
                    cylinder(h=boss_ext, r1=boss_dia_ear/2, r2=boss_dia_rear/2);

            // Right Boss
            translate([hole_spacing/2, ear_y_offset, cradle_height/2])
                rotate([90, 0, 0])
                    cylinder(h=boss_ext, r1=boss_dia_ear/2, r2=boss_dia_rear/2);
        }
        
        // --- CAVITIES & CUTOUTS ---
        
        // 1. Device Cavity (Correct multi-stage wedge matching lower portion precisely)
        hull() {
            translate([-inner_w/2, wall_thickness, wall_thickness])
                cube([inner_w, thickness_bottom, 0.1]);
            
            translate([-inner_w/2, wall_thickness, cradle_height/2])
                cube([inner_w, get_thickness(cradle_height/2), 0.1]);

            translate([-inner_w/2, wall_thickness, cradle_height])
                cube([inner_w, t_cradle, 5.0]);
        }

        // 2. M6 Hex Nut Sockets (Rotated around longitudinal Y axis for support-free flat-top ceiling)
        translate([-hole_spacing/2, ear_y_offset - boss_ext, cradle_height/2])
            rotate([-90, 30, 0])
                cylinder(h=nut_depth + 0.1, d=nut_across_flats / 0.866025, $fn=6);

        translate([hole_spacing/2, ear_y_offset - boss_ext, cradle_height/2])
            rotate([-90, 30, 0])
                cylinder(h=nut_depth + 0.1, d=nut_across_flats / 0.866025, $fn=6);

        // 3. M6 Screw Through-Holes (Punching cleanly through bosses and ears)
        translate([-hole_spacing/2, ear_y_offset - boss_ext - 1, cradle_height/2])
            rotate([-90, 0, 0])
                cylinder(h=boss_ext + ear_thickness + 2, d=screw_dia);

        translate([hole_spacing/2, ear_y_offset - boss_ext - 1, cradle_height/2])
            rotate([-90, 0, 0])
                cylinder(h=boss_ext + ear_thickness + 2, d=screw_dia);

        // 4. Cooling Ventilation Hex Holes (Bottom, Front, and Back Walls)
        if (enable_cooling) {
            // Bottom Wall Cooling Grid (Centered symmetrically in X and Y)
            usable_w_bottom = inner_w - 36;
            num_x_bottom = floor(usable_w_bottom / hex_spacing);
            start_x_bottom = -(num_x_bottom * hex_spacing) / 2;

            y_start = wall_thickness + 2.0;
            y_end = wall_thickness + thickness_bottom - 2.0;
            usable_h_bottom = y_end - y_start;
            num_y_bottom = floor(usable_h_bottom / hex_spacing);
            start_y_bottom = y_start + (usable_h_bottom - (num_y_bottom * hex_spacing)) / 2;

            for (ix = [0 : num_x_bottom]) {
                for (iy = [0 : num_y_bottom]) {
                    x = start_x_bottom + (ix * hex_spacing);
                    y = start_y_bottom + (iy * hex_spacing);
                    translate([x, y, -1])
                        cylinder(h = wall_thickness + 2, d = hex_size, $fn = 6);
                }
            }

            // Back Wall Cooling Grid (Rotated 90 deg for optimal bridging/printability)
            usable_w_back = inner_w - 36;
            num_x_back = floor(usable_w_back / hex_spacing);
            start_x_back = -(num_x_back * hex_spacing) / 2;

            for (z = [10 : 10 : 30]) {
                for (ix = [0 : num_x_back]) {
                    x = start_x_back + (ix * hex_spacing);
                    translate([x, -1.0, z])
                        rotate([-90, 90, 0])
                            cylinder(h = wall_thickness + 2.0, d = hex_size, $fn = 6);
                }
            }

            // Front Wall Cooling Grid (Rotated 90 deg for optimal bridging/printability)
            usable_w_front = inner_w - 36;
            num_x_front = floor(usable_w_front / hex_spacing);
            start_x_front = -(num_x_front * hex_spacing) / 2;

            for (z = [10 : 10 : 30]) {
                t_z = get_thickness(z);
                front_inner_y = wall_thickness + t_z;
                for (ix = [0 : num_x_front]) {
                    x = start_x_front + (ix * hex_spacing);
                    translate([x, front_inner_y - 1.0, z])
                        rotate([-90, 90, 0])
                            cylinder(h = wall_thickness + 2.0, d = hex_size, $fn = 6);
                }
            }
        }
    }
}

// Render the final module
streamer_holder_bottom();