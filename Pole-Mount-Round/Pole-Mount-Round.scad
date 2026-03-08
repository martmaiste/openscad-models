// --- PROJECT INFO ---
/* Circular Wall-mounted Pipe Holder
   Version: 1.16
   Features: Circular design, chamfered outer and inner edges, 2 countersunk screw holes.
*/

// --- USER PARAMETERS ---

/* [Main Dimensions] */
// Type of the mount
mount_type = "closed"; // [open, closed]
// Diameter of the pipe (mm)
pipe_diameter = 30;
// Total diameter of the disk
disk_diameter = 75;
// Thickness of the disk (Z-axis)
block_thickness = 15;

/* [Screw Holes] */
// Enable screw holes
add_screw_holes = true;
// Type of screw head hole
screw_head_type = "counterbore"; // [countersink, counterbore]
// Diameter of the screw shank (mm)
screw_diameter = 4.5;
// Diameter of the screw head (countersink or counterbore) (mm)
screw_head_diameter = 9.0;
// Depth of the counterbore (only used if screw_head_type is "counterbore")
counterbore_depth = 5;
// Extra distance from the chamfer edge (mm)
screw_offset_padding = 4;
// Depth of the dowel washer recess on the bottom side (mm)
dowel_washer_recess_depth = 1.2;
// Dowel washer recess calculations
dowel_washer_recess_diameter = 16;
dowel_washer_recess_radius = dowel_washer_recess_diameter / 2;

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
outer_r = disk_diameter / 2;
c = universal_chamfer;



// --- MODEL CONSTRUCTION ---

difference() {

    // 1. MAIN DISK WITH OUTER CHAMFER
    union() {
        // Lower part (straight)
        translate([0, 0, -block_thickness/2])
            cylinder(r = outer_r, h = block_thickness - c);

        // Upper part (chamfered)
        translate([0, 0, block_thickness/2 - c])
            cylinder(r1 = outer_r, r2 = outer_r - c, h = c);
    }

    // 2. MAIN HOLE AND ITS CHAMFER
    translate([0, 0, -block_thickness])
        cylinder(r = inner_r, h = block_thickness * 2);

    // Internal top chamfer
    translate([0, 0, block_thickness/2 - c])
        cylinder(r1 = inner_r, r2 = inner_r + c, h = c + 0.01);

    // 3. SLOT CUTOUT (For "open" mount type)
    if (mount_type == "open") {
        // Main rectangular cut
        translate([0, outer_r/2, 0])
            cube([inner_r * 2, outer_r + 2, block_thickness + 2], center = true);

        // Vertical edge chamfers at the opening
        for(i = [-1, 1]) {
            // Finding the Y-coordinate where the inner circle meets the straight cut
            translate([i * inner_r, outer_r - c, 0])
            rotate([0, 0, i * 45])
            cube([c * sqrt(2), c * sqrt(2), block_thickness + 2], center = true);

            // Horizontal top edge chamfers along the slot
            translate([i * inner_r, outer_r/2, block_thickness/2])
            rotate([0, 45, 0])
            cube([c * sqrt(2), outer_r + 2, c * sqrt(2)], center = true);
        }
    }

    // 4. SCREW HOLES (2 holes on X-axis)
    if (add_screw_holes) {
        // Calculate safe distance from center
        // It accounts for the outer chamfer and the screw head size
        screw_x_dist = outer_r - c - (screw_head_diameter/2) - screw_offset_padding;

        for(x = [-screw_x_dist, screw_x_dist])
        {
            // Screw shank
            translate([x, 0, -block_thickness])
                cylinder(d = screw_diameter, h = block_thickness * 2);

            // Screw head (countersink or counterbore)
            if (screw_head_type == "countersink") {
                // Countersink (peitpea)
                // Depth is half of the diameter difference for a 90-degree head
                head_depth = (screw_head_diameter - screw_diameter) / 2;
                translate([x, 0, block_thickness/2 - head_depth])
                    cylinder(d1 = screw_diameter, d2 = screw_head_diameter, h = head_depth + 0.1);
            } else if (screw_head_type == "counterbore") {
                // Counterbore (silindriline süvendus)
                translate([x, 0, block_thickness/2 - counterbore_depth])
                    cylinder(d = screw_head_diameter, h = counterbore_depth + 0.1);

                // Chamfer for the counterbore (1mm)
                translate([0, 0, block_thickness/2 - 1])
                translate([x, 0, 0])
                    cylinder(d1 = screw_head_diameter, d2 = screw_head_diameter + 2, h = 1.01);
            }

            // Dowel washer recess on the bottom side
            // Starts inside the disk and extends to the bottom surface
            translate([x, 0, -block_thickness/2 - 0.05])
                cylinder(d = dowel_washer_recess_diameter, h = dowel_washer_recess_depth + 0.05);

        }
    }
}
