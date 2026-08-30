/*
 * 12V Chinese Screwdriver Battery Wall Mount 
 * Version: v0.20
 * 
 * Changelog:
 * - v0.18/v0.19: Attempted fixes with subtractive 3D cutter prisms (sliced off cups).
 * - v0.20: COMPLETE REWRITE OF CHAMFER ENGINE.
 *          Removed all 3D subtractive cutter blocks. Both the wall plate and holders 
 *          are now extruded natively with layered chamfers. The rear wall face is 
 *          trimmed flat using a single planar cut, ensuring crisp 45-degree chamfers 
 *          on all top, bottom, and side edges without risking holder disappearance 
 *          or boolean artifacts.
 */

// ==========================================
// PARAMETERS
// ==========================================

/* [Holder Configuration] */
// Number of vertical cup sockets (2, 3, 4, etc.)
battery_count = 3;        

// Socket pocket depth (mm)
socket_depth = 30.0;      

// Wall thickness of individual cups (mm)
cup_wall_thickness = 3.5; 

// Bottom thickness of each cup floor (mm)
cup_base_thickness = 4.0; 

/* [Chamfers & Finishing] */
// Size of exterior top & bottom edge chamfers (mm)
chamfer_size = 1.2;

// Number of steps for layered chamfer rendering
chamfer_steps = 10;

// Size of socket entry funnel chamfer for smooth insertion (mm)
entry_chamfer_size = 1.5;

/* [Battery Geometry] */
// Main equilateral triangle side length before cuts (mm)
battery_side = 55.0;      

// Cut height from opposite side (mm)
battery_cut_height = 45.0; 

// Width of the upper part of the battery sticking out of the cup (mm)
battery_top_width = 52.0;

// Space between batteries at their widest point (mm)
finger_spacing = 10.0;

// Corner smoothing radius (mm)
corner_radius = 3.0;      

// Extra fit clearance / tolerance inside the cup (mm)
clearance = 0.8;          

/* [Inter-Cup Bridging & Webbing] */
// Fillet radius for the web bridging adjacent cups (mm)
bridge_fillet_radius = 8.0;

// Minimum side margin extending beyond the outer cups (mm)
side_extension = 6.0;

/* [Wall Mounting Plate Grid] */
// Distance between mounting screw centers (mm)
screw_spacing = 40.0;     

// Rear backplate thickness (mm)
backplate_thickness = 5.0;

// Extra top extension of backplate for screw clearance (mm)
backplate_top_flange_height = 12.0; 

// Screw shank diameter (mm)
screw_d = 4.2;            

// Countersunk screw head max diameter (mm)
screw_head_d = 8.5;       

// Countersink cone angle (degrees)
screw_countersink_angle = 90; 

/* [Render Quality] */
$fn = 60;


// ==========================================
// CALCULATED GEOMETRY & GRID SNAPPING
// ==========================================

// Triangle internal geometry
r_in = battery_side * sqrt(3) / 6;       
cut_dist = battery_cut_height - r_in;    

// Spacing logic between cups
cup_outer_width = battery_side + (clearance * 2) + (cup_wall_thickness * 2);
cell_pitch = max(cup_outer_width, battery_top_width) + finger_spacing;
total_width = (battery_count - 1) * cell_pitch;

// Minimum required physical width for cups + end margins
min_required_width = total_width + cup_outer_width + (side_extension * 2);

// Grid Alignment Math (40mm grid snapping, 20mm edge margins)
num_grid_columns = ceil(min_required_width / screw_spacing);
backplate_w = num_grid_columns * screw_spacing;

total_h = socket_depth + cup_base_thickness;
back_y = -r_in - clearance - cup_wall_thickness;


// ==========================================
// 2D PROFILE MODULES
// ==========================================

// Base 55mm / 45mm cut triangle profile
module base_sharp_polygon() {
    intersection() {
        rotate([0, 0, 90]) circle(r = r_in * 2, $fn=3);
        rotate([0, 0, 270]) circle(r = cut_dist * 2, $fn=3);
    }
}

// Single cup 2D outer boundary with rounded corners
module single_cup_outer_2d() {
    offset(r = corner_radius + clearance + cup_wall_thickness) {
        offset(r = -corner_radius) {
            base_sharp_polygon();
        }
    }
}

// Single cup inner cavity 2D boundary
module single_cup_inner_2d(extra_clearance = 0) {
    offset(r = corner_radius + clearance + extra_clearance) {
        offset(r = -corner_radius) {
            base_sharp_polygon();
        }
    }
}

// Continuous 2D outer shell connecting cups with backplate anchor block
module continuous_outer_shell_2d() {
    offset(r = -bridge_fillet_radius) {
        offset(r = bridge_fillet_radius) {
            union() {
                // Array of cup outer profiles
                translate([-total_width / 2, 0]) {
                    for (i = [0 : battery_count - 1]) {
                        translate([i * cell_pitch, 0]) {
                            single_cup_outer_2d();
                        }
                    }
                }
                
                // Extension block anchoring cups inside backplate
                translate([-backplate_w / 2, back_y - 2.0]) {
                    square([backplate_w, cup_wall_thickness + 4.0]);
                }
            }
        }
    }
}


// ==========================================
// 3D HELPER MODULES
// ==========================================

// Extrudes 2D profiles with BOTH top and bottom edge chamfers natively
module double_chamfered_extrude(h, c, steps = 10) {
    // 1. Bottom chamfer gradient
    for (i = [0 : steps - 1]) {
        z_start = (i * c / steps);
        layer_h = (c / steps) + 0.01;
        inset = c - (i * c / steps);
        
        translate([0, 0, z_start])
            linear_extrude(height = layer_h)
                offset(delta = -inset) children();
    }
    
    // 2. Main straight body
    translate([0, 0, c])
        linear_extrude(height = max(0.1, h - 2 * c))
            children();
            
    // 3. Top chamfer gradient
    for (i = [0 : steps - 1]) {
        z_start = (h - c) + (i * c / steps);
        layer_h = (c / steps) + 0.01;
        inset = (i + 1) * (c / steps);
        
        translate([0, 0, z_start])
            linear_extrude(height = layer_h)
                offset(delta = -inset) children();
    }
}

// Countersunk Screw Hole (oriented into the wall along +Y)
module countersink_screw_hole() {
    head_h = (screw_head_d - screw_d) / (2 * tan(screw_countersink_angle / 2));
    
    rotate([90, 0, 0]) {
        translate([0, 0, -1])
            cylinder(d = screw_d, h = backplate_thickness + side_extension + 10);
            
        translate([0, 0, -0.1])
            cylinder(d1 = screw_head_d, d2 = screw_d, h = head_h + 0.2);
            
        translate([0, 0, -50])
            cylinder(d = screw_head_d, h = 50);
    }
}


// ==========================================
// MAIN ASSEMBLY
// ==========================================

module battery_wall_mount() {
    flange_full_h = total_h + backplate_top_flange_height;

    difference() {
        
        // 1. SOLID MONOLITHIC BODY
        union() {
            // Extruded cup holder bodies with top and bottom chamfers
            double_chamfered_extrude(total_h, chamfer_size, steps = chamfer_steps) {
                continuous_outer_shell_2d();
            }
            
            // Wall plate with top, bottom, and side chamfers
            difference() {
                // Extended backplate block extruded with chamfers
                double_chamfered_extrude(flange_full_h, chamfer_size, steps = chamfer_steps) {
                    translate([-backplate_w / 2, back_y - backplate_thickness - chamfer_size]) {
                        square([backplate_w, backplate_thickness + chamfer_size + 1.0]);
                    }
                }
                
                // Trim extended back face so wall-contacting face stays 100% flat
                translate([-backplate_w - 50, back_y - backplate_thickness - 500, -50]) {
                    cube([backplate_w * 2 + 100, 500, flange_full_h + 100]);
                }
            }
        }
        
        // 2. SUBTRACT CAVITIES & MOUNTING HOLES
        
        // Inner battery cavities with entry funnels
        translate([-total_width / 2, 0, 0]) {
            for (i = [0 : battery_count - 1]) {
                translate([i * cell_pitch, 0, 0]) {
                    
                    // Main socket pocket
                    translate([0, 0, cup_base_thickness]) {
                        linear_extrude(height = socket_depth + 1) {
                            single_cup_inner_2d(0);
                        }
                        
                        // Entry funnel chamfer at socket top opening
                        translate([0, 0, socket_depth - entry_chamfer_size]) {
                            for (j = [0 : 8]) {
                                z_step = j * (entry_chamfer_size / 8);
                                expand = j * (entry_chamfer_size / 8);
                                translate([0, 0, z_step])
                                    linear_extrude(height = (entry_chamfer_size / 8) + 0.1)
                                        single_cup_inner_2d(expand);
                            }
                        }
                    }
                    
                    // Bottom debris drain hole
                    translate([0, 0, -1]) {
                        linear_extrude(height = cup_base_thickness + 2) {
                            single_cup_inner_2d(-5);
                        }
                    }
                }
            }
        }
        
        // Grid-aligned countersunk screw holes
        start_x = - (backplate_w / 2) + (screw_spacing / 2);
        z_top = total_h + (backplate_top_flange_height / 2);
        
        for (s = [0 : num_grid_columns - 1]) {
            hole_x = start_x + (s * screw_spacing);
            
            translate([hole_x, back_y, z_top])
                countersink_screw_hole();
        }
    }
}

// Render Model
battery_wall_mount();