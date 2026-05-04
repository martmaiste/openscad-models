/*
 * Project: Charger-11S-Holder
 * Version: v0.01
 * Description: Parametric wall mount for a cast aluminium charger.
 * The design features a base plate and two extruded rails (top and bottom)
 * that hold the charger's aluminium base plate with a 5mm air gap for cooling.
 * The charger is inserted by sliding the top into a 4mm slot and resting it
 * on a 2mm slot at the bottom.
 */

// --- Parametric Variables ---

// Holder overall dimensions
holder_w = 68;         // Total width of the holder base plate [mm]
holder_h = 116;        // Total height of the holder base plate [mm]
base_t = 3;            // Thickness of the holder base plate [mm]

// Charger base plate specifications
charger_plate_t = 1.6; // Thickness of the charger's aluminium base plate [mm]
air_gap = 5;           // Distance between holder base plate and charger base plate [mm]
slot_tol = 0.2;        // Tolerance for the slot width [mm]

// Slot / Lip dimensions
top_slot_depth = 4;    // Depth of the top retaining lip [mm]
bot_slot_depth = 2;    // Depth of the bottom resting lip [mm]

// Mounting hole specifications
screw_hole_d = 4.5;    // Diameter for 4mm wood screws [mm]
hole_offset = 6;       // Distance from edges to hole center [mm]

// Rail geometry
rail_w = 8;            // Total depth of the extruded rails from the wall [mm]
outer_wall_t = 3;      // Thickness of the outer wall to enclose the slot [mm]

// --- Derived Constants ---
slot_w = charger_plate_t + slot_tol;
total_top_h = air_gap + slot_w + top_slot_depth;
total_bot_h = air_gap;

// --- Modules ---

module mounting_holes() {
    // Positions for the 4 corner holes
    positions = [
        [hole_offset, hole_offset],
        [holder_w - hole_offset, hole_offset],
        [hole_offset, holder_h - hole_offset],
        [holder_w - hole_offset, holder_h - hole_offset]
    ];

    for (pos = positions) {
        translate([pos[0], pos[1], -1])
            cylinder(d = screw_hole_d, h = base_t + 2, $fn = 32);
    }
}

module base_plate() {
    difference() {
        cube([holder_w, holder_h, base_t]);
        mounting_holes();
    }
}

module top_rail() {
    // The top rail is a solid block with a cutout that faces inwards.
    difference() {
        // Outer solid block
        cube([holder_w, rail_w, total_top_h]);

        // Slot cutout facing inwards (Y=0)
        // We remove material from the base plate up to the bottom of the top lip.
        translate([0, 0, 0])
            cube([holder_w, rail_w - outer_wall_t, air_gap + slot_w]);
    }
}

module bottom_rail() {
    // The bottom rail is a solid block with a cutout that faces inwards.
    difference() {
        // Outer solid block
        cube([holder_w, rail_w, total_bot_h]);

        // Slot cutout facing inwards (Y=rail_w)
        // We remove material from the base plate up to the bottom of the resting lip.
        translate([0, outer_wall_t, 0])
            cube([holder_w, rail_w - outer_wall_t, air_gap - bot_slot_depth]);
    }
}

// --- Final Assembly ---

union() {
    // Wall-mounted base plate
    base_plate();

    // Top extruded part (at the top edge of the base plate)
    translate([0, holder_h - rail_w, 0])
        top_rail();

    // Bottom extruded part (at the bottom edge of the base plate)
    translate([0, 0, 0])
        bottom_rail();
}
