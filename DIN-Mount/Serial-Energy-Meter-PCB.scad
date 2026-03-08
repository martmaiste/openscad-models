// PCB Spacer Plate
// Version: 0.02
// Description: Parametric spacer plate with PCB mounts and additional side mounting holes

/* [PCB Dimensions] */
pcb_hole_dist_x = 25;
pcb_hole_dist_y = 69;
plate_thickness = 5;
edge_margin = 5;

/* [PCB Hardware] */
m3_bolt_dia = 3.4;
nut_dia = 6.3; 
nut_depth = 3.0;
standoff_height = 2.0;
standoff_wall_thickness = 1.5;

/* [Plate Mounting Holes] */
mount_hole_dia = 3.4;
mount_edge_offset = 5;
mount_hole_spacing = 50;
cap_recess_dia = 6.5; // Recess for round head bolt
cap_recess_depth = 2.5;

/* [Calculated Dimensions] */
plate_width_x = pcb_hole_dist_x + (edge_margin * 2);
plate_length_y = pcb_hole_dist_y + (edge_margin * 2);
standoff_outer_d = m3_bolt_dia + (standoff_wall_thickness * 2);

$fn = 50; 

module pcb_spacer_plate() {
    difference() {
        // Main Body
        union() {
            cube([plate_width_x, plate_length_y, plate_thickness]);
            
            // PCB Standoffs
            for (x = [edge_margin, edge_margin + pcb_hole_dist_x]) {
                for (y = [edge_margin, edge_margin + pcb_hole_dist_y]) {
                    translate([x, y, plate_thickness])
                        cylinder(h = standoff_height, d = standoff_outer_d);
                }
            }
        }

        // 1. PCB Mounting Holes and Nut Recesses
        for (x = [edge_margin, edge_margin + pcb_hole_dist_x]) {
            for (y = [edge_margin, edge_margin + pcb_hole_dist_y]) {
                translate([x, y, -1])
                    cylinder(h = plate_thickness + standoff_height + 2, d = m3_bolt_dia);
                
                translate([x, y, -0.1])
                    cylinder(h = nut_depth, d = nut_dia, $fn = 6);
            }
        }

        // 2. Plate Side Mounting Holes (20mm spacing, 5mm from long edges)
        y_center = plate_length_y / 2;
        for (x = [mount_edge_offset, plate_width_x - mount_edge_offset]) {
            for (y = [y_center - mount_hole_spacing/2, y_center + mount_hole_spacing/2]) {
                // Through hole
                translate([x, y, -1])
                    cylinder(h = plate_thickness + 2, d = mount_hole_dia);
                
                // Recess for round head (on top)
                translate([x, y, plate_thickness - cap_recess_depth])
                    cylinder(h = cap_recess_depth + 0.1, d = cap_recess_dia);
            }
        }
    }
}

pcb_spacer_plate();