// Spanish Slug Trap
// Version: 3.51 (3rd major version)
// Repository: https://github.com/martmaiste/openscad-models/tree/main/Slug-Trap
// License: MIT

$fn = 128;

// --- VIEW OPTIONS ---
view_mode = "lid"; // ["base": Only base, "lid": Only lid, "both": Both side-by-side, "assembled": Assembled, "cut": Assembled Cross-Section]

// --- PARAMETERS ---
base_diameter = 110;     // Outer diameter of the base wall
base_height = 32;        // Total height of side walls
wall_thickness = 3.0;    // Main wall thickness
ferment_cup_dia = 55;    // Central ferment reservobase, ir outer diameter
chamfer_size = 0.8;      // Chamfer size on outer exposed edges
drain_hole_dia = 2.0;    // Diameter of water drainage holes in pellet floor
slope_height = 2.4;      // Height of slope tapering down to ferment wall

// --- THREAD & CENTRAL TUBE PARAMETERS ---
nail_shaft_hole = 7.0;   // 7mm hole for ground nail inside base central tube and lid
thread_pitch = 3.0;      // Thread pitch in mm
thread_depth = 1.5;      // 1.5mm depth gives a symmetric 90-degree tooth angle (45°/45°)
thread_turns_lid = 2.5;  // Thread turns on lid socket
thread_turns_base = 4.5; // Extended thread turns on base tube
clearance = 0.4;         // Total fit clearance on diameter

tube_outer_dia = 17.4;   // Outer diameter of base central tube
tube_wall_thickness = 2.0;

socket_inner_dia = tube_outer_dia + (thread_depth * 2) + clearance; // 20.8 mm
socket_outer_dia = socket_inner_dia + (tube_wall_thickness * 2);    // 24.8 mm
socket_len = (thread_pitch * (thread_turns_lid + 1));               // 10.5 mm

entry_width = 24;        // Width of entrance slots
entry_height = 18;       // Total height of entrance slots
step_height = 8;         // Height of flat door sill above floor to block rain

// --- HELPER MODULES FOR CHAMFERS ---
module chamfered_cylinder(h, d, c = chamfer_size) {
    union() {
        cylinder(h = c, d1 = d - (c * 2), d2 = d);
        translate([0, 0, c])
        cylinder(h = h - (c * 2), d = d);
        translate([0, 0, h - c])
        cylinder(h = c, d1 = d, d2 = d - (c * 2));
    }
}

// Single-edge chamfered cylinder (Chamfered ONLY at z=0 free edge)
module bottom_chamfer_cylinder(h, d, c = chamfer_size) {
    union() {
        cylinder(h = c, d1 = d - (c * 2), d2 = d);
        translate([0, 0, c])
        cylinder(h = h - c, d = d);
    }
}

// Pipe cylinder with chamfers on both the top-outer and top-inner rims
module top_chamfered_pipe(h, d_outer, d_inner, c = chamfer_size) {
    difference() {
        // Outer body with top-outer chamfer
        union() {
            cylinder(h = h - c, d = d_outer);
            translate([0, 0, h - c])
            cylinder(h = c, d1 = d_outer, d2 = d_outer - (c * 2));
        }

        // Inner bore cutout
        translate([0, 0, -1])
        cylinder(h = h + 2, d = d_inner);

        // Top-inner chamfer cutter
        translate([0, 0, h - c])
        cylinder(h = c + 0.1, d1 = d_inner, d2 = d_inner + (c * 2));
    }
}

// Pipe cylinder with chamfers on top-outer, top-inner, bottom-outer, and bottom-inner rims
module fully_chamfered_pipe(h, d_outer, d_inner, c = chamfer_size) {
    difference() {
        // Outer body with top-outer and bottom-outer chamfers
        union() {
            cylinder(h = c, d1 = d_outer - (c * 2), d2 = d_outer);
            translate([0, 0, c])
            cylinder(h = h - (c * 2), d = d_outer);
            translate([0, 0, h - c])
            cylinder(h = c, d1 = d_outer, d2 = d_outer - (c * 2));
        }

        // Inner bore cutout
        translate([0, 0, -1])
        cylinder(h = h + 2, d = d_inner);

        // Bottom-inner chamfer cutter
        translate([0, 0, -0.1])
        cylinder(h = c + 0.1, d1 = d_inner + (c * 2), d2 = d_inner);

        // Top-inner chamfer cutter
        translate([0, 0, h - c])
        cylinder(h = c + 0.1, d1 = d_inner, d2 = d_inner + (c * 2));
    }
}

// --- WATERTIGHT MANIFOLD TRIANGULATED 90-DEGREE THREAD MODULE ---
module sawtooth_thread(r_base, r_tip, pitch, turns) {
    step_deg = 10;
    steps_per_turn = 360 / step_deg;
    total_steps = floor(turns * steps_per_turn);
    fade_steps = steps_per_turn * (30 / 360); // Crisp fade over 30 degrees

    pts = [
        for (i = [0 : total_steps])
            let (
                a = i * step_deg,
                z = (i / steps_per_turn) * pitch,
                taper_raw = (i < fade_steps) ? (i / fade_steps) :
                            (i > total_steps - fade_steps) ? ((total_steps - i) / fade_steps) : 1.0,
                taper = taper_raw * taper_raw * (3 - 2 * taper_raw),
                curr_r_tip = r_base + (r_tip - r_base) * taper
            )
            each [
                [r_base * cos(a), r_base * sin(a), z],               // 3*i + 0: base bottom
                [curr_r_tip * cos(a), curr_r_tip * sin(a), z + pitch/2], // 3*i + 1: tapered tooth tip
                [r_base * cos(a), r_base * sin(a), z + pitch]        // 3*i + 2: base top
            ]
    ];

    faces = concat(
        [
            for (i = [0 : total_steps - 1])
                let (
                    p0 = 3 * i,
                    p1 = 3 * i + 1,
                    p2 = 3 * i + 2,
                    q0 = 3 * (i + 1),
                    q1 = 3 * (i + 1) + 1,
                    q2 = 3 * (i + 1) + 2
                )
                each [
                    [p0, q0, q1], [p0, q1, p1], // Bottom flank
                    [p1, q1, q2], [p1, q2, p2], // Top flank
                    [p2, q2, q0], [p2, q0, p0]  // Back wall
                ]
        ],
        [
            [0, 1, 2],                                                         // Start cap
            [3*total_steps + 0, 3*total_steps + 2, 3*total_steps + 1]          // End cap
        ]
    );

    polyhedron(points = pts, faces = faces, convexity = 10);
}

module support_free_door_2d() {
    rect_h = entry_height - (entry_width / 2);
    union() {
        translate([-entry_width / 2, 0])
        square([entry_width, rect_h]);

        translate([0, rect_h])
        polygon(points = [
            [-entry_width / 2, 0],
            [entry_width / 2, 0],
            [0, entry_width / 2]
        ]);
    }
}

module main_base() {
    inner_base_wall_dia = base_diameter - (wall_thickness * 2);
    ferment_inner_dia = ferment_cup_dia - (wall_thickness * 2);

    r_in = ferment_cup_dia / 2;
    r_out = inner_base_wall_dia / 2;
    drain_radius = (ferment_cup_dia / 2 + 2.0) + (drain_hole_dia / 2) + 0.1;

    thread_offset_deg_base = 90;
    total_thread_span = (thread_turns_base + 1) * thread_pitch;

    difference() {
        union() {

            // 2. Sloped Floor Wedge in Pellet Trough
            rotate_extrude()
            polygon(points = [
                [r_in, wall_thickness],
                [r_out, wall_thickness],
                [r_out, wall_thickness + slope_height]
            ]);

            // 3. Main Outer Wall (Both bottom-inner and top-inner chamfers)
            difference() {
                chamfered_cylinder(h = base_height, d = base_diameter, c = chamfer_size);
                translate([0, 0, wall_thickness])
                union() {
                    // Bottom-inner chamfer
                    cylinder(h = chamfer_size + 0.1, d1 = inner_base_wall_dia - (chamfer_size * 2), d2 = inner_base_wall_dia);

                    // Main cutout body
                    translate([0, 0, chamfer_size])
                    cylinder(h = base_height - wall_thickness - chamfer_size * 2, d = inner_base_wall_dia);

                    // Top-inner chamfer
                    translate([0, 0, base_height - wall_thickness - chamfer_size])
                    cylinder(h = chamfer_size + 0.1, d1 = inner_base_wall_dia, d2 = inner_base_wall_dia + (chamfer_size * 2));
                }
            }

            // 4. Ferment Reservoir Outer Wall with reinforcing support collars (inside and outside)
            translate([0, 0, wall_thickness])
            difference() {
                union() {
                    // Main pipe body with top-outer chamfer
                    c_size = chamfer_size;
                    h_pipe = base_height - wall_thickness;
                    cylinder(h = h_pipe - c_size, d = ferment_cup_dia);
                    translate([0, 0, h_pipe - c_size])
                    cylinder(h = c_size, d1 = ferment_cup_dia, d2 = ferment_cup_dia - (c_size * 2));

                    // Bottom-outer reinforcing flare
                    flare_h = 2.0;
                    cylinder(h = flare_h, d1 = ferment_cup_dia + (flare_h * 2), d2 = ferment_cup_dia);
                }

                // Straight inner bore cutout (from Z = flare_h to the top)
                flare_h = 2.0;
                translate([0, 0, flare_h])
                cylinder(h = base_height - wall_thickness - flare_h + 1, d = ferment_inner_dia);

                // Bottom-inner reinforcing flare cutout (tapered cone to leave a solid inner support shoulder)
                translate([0, 0, -1])
                cylinder(h = flare_h + 1.1, d1 = ferment_inner_dia - (flare_h * 2), d2 = ferment_inner_dia);

                // Top-inner chamfer cutter
                c_size = chamfer_size;
                h_pipe = base_height - wall_thickness;
                translate([0, 0, h_pipe - c_size])
                cylinder(h = c_size + 0.1, d1 = ferment_inner_dia, d2 = ferment_inner_dia + (c_size * 2));
            }

            // 5. Central Nail Tube Structure (With bottom and top, inner and outer chamfers)
            fully_chamfered_pipe(
                h = base_height,
                d_outer = tube_outer_dia,
                d_inner = nail_shaft_hole
            );

            // 6. Solid reinforcing collar flare around the base of the central tube
            flare_h = 2.0;
            translate([0, 0, wall_thickness])
            cylinder(h = flare_h, d1 = tube_outer_dia + (flare_h * 2), d2 = tube_outer_dia);

            // 7. Male 90-Degree Threads (inside the union so CSG subtraction cuts through the central hole)
            // r_base buried 0.1mm into the tube wall: with r_base exactly at the tube radius the
            // thread back wall lies on the tube's 128-gon surface (vertices coincide), which is a
            // boolean degeneracy that leaves non-manifold slivers in the export.
            translate([0, 0, base_height - total_thread_span])
            sawtooth_thread(
                r_base = (tube_outer_dia / 2) - 0.1,
                r_tip = (tube_outer_dia / 2) + thread_depth,
                pitch = thread_pitch,
                turns = thread_turns_base - (thread_offset_deg_base / 360)
            );
        }

        // SUBTRACTIONS FROM THE BASE
        // A. Entrance doors (ONLY through outer perimeter wall)
        for (a = [0, 45, 90, 135, 180, 225, 270, 315]) {
            rotate([0, 0, a])
            translate([base_diameter / 2 - wall_thickness * 2, 0, wall_thickness + step_height])
            rotate([0, 90, 0])
            rotate([0, 0, 90])
            linear_extrude(height = wall_thickness * 4)
            support_free_door_2d();
        }

        // B. Aroma release slots (ONLY on ferment cup wall)
        for (a = [0 : 22.5 : 337.5]) {
            rotate([0, 0, a])
            translate([ferment_cup_dia / 2, 0, base_height - 6])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness * 3, d = 3.5, center = true);
        }

        // C. Drainage holes through pellet trough floor next to ferment compartment (With top & bottom chamfers)
        chamfer_drain = 0.6;
        for (a = [22.5 : 45 : 337.5]) {
            rotate([0, 0, a])
            translate([drain_radius, 0, 0]) {
                // Through-hole
                translate([0, 0, -1])
                cylinder(h = wall_thickness + slope_height + 2, d = drain_hole_dia);

                // Bottom chamfer (Z = 0)
                translate([0, 0, -0.1])
                cylinder(h = chamfer_drain + 0.1, d1 = drain_hole_dia + (chamfer_drain * 2), d2 = drain_hole_dia);

                // Top chamfer (Z = z_top)
                z_top = wall_thickness + ((drain_radius - r_in) / (r_out - r_in)) * slope_height;
                translate([0, 0, z_top - chamfer_drain + 0.05])
                cylinder(h = chamfer_drain + 0.1, d1 = drain_hole_dia, d2 = drain_hole_dia + (chamfer_drain * 2));
            }
        }

        // D. Ground-facing chamfer on bottom nail hole at Z = 0
        translate([0, 0, -0.1])
        cylinder(h = chamfer_size + 0.1, d1 = nail_shaft_hole + (chamfer_size * 2), d2 = nail_shaft_hole);

        // E. Through-hole for nail shaft through the bottom floor plate and central tube
        translate([0, 0, -1])
        cylinder(h = base_height + 2, d = nail_shaft_hole);

        // F. Counterbore at the top of the central tube to receive the lid's drip-guide lip
        // 45-degree transition cone below the counterbore removes the flat shelf inside the hole,
        // so the slicer prints a self-supporting slope instead of a thin horizontal layer.
        // The cone (z 28.7..29.5) sits below the lip's engagement zone (z 29.5..32), so lid fit is unchanged.
        cb_depth = 2.5;
        cb_dia = nail_shaft_hole + 1.6;
        taper_h = (cb_dia - nail_shaft_hole) / 2; // 45-degree self-supporting angle
        translate([0, 0, base_height - cb_depth])
        union() {
            // Straight counterbore upper section
            cylinder(h = cb_depth + 0.1, d = cb_dia);
            // 45-degree self-supporting transition cone below counterbore
            translate([0, 0, -taper_h])
            cylinder(h = taper_h + 0.01, d1 = nail_shaft_hole, d2 = cb_dia);
        }
    }
}

module rain_roof() {
    lid_inner_dia = base_diameter + clearance;
    lid_lip_height = 1;

    difference() {
        union() {
            // Main Chamfered Roof Shield Plate
            chamfered_cylinder(h = 3, d = lid_inner_dia + 15, c = chamfer_size);

            // Outer Lip
            translate([0, 0, -lid_lip_height])
            difference() {
                bottom_chamfer_cylinder(h = lid_lip_height, d = lid_inner_dia + (wall_thickness * 2), c = chamfer_size);
                translate([0, 0, -1])
                cylinder(h = lid_lip_height + 2, d = lid_inner_dia);
                translate([0, 0, -0.1])
                cylinder(h = chamfer_size + 0.1, d1 = lid_inner_dia + (chamfer_size * 2), d2 = lid_inner_dia);
            }

            // Downward Hollow Socket with reinforcing support collar (flared outside joint)
            translate([0, 0, -socket_len])
            difference() {
                union() {
                    // Bottom-outer chamfer at the tip of the socket (local Z = 0)
                    c_size = chamfer_size / 2;
                    cylinder(h = c_size, d1 = socket_outer_dia - (c_size * 2), d2 = socket_outer_dia);

                    // Main socket cylinder body
                    translate([0, 0, c_size])
                    cylinder(h = socket_len - c_size, d = socket_outer_dia);

                    // Solid reinforcing collar (flares outwards from socket_outer_dia to meet the lid)
                    flare_h = 3.0;
                    translate([0, 0, socket_len - flare_h])
                    cylinder(h = flare_h, d1 = socket_outer_dia, d2 = socket_outer_dia + (flare_h * 2));
                }

                // Hollow inner bore cutout
                translate([0, 0, -1])
                cylinder(h = socket_len + 2, d = socket_inner_dia);

                // Bottom-inner chamfer at the tip of the socket (local Z = 0)
                c_size = chamfer_size / 2;
                translate([0, 0, -0.1])
                cylinder(h = c_size + 0.1, d1 = socket_inner_dia + (c_size * 2), d2 = socket_inner_dia);
            }

            // Female 90-Degree Threads starting 50 degrees above the socket tip
            // Female Threads
            // r_base buried 0.1mm outward into the socket wall (same degeneracy as the base:
            // a back wall exactly on the socket inner surface produced non-manifold edges in the export).
            thread_offset_deg = 50;
            translate([0, 0, -socket_len + (thread_offset_deg / 360) * thread_pitch])
            rotate([0, 0, thread_offset_deg])
            sawtooth_thread(
                r_base = socket_inner_dia / 2 + 0.1,
                r_tip = (socket_inner_dia / 2) - thread_depth,
                pitch = thread_pitch,
                turns = thread_turns_lid - (thread_offset_deg / 360)
            );

            // Downward drip-guide lip (fits inside base's central counterbore to guide water)
            translate([0, 0, -2.5])
            cylinder(h = 2.5, d1 = nail_shaft_hole + 0.6, d2 = nail_shaft_hole + 1.2);
        }

        // Through-hole for ground nail shaft
        translate([0, 0, -socket_len - 2])
        cylinder(h = socket_len + 10, d = nail_shaft_hole);

        // Chamfer on the nail hole at the drip-guide lip tip (local Z = -2.5)
        translate([0, 0, -2.5 - 0.1])
        cylinder(h = (chamfer_size / 2) + 0.1, d1 = nail_shaft_hole + chamfer_size, d2 = nail_shaft_hole);

        // Chamfer on the sky-facing top surface (Local Z=3 plane)
        translate([0, 0, 3 - chamfer_size])
        cylinder(h = chamfer_size + 0.1, d1 = nail_shaft_hole, d2 = nail_shaft_hole + (chamfer_size * 2));
    }
}

// --- RENDER LOGIC ---
module cross_section_cut() {
    difference() {
        children();
        // Cut away Y < 0 half to expose internal cross-section
        translate([-200, -400, -100])
        cube([400, 400, 200]);
    }
}

if (view_mode == "base") {
    main_base();
} else if (view_mode == "lid") {
    // Oriented flat on the print bed
    translate([0, 0, 3])
    rotate([180, 0, 0])
    rain_roof();
} else if (view_mode == "both") {
    // Both side-by-side on the print bed, 5 mm apart
    both_gap = 5;
    lid_plate_dia = base_diameter + clearance + 16; // Matches rain_roof roof plate diameter
    main_base();
    translate([(base_diameter + lid_plate_dia) / 2 + both_gap, 0, 3])
    rotate([180, 0, 0])
    rain_roof();
} else if (view_mode == "assembled") {
    main_base();
    translate([0, 0, base_height])
    rain_roof();
} else if (view_mode == "cut") {
    cross_section_cut() {
        main_base();
        translate([0, 0, base_height])
        rain_roof();
    }
}
