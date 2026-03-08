// Ergonomic Utility Door Key Knob - Filleted Cylinder
// Version: 0.07

/* [Knob Dimensions] */
knob_diameter = 30;
knob_height = 25;
knob_resolution = 64; 

/* [Ergonomic Features] */
rounding_radius = 3; // How much to round the top and bottom edges
number_of_grooves = 18;
groove_depth = 1.0;

/* [Key Dimensions] */
key_thickness = 2.0;
key_total_length = 20; 
key_wide_part_length = 6;
key_width_back = 18;
key_width_front = 12;

/* [Fit Settings] */
clearance = 0.2; 

module key_slot() {
    t = key_thickness + clearance;
    w_back = key_width_back + clearance;
    w_front = key_width_front + clearance;
    
    L1 = key_wide_part_length;
    L_taper = key_total_length - L1;
    
    // Cutting extra long to ensure it clears the rounded ends
    translate([0, 0, -5])
    union() {
        // 1. Back section
        translate([-w_back/2, -t/2, 0]) 
            cube([w_back, t, L1 + 5.1]);
        
        // 2. Taper section
        translate([0, 0, L1 + 5])
            hull() {
                translate([-w_back/2, -t/2, 0]) cube([w_back, t, 0.01]);
                translate([-w_front/2, -t/2, L_taper]) cube([w_front, t, 0.01]);
            }
            
        // 3. Front extension (through the top)
        translate([-w_front/2, -t/2, L1 + 5 + L_taper])
            cube([w_front, t, knob_height + 10]);
    }
}

module knob_body() {
    difference() {
        // Create a cylinder with rounded top and bottom edges
        // We shrink the main cylinder slightly so the 'minkowski' 
        // sphere brings it back to the target diameter.
        minkowski() {
            cylinder(
                d = knob_diameter - (2 * rounding_radius), 
                h = knob_height - (2 * rounding_radius), 
                $fn = knob_resolution, 
                center = true
            );
            sphere(r = rounding_radius, $fn = 32);
        }

        // Vertical grooves for grip
        for (i = [0 : number_of_grooves - 1]) {
            rotate([0, 0, i * (360 / number_of_grooves)])
                translate([knob_diameter / 2, 0, 0])
                cylinder(r = groove_depth, h = knob_height + 2, center = true, $fn = 12);
        }
    }
}

// Final Assembly
difference() {
    // Center the body at Z=height/2 for easy slot alignment
    translate([0, 0, knob_height / 2]) knob_body();
    
    // Subtract the slot (centered vertically)
    translate([0, 0, (knob_height - key_total_length) / 2])
        key_slot();
}