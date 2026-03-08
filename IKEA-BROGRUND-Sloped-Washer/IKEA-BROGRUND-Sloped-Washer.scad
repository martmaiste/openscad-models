// IKEA BROGRUND Faucet Custom Washer
// Version: 0.04
// Date: 2026-01-18

/* [Dimensions] */
// Total length of the faucet base
base_length = 56.5; 
// Width of the base (and diameter of the rounded ends)
base_width = 49.3; 
// Minimum thickness (the flat part)
thickness_min = 2.0; 
// Maximum thickness at the thick end
thickness_max = 4.0; 
// Distance from the end where the thickening begins
wedge_length = 24.0; 
// Wall thickness (width of the "ring")
wall_width = 10.0; 

/* [Rendering Quality] */
$fn = 100;

module brogrund_washer_v0_04() {
    difference() {
        // 1. The Main Solid Body
        intersection() {
            linear_extrude(height = thickness_max + 1) {
                washer_profile(0); // Outer profile
            }
            
            union() {
                // Flat portion (from 24mm mark to far right)
                translate([-(base_length/2) + wedge_length, -base_width/2, 0])
                cube([base_length - wedge_length, base_width, thickness_min]);
                
                // Sloped portion (from far left to 24mm mark)
                hull() {
                    translate([-base_length/2, -base_width/2, 0])
                    cube([0.1, base_width, thickness_max]);
                    
                    translate([-base_length/2 + wedge_length, -base_width/2, 0])
                    cube([0.1, base_width, thickness_min]);
                }
            }
        }

        // 2. The Central Opening
        // Subtracted through the entire height
        translate([0, 0, -1])
        linear_extrude(height = thickness_max + 2) {
            washer_profile(-wall_width); // Inner profile
        }
    }
}

// 2D Profile (Stadium Shape) with optional offset for the hole
module washer_profile(offset_val) {
    // The length of the internal rectangle needs to be adjusted 
    // to maintain the total length after the offset is applied
    internal_dist = (base_length - base_width);
    
    offset(r = offset_val) {
        hull() {
            translate([-internal_dist/2, 0, 0])
            circle(d = base_width);
            
            translate([internal_dist/2, 0, 0])
            circle(d = base_width);
        }
    }
}

// Render
brogrund_washer_v0_04();