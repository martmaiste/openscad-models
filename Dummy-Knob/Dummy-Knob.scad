// Dummy-Knob.scad
// Version: v0.03
// Description: Parametric round dummy knob to fill a hole (e.g., where a timer knob was)
// with a springy catch post that locks it into a box wall.
// This version introduces a self-supporting shoulder ramp and print-ready default orientation
// to allow 100% support-free 3D printing.

/* [Knob Dimensions] */
// Outer diameter of the knob cap (mm)
knob_od = 40.0;

// Total height of the knob cap (mm)
knob_height = 7.0;

// Wall thickness of the hollow knob cap (mm)
knob_wall_thickness = 2.0;

// Chamfer on the top edge of the knob cap (mm)
knob_chamfer = 1.0;

/* [Hole & Box Wall Dimensions] */
// Diameter of the hole in the box wall (mm)
hole_diameter = 14.0;

// Thickness of the box wall (mm)
wall_thickness = 2.0;

/* [Post & Catch Dimensions] */
// Tolerance clearance between the post and the hole (mm)
post_clearance = 0.4;

// Extra play for the catch shoulder to ensure it snaps tightly without rattling (mm)
post_play = 0.2;

// Radial overhang of the catch lip (mm)
catch_lip_width = 1.0;

// Height of the catch lip transition ramp (mm)
catch_ramp_height = 2.5;

// Height of the underside chamfer/ramp (mm) to allow support-free printing.
// A value equal to catch_lip_width creates a 45-degree self-supporting angle.
shoulder_ramp_height = 1.0;

// Width of the split slots to make the prongs springy (mm)
slot_width = 1.6;

// Number of slots (1 = 2 prongs, 2 = 4 prongs)
num_slots = 2;

// Offset from the inside of the knob ceiling where the slot ends (mm)
slot_depth_offset = 1.0;

/* [Optional Aesthetics] */
// Enable a subtle indicator line on the top face
indicator_groove = false;

// Width of the indicator line (mm)
indicator_width = 1.5;

// Depth of the indicator line (mm)
indicator_depth = 0.6;

/* [Print Settings] */
// Automatically rotate and translate the model to lay flat on the print bed for export
print_ready_orientation = true;

/* [Visualization] */
// Show the box wall in preview mode to verify fit
show_preview_wall = true;

// Resolution for cylindrical shapes
$fn = 120;


// --- Derived calculations ---
post_diameter = hole_diameter - post_clearance;
z_start = knob_height - knob_wall_thickness;
z_shoulder = -wall_thickness - post_play;
z_tip = z_shoulder - catch_ramp_height;
tip_diameter = post_diameter - 1.5;


// --- Main Assembly Module ---
module knob_assembly() {
    difference() {
        union() {
            // 1. Main Knob Cap
            difference() {
                // Outer cap with top chamfer
                union() {
                    cylinder(d=knob_od, h=knob_height - knob_chamfer);
                    translate([0, 0, knob_height - knob_chamfer])
                        cylinder(d1=knob_od, d2=knob_od - 2*knob_chamfer, h=knob_chamfer);
                }
                // Hollow interior
                translate([0, 0, -0.1])
                    cylinder(d=knob_od - 2*knob_wall_thickness, h=knob_height - knob_wall_thickness + 0.1);
            }
            
            // 2. Central Post (Straight section)
            translate([0, 0, z_shoulder + shoulder_ramp_height])
                cylinder(d=post_diameter, h=z_start - (z_shoulder + shoulder_ramp_height));
                
            // 3. Underside Support-Free Shoulder Ramp (Conical overhang)
            translate([0, 0, z_shoulder])
                cylinder(d1=post_diameter + 2*catch_lip_width, d2=post_diameter, h=shoulder_ramp_height);
                
            // 4. Catch Lip (Conical ramp for easy insertion)
            translate([0, 0, z_tip])
                cylinder(d1=tip_diameter, d2=post_diameter + 2*catch_lip_width, h=catch_ramp_height);
        }
        
        // 5. Subtract Spring Slots
        for (i = [0 : num_slots - 1]) {
            rotate([0, 0, i * (180 / num_slots)])
                translate([0, 0, (z_start - slot_depth_offset + z_tip - 1) / 2])
                    cube([knob_od + 2, slot_width, z_start - slot_depth_offset - z_tip + 1 + 0.1], center=true);
        }
        
        // 6. Subtract Optional Indicator Line
        if (indicator_groove) {
            translate([0, 0, knob_height - indicator_depth])
                cube([knob_od - 2*knob_chamfer - 4, indicator_width, indicator_depth + 0.1], center=true);
        }
    }

    // 7. Preview-only Box Wall Representation (Kept in assembly to rotate with model)
    if ($preview && show_preview_wall) {
        % translate([0, 0, -wall_thickness]) {
            difference() {
                // Box wall representation (60x60mm square plate)
                translate([-30, -30, 0])
                    cube([60, 60, wall_thickness]);
                // Hole in the box wall
                translate([0, 0, -0.5])
                    cylinder(d=hole_diameter, h=wall_thickness + 1);
            }
        }
    }
}

// --- Print Orientation Handler ---
if (print_ready_orientation) {
    // Position top face at Z=0 and orient pointing upwards for support-free printing
    translate([0, 0, knob_height])
        rotate([180, 0, 0])
            knob_assembly();
} else {
    // Standard right-side-up orientation
    knob_assembly();
}
