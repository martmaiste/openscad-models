//====================================================================
// Parametric Spanish Slug Trap for Ferromax Pellets (Umbrella Design)
// Version: v0.15
// Date: 2026-08-05
// Author: Zed Coding Agent
//
// Description:
// A highly optimized, fully parametric, 3D-printable Spanish slug trap.
//
// Updates in v0.15:
// - Redesigned the Stick T-bars to act as proper locking ledges.
// - Fixed the logic of the twist lock: The bowl and lid now slide down PAST
//   a TOP locking T-bar, land on a BOTTOM rest ledge, and rotate so the top
//   T-bar traps them from above while gravity holds them in the detent below.
// - Accurately matched the Z-heights of the bowl/lid hubs to the neck lengths.
//
// Printing Instructions:
// - Stick: Print flat on its side. No supports.
// - Bowl: Print flat on its bottom, right-side up. No supports.
// - Lid: Print upside down (flat top surface on the build plate). No supports.
//====================================================================

/* [Render Controls] */
// Which part to render
part = "all_separated"; // [all_separated, assembled, bowl, lid, stick]

// Level of detail (number of fragments in cylinder)
$fn = 64;

/* [Bowl Parameters] */
bowl_outer_dia = 80.0;
bowl_bottom_dia = 50.0;
bowl_depth = 25.0;
wall_thickness = 2.4;

/* [Lid Parameters] */
lid_dia = 100.0;
// Perfect 45-degree angle height based on new diameter: (100 - 30(hub))/2 = 35mm
lid_cone_height = 35.0;

/* [Twist-Lock & Stick Parameters] */
clearance = 0.6;
stick_thickness = 8.0;
t_bar_width = 24.0;
neck_dia = 12.0;

// Calculated slot dimensions to cleanly pass over the stick's T-bars
slot_len = t_bar_width + clearance * 2;
slot_width = stick_thickness + clearance * 2;
// Tight circular hole for a snug fit
center_hole = neck_dia + clearance;

//====================================================================
// Modules
//====================================================================

module stick_profile() {
    polygon(points=[
        [0, 0], // Centerline closure (fixes the split issue)

        // Stake (tapered with backward locking barbs)
        [0, 2.0], [15, 4.5], [15, 3.0],
        [35, 6.5], [35, 5.0], [55, 8.5], [55, 7.0],
        [70, 10.0], [70, 8.0],

        // Thick Bowl Rest Ledge (The bowl lands and rests on this, Z=82)
        [70, 17.5], [82, 17.5],

        // Bowl Twist-Lock Neck (Exactly 25mm long to match the 25mm bowl hub)
        // This is the smooth cylinder where the bowl rotates.
        [82, neck_dia/2], [107, neck_dia/2],

        // Bowl TOP Locking T-bar (This prevents the bowl from sliding UP after being twisted)
        [107, t_bar_width/2], [113, t_bar_width/2],

        // Main Stick Shaft
        [113, 8.0], [147, 8.0],

        // Lid Rest Ledge (The Lid lands and rests on this, Z=147)
        // I am adding a T-bar here so the lid has something to sit on!
        [147, t_bar_width/2], [153, t_bar_width/2],

        // Lid Twist-Lock Neck (Exactly 10mm long to match the 10mm Lid hub)
        [153, neck_dia/2], [163, neck_dia/2],

        // Lid TOP Locking T-bar (Prevents lid from flying off in the wind)
        [163, t_bar_width/2], [169, t_bar_width/2],

        // Top Guide Pin
        [169, 4.0], [173, 4.0], [176, 0]
    ]);
}

module slug_trap_stick() {
    // Extruded flat on the build plate
    // The mirroring creates a perfectly symmetric stick, closed at Y=0
    difference() {
        linear_extrude(height = stick_thickness, center = true) {
            union() {
                stick_profile();
                mirror([0, 1]) stick_profile();
            }
        }

        // Chamfer/Round the rectangular corners of the twist-lock necks
        // to allow smooth rotation inside the tight 12.6mm holes.
        // The neck width is 12mm, thickness is 8mm. The diagonal is 14.4mm.
        // We cut away the corners outside a 12mm cylinder.

        // 1. Bowl Twist-Lock Neck (X = 82 to 107) -> Length = 25, Center = 94.5
        translate([94.5, 0, 0])
        difference() {
            cube([25, 14, stick_thickness + 1], center = true); // Encompassing block (exactly 25mm)
            rotate([0, 90, 0]) cylinder(d = neck_dia, h = 25.02, center = true, $fn=32); // Inner circle to keep
        }

        // 2. Lid Twist-Lock Neck (X = 153 to 163) -> Length = 10, Center = 158
        translate([158, 0, 0])
        difference() {
            cube([10, 14, stick_thickness + 1], center = true);
            rotate([0, 90, 0]) cylinder(d = neck_dia, h = 10.02, center = true, $fn=32);
        }
    }
}

module slug_trap_bowl() {
    bowl_hub_len = 25.0; // Increased to 25mm to be exactly level with the bowl's outer rim

    difference() {
        union() {
            // Main bowl shell
            difference() {
                cylinder(d1=bowl_bottom_dia, d2=bowl_outer_dia, h=bowl_depth, $fn=$fn);

                // Hollow interior
                translate([0, 0, wall_thickness])
                cylinder(d1=bowl_bottom_dia - 2 * wall_thickness, d2=bowl_outer_dia - 2 * wall_thickness, h=bowl_depth + 0.1, $fn=$fn);
            }

            // Central hub boss for structural integrity
            cylinder(d=35, h=bowl_hub_len, $fn=$fn);
        }

        // Twist-Lock through-hole
        // Passes over the Lid T-bar AND Bowl T-bar, then rotates on the Bowl Neck
        translate([0, 0, -1])
        linear_extrude(height = bowl_depth + 2)
        union() {
            square([slot_len, slot_width], center=true);
            circle(d=center_hole, $fn=32);
        }

        // 90-Degree Snap-Fit Detent Groove (Now on the BOTTOM for gravity locking)
        // The Stick's bottom Rest Ledge snaps into this groove.
        // It must be deep enough (1mm) and wide enough to fit the 17.5mm half-width (35mm total width) bowl rest!
        // The Bowl rest is 35mm wide, but the slot_len is only 24mm + clearance.
        // Therefore, the detent needs to be large enough for the 35mm rest block.
        translate([0, 0, -1])
        linear_extrude(height = 2.0)
        square([stick_thickness + clearance * 2, 35 + clearance * 2], center=true);

        // Drainage holes for Ferromax pellets
        for (i = [0 : 5]) {
            rotate([0, 0, i * 60])
            translate([22, 0, -1])
            cylinder(d=2.0, h=wall_thickness + 2, $fn=12);
        }
    }
}

module slug_trap_lid() {
    lid_hub_len = 10.0; // Matches the 10mm Lid Neck on the stick

    difference() {
        union() {
            // Conical umbrella shell
            difference() {
                cylinder(d1=lid_dia, d2=35, h=lid_cone_height, $fn=$fn);

                // Hollow interior
                translate([0, 0, -0.1])
                cylinder(d1=lid_dia - 2 * wall_thickness, d2=35 - 2 * wall_thickness, h=lid_cone_height, $fn=$fn);
            }

            // Central solid boss for the twist-lock mechanism
            translate([0, 0, lid_cone_height - lid_hub_len])
            cylinder(d=30, h=lid_hub_len, $fn=$fn);
        }

        // Twist-Lock through-hole
        translate([0, 0, -1])
        linear_extrude(height = lid_cone_height + 2)
        union() {
            square([slot_len, slot_width], center=true);
            circle(d=center_hole, $fn=32);
        }

        // 90-Degree Snap-Fit Detent Groove (Now on the BOTTOM/Top-inner surface for gravity locking)
        // The Lid rest ledge is a standard T-bar (24mm wide)
        translate([0, 0, lid_cone_height - lid_hub_len - 1])
        linear_extrude(height = 2.0)
        square([slot_width, slot_len], center=true);
    }
}

//====================================================================
// Layout Engine
//====================================================================

if (part == "all_separated") {
    // Render all parts flat on the build plate for support-free printing

    // Bowl: Print right-side up
    translate([-65, -40, 0])
        slug_trap_bowl();

    // Lid: Print upside down
    translate([65, -40, lid_cone_height])
        rotate([180, 0, 0])
        slug_trap_lid();

    // Stick: Print flat on its side
    translate([-75, 45, stick_thickness/2])
        slug_trap_stick();

} else if (part == "assembled") {
    // Render parts fully assembled

    // Stick oriented vertically (stake in ground)
    // Z=0 aligns exactly with the Bowl Rest (X=82 on the stick)
    translate([0, 0, -82])
        rotate([0, -90, 0])
        slug_trap_stick();

    // Bowl sits directly on the Z=0 Bowl Rest
    // Turned 90 degrees to lock into the detent
    rotate([0, 0, 90])
        slug_trap_bowl();

    // Lid sits on the Lid Neck
    // The Lid Neck starts at Stick X=153, which is Z=71 (153 - 82)
    // The Lid's hub bottom sits at Z=71, meaning the Lid base is at Z = 71 - lid_cone_height + 10 (hub len)
    // Lid Base = 71 - 35 + 10 = 46mm
    // Bowl Top = 25mm. Gap = 46 - 25 = 21mm.
    translate([0, 0, 71 - lid_cone_height + 10])
        rotate([0, 0, 90])
        slug_trap_lid();

} else if (part == "bowl") {
    slug_trap_bowl();
} else if (part == "lid") {
    translate([0, 0, lid_cone_height])
        rotate([180, 0, 0])
        slug_trap_lid();
} else if (part == "stick") {
    translate([0, 0, stick_thickness/2])
        slug_trap_stick();
}
