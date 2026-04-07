/* [Apollo Air-1 Wall Mount] */
// Width of the sensor (mm)
sensor_w = 62;      
// Depth of the sensor (mm)
sensor_d = 35;      
// Total height of the sensor (mm)
sensor_h = 62;      
// Thickness of the mount walls (mm)
wall_t = 3;         
// Height of the front retaining corners (mm)
corner_h = 15;      
// Printing tolerance offset (mm)
tol = 0.25;         
// Global chamfer size (mm)
ch = 1.0;           

/* [Features & Strength] */
// Height of the solid side wall from the INNER bottom before vents start (mm)
vent_base_h = 4.0;
// Width of the side margins for the front opening (mm)
grip_zone = 10;     
// Clearance from back wall for side vents (mm)
vent_clearance_back = 3; 
// Clearance from front face for side vents (mm)
vent_clearance_front = 4;
// Side margin for the bottom USB-C hole (mm)
usb_side_margin = 22; 

/* [Mounting Screws] */
// Diameter of the screw shaft (mm)
screw_dia = 3.5;
// Diameter of the screw head/countersink (mm)
csink_dia = 6.5; 
// Depth of the countersink (mm)
csink_depth = 2.0; 
// Horizontal distance from center for each screw (mm)
screw_dist_from_center = 20; 

/* [Advanced] */
// Smoothness of circular elements
$fn = 64;

/* [Internal Calculations] */
ch_diag = ch * 1.414; 
inner_w = sensor_w + (2 * tol);
inner_d = sensor_d + tol;
outer_w = inner_w + (2 * wall_t);
total_d = inner_d + wall_t; 
back_h = (sensor_h / 2) + wall_t;
vent_z_start = wall_t + vent_base_h;

module mount() {
    difference() {
        // --- Main Body ---
        union() {
            // BACK WALL: 2D profile for perfect top corner chamfers
            translate([-wall_t, 0, 0])
            rotate([90, 0, 90])
            linear_extrude(height = wall_t)
            polygon([
                [0, 0],                         
                [outer_w, 0],                   
                [outer_w, back_h - ch_diag],         
                [outer_w - ch_diag, back_h],         
                [ch_diag, back_h],                   
                [0, back_h - ch_diag]                
            ]);

            // Bottom base plate
            cube([inner_d, outer_w, wall_t]);
            
            // FRONT FACE: 2D profile with internal chamfers and cutout
            translate([inner_d, 0, 0])
            rotate([90, 0, 90])
            linear_extrude(height = wall_t)
            polygon([
                [0, 0],                                       
                [outer_w, 0],                                 
                [outer_w, corner_h],                          
                [outer_w - grip_zone, corner_h],               
                [outer_w - grip_zone - ch_diag, corner_h - ch_diag], 
                [outer_w - grip_zone - ch_diag, wall_t],       
                [grip_zone + ch_diag, wall_t],                 
                [grip_zone + ch_diag, corner_h - ch_diag],      
                [grip_zone, corner_h],                        
                [0, corner_h]                                 
            ]);
            
            // Left side support wall
            cube([inner_d, wall_t, corner_h]);
            
            // Right side support wall
            translate([0, outer_w - wall_t, 0]) cube([inner_d, wall_t, corner_h]);
        }

        // --- External Edge Chamfers (3D cutters) ---
        
        // Front Panel Frame (Top and Bottom)
        translate([total_d, -1, 0]) rotate([0, -45, 0]) translate([-ch, 0, -ch]) cube([ch*2, outer_w + 2, ch*2]);
        translate([total_d, -1, corner_h]) rotate([0, -45, 0]) translate([-ch, 0, -ch]) cube([ch*2, outer_w + 2, ch*2]);
        
        // Front Vertical Outer Edges
        translate([total_d, 0, -1]) rotate([0, 0, 45]) translate([-ch, -ch, 0]) cube([ch*2, ch*2, corner_h + 2]);
        translate([total_d, outer_w, -1]) rotate([0, 0, 45]) translate([-ch, -ch, 0]) cube([ch*2, ch*2, corner_h + 2]);

        // Longitudinal Side Edges
        translate([-wall_t - 0.1, 0, 0]) rotate([-45, 0, 0]) translate([0, -ch, -ch]) cube([total_d + wall_t + 0.2, ch*2, ch*2]);
        translate([-wall_t - 0.1, outer_w, 0]) rotate([-45, 0, 0]) translate([0, -ch, -ch]) cube([total_d + wall_t + 0.2, ch*2, ch*2]);
        translate([0, 0, corner_h]) rotate([-45, 0, 0]) translate([0, -ch, -ch]) cube([total_d + 0.1, ch*2, ch*2]);
        translate([0, outer_w, corner_h]) rotate([-45, 0, 0]) translate([0, -ch, -ch]) cube([total_d + 0.1, ch*2, ch*2]);
        
        // Back Wall Top Internal Edge
        translate([0, -1, back_h]) rotate([0, -45, 0]) translate([-ch, 0, -ch]) cube([ch*2, outer_w + 2, ch*2]);

        // --- Functional Cutouts ---
        
        // Side ventilation windows (Elevated for strength)
        translate([vent_clearance_back, -1, vent_z_start]) 
            cube([inner_d - vent_clearance_back - vent_clearance_front, wall_t + 2, corner_h - vent_z_start + 1]);
        translate([vent_clearance_back, outer_w - wall_t - 1, vent_z_start]) 
            cube([inner_d - vent_clearance_back - vent_clearance_front, wall_t + 2, corner_h - vent_z_start + 1]);
        
        // USB-C port access in the bottom
        usb_x_start = 17;
        usb_x_end = 12;
        translate([usb_x_start, wall_t + tol + usb_side_margin, -1]) 
            cube([inner_d - usb_x_start - usb_x_end, inner_w - (2 * usb_side_margin), wall_t + 2]);

        // Mounting Holes
        screw_z_pos = back_h / 2;
        center_y_pos = outer_w / 2;
        translate([0, center_y_pos - screw_dist_from_center, screw_z_pos]) screw_hole();
        translate([0, center_y_pos + screw_dist_from_center, screw_z_pos]) screw_hole();
    }
}

// Module for countersunk wall screws
module screw_hole() {
    rotate([0, -90, 0]) {
        cylinder(d = screw_dia, h = wall_t + 2);
        cylinder(d1 = csink_dia, d2 = screw_dia, h = csink_depth);
    }
}

mount();