/*
 * Headphone Hook for Desk Edge (C-Clamp style)
 * Version: 0.23
 * Description: Final coordinate fix. 
 * Corrected: Wall thickness (10mm), Desk gap (16.5mm), Hook gap (25mm).
 */

// --- Parameters ---
desk_thickness = 16.5;     
jaw_depth = 25;            
material_thickness = 10;   

hook_base_internal = 25;   
hook_lip_internal = 12.5;  

chamfer_size = 2;          
$fn = 32;                  

module desk_headphone_hook_v0_23() {
    t = material_thickness;
    w = 25; 
    c = chamfer_size;

    // --- X-Coordinates (Calculated from internal gap) ---
    // Sisevahe x1 ja x2 vahel on 25mm.
    x_left_tip = -jaw_depth + c;     
    x0 = 0 + c;                      // Selja sisekülg
    x1 = t - c;                      // Selja väliskülg
    x2 = x1 + hook_base_internal + 2*c; // Konksu lõpp (tsentrite vahe 25+2c)
    x3 = x2 + t - 2*c;               // Huule väliskülg

    // --- Z-Coordinates (Calculated from internal gap) ---
    // Sisevahe z_desk_top ja z_desk_bot vahel on 16.5mm.
    z_desk_top = 0 + c;              
    z_top_outer = t - c;             // Ülemise plaadi välispind (10mm paksus)
    
    z_desk_bot = -desk_thickness - c;
    z_bot_outer = z_desk_bot - t + 2*c; // Alumise plaadi välispind (10mm paksus)
    
    z_lip_top = z_bot_outer + t + hook_lip_internal - 2*c;

    // Y-axis (Depth)
    y_min = c;
    y_max = w - c;

    module profile_segment(points) {
        hull() {
            for (p = points) {
                translate([p[0], y_min, p[1]]) sphere(r = c);
                translate([p[0], y_max, p[1]]) sphere(r = c);
            }
        }
    }

    // --- CONSTRUCTION ---
    
    // 1. TOP JAW (Laua peal) - Paksus: z_top_outer - z_desk_top + 2c = 10mm
    profile_segment([[x_left_tip, z_desk_top], [x1, z_desk_top], 
                     [x_left_tip, z_top_outer], [x1, z_top_outer]]);

    // 2. BACK WALL (Selg) - Paksus: x1 - x0 + 2c = 10mm
    profile_segment([[x0, z_desk_top], [x1, z_desk_top], 
                     [x0, z_desk_bot], [x1, z_desk_bot]]);

    // 3. BOTTOM BASE (Laua all + Konks) - Paksus: z_desk_bot - z_bot_outer + 2c = 10mm
    profile_segment([[x_left_tip, z_desk_bot], [x3, z_desk_bot], 
                     [x_left_tip, z_bot_outer], [x3, z_bot_outer]]);

    // 4. HOOK LIP (Konksu ots)
    profile_segment([[x2, z_desk_bot], [x3, z_desk_bot], 
                     [x2, z_lip_top], [x3, z_lip_top]]);
}

// Render
desk_headphone_hook_v0_23();