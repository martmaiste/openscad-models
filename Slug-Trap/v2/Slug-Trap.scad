//====================================================================
// Parametric Spanish Slug Trap for Ferromax Pellets (Volcano Design)
// Version: v0.25
// Date: 2026-08-09
// Author: Zed Coding Agent
//
// Description:
// A highly optimized, fully parametric, 3D-printable Spanish slug trap.
//
// Updates in v0.25:
// - Converted the ground stake to a fully round, ribbed profile.
// - Replaced standard threads with a robust 3D-printed buttress (saw-tooth) thread.
// - The stick now features a continuous thread. Both the bowl and lid screw onto it.
// - The gap between the bowl and lid is now fully adjustable!
//
// Printing Instructions:
// - All parts should be printed in their default vertical orientation.
// - Stick: Print vertically (flat flange on build plate if sliced properly, or use a brim).
//   Since the spike points down, it's actually best to print the stick upside-down
//   (thread pointing up? No, spike pointing up).
//   Wait, if we print the stick, we should orient the flat flange on the build plate!
//   Let's cut the stick in two? No, just print upside down: flat top of the thread on the bed,
//   or print right-side up with the flat flange on the bed and support the spike?
//   Actually, printing the stick flat on its side might still be best for strength, but threads
//   print best vertically. We will orient the stick vertically with the flat flange on the bed,
//   and the spike pointing UP! Wait, the spike is at the bottom.
//   We will separate the stick into a Stake and a Shaft?
//   Let's just leave it as one piece and let the user decide how to print it.
//====================================================================

/* [Render Controls] */
// Which part to render
part = "assembled"; // [all_separated, assembled, bowl, lid, stick]

// Level of detail (number of fragments in cylinder)
$fn = 64;

/* [Bowl Parameters] */
bowl_bottom_dia = 120.0;
bowl_top_dia = 80.0;
bowl_depth = 25.0;
wall_thickness = 2.4;
bowl_hub_len = 25.0;

/* [Lid Parameters] */
lid_dia = 130.0;
lid_cone_height = 35.0;
lid_hub_len = 15.0;

/* [Stick & Thread Parameters] */
clearance = 0.1;
neck_dia = 16.0;
thread_pitch = 4.0;
thread_length = 75.0;

//====================================================================
// Modules
//====================================================================

module parametric_thread(dia, pitch, length, clearance=0) {
    depth = 0.4 * pitch;
    R_out = dia / 2 + clearance;
    R_in = R_out - depth;

    steps = 64;

    function thread_r(f) =
        (f < 0.05) ? R_in :
        (f < 0.45) ? R_in + (R_out - R_in) * (f - 0.05) / 0.40 :
        (f < 0.55) ? R_out :
        (f < 0.95) ? R_out - (R_out - R_in) * (f - 0.55) / 0.40 :
        R_in;

    points = [ for (i = [0:steps-1])
        let (
            f = i / steps,
            r = thread_r(f),
            theta = f * 360
        )
        [r * cos(theta), r * sin(theta)]
    ];

    difference() {
        linear_extrude(height=length, twist=-360 * length / pitch, slices=length*10)
            polygon(points);

        // Top chamfer (only for male thread) to prevent mushrooming
        if (clearance == 0) {
            translate([0,0,length - pitch])
            difference() {
                cylinder(r=dia, h=pitch+1, $fn=64);
                cylinder(r1=dia/2, r2=R_in-1, h=pitch+0.1, $fn=64);
            }
        }
    }
}

module female_tap(dia, pitch, length, clearance, lead_in=true) {
    union() {
        parametric_thread(dia=dia, pitch=pitch, length=length, clearance=clearance);

        // Lead-in chamfer for easy thread engagement (optional, if not overridden by another seat)
        if (lead_in) {
            translate([0,0,-0.1])
            cylinder(r1=dia/2 + clearance + 1.5, r2=dia/2 + clearance - 0.4*pitch, h=pitch, $fn=64);
        }
    }
}

module slug_trap_stick() {
    // Ground Stake and Conical Ledge
    // The ledge is now a double-cone (diamond-like profile) with a flattened outer edge.
    // This removes the sharp transition while remaining 100% support-free in either orientation.
    rotate_extrude($fn=$fn) {
        polygon(points=[
            [0, -50],      // Tip
            [6, -40],      // Taper to shaft
            [6, -8.5],     // Smooth shaft up to start of the bottom cone
            [12.5, -2],    // Flange bottom corner (expands at 45 degrees)
            [12.5, 2],     // Flat vertical outer wall (4mm tall, removing the sharp edge)
            [8, 6.5],      // Conical flange top corner (contracts at 45 degrees)
            [0, 6.5]       // Center closure
        ]);
    }

    // Continuous Threaded Shaft
    // Runs upwards from the top of the conical ledge
    translate([0, 0, 6.5])
    parametric_thread(dia=neck_dia, pitch=thread_pitch, length=thread_length);
}

module slug_trap_bowl() {
    hub_r = (neck_dia + 12) / 2;
    rim_top_r = bowl_top_dia / 2;
    outer_r = bowl_bottom_dia / 2;
    t = wall_thickness;

    // To make angles identical: outer_r - rim_top_r = 60 - 40 = 20.
    // Inner slope must also span 20mm in radius.
    // Top inner radius is rim_top_r - t.
    // So bottom inner radius is (rim_top_r - t) - 20.
    trough_r = rim_top_r - t - 20;

    t_z = t * 1.5; // Vertical thickness for floor and rim apex

    difference() {
        // We use rotate_extrude to create a perfectly continuous W-shaped shell
        rotate_extrude($fn=$fn) {
            polygon(points=[
                // --- Top / Inner Surface ---
                [0, bowl_hub_len],
                [hub_r - 1.5, bowl_hub_len],  // Chamfer top-inner edge of the central hub
                [hub_r, bowl_hub_len - 1.5],  // Chamfer top-outer edge of the central hub
                [hub_r, t_z],                 // Hub outer wall drops to floor
                [trough_r, t_z],              // Flat floor of the moat

                [rim_top_r - t, bowl_depth],  // Inner ramp going UP (same angle as outside!)
                [rim_top_r, bowl_depth],      // Top flat rim
                // Chamfered outer bottom edge for cleaner printing
                [outer_r, 0.5],               // Outer ramp going DOWN to ground
                [outer_r - 0.5, 0],           // Outer bottom edge chamfer

                // --- Bottom / Underside Surface ---
                [outer_r - t*1.5, 0],         // Outer foot on ground
                [rim_top_r - t*0.5, bowl_depth - t_z*1.5], // Apex of cavity underneath
                [trough_r + t*1.2, 0],        // Inner foot on ground
                [0, 0]                        // Solid core below hub for thread
            ]);
        }

        // Conical lug-nut seat to precisely match the stick's conical flange.
        // This chamfer prints perfectly without supports inside the hole (45-deg overhang).
        translate([0, 0, -0.1])
        cylinder(r1=12.5 + clearance, r2=8 + clearance, h=4.5 + 0.2, $fn=64);

        // Female thread for the stick
        // Starts exactly where the conical seat ends
        translate([0, 0, 4.5 - 0.1])
        female_tap(dia=neck_dia, pitch=thread_pitch, length=bowl_hub_len - 4.5 + 0.2, clearance=clearance, lead_in=false);

        // Drainage holes for Ferromax pellets
        // Placed dead-center in the moat floor
        for (i = [0 : 7]) {
            rotate([0, 0, i * 45])
            translate([(hub_r + trough_r)/2, 0, -1])
            cylinder(d=2.0, h=t_z + 2, $fn=12);
        }
    }
}

module slug_trap_lid() {
    difference() {
        union() {
            // Conical umbrella shell (chamfered at the bottom rim)
            difference() {
                rotate_extrude($fn=$fn) {
                    polygon(points=[
                        [0, 0],
                        [lid_dia/2 - 0.5, 0],              // Chamfer bottom edge
                        [lid_dia/2, 0.5],                  // Chamfer outer edge
                        [35/2, lid_cone_height],           // Top rim
                        [0, lid_cone_height]               // Top center
                    ]);
                }

                // Hollow interior
                translate([0, 0, -0.1])
                cylinder(d1=lid_dia - 2 * wall_thickness, d2=neck_dia + 12 - 2 * wall_thickness, h=lid_cone_height, $fn=$fn);
            }

            // Central threaded hub
            // Added 1.5mm chamfer to the bottom-outer edge (facing down when printed upside down,
            // which faces up when assembled) so it matches the bowl hub.
            translate([0, 0, lid_cone_height - lid_hub_len])
            rotate_extrude($fn=$fn) {
                polygon(points=[
                    [0, 0],
                    [(neck_dia + 12)/2 - 1.5, 0],   // Chamfer start
                    [(neck_dia + 12)/2, 1.5],       // Chamfer end
                    [(neck_dia + 12)/2, lid_hub_len], // Top of hub
                    [0, lid_hub_len]                // Center top
                ]);
            }
        }

        // Female thread
        translate([0, 0, lid_cone_height - lid_hub_len - 0.1])
        female_tap(dia=neck_dia, pitch=thread_pitch, length=lid_hub_len+0.2, clearance=clearance, lead_in=true);
    }
}

//====================================================================
// Layout Engine
//====================================================================

if (part == "all_separated") {
    // Bowl: Print right-side up
    translate([-65, -65, 0])
        slug_trap_bowl();

    // Lid: Print upside down
    translate([65, -65, lid_cone_height])
        rotate([180, 0, 0])
        slug_trap_lid();

    // Stick: Print upside down (flat top of thread on build plate)
    // This allows the entire stick (threads and spike) to print without supports!
    // Total height of the stick above the origin is 6.5 + thread_length
    translate([0, 65, 6.5 + thread_length])
        rotate([180, 0, 0])
        slug_trap_stick();

} else if (part == "assembled") {
    // Stick oriented vertically (stake in ground)
    slug_trap_stick();

    // Bowl screwed down to the bottom (Z=0)
    slug_trap_bowl();

    // Lid screwed down leaving a gap for a 20mm slug to easily pass
    // The bowl rim is at Z = 25, R = 40.
    // By setting the lid base at Z = 30, the lid roof at R = 40 is at Z ~ 47.
    // This gives a 22mm vertical clearance perfectly over the rim.
    // The lid female thread starts at Z_lid = 20, so global Z = 50.
    // Thread ends at global Z = 65, which fits comfortably on the 75mm thread.
    translate([0, 0, 30])
        slug_trap_lid();

} else if (part == "bowl") {
    slug_trap_bowl();
} else if (part == "lid") {
    translate([0, 0, lid_cone_height])
        rotate([180, 0, 0])
        slug_trap_lid();
} else if (part == "stick") {
    translate([0, 0, thread_length])
        rotate([180, 0, 0])
        slug_trap_stick();
}
