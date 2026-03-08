/*
 * DIN-liistu universaalne kinnitus
 * Versioon: 0.26
 */

// --- Baasparameetrid ---
rail_width = 34.9;      
rail_thick = 0.9;       
tolerance = 0.2;        

base_w = 40.0;          
base_d = 10.0;          
base_h = 25.0;          

dist_from_bottom = 3.0; 

// --- Vertikaalse pilu parameetrid ---
slit_width = 1.0;       
slit_length = 15.0;     

// --- Hamba parameetrid ---
hook_size = 3.0;        

// --- L-konksu (vabastushoova) parameetrid ---
lever_ext = 4.0;        
lever_h = 5.0;          
lever_wall_t = 2.0;     
lever_base_h = dist_from_bottom; 

// --- Kinnitusaukude ja mutrite parameetrid ---
screw_d = 3.4;          
nut_d = 6.5;            
nut_h = 3.0;            
dist_from_top = 4.0;    
screw_dist_from_center = 10.0; 

// --- Kinnituskõrvade parameetrid ---
enable_ears = true;     
ear_l = 10.0;           
ear_h = 6.0;            // Muudetud: Madalam profiil (6mm)

// --- Arvutatud väärtused ---
rail_x_center = base_w / 2;
rail_x_start = (base_w - (rail_width + tolerance)) / 2;
rail_x_end = rail_x_start + (rail_width + tolerance);
trap_top_width = (rail_width + tolerance) - hook_size;
trap_bot_width = (rail_width + tolerance);

$fn = 64;

module screw_and_nut(x, y, z_total_h) {
    translate([x, y, -1]) {
        cylinder(d = screw_d, h = z_total_h + 2);
        nut_pocket_h = max(0, z_total_h - dist_from_top + 1);
        cylinder(d = nut_d, h = nut_pocket_h, $fn=6);
    }
}

module din_mount() {
    union() {
        // 1. PÕHIKEHA
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

            for (x_offset = [-screw_dist_from_center, screw_dist_from_center]) {
                screw_and_nut(rail_x_center + x_offset, base_d / 2, base_h);
            }
        }

        // 2. L-KONKS
        translate([base_w, 0, 0]) {
            cube([lever_ext, base_d, lever_base_h]); 
            translate([lever_ext - lever_wall_t, 0, lever_base_h])
                cube([lever_wall_t, base_d, lever_h - lever_base_h]);
        }

        // 3. KINNITUSKÕRVAD
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