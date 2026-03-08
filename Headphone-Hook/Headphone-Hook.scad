/*
 * Headphone Hook for 40x40 Square Tube
 * Version: 0.14
 * Description: Chain-hull method to preserve right-angle internal clearance 
 * while ensuring zero gaps or grooves between parts.
 */

// --- Parameters ---
tube_size = 40;            
bracket_depth = 25;        
material_thickness = 10;   

left_side_internal = 20;   
hook_base_internal = 25;   
hook_lip_internal = 12.5;  

chamfer_size = 2;          
$fn = 24;                  

// Helper module: Creates a chamfered segment between two boxes
// This ensures that the transition is a single solid mass.
module connected_segment(p1, p2, size1, size2) {
    c = chamfer_size;
    hull() {
        // Box 1 corners
        for(x=[p1.x+c, p1.x+size1.x-c], y=[p1.y+c, p1.y+size1.y-c], z=[p1.z+c, p1.z+size1.z-c])
            translate([x,y,z]) sphere(r=c);
        // Box 2 corners
        for(x=[p2.x+c, p2.x+size2.x-c], y=[p2.y+c, p2.y+size2.y-c], z=[p2.z+c, p2.z+size2.z-c])
            translate([x,y,z]) sphere(r=c);
    }
}

module headphone_hook() {
    t = material_thickness;
    w = bracket_depth;
    
    // Coordinates for exact internal clearance
    x_left = 0;
    x_tube_start = t;
    x_tube_end = t + tube_size;
    x_hook_start = x_tube_end + t;
    x_hook_end = x_hook_start + hook_base_internal;
    x_total = x_hook_end + t;

    z_top = 0;
    z_top_in = -t;
    z_left_bot = z_top_in - left_side_internal;
    z_right_bot = z_top_in - tube_size;
    z_lip_top = z_right_bot + t + hook_lip_internal;

    // --- Piece by Piece Construction with Overlap Hulling ---
    
    // 1. Top Plate (main connector)
    connected_segment([x_left, 0, z_top_in], [x_left, 0, z_top_in], 
                      [x_hook_start, w, t], [x_hook_start, w, t]);

    // 2. Left Wall -> Top Plate (Hulled together to bridge the gap)
    connected_segment([x_left, 0, z_left_bot], [x_left, 0, z_top_in],
                      [t, w, left_side_internal], [t, w, t]);

    // 3. Right Wall -> Top Plate
    connected_segment([x_tube_end, 0, z_right_bot], [x_tube_end, 0, z_top_in],
                      [t, w, tube_size], [t, w, t]);

    // 4. Hook Base -> Right Wall
    connected_segment([x_tube_end, 0, z_right_bot], [x_hook_start, 0, z_right_bot],
                      [t, w, t], [hook_base_internal + t, w, t]);

    // 5. Hook Lip -> Hook Base
    connected_segment([x_hook_end, 0, z_right_bot], [x_hook_end, 0, z_right_bot],
                      [t, w, t + hook_lip_internal], [t, w, t + hook_lip_internal]);
}

headphone_hook();