// ADO-AIR-Carbon-Rear-Rack-Stand.scad
// Version: v0.26
// Date: 2026-06-16
// Author: Zed Coding Agent
// License: Creative Commons - Attribution - ShareAlike
//
// Description:
// A simplified, highly elegant, single-piece parametric stand/protector block for the ADO AIR Carbon folding e-bike rear rack.
// When the bike is folded and stood upright, the rear rack is oriented vertically like an upright 'U'.
// The flat bottom of the 'U' (the rear transverse section) faces the ground, and the tail light bracket is horizontal.
// This block stands flat on the floor and is designed for the rack to be lowered vertically (along the Z-axis) onto it from above.
// It features a vertical drop-in trench that hugs the rack tube, and an open vertical central slot in the rear wall
// that allows the welded tail light bracket to slide down vertically and protrude safely out of the back.

/* [Rack Specifications] */
// Outer-to-outer width of the rear rack (mm)
rack_width = 116; // [80:200]
// Size of the square metal tube (mm)
tube_size = 16; // [10:30]
// Outer bend radius of the rack corners (mm)
bend_radius = 40; // [20:80]
// Clearance around the tube inside the stand channel (mm)
fit_clearance = 0.2; // [0.0:1.0]

/* [Stand Dimensions] */
// Front-to-back depth of the stand block (mm)
stand_depth = 40; // [25:80]
// Clearance between the bottom of the rack tube and the floor (mm)
clearance_floor = 20; // [5:50]
// Height of the stand outer walls hugging the tube (mm)
hug_height = 30; // [10:60]
// Wall thickness on the sides of the rack (mm)
wall_thickness = 8; // [4:15]
// Corner and edge rounding radius for the entire stand block (mm)
foot_rounding = 1; // [0:10]

/* [Tail Light Attachment] */
// Location of the tail light bracket on the rack
tail_light_position = "center"; // [center, none]
// Width of the metal bracket tab (mm)
tail_light_width = 30; // [10:60]
// How far the bracket extends backwards from the bended tube (mm)
tail_light_distance = 16; // [5:40]
// Thickness of the bracket plate (mm)
tail_light_thickness = 3; // [1:10]
// Height of bracket center from the tube's bottom (mm)
tail_light_z_offset = 8; // [0:20]
// Extra clearance pocket around the bracket (mm)
tail_light_clearance = 1.0; // [0.0:3.0]

/* [Drainage & Mounting Features] */
// Diameter of the vertical drainage/mounting holes at the bottom of the channel (mm, 0 to disable)
drainage_hole_diameter = 4.5; // [0:10.0]
// Enable countersinks on the drainage holes for flat-head floor mounting screws
mounting_countersinks_enabled = true;
// Diameter of the flat head countersink (mm)
countersink_diameter = 9.0; // [4.0:15.0]
// Countersink cone angle (degrees, 90 for metric flat head, 82 for imperial)
countersink_angle = 90; // [60:120]
// Additional recess depth for the countersink (mm) to guarantee screw heads sit below the plastic surface
countersink_depth_offset = 5.0; // [0.0:15.0]

/* [Features] */
// Rounding radius at the top inner lip of the cutout to smoothly guide insertion (mm)
inner_lip_rounding = 2.0; // [0.0:5.0]

/* [Engraved Text] */
// Text to engrave on the front face
front_text_string = "Hele-E-Velo";
// Depth of the engraved text (mm)
front_text_depth = 0.5; // [0.1:2.0]
// Size of the text (mm)
front_text_size = 14; // [5:30]
// Handwriting/Cursive font name. Pre-installed / downloaded options: "Z003" (Calligraphy), "Caveat:style=Bold" (Natural printing), "Dancing Script:style=Bold" (Flowy Cursive)
front_text_font = "Z003";

/* [Render Mode] */
// What to render in the viewport
render_mode = "stand"; // [stand: Stand block only, rack: Rack visualization only, both: Both stand and rack, cutaway: Half-cut view to see inside the curved floor]

// --- Geometry Calculations ---
// Center of curvature for the corner bend
x_c = rack_width/2 - bend_radius;
z_c = bend_radius;
// Center radius of the curved tube segment
R_c = bend_radius - tube_size/2;

// Exact outer width of the rack's swept 3D hull at a given vertical height Z (relative to the bottom of the rack)
function rack_width_at(z) =
    (z >= z_c) ?
        (rack_width + 2 * fit_clearance) :
        2 * (x_c + sqrt( max(0, pow(R_c + tube_size/2 + fit_clearance, 2) - pow(z_c - z, 2)) ));

// --- Modules ---

// 2D Profile of the upright U-shaped rack tube (drawn in X-Z plane where horizontal is X and vertical is Z)
// 'd' is an offset/expansion parameter (e.g., wall thickness or fit clearance)
// 'side_ext' is how far the vertical side rails extend upwards
module rack_2d_xz(d, side_ext) {
    // Bottom straight section (horizontal)
    translate([-x_c, -d])
        square([2 * x_c, tube_size + 2 * d]);

    // Right corner bend (from horizontal to vertical, 4th quadrant relative to center)
    translate([x_c, z_c]) {
        intersection() {
            difference() {
                circle(r = R_c + tube_size/2 + d, $fn = 100);
                if (R_c - tube_size/2 - d > 0) {
                    circle(r = R_c - tube_size/2 - d, $fn = 100);
                }
            }
            translate([0, -(R_c + tube_size/2 + d)])
                square([R_c + tube_size/2 + d, R_c + tube_size/2 + d]);
        }
    }

    // Left corner bend (from horizontal to vertical, 3rd quadrant relative to center)
    translate([-x_c, z_c]) {
        intersection() {
            difference() {
                circle(r = R_c + tube_size/2 + d, $fn = 100);
                if (R_c - tube_size/2 - d > 0) {
                    circle(r = R_c - tube_size/2 - d, $fn = 100);
                }
            }
            translate([-(R_c + tube_size/2 + d), -(R_c + tube_size/2 + d)])
                square([R_c + tube_size/2 + d, R_c + tube_size/2 + d]);
        }
    }

    // Right side straight section (vertical)
    translate([rack_width/2 - tube_size - d, z_c])
        square([tube_size + 2 * d, side_ext]);

    // Left side straight section (vertical)
    translate([-rack_width/2 - d, z_c])
        square([tube_size + 2 * d, side_ext]);
}

// 3D Tube model generated by linear extruding the 2D upright profile along Y
// Mirroring on Z ensures that the horizontal section bottom is exactly at Z=0 (pointing legs upwards)
module rack_3d(d = 0, side_ext = 100) {
    mirror([0, 0, 1])
        rotate([-90, 0, 0])
            linear_extrude(height = tube_size + 2 * d, center = true)
                rack_2d_xz(d, side_ext);
}

// 3D Swept Cutout model for the perfect vertical drop-in trench
// Using hull() perfectly fills the space between the upright legs while keeping the bottom matched to the curved corners!
module rack_swept_3d(d = 0, side_ext = 100) {
    mirror([0, 0, 1])
        rotate([-90, 0, 0])
            linear_extrude(height = tube_size + 2 * d, center = true)
                hull()
                    rack_2d_xz(d, side_ext);
}

// Horizontal tail light bracket welded at the center of the bottom horizontal section
module tail_light_bracket(clearance = 0) {
    w = tail_light_width + 2 * clearance;
    t = tail_light_thickness + 2 * clearance;
    d = tail_light_distance + (clearance > 0 ? clearance + 2 : 0);

    // Position of the bracket along Z
    z_pos = clearance_floor + tail_light_z_offset - t/2;
    // Starts at the tube outer surface (y = tube_size/2)
    y_pos = tube_size/2 - (clearance > 0 ? clearance : 0);

    if (tail_light_position == "center") {
        translate([-w/2, y_pos, z_pos])
            cube([w, d, t]);
    }
}

// Vertical drainage and mounting holes through the bottom of the seat channel
module drainage_holes() {
    if (drainage_hole_diameter > 0) {
        // Calculate the depth of the countersink cone based on diameters and angle
        h_cs = (countersink_diameter - drainage_hole_diameter) / 2 / tan(countersink_angle / 2);

        for (x = [-20, 20]) {
            translate([x, 0, 0]) {
                // Main shank / drainage hole
                translate([0, 0, -1])
                    cylinder(d = drainage_hole_diameter, h = clearance_floor + 2, $fn = 24);

                // Countersink cone and counterbore (if enabled)
                if (mounting_countersinks_enabled) {
                    // The top of the cone sits at (clearance_floor - countersink_depth_offset)
                    z_cone_top = clearance_floor - countersink_depth_offset;
                    z_cone_bottom = z_cone_top - h_cs;

                    // Cone cuts down into the trench floor
                    translate([0, 0, z_cone_bottom])
                        cylinder(d1 = drainage_hole_diameter, d2 = countersink_diameter, h = h_cs + 0.1, $fn = 24);

                    // Clearance cylinder above the countersink to ensure the screw head can drop in deeply
                    translate([0, 0, z_cone_top])
                        cylinder(d = countersink_diameter, h = hug_height + countersink_depth_offset + 5, $fn = 24);
                }
            }
        }
    }
}

// 3D Rounded Block (used for smoothing all edges of the main body: top, bottom, and sides)
module rounded_block_3d(w, d, h, r) {
    if (r > 0) {
        hull() {
            for (x = [-w/2 + r, w/2 - r]) {
                for (y = [-d/2 + r, d/2 - r]) {
                    for (z = [r, h - r]) {
                        translate([x, y, z])
                            sphere(r = r, $fn = 24);
                    }
                }
            }
        }
    } else {
        translate([0, 0, h/2])
            cube([w, d, h], center = true);
    }
}

// Engraved text on the front face
module front_text() {
    if (len(front_text_string) > 0 && front_text_depth > 0) {
        // Rotate 90 around X makes the text face the front (-Y direction).
        // Translating to (-stand_depth/2 + front_text_depth) cuts exactly the specified depth into the block.
        translate([0, -stand_depth/2 + front_text_depth, (clearance_floor + hug_height)/2])
            rotate([90, 0, 0])
                linear_extrude(height = front_text_depth + 1)
                    text(text = front_text_string, size = front_text_size, font = front_text_font, halign = "center", valign = "center");
    }
}

// 1. Trench Profile (for vertical drop-in slot of the square bended tube)
// Accepts 'z' to calculate exact width at that height, and 'expand' for chamfering
module trench_footprint_2d(z, expand = 0) {
    square([
        rack_width_at(z) + 2 * expand,
        tube_size + 2 * fit_clearance + 2 * expand
    ], center = true);
}

// 2. Tail Light Slot Profile (extending backwards from the trench to the back of the block)
module tail_light_slot_footprint_2d() {
    if (tail_light_position != "none") {
        w_light = tail_light_width + 2 * tail_light_clearance;
        d_trench = tube_size + 2 * fit_clearance;

        // Base rectangular slot (extending slightly inside the trench for clean boolean overlap)
        translate([-w_light/2, d_trench/2 - 0.1])
            square([w_light, stand_depth/2 - d_trench/2 + 2]);
    }
}

// The stand block
module stand_block() {
    difference() {
        // 1. Main outer body (3D rectangular block with rounded edges on all sides)
        rounded_block_3d(
            rack_width + 2 * wall_thickness,
            stand_depth,
            clearance_floor + hug_height,
            foot_rounding
        );

        // 2. Subtract the vertical drop-in trench for the rack tube
        // We use a swept hull of the exact rack profile to create a trench that perfectly cups the rack's curvature!
        translate([0, 0, clearance_floor]) {
            rack_swept_3d(fit_clearance, hug_height + 5);
        }

        // 3. Subtract the vertical drop-in slot for the welded tail light bracket
        // This is open to the top and runs from the main trench to the back of the block.
        if (tail_light_position != "none") {
            w = tail_light_width + 2 * tail_light_clearance;
            t = tail_light_thickness + 2 * tail_light_clearance;

            // The slot goes from the bracket's bottom height all the way to the top of the block
            z_pos = clearance_floor + tail_light_z_offset - t/2;

            translate([-w/2, tube_size/2, z_pos])
                cube([
                    w,
                    stand_depth/2 - tube_size/2 + 2,
                    hug_height - tail_light_z_offset + t/2 + 5
                ]);
        }

        // 4. Subtract the top guide rounding to perfectly smooth the inner horizontal lips of the main trench
        // We use an offset rounding profile that accurately matches the actual width of the curved rack
        // at the specific Z height, eliminating any floating gaps on the short sides!
        if (inner_lip_rounding > 0) {
            z_top = clearance_floor + hug_height;
            z_rack_top = hug_height;
            z_rack_base = hug_height - inner_lip_rounding;

            hull() {
                // Base of the rounding (sharp shape slightly below the top surface matching exact rack width)
                translate([0, 0, z_top - inner_lip_rounding])
                    linear_extrude(height = 0.1)
                        trench_footprint_2d(z_rack_base, 0);

                // Top of the rounding (smoothly rounded offset shape above the surface)
                translate([0, 0, z_top + 1])
                    linear_extrude(height = 0.1)
                        offset(r = inner_lip_rounding + 1, $fn = 24)
                            trench_footprint_2d(z_rack_top, 0);
            }
        }

        // 5. Subtract the dual-purpose drainage/mounting holes
        drainage_holes();

        // 6. Subtract the engraved text on the front face
        front_text();
    }
}

// Visualizer helper for the rack tube and tail light bracket
module rack_visualization() {
    // The U-shape rack tube (semitransparent silver)
    color("Silver", 0.6) {
        translate([0, 0, clearance_floor]) {
            rack_3d(0, 150); // extended straight tubes to show rack context
        }
    }

    // The tail light bracket (semitransparent grey)
    if (tail_light_position != "none") {
        color("DimGray", 0.8) {
            tail_light_bracket(clearance = 0);
        }
    }
}

// --- Main Assembly Control ---
if (render_mode == "stand") {
    stand_block();
} else if (render_mode == "rack") {
    rack_visualization();
} else if (render_mode == "both") {
    color("DodgerBlue") stand_block();
    rack_visualization();
} else if (render_mode == "cutaway") {
    // Slice the front half of the block away to reveal the internal curves!
    difference() {
        color("DodgerBlue") stand_block();
        // Cutaway bounding box (removes y < 0)
        translate([-rack_width, -stand_depth, -10])
            cube([rack_width * 2, stand_depth, hug_height + clearance_floor + 20]);
    }
    rack_visualization();
}
