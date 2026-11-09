// ===================================================================
// File: washer_with_locator.scad
// Version: v0.04
// Description: Parametric and modular washer with a fixed global shape 
//              switch for square or round centering sections.
// ===================================================================

// --- GLOBAL PARAMETERS ---
$fn = 120; // Rendering resolution for smooth circles/corners

// Washer parameters
WASHER_OD = 12.0;    // Washer Outer Diameter (mm)
WASHER_ID = 6.5;     // Washer Inner Hole Diameter (mm)
WASHER_T  = 1.5;     // Washer Thickness (mm)

// Centering section type: "square" or "round"
LOCATOR_SHAPE  = "square"; // Muuda siin: "square" või "round"

// Square centering section parameters
LOCATOR_SIZE   = 8.0;     // Square side length (mm)
LOCATOR_RADIUS = 2.0;     // Corner radius (mm)

// Round centering section parameters (for adapting to a bigger round hole)
LOCATOR_OD     = 10.0;    // Outer diameter of the round centering collar (mm)

// Centering section thickness / height
LOCATOR_T      = 1.0;     // Thickness of the centering section (mm)


// --- MODULAR COMPONENTS ---

/**
 * Creates a 2D rounded square centered at the origin.
 */
module rounded_square_2d(size, r) {
    offset(r = r) {
        square([size - 2 * r, size - 2 * r], center = true);
    }
}

/**
 * Creates a washer with an integrated centering section (square or round).
 */
module washer_with_locator(
    od = WASHER_OD,
    id = WASHER_ID,
    t_washer = WASHER_T,
    shape = "square",
    loc_size = LOCATOR_SIZE,
    loc_r = LOCATOR_RADIUS,
    loc_od = LOCATOR_OD,
    t_loc = LOCATOR_T
) {
    difference() {
        union() {
            // Main Washer Body
            cylinder(d = od, h = t_washer);
            
            // Centering Section (Square or Round) on top of the washer body
            translate([0, 0, t_washer])
                linear_extrude(height = t_loc) {
                    if (shape == "round") {
                        circle(d = loc_od);
                    } else {
                        rounded_square_2d(loc_size, loc_r);
                    }
                }
        }
        
        // Continuous Center Hole for the Bolt
        translate([0, 0, -0.1])
            cylinder(d = id, h = t_washer + t_loc + 0.2);
    }
}


// --- MAIN INSTANTIATION ---
// Kasutab automaatselt faili alguses määratud LOCATOR_SHAPE väärtust
washer_with_locator(shape = LOCATOR_SHAPE);