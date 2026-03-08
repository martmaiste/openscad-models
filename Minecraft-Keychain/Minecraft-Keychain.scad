/*
 * Emotional Communication Keychain (Surprised Update)
 * Version: 0.16
 */

$fn = 64;

// --- Parameters ---
body_w = 15;         
body_d = 15;         
total_h = 40;        

head_size = 18;      
leg_h = 6;           
leg_w = 6;           

attach_w = 6;        
attach_d = 10;       
attach_h = 4;        
hole_r = 2.5;        

// --- Calculated Z-Heights ---
body_h = total_h - head_size - leg_h;

z_leg = leg_h / 2;
z_body = leg_h + (body_h / 2);
z_head = leg_h + body_h + (head_size / 2);
z_attach = leg_h + body_h + head_size; 

f_y = -head_size / 2;
f_d = 3; 

// --- Face Modules ---

module face_sad() {
    translate([-4, f_y, 2]) cube([3, f_d, 3], center=true); 
    translate([4, f_y, 2]) cube([3, f_d, 3], center=true);
    translate([0, f_y, -2.5]) cube([6, f_d, 2], center=true); 
    translate([-3, f_y, -3.5]) cube([2, f_d, 2], center=true); 
    translate([3, f_y, -3.5]) cube([2, f_d, 2], center=true); 
}

module face_meh() {
    translate([-4, f_y, 2]) cube([3, f_d, 3], center=true); 
    translate([4, f_y, 2]) cube([3, f_d, 3], center=true);
    translate([0, f_y, -3]) cube([8, f_d, 2], center=true); 
}

module face_smily() {
    translate([-4, f_y, 2]) cube([3, f_d, 3], center=true); 
    translate([4, f_y, 2]) cube([3, f_d, 3], center=true);
    translate([0, f_y, -4]) cube([6, f_d, 2], center=true); 
    translate([-3, f_y, -3]) cube([2, f_d, 2], center=true); 
    translate([3, f_y, -3]) cube([2, f_d, 2], center=true); 
}

module face_surprised() {
    // Tall eyes for a "wide-eyed" look
    translate([-4, f_y, 3]) cube([3, f_d, 5], center=true);
    translate([4, f_y, 3]) cube([3, f_d, 5], center=true);
    // Tall rectangular "O" mouth
    translate([0, f_y, -3]) cube([4, f_d, 5], center=true);
}

// --- Main Assembly ---
module comms_keychain() {
    
    // 1. Four Legs
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * (body_w/2 - leg_w/2), y * (body_d/2 - leg_w/2), z_leg])
                cube([leg_w, leg_w, leg_h], center=true);
        }
    }

    // 2. Body
    translate([0, 0, z_body]) {
        cube([body_w, body_d, body_h], center=true);
    }

    // 3. Head with 4 Moods
    translate([0, 0, z_head]) {
        difference() {
            cube([head_size, head_size, head_size], center=true);
            rotate([0, 0, 0]) face_sad();       
            rotate([0, 0, 90]) face_meh();      
            rotate([0, 0, 180]) face_smily();   
            rotate([0, 0, 270]) face_surprised(); 
        }
    }

    // 4. Keyring Attachment
    translate([0, 0, z_attach]) {
        difference() {
            union() {
                translate([0, 0, attach_h / 2])
                    cube([attach_w, attach_d, attach_h], center=true);
                translate([0, 0, attach_h])
                    rotate([0, 90, 0])
                    cylinder(h=attach_w, d=attach_d, center=true);
            }
            translate([0, 0, attach_h])
                rotate([0, 90, 0])
                cylinder(h=attach_w + 2, r=hole_r, center=true);
        }
    }
}

comms_keychain();