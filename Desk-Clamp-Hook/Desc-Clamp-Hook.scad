/*
 * Headphone / Window Hook for Desk Edge (C-Clamp style)
 * Version: 0.35
 * Description: Removed version number from the module name.
 */

// --- Parameters ---
rotate_hook_90_x = true;   // Set to true to rotate the L-hook 90 degrees around the X-axis

desk_thickness = 16.5;     
jaw_depth = 25;            
material_thickness = 10;   

hook_base_internal = 25;   
hook_lip_internal = 12.5;  

chamfer_size = 2;          
$fn = 32;                  

module desk_headphone_hook() {
    t = material_thickness;
    w = 25; 
    c = chamfer_size;

    // --- Coordinates ---
    x_left_tip = -jaw_depth + c;     
    x0 = 0 + c;                      
    x1 = t - c;                      
    x2 = x1 + hook_base_internal + 2*c; 
    x3 = x2 + t - 2*c;               

    z_desk_top = 0 + c;              
    z_top_outer = t - c;             
    
    z_desk_bot = -desk_thickness - c;
    z_bot_outer = z_desk_bot - t + 2*c; 
    
    z_lip_top = z_bot_outer + t + hook_lip_internal - 2*c;

    y_min = c;
    y_max = w - c;

    // Total height of the main clamp body
    total_clamp_height = z_top_outer - z_bot_outer + 2*c;

    module profile_segment(points, custom_width = w) {
        y_max_custom = custom_width - c;
        hull() {
            for (p = points) {
                translate([p[0], y_min, p[1]]) sphere(r = c);
                translate([p[0], y_max_custom, p[1]]) sphere(r = c);
            }
        }
    }

    // 1. TOP JAW (Laua peal)
    profile_segment([[x_left_tip, z_desk_top], [x1, z_desk_top], 
                     [x_left_tip, z_top_outer], [x1, z_top_outer]]);

    // 2. BACK WALL (Selg)
    profile_segment([[x0, z_desk_top], [x1, z_desk_top], 
                     [x0, z_desk_bot], [x1, z_desk_bot]]);

    // 3. BOTTOM BASE (Laua all)
    profile_segment([[x_left_tip, z_desk_bot], [x1, z_desk_bot], 
                     [x_left_tip, z_bot_outer], [x1, z_bot_outer]]);

    // 4. HOOK ASSEMBLY (Standard or 90-degree rotated over X-axis)
    if (rotate_hook_90_x) {
        translate([0, z_bot_outer + w - c, z_bot_outer - c])
            rotate([90, 0, 0]) {
                profile_segment([[x1, z_desk_bot], [x3, z_desk_bot], 
                                 [x1, z_bot_outer], [x3, z_bot_outer]], 
                                custom_width = total_clamp_height);
                profile_segment([[x2, z_desk_bot], [x3, z_desk_bot], 
                                 [x2, z_lip_top], [x3, z_lip_top]], 
                                custom_width = total_clamp_height);
            }
    } else {
        profile_segment([[x1, z_desk_bot], [x3, z_desk_bot], 
                         [x1, z_bot_outer], [x3, z_bot_outer]]);
        profile_segment([[x2, z_desk_bot], [x3, z_desk_bot], 
                         [x2, z_lip_top], [x3, z_lip_top]]);
    }
}

// Render
desk_headphone_hook();