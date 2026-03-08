// Pipe Cap Model
// Version: 0.01
// Description: A parametric cap for a 50mm PVC pipe.

//
// Parameters
//

// The outer diameter of the pipe this cap should fit over
pipe_diameter = 50; // [mm]

// The total length/height of the cap
cap_length = 30; // [mm]

// The thickness of the side walls
wall_thickness = 3; // [mm]

// The thickness of the top surface
top_thickness = 3; // [mm]

// Tolerance for the fit. A positive value creates a looser fit.
// For a press-fit, 0.2 to 0.5 is a good starting range depending on the printer.
fit_tolerance = 0.4; // [mm]

// The amount by which the inner diameter decreases from the bottom to the top.
// This creates a taper on the inside for a snugger fit.
inner_taper = 1; // [mm]

// The resolution of the curves. Higher values create smoother circles.
resolution = 128;


//
// Model
//

$fn = resolution;

difference() {
    // 1. Create the outer solid shape of the cap.
    // The outer diameter is the pipe's diameter, plus tolerance, plus the thickness of two walls.
    outer_diameter = pipe_diameter + fit_tolerance + (2 * wall_thickness);
    cylinder(h = cap_length, d = outer_diameter, center = false);

    // 2. Create the inner void and subtract it.
    // The height is calculated to leave the specified top_thickness.
    // The "+1" is a common technique to ensure a clean boolean subtraction.
    inner_height = cap_length - top_thickness + 1;

    // The inner diameter at the opening includes the tolerance.
    inner_bottom_diameter = pipe_diameter + fit_tolerance;

    // The inner diameter at the top is smaller to create the taper.
    inner_top_diameter = inner_bottom_diameter - inner_taper;

    // We don't need to translate this cylinder as both shapes start at z=0.
    cylinder(h = inner_height, d1 = inner_bottom_diameter, d2 = inner_top_diameter, center = false);
}
