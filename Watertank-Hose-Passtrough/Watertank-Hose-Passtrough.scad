// ==========================================
// Parametric Water Hose Tank Passthrough
// Version: 0.35
// ==========================================

$fn = 64; // Smoothness for cylindrical parts

// --- PARAMETERS ---
// Part to generate (each part prints in its own optimal orientation)
part = "passthrough"; // [passthrough:Tank Passthrough, nut:G 1/2" Nut]

cut_view = false;    // true = slice model in half to inspect internal channels

// G 1/2" companion nut
nut_af = 27;             // Nut hex width across flats (mm) - standard G 1/2" hex
nut_thick = 8;           // Nut thickness (mm)
nut_clearance = 0.4;     // Diametral print clearance for internal thread (mm)
nut_flange = true;       // Add round sealing flange for the washer?
nut_flange_d = 32;       // Flange diameter (mm)
nut_flange_thick = 1.5;  // Flange thickness (mm)

// Top Hose Barb
top_base_d = 11;     // Base diameter (mm)
top_tip_d = 8;       // Tip diameter (mm)
top_len = 28;        // Total length of top barb (mm)
top_barbs = 4;       // Number of barb ridges

// Hex Flange & Washer Seating Flanges
flange_af = 30;      // Width across flats (mm)
flange_thick = 5;    // Flange thickness (mm)
washer_flange_thick = 0.5; // Thickness of round washer flanges on both sides
washer_flange_d = flange_af - 1; // 1mm smaller than the hex across flats

// Threaded Shaft (Tank Wall Mount) - G 1/2" BSPP parallel pipe thread
thread_d = 20.955;   // G 1/2" outer (major) diameter (mm)
thread_len = 18;     // Length of threaded shaft (mm)
thread_pitch = 2.309;  // G 1/2" pitch (mm, 11 TPI = 1/11")
tooth_depth = 0.6403 * thread_pitch; // Whitworth 55-deg V thread depth (~1.48mm)
thread_core_d = thread_d - (2 * tooth_depth); // Bottom/root diameter of the thread (~18mm)

// Internal Bore (Water Flow Hole)
bore_d = 7.0;          // Inner through-hole diameter (mm)

// Bottom Connection
bottom_base_angle = 45; // Bottom barb angle: 0 = straight down, 90 = 90-degree elbow sideways
bottom_len = 30;     // Length of bottom barb (mm)
bottom_base_d = 11;  // Bottom barb base diameter (mm)

// --- MODULES ---

// Top barb (pointing upward / outward from flange)
module hose_barb(base_d, tip_d, length, count, skip_base = false) {
    step = length / count;
    barb_h = step * 0.7;
    union() {
        cylinder(h=length, d1=base_d, d2=tip_d);
        for (i = [0 : count - 1]) {
            if (!(skip_base && i == 0)) {
                z_start = i * step + step * 0.3;
                z_end = z_start + barb_h;
                if (z_end <= length) {
                    d_core_start = base_d - (base_d - tip_d) * (z_start / length);
                    d_core_end = base_d - (base_d - tip_d) * (z_end / length);
                    translate([0, 0, z_start])
                    cylinder(h=barb_h, d1=d_core_start + 1.8, d2=d_core_end);
                }
            }
        }
    }
}

// Bottom straight barb (pointing downward, correctly inverted taper & shoulders)
module bottom_hose_barb(base_d, tip_d, length, count, skip_base = false) {
    step = length / count;
    barb_h = step * 0.7;
    union() {
        cylinder(h=length, d1=tip_d, d2=base_d);
        for (i = [0 : count - 1]) {
            if (!(skip_base && i == count - 1)) {
                z_start = i * step + step * 0.1;
                z_end = z_start + barb_h;
                if (z_end <= length) {
                    d_core_start = tip_d + (base_d - tip_d) * (z_start / length);
                    d_core_end = tip_d + (base_d - tip_d) * (z_end / length);
                    translate([0, 0, z_start])
                    cylinder(h=barb_h, d1=d_core_start, d2=d_core_end + 1.8);
                }
            }
        }
    }
}

module hex_prism(af, h) {
    r = (af / 2) / cos(30);
    cylinder(h=h, r=r, $fn=6);
}

// Generates a helical V-thread body using a 360-degree polar-wedge 2D
// profile (from Electrical-Box-Plugs.scad). Maps 2D angular coordinates directly
// to 3D axial pitch over a full turn, producing a continuous sawtooth axial profile
// with a base width of exactly 1.0 * pitch (works for PG and pipe V-threads).
// Adjust the depth constant in tooth_depth for the thread form (0.6403*pitch for
// 55-deg Whitworth/G-pipe, 0.6134*pitch for 60-deg metric).
module pg_thread(od, pitch, length, $fn=36) {
    r_crest = od / 2;
    depth = 0.6403 * pitch; // Whitworth 55-deg V thread depth
    r_root = r_crest - depth;

    turns = length / pitch;
    twist_angle = turns * 360;

    // Wedge steps - 36 steps is perfect for 360 degrees
    wedge_steps = 36;

    // 360-degree wedge representing the sharp sawtooth thread profile
    points = [
        for (i = [0 : wedge_steps])
            let (
                angle = -180 + i * 360 / wedge_steps,
                t = 1 - abs(angle) / 180,
                r = r_root + (r_crest - r_root) * t
            )
            [ r * cos(angle), r * sin(angle) ]
    ];

    linear_extrude(height=length, twist=-twist_angle, slices=turns*$fn, convexity=10) {
        polygon(points=points);
    }
}

// Matching hex nut with internal helical thread. With nut_flange enabled, one
// face is a flat round washer seat (no chamfer); the opposite face keeps the
// entry chamfer for easy thread starts.
module thread_nut(od, pitch, thickness, af, clearance) {
    r_hole = (od + clearance) / 2;  // Crest radius of the internal thread hole
    cham = 1.2;                     // Thread entry chamfer size
    f_h = nut_flange ? nut_flange_thick : 0; // Flange height
    hex_h = thickness - f_h;        // Remaining hex body height

    difference() {
        union() {
            // Round sealing flange sitting flat on the bed (washer face)
            if (nut_flange) {
                cylinder(h=f_h, d=nut_flange_d);
            }

            // Hex body above the flange
            translate([0, 0, f_h])
            hex_prism(af, hex_h);
        }

        // Internal helical thread (wedge profile includes the core, so this
        // subtracts both the bore and the thread groove in one cut)
        translate([0, 0, -0.5])
        pg_thread(od + clearance, pitch, thickness + 1);

        if (nut_flange) {
            // Top entry chamfer only - the flange face stays completely flat
            // to seat the sealing washer evenly
            translate([0, 0, thickness - cham])
            cylinder(h=cham + 0.1, r1=r_hole - 0.1, r2=r_hole + cham);
        } else {
            // Entry chamfers on both faces
            translate([0, 0, -0.1])
            cylinder(h=cham + 0.1, r1=r_hole + cham, r2=r_hole - 0.1);

            translate([0, 0, thickness - cham])
            cylinder(h=cham + 0.1, r1=r_hole - 0.1, r2=r_hole + cham);
        }
    }
}

module tank_passthrough() {
    difference() {
        union() {
            // 1. Top Hose Barb (shifted up to account for top washer flange)
            translate([0, 0, flange_thick + thread_len + washer_flange_thick])
            hose_barb(top_base_d, top_tip_d, top_len, top_barbs);

            // Top Round Washer Flange (1mm smaller than hex across flats)
            translate([0, 0, thread_len + flange_thick])
            cylinder(h=washer_flange_thick, d=washer_flange_d);

            // 2. Hex Flange
            translate([0, 0, thread_len])
            hex_prism(flange_af, flange_thick);

            // Bottom Round Washer Flange (1mm smaller than hex across flats)
            translate([0, 0, thread_len - washer_flange_thick])
            cylinder(h=washer_flange_thick, d=washer_flange_d);

            // 3. G 1/2" Threaded Shaft (Shank) from z = 0 to z = thread_len
            translate([0, 0, 0])
            pg_thread(thread_d, thread_pitch, thread_len);

            // 4. Bottom Connection (Continuous conical taper from thread root down to bottom barb base)
            translate([0, 0, -13])
            cylinder(h=13, d1=bottom_base_d, d2=thread_core_d);

            if (bottom_base_angle == 0) {
                translate([0, 0, -13 - bottom_len])
                bottom_hose_barb(bottom_base_d, bottom_base_d - 3, bottom_len, 3, skip_base = true);
            } else {
                elbow_z = -13 + bottom_base_d/2;
                translate([0, 0, elbow_z])
                rotate([0, 180 - bottom_base_angle, 0])
                hose_barb(bottom_base_d, bottom_base_d - 3, bottom_len, 3, skip_base = true);
            }
        }

        // --- INTERNAL WATER BORE ---
        union() {
            if (bottom_base_angle == 0) {
                // Through-hole for straight hose connector configuration
                translate([0, 0, -bottom_len - 20])
                cylinder(h=thread_len + top_len + bottom_len + 40, d=bore_d);
            } else {
                // Blind vertical bore + angled branch bore
                elbow_z = -13 + bottom_base_d/2;
                bore_bottom_z = elbow_z - bore_d/2;
                total_top_z = flange_thick + thread_len + top_len + washer_flange_thick + 5;
                
                translate([0, 0, bore_bottom_z])
                cylinder(h=total_top_z - bore_bottom_z, d=bore_d);

                translate([0, 0, elbow_z])
                rotate([0, 180 - bottom_base_angle, 0])
                cylinder(h=bottom_len + 5, d=bore_d);
            }
        }
    }
}

// Render the selected part (with optional cut view)
if (part == "nut") {
    // Nut stands on its hex face, support-free
    if (cut_view) {
        difference() {
            thread_nut(thread_d, thread_pitch, nut_thick, nut_af, nut_clearance);
            translate([-50, -100, -20])
            cube([100, 100, 100]);
        }
    } else {
        thread_nut(thread_d, thread_pitch, nut_thick, nut_af, nut_clearance);
    }
} else if (cut_view) {
    difference() {
        tank_passthrough();
        // Slices away the Y < 0 half to reveal internal channels
        translate([-50, -100, -60])
        cube([100, 100, 150]);
    }
} else {
    tank_passthrough();
}