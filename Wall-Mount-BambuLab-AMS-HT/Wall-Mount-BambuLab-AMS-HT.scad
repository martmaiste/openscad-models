// ====================================================================
// Bambu Lab AMS HT Wall Mount Bracket
// Version: v0.28
// Description: Parametric wall mount bracket for Bambu Lab AMS HT unit.
//              Two identical brackets form a side-wall mounting platform.
// Fixes (v0.28): Added a side retaining lip along the gusset side (X=0)
//                with matching height (10mm) and thickness (5mm) to 
//                prevent sideways movement of the AMS HT unit.
// ====================================================================

/* [Layout Options] */
// Which bracket(s) to render for the build plate
render_layout = "left"; // ["left": Left Bracket, "right": Right Bracket, "pair": Both Brackets]

/* [Wall Mounting Parameters] */
// Center-to-center vertical distance between screws (e.g., 40 or 80 for grid plate)
screw_spacing = 40; // [40, 80]

// Wood screw shank diameter (pass-through hole)
screw_hole_diam = 4.5; 

// Wood screw countersink head diameter
countersink_diam = 8.5; 

// Countersink depth angle in degrees (standard 90 deg wood screw)
countersink_angle = 90; 

/* [Platform & AMS HT Dimensions] */
// Width of the support arm platform (mm)
arm_width = 30.0; 

// Width of the bottom base of AMS HT that sits between notches (mm)
ams_base_width = 103.0; 

// Extra tolerance/fit clearance between notches (mm)
fit_clearance = 1.0; 

// Thickness of the horizontal support platform (mm)
platform_thickness = 5.0; 

/* [Notch / Retaining Lip Parameters] */
// Height of front outer retaining lip above platform (mm)
outer_notch_height = 10.0; 

// Thickness of front outer retaining lip (mm)
outer_notch_thickness = 5.0; 

// Height of rear wall-side notch above platform (mm)
rear_notch_height = 10.0; 

// Thickness of rear wall-side notch (mm)
rear_notch_thickness = 5.0; 

// Height of side retaining lip above platform (mm)
side_lip_height = 10.0;

// Thickness of side retaining lip (mm)
side_lip_thickness = 5.0;

/* [Bracket Structure Parameters] */
// Thickness of the vertical plate attached to the wall (mm)
wall_plate_thickness = 5.0; 

// Thickness of the diagonal structural support rib (mm)
gusset_thickness = 5.0; 

// Chamfer size for all non-wall-facing outer edges (mm)
chamfer_size = 1.0;

/* [Hidden] */
$fn = 60; // Smooth curves resolution

// Dynamic platform depth between notches
platform_depth = ams_base_width + fit_clearance;

// Calculate total height needed for wall plate based on screw spacing
wall_plate_height = screw_spacing + (countersink_diam * 2) + 20;

// Total depth trimmed to end flush at the front edge of the outward notch
total_arm_depth = rear_notch_thickness + platform_depth + outer_notch_thickness;

// --- Main Layout Rendering ---
if (render_layout == "left") {
    ams_ht_bracket();
} else if (render_layout == "right") {
    mirror([1, 0, 0]) ams_ht_bracket();
} else {
    // Render side-by-side mirrored pair
    translate([-arm_width - 10, 0, 0]) ams_ht_bracket();
    translate([10, 0, 0]) mirror([1, 0, 0]) ams_ht_bracket();
}

// --- Modules ---

module ams_ht_bracket() {
    difference() {
        // 1. Base Solid Geometry
        union() {
            // Vertical Wall Plate
            translate([0, 0, 0])
                cube([arm_width, wall_plate_thickness, wall_plate_height]);
            
            // Horizontal Support Arm
            translate([0, 0, wall_plate_height - platform_thickness])
                cube([arm_width, total_arm_depth, platform_thickness]);
            
            // Rear Wall-Side Notch (flush with wall side y=0)
            translate([0, 0, wall_plate_height - platform_thickness])
                cube([arm_width, rear_notch_thickness, platform_thickness + rear_notch_height]);

            // Front Outer Retaining Lip
            translate([0, total_arm_depth - outer_notch_thickness, wall_plate_height - platform_thickness])
                cube([arm_width, outer_notch_thickness, platform_thickness + outer_notch_height]);

            // Side Retaining Lip (on diagonal support side X=0)
            translate([0, 0, wall_plate_height - platform_thickness])
                cube([side_lip_thickness, total_arm_depth, platform_thickness + side_lip_height]);

            // Structural Diagonal Gusset (placed on Left side X=0)
            translate([0, wall_plate_thickness, 0])
                rotate([90, 0, 90])
                    linear_extrude(height = gusset_thickness)
                        polygon(points = [
                            [0, 10], // Moved 10mm up the wall plate
                            [total_arm_depth - wall_plate_thickness - 10, wall_plate_height - platform_thickness], // Moved 10mm back from the front
                            [0, wall_plate_height - platform_thickness]
                        ]);
        }

        // 2. Countersunk Screwholes
        translate([arm_width / 2, wall_plate_thickness + 1, wall_plate_height / 2 + screw_spacing / 2])
            rotate([90, 0, 0])
                screw_hole_subtraction();

        translate([arm_width / 2, wall_plate_thickness + 1, wall_plate_height / 2 - screw_spacing / 2])
            rotate([90, 0, 0])
                screw_hole_subtraction();
                
        // 3. Precise Edge Chamfer Subtractions
        chamfer_cutters();
    }
}

// Applies explicit edge subtractions along the model's outer profile
module chamfer_cutters() {
    wp_z = wall_plate_height;
    total_y = total_arm_depth;
    c = chamfer_size;
    
    // X-Aligned Edge Chamfers (Horizontal edges across the bracket)
    translate([0, 5, 0]) edge_cutter_x(arm_width, c);
    translate([0, total_y, wp_z - platform_thickness]) edge_cutter_x(arm_width, c);
    
    translate([0, total_y, wp_z + outer_notch_height]) edge_cutter_x(arm_width, c);
    translate([0, total_y - outer_notch_thickness, wp_z + outer_notch_height]) edge_cutter_x(arm_width, c);
    translate([0, 5, wp_z + rear_notch_height]) edge_cutter_x(arm_width, c);
    
    // Execute side chamfer trace for Left Outer Face (X=0)
    translate([0, 0, 0]) {
        edge_cutter_segment([0, 0], [5, 0], c);
        
        edge_cutter_segment([5, 0], [5, 10], c, 1, 0); 
        
        // Precision Miter Joint to fix the inner corner gouge on outer profile
        edge_cutter_joint([5, 10], [5, 0], [total_y - 10, wp_z - platform_thickness], c);
        
        edge_cutter_segment([5, 10], [total_y - 10, wp_z - platform_thickness], c, 0, 0);
        
        // Precision Miter Joint for top platform corner
        edge_cutter_joint([total_y - 10, wp_z - platform_thickness], [5, 10], [total_y, wp_z - platform_thickness], c);
        
        edge_cutter_segment([total_y - 10, wp_z - platform_thickness], [total_y, wp_z - platform_thickness], c, 0, 1);
        
        // Front vertical edge leading to top of side lip
        edge_cutter_segment([total_y, wp_z - platform_thickness], [total_y, wp_z + side_lip_height], c);
        
        // Continuous top outer chamfer along the full side lip
        edge_cutter_segment([total_y, wp_z + side_lip_height], [5, wp_z + side_lip_height], c);
        
        edge_cutter_segment([5, wp_z + side_lip_height], [0, wp_z + side_lip_height], c);
    }
    
    // Chamfer on the inner top edge of the side lip (at X = side_lip_thickness)
    translate([side_lip_thickness, 0, 0])
        edge_cutter_segment(
            [total_y - outer_notch_thickness, wp_z + side_lip_height], 
            [rear_notch_thickness, wp_z + side_lip_height], 
            c, 0, 0
        );

    // Execute side chamfer trace for Right Face (X=arm_width)
    translate([arm_width, 0, 0]) {
        edge_cutter_segment([0, 0], [5, 0], c);
        
        edge_cutter_segment([5, 0], [5, wp_z - platform_thickness], c, 1, 0);
        edge_cutter_segment([5, wp_z - platform_thickness], [total_y, wp_z - platform_thickness], c, 0, 1);
        
        edge_cutter_segment([total_y, wp_z - platform_thickness], [total_y, wp_z + outer_notch_height], c);
        edge_cutter_segment([total_y, wp_z + outer_notch_height], [total_y - outer_notch_thickness, wp_z + outer_notch_height], c);
        
        edge_cutter_segment(
            [total_y - outer_notch_thickness, wp_z + outer_notch_height], 
            [total_y - outer_notch_thickness, wp_z], 
            c, 1, 0
        );
        
        edge_cutter_segment(
            [total_y - outer_notch_thickness, wp_z], 
            [5, wp_z], 
            c, 0, 0
        );
        
        edge_cutter_segment(
            [5, wp_z], 
            [5, wp_z + rear_notch_height], 
            c, 0, 1
        );
        
        edge_cutter_segment([5, wp_z + rear_notch_height], [0, wp_z + rear_notch_height], c);
    }
    
    // Chamfer the inner diagonal edge of the gusset (at X=gusset_thickness)
    intersection() {
        translate([gusset_thickness, 0, 0]) 
            edge_cutter_segment([5, 10], [total_y - 10, wp_z - platform_thickness], c, 5, 5); 
            
        translate([-10, 5, -50]) 
            cube([arm_width + 20, total_y + 50, wp_z - platform_thickness + 50]);
    }
        
    // --- 3D Miter Corner Subtractions ---
    // Left Inner Miters (shifted inward to X = side_lip_thickness)
    inner_corner_miter([total_y - outer_notch_thickness, wp_z], c, false, 1, -1, x_pos = side_lip_thickness);  // Front Top
    inner_corner_miter([5, wp_z], c, false, -1, -1, x_pos = side_lip_thickness);                               // Rear Top
    
    // Right Face Inner Miters
    inner_corner_miter([total_y - outer_notch_thickness, wp_z], c, true, 1, -1);   // Front Top
    inner_corner_miter([5, wp_z], c, true, -1, -1);                                // Rear Top
    inner_corner_miter([5, wp_z - platform_thickness], c, true, -1, 1);            // Rear Bottom (wall plate to arm)
}

// Connects two chamfer segments cleanly at a corner to prevent gouging or spikes
module edge_cutter_joint(p, p_prev, p_next, c) {
    ang1 = atan2(p[1] - p_prev[1], p[0] - p_prev[0]);
    ang2 = atan2(p_next[1] - p[1], p_next[0] - p[0]);
    
    hull() {
        translate([0, p[0], p[1]]) rotate([ang1, 0, 0]) rotate([0, 0, 90]) rotate([45, 0, 0]) translate([-0.005, -c/sqrt(2), -c/sqrt(2)]) cube([0.01, c * sqrt(2), c * sqrt(2)]);
        translate([0, p[0], p[1]]) rotate([ang2, 0, 0]) rotate([0, 0, 90]) rotate([45, 0, 0]) translate([-0.005, -c/sqrt(2), -c/sqrt(2)]) cube([0.01, c * sqrt(2), c * sqrt(2)]);
    }
}

// Subtraction module that cleanly bridges square-ended chamfers using a diagonal plane
module inner_corner_miter(p, c, is_right, dir_y, dir_z=-1, x_pos=-1) {
    x = (x_pos >= 0) ? x_pos : (is_right ? arm_width : 0);
    x_dir = is_right ? -1 : 1;
    
    translate([x, p[0], p[1]])
        scale([x_dir, 1, 1])
        hull() {
            translate([-0.05, -dir_y*0.05, -dir_z*0.05]) cube(0.01, center=true);
            translate([c, 0, 0]) cube(0.01, center=true);
            translate([0, dir_y * c, 0]) cube(0.01, center=true);
            translate([0, 0, dir_z * c]) cube(0.01, center=true);
        }
}

// Places a chamfer cutting diamond along any 2D coordinate segment in the YZ plane
module edge_cutter_segment(p1, p2, c, os1=1, os2=1) {
    l = norm(p2 - p1);
    ang = atan2(p2[1] - p1[1], p2[0] - p1[0]);
    translate([0, p1[0], p1[1]])
        rotate([ang, 0, 0])
        rotate([0, 0, 90])
        edge_cutter_x(l, c, os1, os2);
}

// Base shape for shaving a perfect 45-degree chamfer off a straight edge
module edge_cutter_x(l, c, os1=1, os2=1) {
    rotate([45, 0, 0])
        translate([-os1, -c/sqrt(2), -c/sqrt(2)])
        cube([l + os1 + os2, c * sqrt(2), c * sqrt(2)]);
}

// Subtraction module for wood screw with countersink head
module screw_hole_subtraction() {
    countersink_height = (countersink_diam - screw_hole_diam) / (2 * tan(countersink_angle / 2));
    
    union() {
        cylinder(h = wall_plate_thickness + 5, d = screw_hole_diam);
        cylinder(h = countersink_height, d1 = countersink_diam, d2 = screw_hole_diam);
    }
}