// Sushi Roll Cutting Guide
// Version: 0.08

/* [General Dimensions] */
// Total length of the sushi roll (mm)
roll_length = 250; 
// Width of each sushi piece (mm)
piece_width = 20;
// Diameter of the sushi roll (mm)
roll_diameter = 40; 

/* [Cradle Settings] */
// Thickness of the bottom base (mm)
bottom_thickness = 10; 
// Extra height above the sushi roll to guide the knife before contact (mm)
guide_clearance = 5;
// Thickness of the side walls (mm)
wall_thickness = 5;
// Radius of edge rounding (mm)
edge_radius = 2;

/* [Cutting Slots] */
// Standard width of the knife slot in the middle section (mm)
slot_width = 2; 
// Width of the slot at the very bottom (mm)
bottom_slot_width = 1;
// How much wider the top opening is
top_guide_extra_width = 2;
// Extra depth for the knife to cut into the bottom (to ensure clean cut)
cut_depth_clearance = 1; 

/* [Hidden] */
$fn = 120; 
num_pieces = floor(roll_length / piece_width);
total_cut_span = (num_pieces - 1) * piece_width;
start_offset = (roll_length - total_cut_span) / 2;

module sushi_cutter() {
    total_width = roll_diameter + (2 * wall_thickness);
    // Height ensures the wall guides the knife before it hits the top of the roll
    total_height = bottom_thickness + roll_diameter + guide_clearance;
    
    base_w = total_width - (2 * edge_radius);
    base_l = roll_length - (2 * edge_radius);
    base_h = total_height - (2 * edge_radius);

    slot_start_z = bottom_thickness - cut_depth_clearance;
    slot_total_h = (total_height - slot_start_z) + 2; 
    
    difference() {
        // 1. Main Body
        translate([-(total_width/2) + edge_radius, edge_radius, edge_radius])
        minkowski() {
            cube([base_w, base_l, base_h]);
            sphere(r=edge_radius);
        }

        // 2. The Sushi Cradle (Cylinder cutout)
        translate([0, -1, bottom_thickness + (roll_diameter/2)])
        rotate([-90, 0, 0])
        cylinder(d=roll_diameter, h=roll_length + 2);

        // 3. Top Trimming (Opening for the sushi and knife)
        translate([-(roll_diameter/2), -1, bottom_thickness + (roll_diameter/2)])
        cube([roll_diameter, roll_length + 2, total_height]);

        // 4. Symmetrical Vertical Tapered Cutting Slots
        for (i = [0 : num_pieces - 1]) {
            translate([
                -(total_width/2) - 1, 
                start_offset + (i * piece_width), 
                slot_start_z
            ])
            rotate([90, 0, 90]) 
            linear_extrude(height = total_width + 2)
            knife_slot_profile(slot_total_h);
        }
    }
}

module knife_slot_profile(h) {
    w_mid = slot_width / 2;
    w_bot = bottom_slot_width / 2;
    w_top = (slot_width + top_guide_extra_width) / 2;
    
    h_bot_taper = h * 0.2;
    h_top_taper = h * 0.8; 
    
    polygon(points=[
        [-w_bot, 0],
        [-w_mid, h_bot_taper],
        [-w_mid, h_top_taper],
        [-w_top, h],
        [w_top, h],
        [w_mid, h_top_taper],
        [w_mid, h_bot_taper],
        [w_bot, 0]
    ]);
}

sushi_cutter();