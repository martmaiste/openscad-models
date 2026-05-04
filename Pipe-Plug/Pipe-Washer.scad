// Pipe-Washer.scad
// Version: v0.04
//
// Description:
// A parametric washer designed to fit between a pipe and a flat metal washer.
// One side is flat, and the other is curved to match the pipe's outer surface.
// This version adds a fix to allow for "over-sized" washers (e.g., a square
// washer) where the outer dimension is larger than the pipe diameter.

// --- Main Parameters ---

// The outer diameter of the pipe this washer will sit on.
pipe_od = 40;      // [mm]

// The outer diameter (or width for a square) of the washer.
// Can now be larger than pipe_od.
washer_od = 44;    // [mm]

// The inner diameter for the bolt to pass through (e.g., M10 with clearance).
washer_id = 10.5;  // [mm]

// The thinnest part of the washer, located at its central axis.
min_thickness = 2; // [mm]


// --- Quality Settings ---

// Set the default resolution for curved surfaces.
// This is overridden later for the square washer shape.
$fn = 100;


// --- Calculated Variables ---

// Calculate radii from diameters for easier use in OpenSCAD functions.
pipe_r = pipe_od / 2;
washer_r = washer_od / 2;
washer_ir = washer_id / 2;

// --- Robust Geometry Calculation ---
// FIX: To prevent a math error (sqrt of a negative number), we must ensure
// the radius used for the curve calculation is not greater than the pipe's radius.
// We use the 'min()' function to select the smaller of the two.
// This means if the washer is wider than the pipe, the corners will be flat.
real_curve_r = min(washer_r, pipe_r);

// Calculate the height difference based on the safe radius.
height_difference = pipe_r - sqrt(pow(pipe_r, 2) - pow(real_curve_r, 2));

// The maximum thickness of the washer is at its outermost curved edge.
// The "-1" provides a simple 1mm chamfer on the top edge.
max_thickness = min_thickness + height_difference;


// --- Model Generation ---

// The model is constructed with its flat top surface near the z=0 plane.
difference() {
    // 1. The washer "blank".
    // This is a hollow shape that we will cut the curve into.
    translate([0, 0, -max_thickness]) {
        difference() {
            // Main outer body.
            // Rotated by 45 degrees and using $fn=4 to create a square shape.
            // To make it a round washer again, remove the rotate() and the $fn=4.
            rotate([0, 0, 45]) {
              cylinder(h = max_thickness, r = washer_r, $fn=4);
            }
            // Inner hole for the bolt.
            // Made taller to ensure a clean cut all the way through the blank.
            translate([0, 0, -1]) {
                cylinder(h = max_thickness + 2, r = washer_ir);
            }
        }
    }

    // 2. The "cutter" that forms the curved bottom surface.
    // This is a cylinder with the pipe's radius, rotated on its side.
    // It is positioned to carve the curve into the bottom of the blank.
    translate([0, 0, -min_thickness - pipe_r]) {
        rotate([90, 0, 0]) {
            // The cutter cylinder must be long enough to span the entire washer.
            cylinder(h = washer_od * 1.5, r = pipe_r, center = true);
        }
    }
}
