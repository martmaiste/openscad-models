// Pipe Spacer for Anemometer Mount
// Version: v0.02
// Description: Parametric spacer to offset an aluminium pipe from a wall.
// The spacer body is cylindrical to prevent dust accumulation and improve aesthetics.
// The wall side is flat, and the pipe side has a cylindrical cutout to
// cradle and support the 40mm pipe securely. Designed for M8 bolts.

/* [Dimensions] */

// Outer diameter of the aluminium pipe
pipe_od = 40;

// Required offset distance from the wall to the closest edge of the pipe
wall_offset = 2;

// Outer diameter of the cylindrical spacer body
spacer_diameter = 62;

// How deeply the spacer wraps around / cradles the pipe (must be < pipe_od/2)
cradle_depth = 15;

/* [Hardware] */

// Bolt clearance hole diameter (8.5mm provides clearance for an M8 bolt)
bolt_hole_dia = 10.5;

/* [Rendering Settings] */

// Number of facets for cylinders (determines curve smoothness)
$fn = 100;

module pipe_spacer() {
    pipe_r = pipe_od / 2;

    // Total height of the printed body before the concave cutout is subtracted
    total_height = wall_offset + cradle_depth;

    difference() {
        // Main solid body - Cylindrical shape for neatness and dust shedding
        // Centered at X=0, Y=0, extending from Z=0 (the wall surface)
        rotate([0,0,45]) {
            #cylinder(h=total_height, d=spacer_diameter, $fn=4);
        }
        // Concave cutout for the pipe
        // The closest edge of the pipe to the wall is exactly at Z = wall_offset
        // Therefore, the center axis of the pipe is at Z = wall_offset + pipe_r
        // Oriented along the Y-axis to cradle the pipe
        translate([0, 0, wall_offset + pipe_r]) {
            rotate([90, 0, 0]) {
                cylinder(h=spacer_diameter + 2, r=pipe_r, center=true);
            }
        }

        // Center hole for the M8 mounting bolt
        // Passes entirely through the spacer from the wall to the pipe
        translate([0, 0, -1]) {
            cylinder(h=total_height + 2, d=bolt_hole_dia);
        }
    }
}

// Render the final part
pipe_spacer();
