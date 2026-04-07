//
// Parametric Unlocking Pin Spacer for Chinese Battery Tools
// Version 0.04
//

// -- Global Parameters --
// You can adjust these values to customize the spacer.

// Total length of the spacer along the Y-axis.
spacer_length = 5; // [mm]

// Width of the bottom part of the spacer along the X-axis.
bottom_width = 13; // [mm]

// Thickness (height) of the bottom part along the Z-axis.
bottom_thickness = 1; // [mm]

// Width of the top part of the spacer along the X-axis.
top_width = 10; // [mm]

// Thickness (height) of the top part along the Z-axis.
top_thickness = 1; // [mm]

// The size of the chamfer cut. For a 45-degree chamfer,
// the horizontal and vertical extent of the cut are equal.
// We set it to the top_thickness to create a full 45-degree chamfer.
chamfer_size = top_thickness; // [mm]


// -- Model Definition --

// The main module for creating the spacer.
// It combines a bottom and top part, then subtracts a chamfer.
module unlocking_pin_spacer() {
    // The difference() function is used to subtract the chamfer cutter
    // from the main body of the spacer.
    difference() {
        // The main body is created by uniting the bottom and top parts.
        union() {
            // 1. Bottom Part
            // A simple cube for the base.
            // It is translated to be centered along the X-axis for symmetry.
            translate([-bottom_width / 2, 0, 0]) {
                cube([bottom_width, spacer_length, bottom_thickness]);
            }

            // 2. Top Part
            // Another cube that sits on top of the bottom part.
            // It is also centered along the X-axis.
            translate([-top_width / 2, 0, bottom_thickness]) {
                cube([top_width, spacer_length, top_thickness]);
            }
        }

        // 3. Chamfer Cutter
        // A large cube rotated by 45 degrees creates a completely clean chamfer.
        // To prevent any "skin" or rendering artifacts from co-planar faces,
        // the origin of the cutter is shifted down and away from the part along
        // the cutting plane. This ensures the cut starts completely outside the
        // part and slices infinitely through the corner.
        cutter_width = bottom_width + 10;
        translate([-cutter_width / 2, spacer_length + chamfer_size, bottom_thickness - chamfer_size]) {
            rotate([45, 0, 0]) {
                // A sufficiently large cube to slice off the entire corner
                cube([cutter_width, 10, 10]);
            }
        }
    }
}


// -- Render the Model --
// Call the module to generate the final geometry.
unlocking_pin_spacer();
