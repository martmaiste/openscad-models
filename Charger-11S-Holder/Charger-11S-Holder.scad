// Project: Wall Plate Mounting System (Clean Angled Cut)
// Version: 0.21

/* [Global Dimensions] */
width = 68;
height = 16;
depth = 14;

/* [Plate Constraints] */
plate_thickness = 1.8;

/* [Cutout Depths & Angles] */
top_depth = 4;      
bottom_depth = 2;   
top_slot_angle = 4; 

/* [Calculated Cutout Thicknesses] */
// Width for tilted plate: W = t*cos(theta) + d*sin(theta) + clearance
top_cutout_thickness = (plate_thickness * cos(top_slot_angle)) + (top_depth * sin(top_slot_angle)) + 0.05;
bottom_cutout_thickness = 2.0; 

/* [Screw Holes] */
screw_dia = 4;
head_dia = 8;
head_sink = 4;
screw_offset = 12;

/* [Finishing] */
chamfer_size = 1.2;

module mounting_block(cutout_d, cutout_w, slot_angle=0) {
    difference() {
        // Base Block
        cube([width, depth, height]);

        // Cutout (Always on the top face: z = height)
        // We use a taller cube for the subtraction to ensure it clears the top when angled
        translate([-1, depth / 2, height])
            rotate([slot_angle, 0, 0])
            translate([0, -cutout_w / 2, -cutout_d])
                cube([width + 2, cutout_w, cutout_d + 5]); // Height buffer added here

        // Screw Holes
        for(x = [screw_offset, width - screw_offset]) {
            translate([x, -1, height / 2])
                rotate([-90, 0, 0]) {
                    cylinder(d = screw_dia, h = depth + 2, $fn = 32);
                    cylinder(d = head_dia, h = head_sink + 1, $fn = 32);
                }
        }

        // --- CHAMFERS ---
        // 1. Vertical Front Corners
        for(x = [0, width]) {
            translate([x, 0, -1])
                rotate([0, 0, 45 + (x == width ? 90 : 0)])
                    translate([-chamfer_size, -chamfer_size, 0])
                        cube([chamfer_size * 2, chamfer_size * 2, height + 2]);
        }
        
        // 2. Horizontal Outer Edge (Bottom-front)
        translate([-1, 0, 0])
            rotate([45, 0, 0])
                translate([0, -chamfer_size, -chamfer_size])
                    cube([width + 2, chamfer_size * 2, chamfer_size * 2]);
        
        // 3. Side Horizontal Edges (Bottom-sides)
        for(x = [0, width]) {
            translate([x, -1, 0])
                rotate([0, -45 - (x == width ? 90 : 0), 0])
                    translate([-chamfer_size, 0, -chamfer_size])
                        cube([chamfer_size * 2, depth + 1, chamfer_size * 2]);
        }
    }
}

// Block 1: TOP position (Mount upside down on wall)
mounting_block(cutout_d = top_depth, cutout_w = top_cutout_thickness, slot_angle = top_slot_angle);

// Block 2: BOTTOM position
translate([0, depth + 10, 0]) 
    mounting_block(cutout_d = bottom_depth, cutout_w = bottom_cutout_thickness, slot_angle = 0);