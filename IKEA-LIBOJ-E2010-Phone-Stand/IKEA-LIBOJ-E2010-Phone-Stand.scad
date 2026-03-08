// =========================================================
// S25 ULTRA + IKEA LIBOJ CHARGER STAND (v117)
// Absolute Alignment Correction
// =========================================================

/* [Main Dimensions] */

// Total width of the stand
total_w = 80; // [60:120]

// Height from the phone's RESTING SURFACE to the coil center
// (Measure your phone from bottom edge to center of coil)
charger_center_h = 81.5; // [70:95]

// Diameter of the IKEA Liboj charger disk
charger_d = 91.8; 

// Depth of the charger pocket
charger_t = 11.0; 

// Angle of the stand
stand_angle = 45; // [30:75]

/* [Phone Fit] */

// Thickness allowed for phone + case
phone_t = 12.5; 

// Height of the front retaining lip
lip_h = 10; 

/* [Technical Details] */

// Diameter of the center hole
hole_d = 64; 

// Width of the cable slot
cable_channel_w = 16; 

// Smoothing radius (Minkowski)
round_r = 1.5; 

// Detail level
$fn = 60; 

/* [Hidden Calculations] */
// The phone sits on a base of thickness 'lip_base_t'
lip_base_t = 5; 

// The internal Y-coordinate for the charger center must include the base thickness
// to ensure the phone's coil aligns with the charger.
internal_charger_y = charger_center_h + lip_base_t;

// Total backrest length calculated from the top of the charger
L_back = internal_charger_y + (charger_d / 2) + 5;

back_t = 15;
side_wall_t = 5;
chamfer_depth = 0.8;
chamfer_d = hole_d + (chamfer_depth * 2);

module stand() {
    difference() {
        // A. MAIN BODY
        minkowski() {
            stand_core_geometry(); 
            sphere(r = round_r, $fn=15); 
        }

        // B. CUTOUTS
        rotate([90 - stand_angle, 0, 0]) {
            
            // 1. CHARGER POCKET & NIPPLES
            translate([0, internal_charger_y, back_t - charger_t + 0.1]) {
                difference() {
                    cylinder(d = charger_d, h = charger_t + 10); 
                    for(a = [90, 220, 320]) { 
                        rotate([0, 0, a])
                        translate([charger_d/2 + 0.1, 0, charger_t - 1.2])
                        sphere(d = 2.0); 
                    }
                }
            }
            
            // 2. CENTER THROUGH-HOLE
            translate([0, internal_charger_y, -15]) 
            cylinder(d = hole_d, h = back_t + 30);

            // 3. 45° CHAMFERS
            translate([0, internal_charger_y, back_t - charger_t - chamfer_depth + 0.05]) 
            cylinder(d1 = hole_d, d2 = chamfer_d, h = chamfer_depth + 0.05);
            
            translate([0, internal_charger_y, -round_r]) 
            cylinder(d1 = chamfer_d, d2 = hole_d, h = chamfer_depth + 0.05);

            // 4. SIDE TRIMMING
            translate([0, internal_charger_y, back_t - charger_t/2 + 0.1])
            cube([total_w + 2 , charger_d - 40, charger_t], center=true);
        }    
    }
}

module stand_core_geometry() {
    s = sin(stand_angle);
    c = cos(stand_angle);
    base_l = L_back * c;
    internal_w = total_w - (2 * round_r);
    
    union() {
        // Base plate (desk contact)
        translate([-internal_w/2, 0, 0]) cube([internal_w, base_l, 4]);
        
        // Back plate
        rotate([90 - stand_angle, 0, 0])
        translate([-internal_w/2, 0, 0]) {
            difference() {
                cube([internal_w, L_back, back_t - round_r]);
                // Cable slot now accounts for the absolute height offset
                translate([internal_w/2 - cable_channel_w/2, -0.1, -0.1])
                cube([cable_channel_w, internal_charger_y + 5, back_t]);
            }
        }
        
        // Phone Support Shelf (where the phone actually touches)
        rotate([90 - stand_angle, 0, 0]) {
            translate([-internal_w/2, 0, back_t - round_r]) 
            cube([internal_w, lip_base_t, phone_t + 2*round_r]);
            translate([-internal_w/2, 0, back_t + phone_t + round_r]) 
            cube([internal_w, lip_h, 4]);
        }
        
        // Side Brackets
        for(i = [-1, 1]) {
            pos_x = (i == -1) ? -internal_w/2 : internal_w/2 - (side_wall_t - round_r);
            translate([pos_x, 0, 0])
            rotate([90, 0, 90]) 
            linear_extrude(height = side_wall_t - round_r)
            polygon(points=[[0, 0], [base_l, 0], [base_l, L_back * s], [0, 0]]);
        }
    }
}

stand();