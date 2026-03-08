// PCB Spacer Plate - Wemos D1 Mini
// Version: 0.33
// Description: Fully centered geometry. Plate is exactly PCB width + margins.
// Bottom ledge: Flat surface facing UP. Top: Half-cylinder lock.

/* [Wemos D1 Mini PCB Dimensions] */
pcb_width = 25.6;
pcb_length = 34.2;
pcb_thickness = 1.0;
plate_thickness = 5.0;
edge_margin = 5;

/* [Clip Parameters] */
pcb_resting_height = 3.0;
clip_width = 3.5;
clip_wall_thickness = 2.9;
snap_dia = 2.0;
clip_margin = 1.3;

/* [Plate Mounting Holes] */
mount_hole_dia = 3.4;
mount_hole_spacing_y = 20; // Distance between holes on one side
cap_recess_dia = 6.5;
cap_recess_depth = 2.5;

/* [PCB Hardware] */
m3_bolt_dia = 3.4;
nut_dia = 6.3;
nut_depth = 3.0;

/* [Calculated Dimensions] */
//plate_w = pcb_width + (edge_margin * 2);
//plate_l = pcb_length + (edge_margin * 2);
//plate_w = pcb_width + edge_margin * 2;
plate_w = 30;
plate_l = 40;
//plate_l = pcb_length + (clip_wall_thickness * 2);

$fn = 50;

module dual_snap_clip(rotate_z) {
    // Clips are positioned relative to the PCB edges
    rotate([0, 0, rotate_z])
    translate([0, pcb_length/2, plate_thickness])
    union() {
        // 1. VERTICAL POST (Inner face at Y=0 relative to translate)
        translate([-clip_width*0.9, 0, 0])
            cube([clip_width*1.8, clip_wall_thickness, pcb_resting_height + pcb_thickness + snap_dia]);

        // 2. LOWER SUPPORT LEDGE (Flat surface facing UP)
        translate([0, 0, pcb_resting_height - snap_dia/2])
        rotate([0, 90, 0])
        cylinder(h = clip_width, d = snap_dia, center = true);

        // 3. UPPER SNAP LOCK (Half-cylinder facing IN)
        translate([0, snap_dia/3, pcb_resting_height + pcb_thickness + snap_dia/2])
        rotate([0, 90, 0])
        cylinder(h = clip_width, d = snap_dia, center = true);
    }
}

module wemos_d1_mini_v0_32() {
    difference() {
        // Base plate centered
        translate([-plate_w/2, -plate_l/2, 0])
            cube([plate_w, plate_l, plate_thickness]);

        // Mounting holes - Centered logic
        // Holes are placed at the side margins
        //x_pos = plate_w/2 - 5.5; // Offset 2.5mm from outer edge
        x_pos = 10; // Offset 2.5mm from outer edge
        for (x = [-x_pos, x_pos]) {
            for (y = [-mount_hole_spacing_y/2, mount_hole_spacing_y/2]) {
                translate([x, y, -1])
                    cylinder(h = plate_thickness + 2, d = mount_hole_dia);
                translate([x, y, plate_thickness - cap_recess_depth])
                    cylinder(h = cap_recess_depth + 0.1, d = cap_recess_dia);
            }
        }


    }

    // Corner Clips - Placed by rotating and translating from center
    // We use a small offset to account for the clip width
    x_off = pcb_width/2 - clip_width/2;

    translate([x_off - clip_margin, 0, 0]) dual_snap_clip(0);
    translate([-x_off + clip_margin, 0, 0]) dual_snap_clip(0);
    translate([x_off - clip_margin, 0, 0]) dual_snap_clip(180);
    translate([-x_off + clip_margin, 0, 0]) dual_snap_clip(180);
}

wemos_d1_mini_v0_32();
