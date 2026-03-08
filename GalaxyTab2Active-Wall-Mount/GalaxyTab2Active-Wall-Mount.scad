// =========================================================
// GALAXY TAB 2 ACTIVE WALL MOUNT - FULLY COMMENTED
// =========================================================

// --- 1. PHYSICAL TABLET DIMENSIONS ---
tab_w = 215;         // Real width of Galaxy Tab 2 Active (Landscape)
tab_h = 128;         // Real height of tablet
tab_d = 10.5;        // Thickness of tablet body

// --- 2. ENCLOSURE GEOMETRY & TOLERANCES ---
base_plate_t    = 3;    // Thickness of the floor attached to the wall
wall_t          = 3;    // Thickness of the outer lid shell
clip_t          = 5;    // Internal clip width holding the tablet in place
lip_size        = 6;    // Screen overlap (bezel cover) on the lid
clearance       = 1.0;  // Extra wiggle room inside the shell for the tablet
lid_gap         = 0.2;  // Precision gap between base and lid for a snug fit
rounding_r      = 10;   // Main corner radius for the whole enclosure
edge_smoothness = 2.0;  // Radius of the comfort bevel on the front of the lid
viewport_r      = 4;    // Internal corner radius of the screen cutout

// --- 3. CABLE ROUTING SETTINGS ---
cable_groove_w     = 10;   // Width of the exit channel for the charging lead
cable_groove_depth = 1;    // Depth cut into the 3mm floor (leaves 2mm solid)

// --- 4. HARDWARE & MOUNTING SPECS ---
base_screw_hole = 4.2;  // Hole size for M3 Brass Heat-Set Inserts
lid_screw_hole  = 3.4;  // Clearance hole for M3 screw shank
head_diam       = 6.5;  // M3 Countersink head diameter
hole_edge_dist  = 6;    // Distance from the outer edge to screw center
pillar_size     = 14;   // Size of the corner pillars holding the lid screws
chamfer_inner   = 10;   // Interior relief to clear tablet corners
chamfer_outer   = 1;    // Leading edge chamfer to help the lid slide on

mount_hole_d    = 4.5;  // Wall screw shank diameter
mount_head_d    = 9.0;  // Wall screw head diameter (countersink)
mount_inset     = 25;   // Wall mounting holes distance from corners

// --- 5. PINHOLE CONFIGURATION (TOP-LEFT FOCUS) ---
enable_pinhole     = 1;     // Set to 0 to remove the pinhole entirely
pinhole_dia        = 1.5;   // 1.5mm fits a standard paperclip
pin_on_short_side  = false; // Set to true for Left/Right sides | false for Top/Bottom
pin_corner         = [0, 1]; // [0,1] refers to the Top-Left corner of the tablet
pin_offset_dist    = 40;    // Measurement from top-left corner toward the right
pin_z_height       = 5.25;  // Height from back of tablet (usually tab_d / 2)

// --- 6. DERIVED CALCULATIONS (INTERNAL LOGIC) ---
inner_w = tab_w + clearance;
inner_h = tab_h + clearance;
outer_w = inner_w + (clip_t * 2);
outer_h = inner_h + (clip_t * 2);
total_depth = base_plate_t + tab_d; 

// External footprint of the front cover (lid)
l_ext_w = outer_w + lid_gap + (wall_t * 2);
l_ext_h = outer_h + lid_gap + (wall_t * 2);

// Offset Anchor: Locates the exact [0,0] corner of the tablet inside the enclosure
origin_off_x = wall_t + lid_gap/2 + clip_t + clearance/2;
origin_off_y = wall_t + lid_gap/2 + clip_t + clearance/2;

// Calculate Absolute X: Adds offset to the origin anchor
calc_pin_x = (pin_on_short_side) ? 
    ((pin_corner[0] == 0) ? wall_t/2 : l_ext_w - wall_t/2) : 
    ((pin_corner[0] == 0) ? origin_off_x + pin_offset_dist : origin_off_x + tab_w - pin_offset_dist);

// Calculate Absolute Y: Determines if the hole is on the top or bottom wall
calc_pin_y = (pin_on_short_side) ? 
    ((pin_corner[1] == 0) ? origin_off_y + pin_offset_dist : origin_off_y + tab_h - pin_offset_dist) : 
    ((pin_corner[1] == 1) ? l_ext_h - wall_t/2 : wall_t/2);

calc_pin_z = base_plate_t + pin_z_height;

// --- 7. UTILITY MODULES ---

// Creates a 3D block with rounded corners via hull() of 4 cylinders
module rounded_rect(w, h, r, z) {
    linear_extrude(height = z)
    hull() {
        translate([r, r]) circle(r = r, $fn=64);
        translate([w-r, r]) circle(r = r, $fn=64);
        translate([r, h-r]) circle(r = r, $fn=64);
        translate([w-r, h-r]) circle(r = r, $fn=64);
    }
}

// Internal clips that hold the tablet against the base floor
module oriented_clip(pos, size, dir, h, lip, c_out) {
    translate([pos[0], pos[1], base_plate_t])
    difference() {
        union() {
            cube([size[0], size[1], h]); 
            // The "lip" that catches the edge of the tablet
            translate([0, 0, h - 1.5]) 
            hull() {
                cube([size[0], size[1], 1.5]);
                translate([dir[0]*lip, dir[1]*lip, 0.5]) 
                    cube([size[0], size[1], 0.5]);
            }
        }
        // Angled relief to make sliding the lid on easier
        if (c_out > 0) {
            translate([-dir[0]*size[0], -dir[1]*size[1], h - c_out])
            rotate([dir[1]*45, -dir[0]*45, 0])
            translate([-size[0], -size[1], 0])
                cube([size[0]*4, size[1]*4, c_out*2]);
        }
    }
}

// 2D shape for the corner pillars (includes inner chamfer for tablet clearance)
module chamfered_pillar_shape(s, c) {
    polygon(points=[[0,0], [s,0], [s, s-c], [s-c, s], [0,s]]);
}

// --- 8. BASE COMPONENT ---
module base() {
    difference() {
        union() {
            // Main floor plate
            rounded_rect(outer_w, outer_h, rounding_r, base_plate_t);
            
            // Corner Pillars assembly
            intersection() {
                hull() {
                    rounded_rect(outer_w, outer_h, rounding_r, total_depth - chamfer_outer);
                    translate([chamfer_outer, chamfer_outer, total_depth - 0.1])
                        rounded_rect(outer_w - chamfer_outer*2, outer_h - chamfer_outer*2, max(0.1, rounding_r - chamfer_outer), 0.1);
                }
                union() {
                    translate([0,0,0]) linear_extrude(total_depth) chamfered_pillar_shape(pillar_size, chamfer_inner);
                    translate([outer_w, 0, 0]) mirror([1,0,0]) linear_extrude(total_depth) chamfered_pillar_shape(pillar_size, chamfer_inner);
                    translate([0, outer_h, 0]) mirror([0,1,0]) linear_extrude(total_depth) chamfered_pillar_shape(pillar_size, chamfer_inner);
                    translate([outer_w, outer_h, 0]) mirror([1,1,0]) linear_extrude(total_depth) chamfered_pillar_shape(pillar_size, chamfer_inner);
                }
            }
            // Array of tablet clips
            c_len = 18; c_off_s = 30; c_off_tb = 21;
            oriented_clip([0, c_off_s], [clip_t, c_len], [1, 0], tab_d, 1.2, chamfer_outer);
            oriented_clip([0, outer_h - c_off_s - c_len], [clip_t, c_len], [1, 0], tab_d, 1.2, chamfer_outer);
            oriented_clip([outer_w - clip_t, c_off_s], [clip_t, c_len], [-1, 0], tab_d, 1.2, chamfer_outer);
            oriented_clip([outer_w - clip_t, outer_h - c_off_s - c_len], [clip_t, c_len], [-1, 0], tab_d, 1.2, chamfer_outer);
            oriented_clip([c_off_tb, 0], [c_len, clip_t], [0, 1], tab_d, 1.2, chamfer_outer);
            oriented_clip([outer_w - c_off_tb - c_len, 0], [c_len, clip_t], [0, 1], tab_d, 1.2, chamfer_outer);
            oriented_clip([c_off_tb, outer_h - clip_t], [c_len, clip_t], [0, -1], tab_d, 1.2, chamfer_outer);
            oriented_clip([outer_w - c_off_tb - c_len, outer_h - clip_t], [c_len, clip_t], [0, -1], tab_d, 1.2, chamfer_outer);
        }
        
        // Large center cutout for cooling and wire access
        opening_w = outer_w * 0.6; opening_h = outer_h * 0.6;
        translate([(outer_w - opening_w)/2, (outer_h - opening_h)/2, -1]) 
            rounded_rect(opening_w, opening_h, 5, base_plate_t + 2);
        
        // Assembly screw holes for the Heat-Set Inserts
        for(x = [hole_edge_dist, outer_w - hole_edge_dist]) for(y = [hole_edge_dist, outer_h - hole_edge_dist])
            translate([x, y, -1]) cylinder(d=base_screw_hole, h=total_depth + 2, $fn=32);
        
        // Wall Mounting screw holes (countersunk)
        for(mx = [mount_inset, outer_w - mount_inset]) for(my = [mount_inset, outer_h - mount_inset]) {
            translate([mx, my, -1]) cylinder(d=mount_hole_d, h=base_plate_t + 2, $fn=32);
            translate([mx, my, base_plate_t - 1.5]) cylinder(d1=mount_hole_d, d2=mount_head_d, h=2, $fn=32);
        }

        // Parametric Cable Groove subtraction
        translate([-1, outer_h/2 - cable_groove_w/2, base_plate_t - cable_groove_depth]) 
            cube([outer_w + 2, cable_groove_w, cable_groove_depth + 1]);
    }
}

// --- 9. LID COMPONENT ---
module lid() {
    lid_hole_x = hole_edge_dist + wall_t + lid_gap/2;
    lid_hole_y = hole_edge_dist + wall_t + lid_gap/2;
    v_w = inner_w - (lip_size*2); v_h = inner_h - (lip_size*2);
    v_x = wall_t + clip_t + lid_gap/2 + lip_size;
    v_y = wall_t + clip_t + lid_gap/2 + lip_size;

    difference() {
        // Outer shell beveled hull
        hull() {
            rounded_rect(l_ext_w, l_ext_h, rounding_r + wall_t, 0.1);
            translate([0, 0, total_depth + wall_t - edge_smoothness]) 
                rounded_rect(l_ext_w, l_ext_h, rounding_r + wall_t, 0.1);
            translate([edge_smoothness, edge_smoothness, total_depth + wall_t]) 
                rounded_rect(l_ext_w - edge_smoothness*2, l_ext_h - edge_smoothness*2, max(0.1, rounding_r + wall_t - edge_smoothness), 0.1);
        }
        
        // Hollow center for the base plate assembly
        translate([wall_t, wall_t, -1]) 
            rounded_rect(outer_w + lid_gap, outer_h + lid_gap, rounding_r + lid_gap/2, total_depth + 1.1); 
        
        // Viewport window with beveled edges
        hull() {
            translate([v_x, v_y, total_depth + wall_t - 0.2]) rounded_rect(v_w, v_h, viewport_r, 0.5);
            translate([v_x + edge_smoothness, v_y + edge_smoothness, total_depth - 0.5]) rounded_rect(v_w - edge_smoothness*2, v_h - edge_smoothness*2, max(0.1, viewport_r - edge_smoothness), 0.5);
        }
        translate([v_x + edge_smoothness, v_y + edge_smoothness, total_depth - 2]) rounded_rect(v_w - edge_smoothness*2, v_h - edge_smoothness*2, max(0.1, viewport_r - edge_smoothness), wall_t + 3);

        // Subtraction for the Pinhole Access
        if (enable_pinhole == 1) {
            translate([calc_pin_x, calc_pin_y, calc_pin_z])
            rotate([(pin_on_short_side ? 0 : 90), (pin_on_short_side ? 90 : 0), 0])
            cylinder(d=pinhole_dia, h=40, center=true, $fn=24);
        }

        // Lid screw holes and countersinks
        for(x = [lid_hole_x, l_ext_w - lid_hole_x]) for(y = [lid_hole_y, l_ext_h - lid_hole_y]) {
            translate([x, y, -1]) cylinder(d=lid_screw_hole, h=total_depth + wall_t + 2, $fn=32);
            translate([x, y, total_depth + wall_t - 2.5]) cylinder(d1=lid_screw_hole, d2=head_diam, h=3, $fn=32);
        }
    }
}

// --- 10. FINAL ASSEMBLY RENDER ---
base();
translate([0, outer_h + 30, 0]) lid();