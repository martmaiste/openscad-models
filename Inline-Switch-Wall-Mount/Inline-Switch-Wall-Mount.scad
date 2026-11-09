// Parametric Pocket-Style Wall Mount for Inline Light Switch
// Version: 0.30

/* [Switch Dimensions] */
switch_width     = 27.0; // [mm] Core body width
switch_thickness = 15.0; // [mm] Core body thickness
switch_length    = 62.0; // [mm] Core body length

/* [Switch Features] */
switch_actuator_inset = 20.0; // [mm] Distance from end to start of actuator cutout
switch_actuator_width = 12.0; // [mm] Actuator cutout width

/* [Mounting & Print Options] */
wall_clearance  = 0.4; // [mm] Extra space for smooth slide fit
wall_thickness  = 2.4; // [mm] Pocket wall thickness
bottom_rear_lip = 4.0; // [mm] Solid bottom ledge left at the back for rigidity
chamfer_size    = 0.6; // [mm] Size of edge chamfers
screw_d         = 4.0; // [mm] Screw shaft diameter
screw_head_d    = 8.0; // [mm] Screw head countersink diameter

$fn = 60;

// Internal pocket dimensions
pw = switch_width + 2 * wall_clearance;
pt = switch_thickness + 2 * wall_clearance;
pl = switch_length + wall_clearance;

// Outer shell dimensions
cw = pw + 2 * wall_thickness;
ct = pt + 2 * wall_thickness;
cl = pl + wall_thickness;

// Cutout dimensions
cutout_w = switch_actuator_width;
radius = cutout_w / 2;
cutout_y_end = wall_thickness + pt - bottom_rear_lip - radius;

// 1. Outer Shell with Mitered 3D Octahedral Chamfers (Flat Back Wall)
module outer_shell_chamfered() {
    c = chamfer_size;
    difference() {
        minkowski() {
            translate([-(cw/2 - c), c, c])
                cube([cw - 2*c, ct - c, cl - 2*c]);
            
            // 3D Octahedron chamfer element creates clean mitered 3-way corners
            polyhedron(
                points = [
                    [c,0,0], [-c,0,0],
                    [0,c,0], [0,-c,0],
                    [0,0,c], [0,0,-c]
                ],
                faces = [
                    [0,2,4], [2,1,4], [1,3,4], [3,0,4],
                    [2,0,5], [1,2,5], [3,1,5], [0,3,5]
                ]
            );
        }

        // Crop extension past y = ct so back wall remains 100% flat
        translate([-(cw + 10)/2, ct, -10])
            cube([cw + 10, c + 10, cl + 20]);
    }
}

// 2. Inverted Truncated Pyramid Cutter for Inner Top Rim
module inner_top_chamfer_cutter() {
    c = chamfer_size;
    hull() {
        // Lower footprint at z = cl - c
        translate([-pw/2, wall_thickness, cl - c])
            cube([pw, pt, 0.01]);
        
        // Upper footprint at z = cl + 1
        translate([-(pw/2 + c + 1), wall_thickness - c - 1, cl + 1])
            cube([pw + 2*(c + 1), pt + 2*(c + 1), 0.01]);
    }
}

// 3. Perfected Front Slot Cutter (Split Z-sections to prevent skins and floor gouges)
module front_slot_cutter() {
    c = chamfer_size;
    w = cutout_w;
    t = wall_thickness;

    // LOWER section: z = -1 to t
    translate([0, 0, -1])
        linear_extrude(h = t + 1.01) {
            polygon(points = [
                [-(w/2 + c), -1],
                [-(w/2 + c), 0],
                [-w/2, c],
                [-w/2, t],
                [w/2, t],
                [w/2, c],
                [w/2 + c, 0],
                [w/2 + c, -1]
            ]);
        }

    // UPPER section: z = t to cl + 2
    translate([0, 0, t])
        linear_extrude(h = cl - t + 2) {
            polygon(points = [
                [-(w/2 + c), -1],
                [-(w/2 + c), 0],
                [-w/2, c],
                [-w/2, t - c],
                [-(w/2 + c), t],
                [-(w/2 + c), t + 2],
                [w/2 + c, t + 2],
                [w/2 + c, t],
                [w/2, t - c],
                [w/2, c],
                [w/2 + c, 0],
                [w/2 + c, -1]
            ]);
        }

    // Top rim horizontal chamfer cleanly miters with the vertical chamfers
    hull() {
        translate([0, 0, cl - c])
            linear_extrude(h = 0.01)
                translate([-w/2, -1])
                    square([w, t + 2]);
        
        translate([0, 0, cl + 0.01])
            linear_extrude(h = 0.01)
                translate([-(w/2 + c), -1])
                    square([w + 2*c, t + 2]);
    }
}

// 4. Bottom Floor Cutout with Perfectly Extended Top Edge Chamfer
module bottom_floor_cutout_with_chamfer() {
    c = chamfer_size;
    
    // Straight pass-through void through floor
    translate([0, 0, -0.1])
        linear_extrude(h = wall_thickness + 1.2) {
            translate([-cutout_w/2, -1])
                square([cutout_w, cutout_y_end + 1]);
            translate([0, cutout_y_end])
                circle(r = radius);
        }
    
    // Smooth flared 45° chamfer transition strictly at the bottom (z = 0)
    translate([0, 0, -0.01]) {
        hull() {
            // Bottom wide footprint
            linear_extrude(h = 0.01) {
                translate([-(cutout_w/2 + c), -1])
                    square([cutout_w + 2*c, cutout_y_end + 1]);
                translate([0, cutout_y_end])
                    circle(r = radius + c);
            }
            
            // Upper normal footprint
            translate([0, 0, c + 0.01])
                linear_extrude(h = 0.01) {
                    translate([-cutout_w/2, -1])
                        square([cutout_w, cutout_y_end + 1]);
                    translate([0, cutout_y_end])
                        circle(r = radius);
                }
        }
    }

    // Smooth flared 45° chamfer transition at the top of the floor, perfectly extended to meet the vertical chamfer
    intersection() {
        translate([0, 0, wall_thickness - c]) {
            hull() {
                linear_extrude(h = 0.01) {
                    translate([-cutout_w/2, -1])
                        square([cutout_w, cutout_y_end + 1]);
                    translate([0, cutout_y_end])
                        circle(r = radius);
                }
                
                translate([0, 0, c + 0.01])
                    linear_extrude(h = 0.01) {
                        translate([-(cutout_w/2 + c), -1])
                            square([cutout_w + 2*c, cutout_y_end + 1]);
                        translate([0, cutout_y_end])
                            circle(r = radius + c);
                    }
            }
        }
        // Restrict top floor chamfer to stop right before biting into the outer front wall face
        translate([-cw, wall_thickness - c, -1])
            cube([2*cw, ct, cl + 5]);
    }
}

// 5. Countersunk Back Wall Screw Holes (Exact 40mm center-to-center distance)
module screw_holes() {
    screw_spacing = 40.0; // [mm] Distance between screw hole centers
    mid_z = cl / 2;
    screw_z1 = mid_z - (screw_spacing / 2);
    screw_z2 = mid_z + (screw_spacing / 2);

    for (z_pos = [screw_z1, screw_z2]) {
        translate([0, ct - wall_thickness, z_pos]) {
            rotate([-90, 0, 0]) {
                cylinder(d = screw_d, h = wall_thickness + 1);
                translate([0, 0, -0.1])
                    cylinder(d1 = screw_head_d, d2 = screw_d, h = (screw_head_d - screw_d) / 2 + 0.1);
            }
        }
    }
}

// Final Pocket Mount Assembly
module inline_switch_pocket_mount() {
    difference() {
        // Outer chamfered shell
        outer_shell_chamfered();

        // Inner main pocket void
        translate([-pw/2, wall_thickness, wall_thickness])
            cube([pw, pt, cl + 1]);

        // Mitered top inner rim chamfer
        inner_top_chamfer_cutter();

        // Front slot with perfectly mitered inner/outer 2D chamfers
        front_slot_cutter();

        // Bottom floor slot with perfected top chamfer
        bottom_floor_cutout_with_chamfer();

        // Mounting screw holes
        screw_holes();
    }
}

inline_switch_pocket_mount();