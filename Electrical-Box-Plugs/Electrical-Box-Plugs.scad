// =================================================================================
// Electrical-Box-Plugs.scad
// Parametric Threaded Plugs and Nuts for Electrical Boxes to Close Empty Holes
// Version: v0.11 (2026-06-28)
// License: Creative Commons - Attribution - ShareAlike
// =================================================================================
// Changelog:
// - v0.11: Grouped profiles by name in a single multi-dimensional lookup array
//   to keep all the dimensions of a single size together in one line. This replaces
//   separate, hard-to-maintain ternary chains with a clean, searchable dataset.
// - v0.10: Re-oriented both the plug and the nut to sit in their ideal 3D printing
//   positions: plug is head-down, thread-up; nut is flange-down, hex-up. Both parts
//   now print side-by-side with 100% stability and zero support material required.
// - v0.09: Added smooth horizontal edge chamfering (beveling) for the top and bottom
//   edges of the plug's hex head, and the outer hexagonal edge of the nut.
// - v0.08: Added corner rounding for the hexagon heads (both plug and nut).
//   This is done via a highly efficient 2D hull helper module that maintains exact
//   flat-to-flat sizing so standard wrenches still fit, while making corners smooth.
// - v0.07: Added an integrated circular (round) flange to the flat side of the nut.
//   This acts as a built-in washer face, distributing clamping force evenly across
//   flat rubber seals and eliminating sharp hex corners that could tear or warp the seal.
// - v0.06: Made one face of the nut completely flat (no inner chamfer) to provide a
//   perfect, flush mating surface that compresses flat rubber gaskets/seals against
//   the box wall without pinching. The opposite face retains the inner chamfer for
//   easy thread entry.
// - v0.05: Integrated the circular flange and hexagonal head into a single, unified
//   hexagonal flange head. This eliminates stepped overhangs completely, making the
//   plug incredibly easy to 3D print flat on the bed without any support structures.
// - v0.04: Removed the screwdriver/coin slot from the hex head. Ensured the
//   gasket/seal retention recess is fully optional (toggled via Customizer).
// - v0.03: Upgraded the thread generator to a 360-degree polar-wedge profile.
//   This eliminates the flat bottom valley, producing adjacent, continuous
//   triangular ridges (sawtooth shape) that perfectly match PG and Metric fittings.
// - v0.02: Replaced the 2D Cartesian thread profile with a mathematically perfect
//   polar-wedge profile to solve the "hair-thin" thread thickness bug.
// - v0.01: Initial parametric implementation.
// =================================================================================

/* [General Configuration] */
// Part to generate
part = "both"; // [plug:Plug Only, nut:Nut Only, both:Plug & Nut Side-by-Side]

// Select size profile (select "Custom" to use custom parameters below)
size_profile = "M20"; // [M12, M16, M20, M25, M32, PG7, PG9, PG11, PG13.5, PG16, PG21, Custom]

/* [Custom Dimensions] */
// Custom Thread Outer Diameter (mm) - only used if size_profile is "Custom"
custom_od = 20.0; // [5:0.1:50]
// Custom Thread Pitch (mm) - only used if size_profile is "Custom"
custom_pitch = 1.5; // [0.5:0.01:3.0]
// Custom Flange Diameter (mm) - only used if size_profile is "Custom"
custom_flange_d = 25.0; // [8:0.1:60]
// Custom Wrench/Hex Size across flats (mm) - only used if size_profile is "Custom"
custom_hex_w = 22.0; // [8:0.1:50]

/* [Plug Mechanical Features] */
// Thread length for the plug (mm)
thread_length = 10.0; // [5:0.5:25]

// Flange/Head thickness (mm)
flange_thickness = 4.0; // [2.0:0.5:12]

// Corner rounding radius for the hexagon flats (mm, set to 0 for sharp corners)
corner_rounding = 1.0; // [0.0:0.1:3.0]

// Edge chamfer size for the top/bottom faces of the hexagons (mm, set to 0 for no chamfer)
edge_chamfer = 0.8; // [0.0:0.1:2.0]

// Add a retention recess for a rubber gasket/seal on the underside of the flange?
seal_recess = true;

// Depth of the gasket recess (mm)
recess_depth = 0.5; // [0.2:0.1:2.0]

// Width of the retaining rim on the outer edge of the flange (mm)
rim_width = 1.0; // [0.5:0.1:3.0]

// Radial clearance between thread OD and recess inner wall (mm)
recess_clearance = 0.8; // [0.2:0.1:2.0]

/* [Nut Configuration] */
// Thickness of the nut (mm)
nut_thickness = 6.0; // [3:0.5:15]

// 3D printing clearance for the nut's internal thread (diameter enlargement in mm)
clearance = 0.3; // [0.0:0.05:0.8]

// Add a circular (round) sealing flange to the flat side of the nut?
nut_flange = true;

// Thickness of the nut's circular flange (mm)
nut_flange_thickness = 1.5; // [0.5:0.1:4.0]

/* [Print Quality Settings] */
// Number of segments per thread turn (higher is smoother, lower compiles faster)
thread_fn = 36; // [24, 30, 36, 45, 60]

// Number of segments for round elements like flange/groove
circle_fn = 60; // [36, 45, 60, 90, 120]


// =================================================================================
// PROFILE LOOKUP TABLE
// =================================================================================

// Profiles are grouped by name to keep all dimensions of a single size together.
// Format: [ Name, Thread_OD, Pitch, Flange_Diameter, Wrench_Hex_Size ]
profiles = [
    [ "M12",     12.0, 1.5,   16.0,     14.0 ],
    [ "M16",     16.0, 1.5,   20.0,     18.0 ],
    [ "M20",     20.0, 1.5,   25.0,     22.0 ],
    [ "M25",     25.0, 1.5,   30.0,     27.0 ],
    [ "M32",     32.0, 1.5,   38.0,     34.0 ],
    [ "PG7",     12.5, 1.27,  16.0,     14.0 ],
    [ "PG9",     15.2, 1.411, 19.0,     17.0 ],
    [ "PG11",    18.6, 1.411, 23.0,     20.0 ],
    [ "PG13.5",  20.4, 1.411, 25.0,     22.0 ],
    [ "PG16",    22.5, 1.411, 27.0,     24.0 ],
    [ "PG21",    28.3, 1.588, 34.0,     30.0 ]
];

// Look up selected profile index
profile_indices = search([size_profile], profiles);
profile_idx = (len(profile_indices) > 0) ? profile_indices[0] : -1;

// Extract dimensions (fallback to Custom values if "Custom" or not found)
od = (profile_idx >= 0) ? profiles[profile_idx][1] : custom_od;
pitch = (profile_idx >= 0) ? profiles[profile_idx][2] : custom_pitch;
flange_d = (profile_idx >= 0) ? profiles[profile_idx][3] : custom_flange_d;
hex_w = (profile_idx >= 0) ? profiles[profile_idx][4] : custom_hex_w;


// =================================================================================
// HELPER MODULES
// =================================================================================

// Generates a 3D hexagonal cylinder with rounded vertical corners.
// width: flat-to-flat distance (exact wrench sizing is maintained!)
// height: height of the hexagonal body
// r: rounding radius of the vertical corners
module hexagon_body(width, height, r=1.0) {
    if (r <= 0) {
        cylinder(r=width/2 / cos(30), h=height, $fn=6);
    } else {
        r_clamped = min(r, width/2 - 0.5);
        r_small = (width/2 - r_clamped) / cos(30);

        linear_extrude(height=height) {
            hull() {
                for (a = [0 : 60 : 300]) {
                    translate([r_small * cos(a), r_small * sin(a)])
                        circle(r=r_clamped, $fn=24);
                }
            }
        }
    }
}

// Generates a 3D hexagonal cylinder with both rounded vertical corners and
// smooth horizontal edge chamfers (beveling) on top and/or bottom faces.
module chamfered_hexagon_body(width, height, r=1.0, chamfer=0.8, top=true, bottom=true) {
    Rc = width/2 / cos(30);
    difference() {
        hexagon_body(width, height, r);

        if (top && chamfer > 0) {
            translate([0, 0, height - chamfer])
                difference() {
                    cylinder(r=Rc + 2, h=chamfer + 0.1, $fn=60);
                    cylinder(r1=Rc, r2=Rc - chamfer, h=chamfer + 0.2, $fn=60);
                }
        }

        if (bottom && chamfer > 0) {
            translate([0, 0, -0.1])
                difference() {
                    cylinder(r=Rc + 2, h=chamfer + 0.1, $fn=60);
                    cylinder(r1=Rc - chamfer, r2=Rc, h=chamfer + 0.2, $fn=60);
                }
        }
    }
}

// Generates a helical thread body using a 360-degree polar-wedge 2D profile.
// This maps 2D angular coordinates directly to 3D axial pitch over a full turn.
// A 360-degree wedge results in a continuous sawtooth profile in the axial plane
// (with a base width of exactly 1.0 * pitch), leaving no flat space at the bottom
// of the thread groove. This perfectly matches standard ISO metric and PG V-threads.
module thread_linear_extrude(od, pitch, length, thread_fn=36) {
    r_crest = od / 2;
    depth = 0.6134 * pitch; // Standard thread depth approximation
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

    linear_extrude(height=length, twist=-twist_angle, slices=turns*thread_fn, convexity=10) {
        polygon(points=points);
    }
}

// Generates the threaded plug with an integrated hexagonal head (no stepped flange)
// oriented head-down, thread-up so that the flat head sits flat on the print bed
// for maximum bed adhesion and perfect 100% support-free printing.
module plug(od, pitch, length, flange_d, flange_h, thread_fn=36, circle_fn=60) {
    depth = 0.6134 * pitch;
    r_root = od / 2 - depth;
    chamfer_h = min(1.5, length * 0.2); // Taper at the starting tip of the thread

    union() {
        // --- Integrated Hexagonal Head (Sitting Flat on Bed from z = 0 to flange_h) ---
        difference() {
            // Hex cylinder with rounded corners and top/bottom horizontal chamfers
            chamfered_hexagon_body(width=flange_d, height=flange_h, r=corner_rounding, chamfer=edge_chamfer, top=true, bottom=true);

            // Gasket/Seal retention groove on underside (now at the top face z = flange_h of the head)
            if (seal_recess && flange_h > recess_depth + 0.5) {
                recess_r_outer = flange_d/2 - rim_width;
                recess_r_inner = od/2 + recess_clearance;
                if (recess_r_outer > recess_r_inner) {
                    translate([0, 0, flange_h - recess_depth]) // Subtracted from the top face of the head
                        difference() {
                            cylinder(r=recess_r_outer, h=recess_depth + 0.1, $fn=circle_fn);
                            cylinder(r=recess_r_inner, h=recess_depth + 0.2, $fn=circle_fn);
                        }
                }
            }
        }

        // --- Threaded Body (Rising straight UP from z = flange_h to z = flange_h + length) ---
        translate([0, 0, flange_h]) {
            difference() {
                // Thread helix pointing upwards
                thread_linear_extrude(od=od, pitch=pitch, length=length, thread_fn=thread_fn);

                // Thread starting chamfer (conical subtraction at the top tip of the thread)
                translate([0, 0, length - chamfer_h])
                    difference() {
                        cylinder(r=od + 1, h=chamfer_h + 0.1, $fn=circle_fn);
                        cylinder(r1=od/2 + 0.2, r2=r_root - 0.2, h=chamfer_h + 0.2, $fn=circle_fn);
                    }
            }
        }
    }
}

// Generates the matching hex nut with the circular flange sitting flat on the print bed
// for maximum bed adhesion, flat seal face quality, and perfect 100% support-free printing.
module nut(od, pitch, thickness, hex_w, flange_d, clearance=0.3, thread_fn=36, circle_fn=60) {
    r_inner = (od + clearance) / 2;
    chamfer_d = min(1.0, thickness * 0.2); // Chamfer to make starting the thread easy

    // Nut flange height
    f_h = nut_flange ? nut_flange_thickness : 0;
    hex_h = thickness - f_h;

    difference() {
        union() {
            // Circular sealing flange on the bed (from z = 0 to f_h)
            if (nut_flange) {
                cylinder(r=flange_d/2, h=f_h, $fn=circle_fn);
            }

            // Hex body with rounded corners and top face chamfer (from z = f_h to thickness)
            // Note: The outer hex face is chamfered, leaving the flange mating side flat
            translate([0, 0, f_h])
                chamfered_hexagon_body(width=hex_w, height=hex_h, r=corner_rounding, chamfer=edge_chamfer, top=true, bottom=false);
        }

        // Subtract internal thread
        translate([0, 0, -0.5])
            thread_linear_extrude(od=od + clearance, pitch=pitch, length=thickness + 1, thread_fn=thread_fn);

        // Bottom inner chamfer (makes starting the thread easy from this side)
        translate([0, 0, -0.1])
            cylinder(r1=r_inner + chamfer_d, r2=r_inner - 0.1, h=chamfer_d + 0.1, $fn=circle_fn);

        // Note: The top face of the circular flange (at z = thickness) is kept completely flat (no chamfer)
        // to provide a perfect mating surface for flat rubber gaskets/seals!
    }
}


// =================================================================================
// MAIN ASSEMBLY GENERATION
// =================================================================================

echo("-------------------------------------------------------");
echo(str("Generating size profile: ", size_profile));
echo(str("Thread Outer Diameter: ", od, " mm"));
echo(str("Thread Pitch: ", pitch, " mm"));
echo(str("Hex Head/Flange Width across flats: ", flange_d, " mm"));
echo(str("Hex Nut Width across flats: ", hex_w, " mm"));
echo("-------------------------------------------------------");

if (part == "plug") {
    // Already sitting flat on the print bed (z=0)
    plug(od=od, pitch=pitch, length=thread_length, flange_d=flange_d, flange_h=flange_thickness, thread_fn=thread_fn, circle_fn=circle_fn);
} else if (part == "nut") {
    // Already sitting flat on the print bed (z=0)
    nut(od=od, pitch=pitch, thickness=nut_thickness, hex_w=hex_w, flange_d=flange_d, clearance=clearance, thread_fn=thread_fn, circle_fn=circle_fn);
} else if (part == "both") {
    // Layout plug and nut side-by-side, both sitting flat on the print bed (z=0)
    translate([-flange_d/2 - 5, 0, 0])
        plug(od=od, pitch=pitch, length=thread_length, flange_d=flange_d, flange_h=flange_thickness, thread_fn=thread_fn, circle_fn=circle_fn);

    translate([hex_w/2 + 5, 0, 0])
        nut(od=od, pitch=pitch, thickness=nut_thickness, hex_w=hex_w, flange_d=flange_d, clearance=clearance, thread_fn=thread_fn, circle_fn=circle_fn);
}
