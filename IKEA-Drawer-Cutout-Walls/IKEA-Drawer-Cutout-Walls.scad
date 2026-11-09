// Parametric Interlocked Multi-Part Drawer Walls (3-Part Layout)
// Version: 0.07

$fn = 128; 

// --- Parameters ---
wall_thickness = 10;
wall_height    = 65;
corner_radius  = 12;

// Dimensions (mm)
cutout_width   = 348; // Exact distance between the inner faces of left and right walls (34.8 cm)
side_length    = 270; // 26cm + 10mm

clearance      = 0.2; // 3D printing tolerance fit
joint_offset   = 15;  // Shifts the joint into the straight wall for thickness safety

// --- Screw Parameters ---
screw_hole_d = 2.5; // Pilot hole diameter for 3mm wood screws
screw_depth  = 20;  // Depth of the screw holes (mm)

// Render Selection: "assembled", "exploded", "left", "middle", "right"
part_to_render = "assembled"; 

// --- Puzzle Joint Modules ---
module puzzle_base() {
    union() {
        translate([0, -1.75]) square([3.1, 3.5]); 
        translate([3, 0]) circle(d=6);
    }
}

module puzzle_male() {
    puzzle_base();
}

module puzzle_female(c = 0.2) {
    offset(delta = c) puzzle_base();
}

// --- 2D Component Profiles ---
module left_part_2d() {
    r_out = corner_radius + wall_thickness; // 22mm
    
    difference() {
        union() {
            // Straight side wall along Y axis
            translate([0, r_out]) square([wall_thickness, side_length - r_out]);
            
            // Uniformly rounded corner
            intersection() {
                square([r_out, r_out]);
                difference() {
                    translate([r_out, r_out]) circle(r=r_out);
                    translate([r_out, r_out]) circle(r=corner_radius);
                }
            }
            
            // Extension into the straight middle section to safely house the joint
            translate([r_out, 0]) square([joint_offset, wall_thickness]);
        }
        
        // Puzzle socket moved safely onto the straight extension
        translate([r_out + joint_offset, wall_thickness / 2]) 
            rotate([0, 0, 180]) 
            puzzle_female(clearance);
    }
}

module middle_part_2d() {
    r_out = corner_radius + wall_thickness;
    start_x = r_out + joint_offset;
    
    // Total span calculation ensuring the inner opening width equals cutout_width (348mm)
    total_span = cutout_width + (2 * wall_thickness);
    end_x = total_span - (r_out + joint_offset);
    length = end_x - start_x;
    
    union() {
        // Main straight connecting wall
        translate([start_x, 0]) square([length, wall_thickness]);
        
        // Left male pin
        translate([start_x, wall_thickness / 2]) 
            rotate([0, 0, 180]) 
            puzzle_male();
            
        // Right male pin
        translate([end_x, wall_thickness / 2]) 
            rotate([0, 0, 0]) 
            puzzle_male();
    }
}

// --- 3D Extrusion & Assembly ---
module left_part() { 
    difference() {
        linear_extrude(height = wall_height) left_part_2d();
        
        // End face screw holes
        translate([wall_thickness / 2, side_length + 0.1, 15])
            rotate([90, 0, 0])
            cylinder(d=screw_hole_d, h=screw_depth + 1, $fn=32);
            
        translate([wall_thickness / 2, side_length + 0.1, 50])
            rotate([90, 0, 0])
            cylinder(d=screw_hole_d, h=screw_depth + 1, $fn=32);
            
        // Bottom face screw holes 
        for (y_pos = [50, 150, 250]) {
            translate([wall_thickness / 2, y_pos, -0.1])
                cylinder(d=screw_hole_d, h=screw_depth + 0.1, $fn=32);
        }
    }
}

module middle_part() { 
    difference() {
        linear_extrude(height = wall_height) middle_part_2d(); 
        
        // Bottom face screw holes aligned correctly with the 348mm inner span center (X = 184mm)
        for (x_offset = [-100, 0, 100]) {
            x_pos = (wall_thickness + (cutout_width / 2)) + x_offset;
            translate([x_pos, wall_thickness / 2, -0.1])
                cylinder(d=screw_hole_d, h=screw_depth + 0.1, $fn=32);
        }
    }
}

module right_part() { 
    total_span = cutout_width + (2 * wall_thickness);
    translate([total_span, 0, 0]) mirror([1, 0, 0]) left_part(); 
}

module assembly() {
    if (part_to_render == "assembled" || part_to_render == "left") {
        left_part();
    }
    if (part_to_render == "assembled" || part_to_render == "middle") {
        middle_part();
    }
    if (part_to_render == "assembled" || part_to_render == "right") {
        right_part();
    }
    
    if (part_to_render == "exploded") {
        translate([-20, 0, 0]) left_part();
        middle_part();
        translate([20, 0, 0]) right_part();
    }
}

assembly();