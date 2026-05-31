// =========================================================================
// Parametric Threaded SUP Nozzle Adapter (Simplified with Seal Seat)
// File: SUP-Nozzle/SUP-Nozzle.scad
// Version: v0.01
// Date: 2026-05-27
// Description: Parametric OpenSCAD model for a simplified SUP pump hose adapter.
//              Converts a standard SUP pump male bayonet to a
//              threaded nozzle.
//              Features:
//              - Fully parametric Halkey-Roberts compatible female bayonet
//              - Custom parametric male threads with smooth lead-in chamfer
//              - Clean 4mm circular lip (collar) for the seal to rest on
//              - Dedicated 20mm diameter, 4mm long seal seat on the bayonet cylinder
//              - 100% 3D-printable without supports (optimized overhangs)
// =========================================================================

/* [General Settings] */
// Level of detail (number of fragments for curves)
$fn = 64;

/* [Bayonet Side (Female SUP Connection)] */
// Standard SUP nozzle bayonet outer diameter (mm)
bayonet_outer_dia = 21.0;
// Inner diameter to receive the male hose end (mm)
bayonet_inner_dia = 17.0;
// Total length of the bayonet cylinder section from the lip (mm)
bayonet_length = 24.0;
// Width of the J-slot for locking pins (mm)
slot_width = 6.0;
// Axial depth of the J-slot from the rim (mm)
slot_depth = 13.5;
// Angle of the circumferential rotation for locking (degrees)
slot_angle = 50.0;
// Depth of the small circular locking notch on the ceiling (mm)
notch_depth = 0.5;

/* [Middle Seal Lip (Collar)] */
// Thickness of the collar / lip (mm)
lip_thickness = 4.0;
// Outer diameter of the lip: 4mm radial lip on the 21mm bayonet (21 + 2*4 = 29mm)
lip_dia = 29.0;

/* [Threaded Side] */
// Base outer diameter of the thread cylinder (mm)
thread_base_dia = 20.0;
// Length of the threaded portion (mm)
thread_length = 12.0;
// Height of the thread ridge from the base (mm)
thread_height = 1.0;
// Thickness of the thread ridge (mm)
thread_thickness = 1.3;
// Space between thread turns (mm)
thread_spacing = 2.5;

/* [Internal Air Passage] */
// Internal bore diameter for air passage through the neck/thread (mm)
bore_dia = 14.0;

// =========================================================================
// Calculated Parameters
// =========================================================================
thread_pitch = thread_thickness + thread_spacing;

// =========================================================================
// Main Assembly Execution
// =========================================================================
difference() {
    // 1. Combine all positive solid structures
    union() {
        // Simple circular lip (collar)
        cylinder(d = lip_dia, h = lip_thickness);

        // 20mm diameter, 4mm long seal groove neck on the bayonet side
        translate([0, 0, lip_thickness])
            cylinder(d = 20.0, h = 4.0);

        // Standard bayonet cylinder (OD 21mm, remaining 20mm length)
        translate([0, 0, lip_thickness + 4.0])
            cylinder(d = bayonet_outer_dia, h = bayonet_length - 4.0);

        // Threaded base cylinder (extending in -Z from the lip)
        translate([0, 0, -thread_length])
            cylinder(d = thread_base_dia, h = thread_length);

        // Helical Thread Ridge
        translate([0, 0, -thread_length])
            helical_thread(
                base_dia = thread_base_dia,
                thread_h = thread_height,
                thread_t = thread_thickness,
                pitch = thread_pitch,
                length = thread_length
            );
    }

    // 2. Subtract all negative cutouts
    // Internal hollow air passage with printable 45-degree shoulder transition
    internal_bore();

    // Mirrored Bayonet features (J-slots and funnel ramps) for correct Clockwise (CW) locking
    mirror([0, 1, 0]) {
        // J-slots on the bayonet end
        jslots();

        // Helical lead-in ramps on the top rim (funnels the pins into the slots)
        let(z_front = lip_thickness + bayonet_length) {
            helical_cutout(r = bayonet_outer_dia/2 + 2.0, z_high = z_front, z_low = z_front - 12, angle_start = slot_angle + 60, angle_end = slot_angle + 90+26);
            helical_cutout(r = bayonet_outer_dia/2 + 2.0, z_high = z_front, z_low = z_front - 12, angle_start = slot_angle + 180 + 60, angle_end = slot_angle + 180 + 90+26);
        }
    }

    // Smooth lead-in chamfer at the threaded tip for easy engagement
    translate([0, 0, -thread_length - 0.05])
        tip_chamfer(
            d_outer = thread_base_dia + 2 * thread_height + 0.5,
            d_inner = thread_base_dia - 2.5,
            height = 1.5
        );
}

// =========================================================================
// Module Definitions
// =========================================================================

// Creates the internal hollow passage of the nozzle
module internal_bore() {
    z_front = lip_thickness + bayonet_length;
    // Align internal transition to match the start of the 4mm seal neck
    // under-seal diameter is 20mm, hollowing out with bore_dia (14mm) provides a thick 3mm wall!
    transition_z = lip_thickness + 4.0;
    transition_h = 1.5; // Creates a neat 45-degree angle transition from 14mm to 17mm

    // 1. Threaded side bore (diameter bore_dia)
    translate([0, 0, -thread_length - 1])
        cylinder(d = bore_dia, h = thread_length + transition_z + 1);

    // 2. Printable chamfered shoulder transition (45 degrees)
    translate([0, 0, transition_z])
        cylinder(d1 = bore_dia, d2 = bayonet_inner_dia, h = transition_h);

    // 3. Bayonet side chamber (diameter bayonet_inner_dia)
    translate([0, 0, transition_z + transition_h])
        cylinder(d = bayonet_inner_dia, h = z_front - transition_z - transition_h + 1);
}

// Creates subtractive J-slots for Halkey-Roberts locking pin mechanism
// This perfectly models the swept volume of the circular locking pin for authentic curves.
module jslots() {
    z_front = lip_thickness + bayonet_length;
    z_bottom = z_front - slot_depth + slot_width/2;

    // Generate two symmetric J-slots rotated 180 degrees apart
    for (a = [0, 180]) {
        rotate([0, 0, a]) {
            // 1. Vertical entry channel
            translate([bayonet_inner_dia/2 - 1.0, -slot_width/2, z_bottom])
                cube([(bayonet_outer_dia - bayonet_inner_dia)/2 + 2.0, slot_width, z_front - z_bottom + 1.0]);

            // 2. Horizontal twist slot (flat bottom edge)
            translate([0, 0, z_bottom - slot_width/2])
                rotate_extrude(angle = slot_angle)
                    translate([bayonet_inner_dia/2 - 1.0, 0])
                        square([(bayonet_outer_dia - bayonet_inner_dia)/2 + 2.0, slot_width]);

            // 3. End of horizontal slot rounding
            rotate([0, 0, slot_angle])
                translate([0, 0, z_bottom])
                    rotate([0, 90, 0])
                        cylinder(d = slot_width, h = bayonet_outer_dia/2 + 2.0, $fn=32);

            // 4. Locking notch on the ceiling (allows pin to click upwards into the detent)
            rotate([0, 0, slot_angle])
                translate([0, 0, z_bottom + notch_depth])
                    rotate([0, 90, 0])
                        cylinder(d = slot_width, h = bayonet_outer_dia/2 + 2.0, $fn=32);

            // 5. Clean vertical wall on the right edge to connect the notch and bottom smoothly
            rotate([0, 0, slot_angle])
                translate([bayonet_inner_dia/2 - 1.0, 0, z_bottom])
                    cube([(bayonet_outer_dia - bayonet_inner_dia)/2 + 2.0, slot_width/2, notch_depth]);

            // 6. Entry corner rounding (rounds the inner hook corner for smooth insertion)
            rotate([0, 0, 0])
                translate([0, 0, z_bottom])
                    rotate([0, 90, 0])
                        cylinder(d = slot_width, h = bayonet_outer_dia/2 + 2.0, $fn=32);
        }
    }
}

// Creates a helical ramp cutout for guiding pins into the slots
module helical_cutout(r, z_high, z_low, angle_start, angle_end) {
    steps = 30;
    da = (angle_end - angle_start) / steps;
    dz = (z_high - z_low) / steps;

    for (i = [0 : steps - 1]) {
        a1 = angle_start + i * da;
        a2 = angle_start + (i + 1) * da;
        z1 = z_high - i * dz;
        z2 = z_high - (i + 1) * dz;

        hull() {
            rotate([0, 0, a1]) translate([0, -0.1, z1]) cube([r, 0.2, z_high - z1 + 5.0]);
            rotate([0, 0, a2]) translate([0, -0.1, z2]) cube([r, 0.2, z_high - z2 + 5.0]);
        }
    }
}

// Creates a mathematically precise, 100% solid helical thread ridge
// using a polyhedron sweep to avoid OpenSCAD's linear_extrude rendering bugs.
module helical_thread(base_dia, thread_h, thread_t, pitch, length, start_offset = 1.5) {
    active_length = length - start_offset;
    turns = active_length / pitch;
    total_angle = turns * 360;

    // Smoothness: 36 slices per turn for an incredibly clean finish
    slices_per_turn = 36;
    N = round(turns * slices_per_turn);

    r_actual_base = base_dia / 2;
    r_base = r_actual_base - 0.8; // 0.8mm overlap into the cylinder to ensure a perfect manifold union

    // We taper the thread at both ends (start and stop) over a smooth 60-degree turn
    taper_angle = 60;

    // Generate the vertices of the 3D helical spiral with smooth tapers
    vertices = [
        for (i = [0 : N])
            let(
                angle = i * total_angle / N,
                z = start_offset + i * active_length / N,
                c = cos(angle),
                s = sin(angle),

                // Calculate the taper factor 't' (from 0 at ends to 1 in middle)
                t = (angle < taper_angle) ? (angle / taper_angle) :
                    ((angle > total_angle - taper_angle) ? ((total_angle - angle) / taper_angle) : 1.0),

                active_h = thread_h * t,
                r_proj = r_actual_base + active_h,

                // Trapezoidal thickness: thickest at base (1.3mm), thinnest at crest (0.39mm)
                h_base = thread_t * (0.05 + 0.95 * t),
                h_tip = (thread_t * 0.3) * (0.05 + 0.95 * t)
            )
            for (pt = [
                [r_base, z - h_base/2],                 // 0: inner bottom (deep inside cylinder)
                [r_proj, z - h_tip/2],                  // 1: outer bottom
                [r_proj, z + h_tip/2],                  // 2: outer top
                [r_base, z + h_base/2]                  // 3: inner top
            ])
            [pt[0] * c, pt[0] * s, pt[1]]
    ];

    // Generate the CCW outward-facing faces connecting the slices
    faces = concat(
        [[0, 1, 2, 3]], // Start cap (bottom)
        [
            for (i = [0 : N - 1])
                for (j = [0 : 3])
                    let(
                        next_j = (j + 1) % 4,
                        curr_curr = 4 * i + j,
                        curr_next = 4 * i + next_j,
                        next_curr = 4 * (i + 1) + j,
                        next_next = 4 * (i + 1) + next_j
                    )
                    [curr_curr, next_curr, next_next, curr_next]
        ],
        [[4*N + 3, 4*N + 2, 4*N + 1, 4*N + 0]] // End cap (top)
    );

    polyhedron(points = vertices, faces = faces, convexity = 10);
}

// Creates a subtractive ring to form a clean chamfer on the screw tip
module tip_chamfer(d_outer, d_inner, height) {
    difference() {
        cylinder(d = d_outer + 1.0, h = height + 0.1, center = false);
        cylinder(d1 = d_inner, d2 = d_outer, h = height + 0.1, center = false);
    }
}
