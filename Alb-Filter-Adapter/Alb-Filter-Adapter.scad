// ALB Filter Entry Adapter Replacement
// File: Alb-Filter-Adapter.scad
// Version: 0.22

VERSION = "0.22";
$fn = 120;

/* [View & Print Options] */
show_cross_section  = false;  // Toggle to inspect internal geometry
print_threads_only  = false; // Toggle to print only the threaded cap (useful for test fits)

/* [FDM / Print Tolerances] */
thread_clearance   = 0.4;   // Extra clearance for PETG shrinkage on internal thread (mm)

/* [Filter Thread Parameters] */
thread_id_nominal  = 65.0;  // Internal thread minor diameter (mm)
thread_len         = 17.0;  // Full depth of the threaded cavity (mm)
unthreaded_len     = 0.0;   // Unthreaded length at the outer lip 
thread_pitch       = 1.5;   // 4 threads per 6mm
thread_depth       = 0.95;  // Radial depth of thread groove (mm)
cap_wall_thickness = 4.0;   // Outer wall thickness around thread (mm)
cap_face_thickness = 5.0;   // Thickness of top cap plate (mm)

/* [Knurling Parameters] */
knurl_count        = 90;    // Number of outer grip grooves
knurl_depth        = 0.6;   // Subtractive groove depth (mm)

/* [Bayonet Parameters] */
bayonet_od         = 40.0;  // Bayonet collar outer diameter (mm)
bayonet_bore       = 30.0;  // Inner water flow diameter (mm)
bayonet_span       = 45.0;  // Total span across both bayonet lugs (mm)
bayonet_len        = 12.0;  // Total bayonet extension length (mm)
notch_len          = 6.0;   // Length of bayonet lugs/notches (mm)
notch_taper_len    = 3.0;   // Height of bottom V-taper lead-in (mm)
notch_width        = 8.0;   // Width of bayonet lugs (mm)
chamfer_size       = 1.2;   // Lead-in chamfer size (mm)

/* [Face Pass-Through Slots] */
enable_face_slots  = true;  // Pass-through slots on top face
slot_radial_len    = 5.0;   // Radial length of slot (5mm long)
slot_arc_width     = 15.0;  // Slot width along the arc (15mm wide)
slot_offset        = 0.5;   // Distance offset from bayonet outer wall (mm)

// Calculated Dimensions
thread_id = thread_id_nominal + thread_clearance;
total_cap_height = thread_len + unthreaded_len + cap_face_thickness;
cap_od = thread_id + (cap_wall_thickness * 2);

module alb_filter_entry_adapter() {
    union() {
        // Main Threaded Body
        difference() {
            knurled_body(d = cap_od, h = total_cap_height, count = knurl_count, depth = knurl_depth);
            
            // Internal symmetrical triangle threads (Right-Handed / Regular)
            tank_thread_internal(d = thread_id, h = thread_len + 0.1, pitch = thread_pitch, depth = thread_depth);
            
            // Lead-in internal chamfer at the bottom opening to help threads catch easily
            translate([0, 0, -0.1])
                cylinder(d1 = thread_id + (thread_depth * 2), d2 = thread_id, h = thread_depth + 0.1);
                
            // Water flow bore through top plate
            translate([0, 0, total_cap_height - cap_face_thickness - 0.1])
                cylinder(d = bayonet_bore, h = cap_face_thickness + 0.2);
                
            // Face slots under notches (rendered only during full print)
            if (enable_face_slots && !print_threads_only) {
                face_slots();
            }
        }

        // Bayonet Connector Assembly (omitted when printing threads only)
        if (!print_threads_only) {
            translate([0, 0, total_cap_height])
                bayonet_connector();
        }
    }
}

module knurled_body(d, h, count, depth) {
    difference() {
        cylinder(d = d, h = h);
        
        // Subtractive vertical knurling grooves
        for (i = [0 : count - 1]) {
            rotate([0, 0, i * (360 / count)])
                translate([d / 2, 0, h / 2])
                rotate([0, 0, 45])
                cube([depth * 1.414, depth * 1.414, h + 0.2], center = true);
        }
        
        // Top rim chamfer
        translate([0, 0, h])
            chamfer_ring_out(d = d + 1.0, chamfer = chamfer_size + 0.5);
            
        // Bottom rim chamfer
        translate([0, 0, 0])
            rotate([180, 0, 0])
            chamfer_ring_out(d = d + 1.0, chamfer = chamfer_size);
    }
}

module bayonet_connector() {
    lug_reach = (bayonet_span - bayonet_od) / 2;
    lug_z_start = bayonet_len - notch_len;

    difference() {
        union() {
            // Main bayonet cylinder with top chamfer on collar body
            difference() {
                cylinder(d = bayonet_od, h = bayonet_len);
                
                translate([0, 0, bayonet_len])
                    chamfer_ring_out(d = bayonet_od + 0.2, chamfer = chamfer_size);
            }
            
            // Side Bayonet Lugs extending over the chamfer zone for a flush top face
            translate([0, 0, lug_z_start]) {
                for (side = [0, 180]) {
                    rotate([0, 0, side]) {
                        bayonet_lug_solid(reach = lug_reach, width = notch_width, height = notch_len, taper_h = notch_taper_len);
                    }
                }
            }
        }
        
        // Inner water flow bore
        translate([0, 0, -0.1])
            cylinder(d = bayonet_bore, h = bayonet_len + 0.2);
            
        // Outer tip chamfer applied exclusively across the lug ends
        translate([0, 0, bayonet_len])
            chamfer_ring_out(d = bayonet_span + 0.2, chamfer = chamfer_size);
    }
}

module bayonet_lug_solid(reach, width, height, taper_h) {
    r_corner = 1.0;
    anchor_inward_reach = chamfer_size + 1.5;
    x_tip = bayonet_od / 2 + reach - r_corner;
    
    hull() {
        // Inner wall anchor points
        translate([bayonet_od / 2 - anchor_inward_reach, -width / 2, taper_h])
            cube([anchor_inward_reach, width, height - taper_h]);
            
        translate([bayonet_od / 2 - anchor_inward_reach, -r_corner, 0])
            cube([anchor_inward_reach, r_corner * 2, r_corner]);

        // Outer tip spheres forming the V-bottom lead-in profile
        translate([x_tip, -width / 2 + r_corner, height - r_corner])
            sphere(r = r_corner);
        translate([x_tip, width / 2 - r_corner, height - r_corner])
            sphere(r = r_corner);
            
        // Mid-height points where bottom V-taper starts
        translate([x_tip, -width / 2 + r_corner, taper_h])
            sphere(r = r_corner);
        translate([x_tip, width / 2 - r_corner, taper_h])
            sphere(r = r_corner);
            
        // Bottom center tip of the V-shape
        translate([x_tip, 0, r_corner])
            sphere(r = r_corner);
    }
}

module face_slots() {
    r_in = (bayonet_od / 2) + slot_offset;
    r_out = r_in + slot_radial_len;
    r_mid = (r_in + r_out) / 2;
    
    arc_deg = (slot_arc_width / (2 * PI * r_mid)) * 360;
    
    for (angle = [0 - (arc_deg / 2), 180 - (arc_deg / 2)]) {
        rotate([0, 0, angle])
            rotate_extrude(angle = arc_deg)
            translate([r_in, total_cap_height - cap_face_thickness - 0.5])
            square([slot_radial_len, cap_face_thickness + 1.0]);
    }
}

module triangle_thread_bit(depth, pitch) {
    rotate([90, 0, 0])
    linear_extrude(height = 0.1, center = true)
    polygon([
        [-0.1, pitch/2 + 0.05],         
        [depth, 0],                     
        [-0.1, -pitch/2 - 0.05]         
    ]);
}

module tank_thread_internal(d, h, pitch, depth) {
    // Central bore (minor diameter)
    cylinder(d = d, h = h + 0.1);
    
    steps_per_turn = 72;
    total_steps = floor(((h - pitch) / pitch) * steps_per_turn);
    start_step = -floor(steps_per_turn / 2); 
    
    for (i = [start_step : total_steps - 1]) {
        z1 = i * (pitch / steps_per_turn);
        a1 = i * (360 / steps_per_turn);
        z2 = (i + 1) * (pitch / steps_per_turn);
        a2 = (i + 1) * (360 / steps_per_turn);
        
        if (z1 <= h) {
            hull() {
                rotate([0, 0, a1]) 
                    translate([d / 2, 0, z1]) 
                    triangle_thread_bit(depth, pitch);
                    
                rotate([0, 0, a2]) 
                    translate([d / 2, 0, z2]) 
                    triangle_thread_bit(depth, pitch);
            }
        }
    }
}

module chamfer_ring_out(d, chamfer) {
    rotate_extrude()
        translate([d / 2, 0, 0])
        polygon(points = [[-chamfer, 0.2], [0.2, 0.2], [0.2, -chamfer]]);
}

// Render Adapter with Optional Cutaway
if (show_cross_section) {
    difference() {
        alb_filter_entry_adapter();
        // Slices away the front half to expose the internal threads
        translate([-cap_od, 0, -10])
            cube([cap_od * 2, cap_od * 2, total_cap_height + bayonet_len + 20]);
    }
} else {
    alb_filter_entry_adapter();
}