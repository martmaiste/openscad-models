// ============================================================================
// AMS Cable & PTFE Tube Guide for IKEA Cabinet (Matched Foot & Wall Thickness)
// Version: 0.18
// Description: Fixed the mounting feet thickness by setting total_flange_depth 
//              equal to profile_thickness (4.0mm). The feet now match the 
//              exact thickness of the clamp walls.
// ============================================================================

// --- PARAMETERS ---

/* [IKEA Cabinet Mounting] */
// Center-to-center distance between vertical IKEA holes
hole_spacing = 50; 

// Diameter of screw shank (IKEA drawer screws are ~5mm)
screw_hole_diameter = 6.2; 

// Diameter of the screw head / counterbore recess
screw_head_diameter = 10.0; 

// Length of each mounting flange tab along the Y axis
flange_length = 15; 

// Wall/arch thickness of the guide profile (clamp wall thickness)
profile_thickness = 4.0; 

// Total depth/thickness of the mounting foot (matches clamp wall thickness)
total_flange_depth = profile_thickness; 

// Solid wall thickness remaining under screw head
flange_wall_thickness = 2.0; 

/* [Guide Loop Geometry] */
// Clearance depth from cabinet wall to outer loop edge
guide_depth = 20; 

// Extrusion height / width of the bracket (Z-axis along print bed / wall)
bracket_width = 15; 

// Radius for inner corner fillets where arch meets mounting flanges
inner_fillet_radius = 3.5; 

// Corner fillet radius for outer/inner profile edges
corner_radius = 1.5; 

// Entry/Exit chamfer size for cable mouth edges (Z=0 and Z=bracket_width)
cable_chamfer = 2.0; 

// Width of optional front slot to slip cables inside without unplugging (0 to disable)
cable_insert_slot = 0; 

/* [Quality] */
$fn = 60;


// --- DERIVED CALCULATIONS ---

// Counterbore recess depth inside the 4mm flange foot
counterbore_depth = total_flange_depth - flange_wall_thickness;


// --- MAIN ASSEMBLY ---

module ams_guide_v0_18() {
    difference() {
        // 1. Extrude smooth 2D profile
        linear_extrude(height = bracket_width) {
            smoothed_2d_profile();
        }

        // 2. Subtract smooth 3D chamfer funnels extending to the wall (X=0)
        cable_entry_chamfers();

        // 3. Subtract counterbored IKEA screw holes
        screw_counterbores();

        // 4. Optional slot cutout for quick cable insertion
        if (cable_insert_slot > 0) {
            cable_slot_cutout();
        }
    }
}

ams_guide_v0_18();


// --- MODULES ---

// 2D Profile with filleted corners everywhere EXCEPT the wall contact face (X=0)
module smoothed_2d_profile() {
    ext = corner_radius * 2;
    difference() {
        // Offset profile extended behind X=0 so rounding occurs off-model
        offset(r = corner_radius)
        offset(r = -2 * corner_radius)
        offset(r = corner_radius)
        raw_2d_profile(ext = ext);

        // Crop precisely at X=0 for a perfectly flat, sharp wall-mating surface
        translate([-ext * 2, -hole_spacing])
            square([ext * 2, hole_spacing * 2]);
    }
}

// Overlapping primitive shapes forming 2D body, optionally extended into -X for wall clipping
module raw_2d_profile(ext = 0) {
    y_top = hole_spacing/2 - flange_length/2;
    y_bot = -hole_spacing/2 + flange_length/2;
    r = inner_fillet_radius;

    union() {
        // Top Flange Foot
        translate([-ext, y_top])
            square([total_flange_depth + ext, flange_length]);
            
        // Bottom Flange Foot
        translate([-ext, y_bot - flange_length])
            square([total_flange_depth + ext, flange_length]);
            
        // Top Arch Leg
        translate([-ext, y_top - profile_thickness])
            square([guide_depth + ext, profile_thickness]);
            
        // Bottom Arch Leg
        translate([-ext, y_bot])
            square([guide_depth + ext, profile_thickness]);
            
        // Outer Bridge connecting top and bottom legs
        translate([guide_depth - profile_thickness, y_bot])
            square([profile_thickness, y_top - y_bot]);

        // Top Inner Corner Fillet
        if (r > 0) {
            translate([total_flange_depth, y_top])
                difference() {
                    square([r, r]);
                    translate([r, r])
                        circle(r = r);
                }
        }

        // Bottom Inner Corner Fillet
        if (r > 0) {
            translate([total_flange_depth, y_bot - r])
                difference() {
                    square([r, r]);
                    translate([r, 0])
                        circle(r = r);
                }
        }
    }
}

// 2D inner opening spanning from the wall plane (X=0) to the inner bridge wall
module inner_opening_2d(extra_expand = 0) {
    w = guide_depth - profile_thickness;
    h = hole_spacing - flange_length - (2 * profile_thickness);
    r = max(0.1, corner_radius);
    
    offset(r = r + extra_expand)
        square([max(0.1, w - 2*r), max(0.1, h - 2*r)], center = true);
}

// 3D Funnel cutters for continuous 45° chamfers reaching all the way to the cabinet wall
module cable_entry_chamfers() {
    c = cable_chamfer;
    if (c > 0) {
        w_in = guide_depth - profile_thickness;
        x_center = w_in / 2;

        // Bottom Entry Funnel (Z = 0)
        translate([x_center, 0, -0.05]) {
            hull() {
                linear_extrude(height = 0.05)
                    inner_opening_2d(extra_expand = c + 0.05);
                
                translate([0, 0, c + 0.05])
                    linear_extrude(height = 0.05)
                        inner_opening_2d(extra_expand = 0);
            }
        }

        // Top Exit Funnel (Z = bracket_width)
        translate([x_center, 0, bracket_width + 0.05]) {
            hull() {
                linear_extrude(height = 0.05)
                    inner_opening_2d(extra_expand = c + 0.05);
                
                translate([0, 0, -(c + 0.05)])
                    linear_extrude(height = 0.05)
                        inner_opening_2d(extra_expand = 0);
            }
        }
    }
}

module screw_counterbores() {
    // Top Screw Hole
    translate([0, hole_spacing / 2, bracket_width / 2]) {
        rotate([0, 90, 0]) {
            cylinder(d = screw_hole_diameter, h = guide_depth * 3, center = true);
            translate([0, 0, flange_wall_thickness])
                cylinder(d = screw_head_diameter, h = guide_depth * 2);
        }
    }

    // Bottom Screw Hole
    translate([0, -hole_spacing / 2, bracket_width / 2]) {
        rotate([0, 90, 0]) {
            cylinder(d = screw_hole_diameter, h = guide_depth * 3, center = true);
            translate([0, 0, flange_wall_thickness])
                cylinder(d = screw_head_diameter, h = guide_depth * 2);
        }
    }
}

module cable_slot_cutout() {
    translate([guide_depth, 0, bracket_width / 2])
        cube([profile_thickness * 3, cable_insert_slot, bracket_width + 10], center = true);
}