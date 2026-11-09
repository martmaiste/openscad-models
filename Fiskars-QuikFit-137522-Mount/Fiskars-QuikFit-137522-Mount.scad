// Lawnmower Handlebar Holder for Fiskars QuikFit (e.g., Weed Extractor 137522 / 1000731)
// Product Link: https://cuix-prod.fiskars.com/sv-se/tradgardsarbete/produkter/planteringsredskap/quikfit-ograsupptagare-1000731
// Version: 0.25
// Features: Added product URL to comment header documentation

/* [Render Selection] */
part = "print_bed"; // [print_bed: Both Parts Placed for Printing, assembly: Complete Mounted View, main_body: Main Holder (Top Clamp + Full Socket), clamp_cap: Lower Clamp Cap]

/* [Handlebar Pipe Parameters] */
pipe_diameter = 19.0;        // Handlebar diameter (mm)
clamp_length = 42.0;         // Length along handlebar pipe (X-axis)
clamp_width = 50.0;          // Total flange width across pipe (Y-axis)
clamp_wall = 5.0;            // Minimum wall thickness around pipe
clamp_gap = 1.0;             // Gap between halves for clamping compression (0.5mm trimmed per half)
corner_radius = 4.0;         // Corner rounding for clamp block

/* [Tool Socket Parameters] */
quikfit_diameter = 28.0;     // Male shank collar outer diameter (+ clearance)
bottom_ring_diameter = 17.0; // Inner diameter of the lower tool stem ring
stem_slot_width = bottom_ring_diameter; // Matched slot width for smooth side entry (17.0mm)

block_height = 30.0;         // Uniform total height for both clamp and tool socket
holder_wall = 4.5;           // Wall thickness of tool socket
collar_shelf_depth = block_height - 10; // Depth from top surface to internal collar stop shelf (20.0mm)
center_distance = 46.0;      // Distance from pipe center to tool socket center

/* [Fastener Parameters (2x M5x25mm Bolts)] */
bolt_hole_d = 5.3;           // M5 bolt pass-through clearance diameter
nut_d = 8.8;                 // M5 nut width across flats (+ clearance)
nut_depth = 6.0;             // Recess depth for hex nuts
cbore_depth = 6.0;           // Recess depth for bolt heads
bolt_offset_y = 17.5;        // Distance from pipe center across width (Y-axis)
sacrificial_layer = 0.3;     // 1-2 print layer thick membrane over bolt holes for clean bridging

/* [Calculated Dimensions] */
shelf_z = (block_height / 2) - collar_shelf_depth;        // Z height of shelf (-5.0mm)
slot_depth = quikfit_diameter/2 + holder_wall + 10.0;     // Depth to ensure slot starts at center and clears front wall
split_y = clamp_width / 2;                                // Y boundary separating clamp block from tool socket (25.0mm)
flare_h = (quikfit_diameter - bottom_ring_diameter) / 2;  // 45-degree self-supporting chamfer height (5.5mm)

$fn = 100;

// Render Control
if (part == "assembly") {
    main_body();
    clamp_cap();
} else if (part == "main_body") {
    main_body();
} else if (part == "clamp_cap") {
    clamp_cap();
} else if (part == "print_bed") {
    // Both parts oriented flat on build plate (Z=0) separated along X-axis
    // main_body: Top flat face resting on print bed
    translate([0, 0, block_height/2]) rotate([180, 0, 0]) main_body();
    
    // clamp_cap: Outer flat bottom face on bed (Z=0), rotated 180 degrees on the print bed plane
    translate([clamp_length + 10, 0, block_height/2]) rotate([0, 0, 180]) clamp_cap();
}

// --- HELPER MODULES ---

module rounded_block(l, w, h, r) {
    hull() {
        for(x = [-(l/2 - r), l/2 - r]) {
            for(y = [-(w/2 - r), w/2 - r]) {
                translate([x, y, 0]) cylinder(r=r, h=h, center=true, $fn=60);
            }
        }
    }
}

module unified_solid(h) {
    hull() {
        // Main pipe clamp block with flanges for bolts
        rounded_block(clamp_length, clamp_width, h, corner_radius);
        
        // Vertical tool socket cylinder body
        translate([0, center_distance, 0])
            cylinder(d = quikfit_diameter + (holder_wall * 2), h = h, center = true);
    }
}

// Domain box defining lower half of clamp block (Z < 0 and Y <= split_y)
module lower_clamp_domain() {
    translate([-100, -100, -block_height])
        cube([200, 100 + split_y, block_height]);
}

// Clamping relief gap slice restricted ONLY to the clamp domain (Y <= split_y)
module clamp_gap_cut() {
    translate([0, split_y/2 - 50, 0])
        cube([clamp_length + 2, split_y + 100, clamp_gap], center = true);
}

// --- MAIN PARTS ---

// Main Detail: Full Tool Socket Body + Upper Clamp Half
module main_body() {
    difference() {
        // Unified solid minus lower clamp domain
        difference() {
            unified_solid(block_height);
            lower_clamp_domain();
        }

        // 1. Upper Half of Handlebar Bore
        rotate([0, 90, 0])
            cylinder(d = pipe_diameter, h = clamp_length + 2, center = true);

        // 2. Clamping Relief Gap (Shaves 0.5mm off bottom face of upper clamp only)
        clamp_gap_cut();

        // 3. 2x Bolt Holes with Counterbored Seats & Sacrificial Floors
        for (y = [-bolt_offset_y, bolt_offset_y]) {
            translate([0, y, 0]) {
                difference() {
                    union() {
                        cylinder(d = bolt_hole_d, h = block_height * 2, center = true);
                        
                        translate([0, 0, block_height/2 - cbore_depth])
                            cylinder(d = bolt_hole_d + 4.5, h = cbore_depth + 0.1, center = false);
                    }
                    // Sacrificial bridging membrane left at counterbore shoulder
                    translate([0, 0, block_height/2 - cbore_depth])
                        cylinder(d = bolt_hole_d + 4.6, h = sacrificial_layer, center = false);
                }
            }
        }

        // 4. Upper QuikFit Shank Collar Pocket (28.0mm diameter down to shelf at -5mm)
        translate([0, center_distance, (block_height/2 + shelf_z)/2])
            cylinder(d = quikfit_diameter, h = collar_shelf_depth + 0.01, center = true);

        // 5. Matched Bottom Ring Bore (17.0mm)
        translate([0, center_distance, 0])
            cylinder(d = bottom_ring_diameter, h = block_height + 2, center = true);

        // 6. Matched Front Insertion Slot (Starts exactly at Y = center_distance)
        translate([0, center_distance + slot_depth/2, 0])
            cube([stem_slot_width, slot_depth, block_height + 2], center = true);

        // 7. 45-Degree Self-Supporting Chamfer Transition (Funnel down from 28.0mm to 17.0mm)
        translate([0, center_distance, shelf_z - flare_h])
            cylinder(d1 = bottom_ring_diameter, d2 = quikfit_diameter, h = flare_h + 0.01, center = false);

        // 8. Beveled Lead-in at Top of Tool Socket
        translate([0, center_distance, block_height/2 - 2])
            cylinder(d1 = quikfit_diameter, d2 = quikfit_diameter + 4, h = 2.1, center = false);
    }
}

// Separate Detail: Lower Pipe Clamp Cap Only
module clamp_cap() {
    difference() {
        // Intersection targeting only the lower clamp volume
        intersection() {
            unified_solid(block_height);
            lower_clamp_domain();
        }

        // 1. Lower Half of Handlebar Bore
        rotate([0, 90, 0])
            cylinder(d = pipe_diameter, h = clamp_length + 2, center = true);

        // 2. Clamping Relief Gap (Shaves 0.5mm off top face of lower clamp cap)
        clamp_gap_cut();

        // 3. 2x Bolt Holes + Hex Nut Traps & Sacrificial Floors
        for (y = [-bolt_offset_y, bolt_offset_y]) {
            translate([0, y, 0]) {
                difference() {
                    union() {
                        cylinder(d = bolt_hole_d, h = block_height * 2, center = true);
                        
                        translate([0, 0, -block_height/2 - 0.1])
                            rotate([0, 0, 30])
                                cylinder(d = nut_d / cos(30), h = nut_depth + 0.1, $fn = 6, center = false);
                    }
                    // Sacrificial bridging membrane left at top shoulder of hex nut trap
                    translate([0, 0, -block_height/2 + nut_depth - sacrificial_layer])
                        cylinder(d = nut_d / cos(30) + 0.1, h = sacrificial_layer, center = false);
                }
            }
        }
    }
}