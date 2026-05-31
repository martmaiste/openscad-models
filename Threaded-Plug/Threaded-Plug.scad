/*
================================================================================
                       PARAMETRIC G3/4" THREADED PLUG
                            Version: v0.01
       Designed for sealing washing machine water inlets and hose couplings
================================================================================

This is a parametric, self-contained OpenSCAD model for a G3/4" threaded plug.
It features a long knurled knob head optimized for tightening and loosening by
hand, without requiring a wrench.

--------------------------------------------------------------------------------
RECOMMENDED PRINT SETTINGS & MATERIAL INSTRUCTIONS:
--------------------------------------------------------------------------------
1. MATERIAL:
   - PETG, ABS, or ASA are highly recommended for plumbing applications.
   - PLA is not recommended for long-term pressurized water use.
2. INFILL & PERIMETERS:
   - Use at least 4-6 perimeters (wall lines) to ensure the plug is watertight.
   - Infill should be high (50% to 100%) for mechanical strength.
3. ORIENTATION:
   - Print with the flat head/knob sitting on the bed and the threads pointing
     upwards. This orientation requires ZERO supports and ensures the sealing
     face of the flange is extremely smooth and flat.
4. SEALING:
   - Always use a standard rubber/silicone washer inside the female connector.
   - For an extra reliable seal, wrap a few turns of PTFE (Teflon) plumber's
     tape around the threads before screwing it in.
================================================================================
*/

/* [Thread Settings] */

// Thread standard (Washing Machine standard is G3/4 BSP)
thread_standard = "G3/4"; // [G3/4: "G3/4 BSP (Washing Machine Standard)", GHT3/4: "3/4\" GHT (Garden Hose Standard)", Custom: "Custom Thread"]

// Major diameter (mm) - only used if Custom standard is selected
custom_major_diameter = 26.44;

// Pitch in mm (14 TPI = 1.8143mm, 11.5 TPI = 2.2087mm) - only used if Custom standard is selected
custom_pitch = 1.8143;

// Total length of the threaded portion (mm)
thread_length = 11.5;

// Outer diameter clearance/tolerance (mm) - increase if thread is too tight, decrease if too loose
thread_tolerance = 0.15;

/* [Knob Head & Sealing Flange] */

// Height of the knurled knob head (mm) - long design for easy hand grip
knob_height = 16.0;

// Outer diameter of the knurled knob head (mm)
knob_diameter = 32.0;

// Number of vertical knurling ridges around the knob
knurling_ridges = 36;

// Depth of the knurling ridges (mm)
knurling_depth = 0.6;

// Diameter of the sealing flange/shoulder (mm) - should be wider than the thread to press the gasket
flange_diameter = 29.5;

// Thickness of the sealing flange (mm)
flange_thickness = 2.5;

/* [Quality / Resolution] */

// Number of steps per 360-degree turn (higher means smoother threads but slower rendering)
steps_per_turn = 60; // [30:Draft, 60:Medium, 120:High]

/* [Hidden] */
$fn = steps_per_turn;

// --- DYNAMIC CALCULATIONS ---

// Extract standard thread parameters based on user selection
major_dia = (thread_standard == "G3/4") ? 26.441 - thread_tolerance :
            (thread_standard == "GHT3/4") ? 26.987 - thread_tolerance :
            custom_major_diameter - thread_tolerance;

pitch = (thread_standard == "G3/4") ? 1.8143 :
        (thread_standard == "GHT3/4") ? 2.2087 :
        custom_pitch;

// --- MAIN GENERATION ---

union() {
    // 1. Knurled Grip Head (Knob)
    knurled_cylinder(d=knob_diameter, h=knob_height, ridges=knurling_ridges, depth=knurling_depth);

    // 2. Sealing Flange / Shoulder (Provides flat surface for rubber gasket)
    translate([0, 0, knob_height]) {
        // Flat flange with a small transition chamfer on the bottom/outer edge
        cylinder(d1=knob_diameter, d2=flange_diameter, h=0.5);
        translate([0, 0, 0.5])
            cylinder(d=flange_diameter, h=flange_thickness - 0.5);
    }

    // 3. Threaded Shaft (Positioned above the flange)
    translate([0, 0, knob_height + flange_thickness]) {
        threaded_shaft(diameter=major_dia, pitch=pitch, length=thread_length, steps=steps_per_turn);
    }
}

// --- HELPER MODULES ---

// Generates a knurled cylinder with vertical grip ridges
module knurled_cylinder(d, h, ridges, depth) {
    difference() {
        cylinder(d=d, h=h);
        // Cut vertical 90-degree triangular grooves into the cylinder edge
        for (i = [0 : ridges - 1]) {
            rotate([0, 0, i * 360 / ridges])
            translate([d/2, 0, h/2])
            rotate([0, 0, 45])
            cube([depth * sqrt(2), depth * sqrt(2), h + 2], center=true);
        }
    }
}

// Generates the solid core and the tapered thread helix
module threaded_shaft(diameter, pitch, length, steps) {
    depth = pitch * 0.61;
    r_outer = diameter / 2;
    r_inner = r_outer - depth;

    // Smooth chamfer at the tip of the core cylinder to guide thread start
    chamfer_h = min(1.5, length * 0.15);

    union() {
        // Solid core cylinder with tapered tip
        cylinder(r=r_inner, h=length - chamfer_h, $fn=steps);
        translate([0, 0, length - chamfer_h])
            cylinder(r1=r_inner, r2=r_inner - 1.0, h=chamfer_h, $fn=steps);

        // Helical thread geometry
        male_thread(diameter=diameter, pitch=pitch, length=length, steps_per_turn=steps);
    }
}

// Generates a watertight thread polyhedron with tapered entry and exit
module male_thread(diameter, pitch, length, steps_per_turn) {
    depth = pitch * 0.61;
    crest_flat = pitch * 0.125;
    r_outer = diameter / 2;
    r_inner = r_outer - depth;

    // Ensure we have at least 1 turn
    turns = max(1.0, (length - pitch) / pitch);
    total_steps = ceil(turns * steps_per_turn);
    dz = pitch / steps_per_turn;
    step_angle = 360 / steps_per_turn;

    // Calculate all vertex positions along the helical path
    vertices = [
        for (i = [0 : total_steps])
        let (
            a = i * step_angle,
            z = i * dz,

            // Apply smoothing/taper over the first and last turn
            taper_start = (i < steps_per_turn) ? (0.01 + 0.99 * i / steps_per_turn) : 1.0,
            taper_end = (i > total_steps - steps_per_turn) ? (0.01 + 0.99 * (total_steps - i) / steps_per_turn) : 1.0,
            taper = min(taper_start, taper_end),

            r_out_eff = r_inner + (r_outer - r_inner) * taper,
            cf_eff = crest_flat * taper,

            // Four points of the trapezoidal thread tooth cross-section
            v0 = [ r_inner * cos(a), r_inner * sin(a), z ],
            v1 = [ r_out_eff * cos(a), r_out_eff * sin(a), z + (pitch - cf_eff)/2 ],
            v2 = [ r_out_eff * cos(a), r_out_eff * sin(a), z + (pitch + cf_eff)/2 ],
            v3 = [ r_inner * cos(a), r_inner * sin(a), z + pitch ]
        )
        each [v0, v1, v2, v3]
    ];

    // Define the faces connecting the vertices to form a closed watertight volume
    faces = [
        // Start cap (flat face at z = 0)
        [0, 1, 2, 3],

        // Helical segments wrapping around the cylinder
        for (i = [0 : total_steps - 1])
        each [
            [4*i + 0, 4*(i+1) + 0, 4*(i+1) + 1, 4*i + 1], // Bottom flank (slanted face)
            [4*i + 1, 4*(i+1) + 1, 4*(i+1) + 2, 4*i + 2], // Crest flat (outer face)
            [4*i + 2, 4*(i+1) + 2, 4*(i+1) + 3, 4*i + 3], // Top flank (slanted face)
            [4*i + 0, 4*i + 3, 4*(i+1) + 3, 4*(i+1) + 0]  // Inner core (cylinder face)
        ],

        // End cap (flat face at z = length)
        [4*total_steps + 3, 4*total_steps + 2, 4*total_steps + 1, 4*total_steps + 0]
    ];

    polyhedron(points=vertices, faces=faces, convexity=10);
}
