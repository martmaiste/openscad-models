// Kohvitermose korgi parameetriline mudel
// Versioon: 1.71 (Põhja paksus ühtlustatud, randivaba sisekülg)

$fn = 100; 

// --- PÕHIPARAMEETRID ---
d_base = 67;           
thread_depth = 1.5;    
turns = 3;             
pitch = 4;             
t_base = 2.0;          
t_top = 1.8;           

wall_thickness = 3;    
grip_h = 20;           
grip_d = 81;           
grip_wall = 3;         
lid_thickness = 3;     

min_lid_depth = 1.0;   
max_lid_depth = 13.0;  
slope_ratio = 0.80;    
chamfer_size = 1.0;    

rib_count = 36;        
rib_depth = 0.8;       
rib_width = 1.5;       

drain_hole_d = 6.0;    
air_hole_d = 2.0;      

// --- SIHTIMISE PARAMEETRID ---
drain_target_r_offset = 10;  
drain_target_z_offset = 1.0; 
air_vertical_r = (d_base/2 - wall_thickness) - air_hole_d/2 - 0.5;

// --- ARVUTATUD VÄÄRTUSED ---
start_offset = 2;      
angle_compensation = 1.03; 
fade_dist = 10;

thread_end_z = start_offset + (turns * pitch);
ring_z = thread_end_z + pitch;
grip_start_z = ring_z + pitch;
inner_d = grip_d - (grip_wall * 2);
inner_base_d = d_base - (wall_thickness * 2);

slope_len = inner_d * slope_ratio;
tilt_angle = atan((max_lid_depth - min_lid_depth) / slope_len);

// --- MOODULID ---

module thread_slice(angle, z_pos, fade_factor=1.0) {
    current_depth = thread_depth * fade_factor;
    rotate([0, 0, angle])
    translate([d_base/2, 0, z_pos])
    rotate([90, 0, 0]) 
    linear_extrude(height = 0.01) 
    polygon(points=[[0, -t_base*fade_factor/2], [current_depth, -t_top*fade_factor/2], [current_depth, t_top*fade_factor/2], [0, t_base*fade_factor/2]]);
}

module generate_solid_thread() {
    total_rise = turns * pitch; 
    total_path_len = sqrt(pow(total_rise, 2) + pow(PI * d_base * turns, 2));
    steps = $fn * turns;
    for (i = [0 : steps - 1]) {
        angle1 = i * (360 * turns * angle_compensation / steps);
        angle2 = (i + 1) * (360 * turns * angle_compensation / steps);
        z1 = start_offset + (i * total_rise / steps);
        z2 = start_offset + ((i + 1) * total_rise / steps);
        s1 = min(1, min((i/steps*total_path_len) / fade_dist, (total_path_len - (i/steps*total_path_len)) / fade_dist));
        s2 = min(1, min(((i+1)/steps*total_path_len) / fade_dist, (total_path_len - ((i+1)/steps*total_path_len)) / fade_dist));
        if (s1 > 0 || s2 > 0) hull() { thread_slice(angle1, z1, s1); thread_slice(angle2, z2, s2); }
    }
}

// --- KOOSTAMINE ---

difference() {
    union() {
        // 1. KORPUS
        cylinder(h = grip_start_z, d = d_base);
        generate_solid_thread();
        translate([0, 0, ring_z]) rotate_extrude() translate([d_base/2, 0, 0]) 
            polygon(points=[[0, -t_base/2], [thread_depth, -t_top/2], [thread_depth, t_top/2], [0, t_base/2]]);
        translate([0, 0, grip_start_z]) cylinder(h = grip_h, d = grip_d);
    }

    // --- TÜHJENDAMISED ---

    // A) ALUMINE ÜHTNE TÜHJENDUS (Sisu tegemine kaldus põhjaga)
    translate([0, 0, -0.1]) cylinder(h = grip_start_z + 0.1, d = inner_base_d);
    
    // Alumine sisefaas
    translate([0, 0, -0.1])
        cylinder(h = chamfer_size + 0.1, d1 = inner_base_d + (chamfer_size * 2), d2 = inner_base_d);

    // See osa lõikab seestpoolt täpselt plaatide kuju järgi
    translate([0, 0, grip_start_z])
    intersection() {
        cylinder(h = grip_h + 1, d = inner_base_d + 0.1); // Piirame korgi sisemõõduga
        union() {
            // Lame tühjendus altpoolt
            translate([-inner_d, -inner_d/2, -0.1])
                cube([inner_d * (1 - slope_ratio) + inner_d/2, inner_d, grip_h - min_lid_depth - lid_thickness + 0.1]);
            
            // Kaldus tühjendus altpoolt (nihutatud lid_thickness võrra)
            translate([-inner_d/2 + inner_d * (1 - slope_ratio) - 0.5, 0, grip_h - min_lid_depth - lid_thickness])
                rotate([0, tilt_angle, 0])
                translate([0, -inner_d/2, -50])
                cube([inner_d * 1.5, inner_d, 50]);
        }
    }

    // B) ÜLEMINE SÜVEND (Plaatide pealne tühjendus)
    translate([0, 0, grip_start_z]) {
        intersection() {
            cylinder(h = grip_h + 1, d = inner_d);
            union() {
                translate([-inner_d, -inner_d/2, grip_h - min_lid_depth])
                    cube([inner_d * (1 - slope_ratio) + inner_d/2, inner_d, 50]);
                translate([-inner_d/2 + inner_d * (1 - slope_ratio), 0, grip_h - min_lid_depth])
                    rotate([0, tilt_angle, 0])
                    translate([-0.1, -inner_d/2, 0])
                    cube([inner_d * 1.5, inner_d, 50]);
            }
        }
        
        // C) HAARATSI DETAILID
        for (i = [0 : rib_count - 1]) {
            rotate([0, 0, i * (360 / rib_count)])
            translate([grip_d / 2, 0, -1])
            cylinder(h = grip_h + 2, d = rib_width, $fn=12);
        }
        translate([0, 0, grip_h - chamfer_size])
            difference() {
                cylinder(h = chamfer_size + 0.1, d = grip_d + 1);
                cylinder(h = chamfer_size + 0.1, d1 = grip_d, d2 = grip_d - (chamfer_size * 2));
            }
        translate([0, 0, grip_h - chamfer_size])
            cylinder(h = chamfer_size + 0.1, d1 = inner_d, d2 = inner_d + (chamfer_size * 2));
    }

    // D) VÄLISFAASID
    translate([0, 0, -0.1])
        difference() {
            cylinder(h = chamfer_size + 0.1, d = d_base + 1);
            cylinder(h = chamfer_size + 0.2, d1 = d_base - (chamfer_size * 2), d2 = d_base);
        }

    // E) AUGUD
    hull() {
        translate([inner_d/2 - drain_hole_d/2 - 0.5, 0, grip_start_z + grip_h - max_lid_depth])
            sphere(d = drain_hole_d);
        translate([inner_base_d/2 - drain_target_r_offset, 0, grip_start_z + drain_target_z_offset])
            sphere(d = drain_hole_d);
    }
    translate([-air_vertical_r, 0, -1])
        cylinder(h = grip_start_z + grip_h + 2, d = air_hole_d);
}