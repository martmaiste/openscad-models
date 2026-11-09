// ============================================================================
// Model: Parametric Rosemary Pot Water Reservoir Bowl
// Version: 0.11
// Description: Renamed module outer_reservoir to bowl.
// ============================================================================

/* [Pot & Reservoir Dimensions] */
// Target inner diameter for plant pot base clearance (mm)
pot_bottom_diameter = 100.0; // [80.0:1.0:160.0]

// Height of the water reservoir bowl (mm)
reservoir_height = 55.0; // [30.0:1.0:120.0]

// Water storage clearance around pot base (mm)
reservoir_clearance = 14.0; // [8.0:1.0:30.0]

// Structural wall thickness (mm)
wall_thickness = 2.4; // [1.6:0.2:4.0]

// Fit clearance tolerance (mm)
fit_tolerance = 0.4; // [0.2:0.1:0.8]

/* [Refill Spout Parameters] */
// Refill spout inner diameter (mm)
spout_diameter = 26.0; // [18.0:1.0:45.0]

/* [Edge Chamfers & Internal Supports] */
// Chamfer size for outer edges and inside top rim lead-in (mm)
chamfer_size = 0.5; // [0.2:0.1:3.0]

// Internal bottom corner support chamfer / slope height (mm)
inner_bottom_chamfer = 3.0; // [0.5:0.5:8.0]

// Rendering resolution
$fn = 120; // [36:12:180]


// ============================================================================
// DERIVED CALCULATIONS
// ============================================================================
pot_r_base = (pot_bottom_diameter / 2) + fit_tolerance;
res_r_base = pot_r_base + wall_thickness + reservoir_clearance;
res_draft_angle = 3.0;
res_r_top  = res_r_base + (reservoir_height * tan(res_draft_angle));

spout_r = spout_diameter / 2;
spout_offset = res_r_top + spout_r + wall_thickness + 1.0;


// ============================================================================
// MODULES
// ============================================================================

module bowl() {
    difference() {
        // Outer Hull Envelope with Base & Top Outer Chamfers
        hull() {
            // Main Bowl Base Chamfer (Bottom Outer Edge)
            cylinder(r1 = res_r_base + wall_thickness - chamfer_size, 
                     r2 = res_r_base + wall_thickness, 
                     h = chamfer_size);

            // Main Bowl Middle Body
            translate([0, 0, chamfer_size])
                cylinder(r1 = res_r_base + wall_thickness, 
                         r2 = res_r_top + wall_thickness, 
                         h = reservoir_height - (2 * chamfer_size));

            // Main Bowl Top Chamfer (Top Lip Outer Edge)
            translate([0, 0, reservoir_height - chamfer_size])
                cylinder(r1 = res_r_top + wall_thickness, 
                         r2 = res_r_top + wall_thickness - chamfer_size, 
                         h = chamfer_size);

            // Spout Base Chamfer
            translate([spout_offset, 0, 0])
                cylinder(r1 = spout_r + wall_thickness - chamfer_size, 
                         r2 = spout_r + wall_thickness, 
                         h = chamfer_size);

            // Spout Middle Body
            translate([spout_offset, 0, chamfer_size])
                cylinder(r1 = spout_r + wall_thickness, 
                         r2 = spout_r + wall_thickness + 2.0, 
                         h = reservoir_height - (2 * chamfer_size));

            // Spout Top Chamfer
            translate([spout_offset, 0, reservoir_height - chamfer_size])
                cylinder(r1 = spout_r + wall_thickness + 2.0, 
                         r2 = spout_r + wall_thickness + 2.0 - chamfer_size, 
                         h = chamfer_size);
        }

        // Inner Void Cutout constructed using chained segment hulls
        translate([0, 0, wall_thickness]) {
            union() {
                // Segment 1: Bottom Reverse Chamfer / Support Wedge
                hull() {
                    // Base contact floor
                    cylinder(r = max(1.0, res_r_base - inner_bottom_chamfer), h = 0.01);
                    translate([spout_offset, 0, 0])
                        cylinder(r = max(1.0, spout_r - inner_bottom_chamfer), h = 0.01);

                    // Top of bottom chamfer
                    translate([0, 0, inner_bottom_chamfer])
                        cylinder(r = res_r_base, h = 0.01);
                    translate([spout_offset, 0, inner_bottom_chamfer])
                        cylinder(r = spout_r, h = 0.01);
                }

                // Segment 2: Main Cavity Body Wall
                hull() {
                    translate([0, 0, inner_bottom_chamfer])
                        cylinder(r = res_r_base, h = 0.01);
                    translate([spout_offset, 0, inner_bottom_chamfer])
                        cylinder(r = spout_r, h = 0.01);

                    translate([0, 0, reservoir_height - wall_thickness - chamfer_size])
                        cylinder(r = res_r_top - (chamfer_size * tan(res_draft_angle)), h = 0.01);
                    translate([spout_offset, 0, reservoir_height - wall_thickness - chamfer_size])
                        cylinder(r = spout_r + 2.0 - (chamfer_size * tan(res_draft_angle)), h = 0.01);
                }

                // Segment 3: Inside Top Rim Lead-in Chamfer (using chamfer_size)
                hull() {
                    translate([0, 0, reservoir_height - wall_thickness - chamfer_size])
                        cylinder(r = res_r_top - (chamfer_size * tan(res_draft_angle)), h = 0.01);
                    translate([spout_offset, 0, reservoir_height - wall_thickness - chamfer_size])
                        cylinder(r = spout_r + 2.0 - (chamfer_size * tan(res_draft_angle)), h = 0.01);

                    translate([0, 0, reservoir_height - wall_thickness + 1.0])
                        cylinder(r = res_r_top + chamfer_size, h = 0.01);
                    translate([spout_offset, 0, reservoir_height - wall_thickness + 1.0])
                        cylinder(r = spout_r + 2.0 + chamfer_size, h = 0.01);
                }
            }
        }
    }
}


// ============================================================================
// MODEL RENDER
// ============================================================================

bowl();