// --- PARAMETRIC ELECTRICAL CABINET KEY ---
// Version: 1.24
// Changes: Lanyard hole is now permanent, code simplified.

/* [Shaft Parameters] */
// Diameter of the shaft and handle (mm)
shaft_dia = 15;        // [10:1:25]
// Length of the shaft until the handle axis (mm)
shaft_length = 50;     // [30:1:100]
// Side length of the square socket (mm)
square_size = 7.2;     // [4:0.1:12]
// Depth of the straight part of the square socket (mm)
square_depth = 10;     // [5:1:20]
// Small pyramid entry chamfer (mm)
socket_entry_chamfer = 0.5; // [0:0.1:4]
// Outer chamfer size for the shaft tip (mm)
shaft_outer_chamfer = 1.5; // [0:0.1:4]

/* [Handle Parameters] */
// Total length of the handle (mm)
handle_length = 80;   // [50:1:150]
// Size of the reinforcements (Gussets)
support_size = 12;     // [5:1:25]
// Flat cut on top for bed adhesion (mm)
handle_flat_cut = 1.0; // [0:0.1:5]

/* [Lanyard Hole] */
// Diameter of the hole (mm)
hole_dia = 5;          // [2:0.1:10]
// Width of the hole chamfers (mm)
hole_chamfer = 1.5;    // [0:0.1:4]
// Distance from the handle end (in multiples of shaft diameter)
dist_factor = 1.0;     // [0.5:0.1:3.0]

/* [Rendering Quality] */
$fn = 128;              

/* [Hidden] */
dist_from_tip = dist_factor * shaft_dia;
hole_pos_x = (handle_length / 2 + shaft_dia / 2) - dist_from_tip;

// --- Model Assembly ---

difference() {
    // 1. MAIN BODY
    union() {
        // Handle and its spherical ends
        translate([0, 0, shaft_length]) {
            rotate([0, 90, 0]) {
                cylinder(d = shaft_dia, h = handle_length, center = true);
                translate([0, 0, -handle_length/2]) sphere(d = shaft_dia);
                translate([0, 0, handle_length/2]) sphere(d = shaft_dia);
            }
        }

        // Seamless Shaft and Reinforcements (Merged via hull)
        hull() {
            translate([0, 0, shaft_length - support_size * 2])
            cylinder(d = shaft_dia, h = 0.1);
            
            for(r = [0, 180]) { 
                rotate([0, 0, r])
                translate([shaft_dia/3 + support_size/2, 0, shaft_length])
                sphere(d = shaft_dia); 
            }
        }

        // Main shaft cylinder
        cylinder(d = shaft_dia, h = shaft_length - support_size * 2);
    }

    // --- SUBTRACTIONS ---

    // 2. Flat top cut for better printing surface
    if (handle_flat_cut > 0) {
        translate([-handle_length, -handle_length, shaft_length + shaft_dia/2 - handle_flat_cut])
        cube([handle_length * 2 + shaft_dia, handle_length * 2, handle_flat_cut + 1]);
    }

    // 3. Square Socket with pyramid entry
    translate([0, 0, -0.01]) {
        if (socket_entry_chamfer > 0) {
            linear_extrude(height = socket_entry_chamfer + 0.01, scale = square_size / (square_size + socket_entry_chamfer * 2))
            square(square_size + socket_entry_chamfer * 2, center = true);
        }
        translate([0, 0, socket_entry_chamfer])
        linear_extrude(height = square_depth)
        square(square_size, center = true);
    }

    // 4. Outer shaft tip chamfer
    if (shaft_outer_chamfer > 0) {
        difference() {
            translate([0,0,-0.1])
            cylinder(d = shaft_dia + 1, h = shaft_outer_chamfer + 0.1);
            translate([0,0,-0.2])
            cylinder(d1 = shaft_dia - shaft_outer_chamfer * 2, d2 = shaft_dia, h = shaft_outer_chamfer + 0.2);
        }
    }

    // 5. Permanent Lanyard Hole with Chamfers
    translate([hole_pos_x, 0, shaft_length])
    rotate([90, 0, 0]) {
        // Main hole
        cylinder(d = hole_dia, h = shaft_dia + 5, center = true);
        
        // Chamfer Side 1 (positive Y)
        translate([0, 0, shaft_dia/2 - hole_chamfer + 0.01])
        cylinder(d1 = hole_dia, d2 = hole_dia + hole_chamfer * 2, h = hole_chamfer);
        
        // Chamfer Side 2 (negative Y)
        translate([0, 0, -shaft_dia/2 - 0.01])
        cylinder(d1 = hole_dia + hole_chamfer * 2, d2 = hole_dia, h = hole_chamfer);
    }
}