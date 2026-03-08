// --- PROJECT INFO ---
/* Wall-mounted Pipe Holder
   Version: 4.17 (Thingiverse Customizer Ready)
   Features: Chamfered edges, toggleable countersunk screw holes with adjustable offset.
*/

// --- USER PARAMETERS ---

/* [Main Dimensions] */
// Type of the mount
mount_type = "open"; // [open, closed]
// Diameter of the pipe (mm)
pipe_diameter = 30; 
// Width of the block (X-axis)
block_width = 75; 
// Height of the block (Y-axis - the longer dimension)
block_height = 80; 
// Thickness of the block (Z-axis)
block_thickness = 15; 

/* [Screw Holes] */
// Enable screw holes for mounting
add_screw_holes = true; 
// Diameter of the screw shank (mm)
screw_diameter = 4;
// Diameter of the screw head (countersink) (mm)
screw_head_diameter = 8;
// Extra distance from the edge/chamfer (mm)
screw_offset_padding = 3.5;

/* [Finishing] */
// Universal chamfer size for all edges (mm)
universal_chamfer = 2.5; 

/* [Technical] */
// Extra room for the pipe (mm)
tolerance = 0.5;        
// Circle resolution
$fn = 100;              

/* [Internal Calculations] */
inner_r = (pipe_diameter / 2) + tolerance;
c = universal_chamfer;

// --- MODEL CONSTRUCTION ---

difference() {
    
    // 1. MAIN BLOCK
    cube([block_width, block_height, block_thickness], center = true);

    // 2. CHAMFER VERTICAL CORNERS (Z-axis edges)
    for(x = [-(block_width/2), (block_width/2)])
    for(y = [-(block_height/2), (block_height/2)])
    {
        translate([x, y, 0])
        rotate([0, 0, 45])
        cube([c * sqrt(2), c * sqrt(2), block_thickness + 2], center = true);
    }

    // 3. CHAMFER TOP EDGES (X and Y axis top edges)
    for(y = [-(block_height/2), (block_height/2)])
    {
        translate([0, y, block_thickness/2])
        rotate([45, 0, 0])
        cube([block_width + 2, c * sqrt(2), c * sqrt(2)], center = true);
    }
    for(x = [-(block_width/2), (block_width/2)])
    {
        translate([x, 0, block_thickness/2])
        rotate([0, 45, 0])
        cube([c * sqrt(2), block_height + 2, c * sqrt(2)], center = true);
    }

    // 4. MAIN HOLE AND ITS CHAMFER
    translate([0, 0, -block_thickness]) 
    cylinder(r = inner_r, h = block_thickness * 2);
    
    translate([0, 0, block_thickness/2 - c])
    cylinder(r1 = inner_r, r2 = inner_r + c, h = c + 0.01);

    // 5. SLOT CUTOUT (For "open" mount type)
    if (mount_type == "open") {
        translate([0, block_height/4 + 1, 0])
        cube([inner_r * 2, block_height/2 + 2, block_thickness + 2], center = true);
        
        for(i = [-1, 1]) {
            translate([i * inner_r, block_height/2, 0])
            rotate([0, 0, i * 45])
            cube([c * sqrt(2), c * sqrt(2), block_thickness + 2], center = true);
        }
        
        for(i = [-1, 1]) {
            translate([i * inner_r, block_height/4, block_thickness/2])
            rotate([0, 45, 0])
            cube([c * sqrt(2), block_height/2 + 2, c * sqrt(2)], center = true);
        }
    }

    // 6. SCREW HOLES (Countersunk)
    if (add_screw_holes) {
        // Calculated offset based on your formula + variable padding
        screw_x_offset = block_width/2 - (c + screw_head_diameter/2 + screw_offset_padding);
        screw_y_offset = block_height/2 - (c + screw_head_diameter/2 + screw_offset_padding);
        
        for(x = [-screw_x_offset, screw_x_offset])
        for(y = [-screw_y_offset, screw_y_offset])
        {
            // Safety check: Don't place screws too close to the central hole or slot
            if (abs(y) < (block_height/2 - 2) && abs(x) > (inner_r + 2)) {
                translate([x, y, -block_thickness]) 
                cylinder(d = screw_diameter, h = block_thickness * 2);
                
                // Countersink (peitpea)
                // Head depth is calculated to be flush with the top surface
                translate([x, y, block_thickness/2 - (screw_head_diameter-screw_diameter)/2])
                cylinder(d1 = screw_diameter, d2 = screw_head_diameter, h = (screw_head_diameter-screw_diameter)/2 + 0.1);
            }
        }
    }
}