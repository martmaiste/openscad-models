// =========================================================================
// Frameless Solar Panel Gap Cover - Single Symmetric Half Design
// Version: 0.56
// =========================================================================

/* [Global Dimensions] */
panel_thickness = 3.6;   // Thickness of frameless panels (mm)
gap_width       = 10.0;  // Gap between panels (mm)
//total_length    = 518.0; // Total assembled cover cap length (mm)
total_length    = 530.0; // Total assembled cover cap length (mm)
cover_width     = 20.0;  // Width of top cap (mm)
top_thickness   = 2.0;   // Thickness of top cap (mm)

/* [Segmented Clips Settings] */
clip_segment_length = 5.0; // Length of individual snap bumps/barbs (mm)
clip_pitch          = 50.0; // Spacing pitch between clip bumps along the cap (mm)

/* [Channel End] */
closed_channel_end = false; // Close the open channel end (Z=0 joint face) with a wall (thickness = wall_thickness)

/* [Interlock Settings] */
enable_interlock    = true; // Enable the half-circle tab/cavity that aligns the two halves at the joint
interlock_radius    = 0.8;  // Radius of the mating half-circle tab at the joint (mm)
interlock_tolerance = 0.2;  // Clearance for the interlock cavity (mm)

/* [Uniform Chamfer Control] */
chamfer_size    = 1.0;   // Global uniform chamfer size applied to cap, tab edges, and lead-ins (mm)

/* [Clip Dimensions] */
wall_thickness  = 1.6;   // Wall thickness for clip legs/channel walls (mm)
snap_barb_size  = 0.8;   // Half-circle bump overhang radius (mm)
clip_inset      = 0.3;   // Distance to move clips inward to reduce protrusion, easing installation (mm)

/* [End Clearances (Washer/Strut Extensions)] */
end_extension_length = 3.0;                    // Length of separate/integrated extension tabs (mm)
extension_thickness  = panel_thickness - 1.0;   // Extension thickness is 1mm thinner than the solar panel (2.6mm)

/* [Render Selection] */
part_to_render = "single_half"; // [assembly: Full Assembly (2x Unified Halves), single_half: Single Unified Half (To Print)]

// =========================================================================
// CALCULATED CONSTANTS
// =========================================================================
half_cap_length = total_length / 2; // 260mm top cap length per unit

// Wall depth is extended so the clip sits entirely below the solar panel
channel_depth = panel_thickness + (snap_barb_size * 2); 

// =========================================================================
// MAIN RENDER SWITCH
// =========================================================================
if (part_to_render == "assembly") {
    // Upper Half: Placed from Z = 0 to Z = 260mm (extension points upward to +Z)
    color("SteelBlue") 
        cover_half();
    
    // Lower Half: Rotated 180° around Y-axis & translated to Z = 0 (extension points downward to -Z)
    // Placed from Z = 0 to Z = -260mm, mating smoothly with upper half exactly at Z = 0
    color("LightSlateGray") 
        translate([0, 0, 0])
            rotate([0, 180, 0])
                cover_half();

} else if (part_to_render == "single_half") {
    cover_half();

}

// =========================================================================
// MODULES
// =========================================================================

// Unified Symmetric Half Module (Print 2 identical copies for 1 full assembly)
module cover_half() {
    difference() {
        union() {
            // 1. Continuous Top Cover Cap Profile
            linear_extrude(height = half_cap_length) {
                top_cap_2d_profile();
            }
            
            // 2. Continuous Straight Channel Walls
            linear_extrude(height = half_cap_length) {
                continuous_channel_2d_profile();
            }
            
            // 3. Distributed Interval Snap Bumps
            segmented_snap_bumps(half_cap_length);
            
            // 4. Solid Structural Fill Block (~10mm) between channel walls near top end
            translate([0, 0, half_cap_length - 10.0]) {
                linear_extrude(height = 10.0) {
                    solid_channel_fill_2d();
                }
            }
            
            // 4b. Optional end wall closing the open channel end at the Z=0 joint
            if (closed_channel_end) {
                linear_extrude(height = wall_thickness) {
                    solid_channel_fill_2d();
                }
            }
            
            // 5. End Extension Tab extending outward from the far end
            translate([0, 0, half_cap_length]) {
                end_extension();
            }
            
            // 6. Interlocking Horizontal Tab (Left channel wall, Z=0 face)
            // Oriented along X-axis inside the wall to lock Y-axis
            if (enable_interlock) {
                translate([-gap_width/2, -channel_depth/2, 0])
                    rotate([0, 90, 0])
                        cylinder(h=wall_thickness, r=interlock_radius, $fn=30);
            }
        }
        
        // Interlocking Horizontal Cavity Cutout (Right channel wall, Z=0 face)
        // Creates a pocket inside the right wall's Z>0 body to receive the other half's tab
        if (enable_interlock) {
            translate([gap_width/2 - wall_thickness - 0.1, -channel_depth/2, 0])
                rotate([0, 90, 0])
                    cylinder(h=wall_thickness + 0.2, r=interlock_radius + interlock_tolerance, $fn=30);
        }
    }
}

// Extension Tab Module at top end of half (reaches outer end of extension)
module end_extension() {
    c = chamfer_size;
    L = end_extension_length;

    union() {
        // 1. Full Extension Body extending to Z = L - c
        linear_extrude(height = L - c) {
            extension_chamfered_2d();
        }

        // 2. Outer Tip Chamfer at very end of extension
        translate([0, 0, L - c]) {
            hull() {
                linear_extrude(height = 0.01) {
                    extension_chamfered_2d();
                }
                translate([0, 0, c]) {
                    linear_extrude(height = 0.01) {
                        offset(delta = -c, chamfer = true) {
                            extension_chamfered_2d();
                        }
                    }
                }
            }
        }
    }
}

// Module to distribute 10mm half-circle snap bumps evenly every 50mm pitch
module segmented_snap_bumps(length) {
    start_offset = clip_pitch / 2;
    
    for (z = [start_offset : clip_pitch : length - (clip_segment_length / 2)]) {
        translate([0, 0, z - (clip_segment_length / 2)])
            linear_extrude(height = clip_segment_length) {
                clip_bumps_2d_profile();
            }
    }
}

// 2D Extension Profile (Centered in the solar panel thickness)
module extension_raw_2d() {
    leg_x_outer = gap_width / 2;
    translate([-leg_x_outer, -panel_thickness/2 - extension_thickness/2])
        square([gap_width, extension_thickness]);
}

// 2D Extension Profile with Uniform Edge Chamfers
module extension_chamfered_2d() {
    offset(delta = chamfer_size, chamfer = true)
        offset(delta = -chamfer_size, chamfer = true)
            extension_raw_2d();
}

// 2D Profile for Top Cap with Uniform Chamfers
module top_cap_2d_profile() {
    c = chamfer_size;
    polygon(points = [
        [-cover_width/2 + c, top_thickness],
        [ cover_width/2 - c, top_thickness],
        [ cover_width/2,     top_thickness - c],
        [ cover_width/2,     0],
        [-cover_width/2,     0],
        [-cover_width/2,     top_thickness - c]
    ]);
}

// 2D Profile for Continuous Channel Legs (Straight Walls)
module continuous_channel_2d_profile() {
    leg_x_outer = gap_width / 2;
    leg_x_inner = leg_x_outer - wall_thickness;
    
    union() {
        // Left Wall
        polygon(points = [
            [-leg_x_outer, 0],
            [-leg_x_inner, 0],
            [-leg_x_inner, -channel_depth],
            [-leg_x_outer, -channel_depth]
        ]);
        
        // Right Wall
        polygon(points = [
            [leg_x_outer, 0],
            [leg_x_inner, 0],
            [leg_x_inner, -channel_depth],
            [leg_x_outer, -channel_depth]
        ]);
    }
}

// 2D Solid Fill Profile for the Gap Between Channel Legs
module solid_channel_fill_2d() {
    leg_x_outer = gap_width / 2;
    translate([-leg_x_outer, -channel_depth])
        square([gap_width, channel_depth]);
}

// 2D Profile for Smooth Half-Circle Retention Bumps (Only added at intervals)
module clip_bumps_2d_profile() {
    leg_x_outer = gap_width / 2;
    r = snap_barb_size;
    
    // Position bump so its absolute highest point is exactly at the bottom of the panel
    center_y = -panel_thickness - r;
    
    union() {
        // Left Leg Half-Circle Snap Bump (Moved inward by clip_inset)
        translate([-leg_x_outer + clip_inset, center_y])
            difference() {
                circle(r = r, $fn = 30);
                translate([0, -r * 2])
                    square([r * 2, r * 4]);
            }
        
        // Right Leg Half-Circle Snap Bump (Moved inward by clip_inset)
        translate([leg_x_outer - clip_inset, center_y])
            difference() {
                circle(r = r, $fn = 30);
                translate([-r * 2, -r * 2])
                    square([r * 2, r * 4]);
            }
    }
}