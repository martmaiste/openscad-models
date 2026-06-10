// ============================================================================
// Pressure-Releaf-Plug-Socket.scad
// Version: v0.08
// Date: 2026-06-10
// Author: Zed Coding Agent
// Description: Parametric 3D-printable socket tool for carbon-sandwich wing-foiling board pressure relief plug.
// Designed to be printed upright (handle-down) without any supports.
// Features customizable handle styles (Rounded or Chamfered Cube) via Customizer.
// ============================================================================

/* [Plug & Socket Dimensions] */
// Hex size across flats of the plug (mm)
hex_size = 16.0;

// Depth of the hex socket recess (mm)
socket_depth = 10.0;

// Outer diameter of the socket (mm). Must be less than the board's recessed area (23mm) and greater than the hex diagonal.
socket_outer_diameter = 22.0;

// Extra clearance for the hex socket to fit easily onto the plug (mm)
clearance = 0.2;

// Height of the lead-in countersink chamfer at the mouth of the socket (mm)
socket_chamfer_height = 0.75;

// Chamfer size on the top outside edge of the socket (mm)
outer_chamfer = 0.5;

/* [Handle Style Options] */
// Style of the handle
handle_style = "cube"; // ["rounded", "cube"]

// Chamfer size for the cube handle (mm) - applied to all 12 edges including bottom
chamfer_size = 1.5;

/* [Handle Dimensions] */
// Width of the T-handle (mm). 50mm limits leverage to prevent over-tightening.
handle_width = 50.0;

// Thickness of the handle (mm)
handle_thickness = 10.0;

// Height of the handle grip portion (mm)
handle_height = 15.0;

// Length of the transitioning shaft between handle and socket (mm)
shaft_length = 20.0;

// Flare width of the transition shaft at the handle (mm). Controls the size of the open wings and inside corner fillet.
transition_flare = 5.0;

/* [Lanyard Hole] */
// Enable lanyard hole in the handle
enable_lanyard_hole = true;

// Diameter of the lanyard hole (mm)
lanyard_hole_diameter = 4.0;

/* [Text Label] */
// Enable text label on the handle face
enable_text = true;

// Text to display on the handle
label_text = "16mm";

// Font size of the text (mm)
text_size = 5.0;

// Depth of the recessed text (mm)
text_depth = 0.2;

/* [Printer & Resolution Settings] */
// Number of fragments for cylindrical parts (smoothness)
$fn = 60;

// ============================================================================
// Computed Parameters & Validation
// ============================================================================

effective_hex = hex_size + clearance;
hex_diagonal = effective_hex / cos(30);
total_height = handle_height + shaft_length + socket_depth;

// Calculate transition shaft start Z to avoid any notch/overhang based on handle style
shaft_start_z = (handle_style == "cube") ?
                (handle_height - chamfer_size) :
                (handle_height - handle_thickness / 2);

// Safety check / warning in console if wall thickness is too thin
if (socket_outer_diameter <= hex_diagonal) {
    echo("<FONT COLOR='red'><B>WARNING: socket_outer_diameter is too small for the selected hex_size!</B></FONT>");
}

// ============================================================================
// Helper Modules
// ============================================================================

// Creates a hexagon centered at the origin, with specified flat-to-flat size and height
module hexagon(flat_size, height) {
    r_outer = (flat_size / 2) / cos(30);
    cylinder(r = r_outer, h = height, $fn = 6);
}

// Helper representing a single slice of the handle shape (flat with rounded ends)
module handle_profile(h) {
    hull() {
        translate([-handle_width/2 + handle_thickness/2, 0, 0])
            cylinder(d=handle_thickness, h=h);
        translate([handle_width/2 - handle_thickness/2, 0, 0])
            cylinder(d=handle_thickness, h=h);
    }
}

// Creates a chamfered box centered in X and Y, sitting on Z=0
module chamfered_cube(w, t, h, c) {
    translate([0, 0, h/2]) {
        hull() {
            cube([w, t - 2*c, h - 2*c], center=true);
            cube([w - 2*c, t, h - 2*c], center=true);
            cube([w - 2*c, t - 2*c, h], center=true);
        }
    }
}

// ============================================================================
// Main Assembly
// ============================================================================

difference() {
    // 1. Combine all additive parts of the tool
    union() {
        // Render selected handle style
        if (handle_style == "cube") {
            // Chamfered Cube Handle
            chamfered_cube(handle_width, handle_thickness, handle_height, chamfer_size);
        } else {
            // Flat-bottomed handle with rounded top ends for ergonomics
            hull() {
                // Left end column (cylinder + sphere)
                translate([-handle_width/2 + handle_thickness/2, 0, 0]) {
                    cylinder(d=handle_thickness, h=handle_height - handle_thickness/2);
                    translate([0, 0, handle_height - handle_thickness/2])
                        sphere(d=handle_thickness);
                }
                // Right end column (cylinder + sphere)
                translate([handle_width/2 - handle_thickness/2, 0, 0]) {
                    cylinder(d=handle_thickness, h=handle_height - handle_thickness/2);
                    translate([0, 0, handle_height - handle_thickness/2])
                        sphere(d=handle_thickness);
                }
            }
        }

        // Transition shaft (hulls a thin flared slice to a thin socket slice to create a perfect support-free T-bar transition)
        // Starts at shaft_start_z to eliminate any overhang notch
        hull() {
            translate([0, 0, shaft_start_z])
                hull() {
                    translate([-socket_outer_diameter/2 - transition_flare + handle_thickness/2, 0, 0])
                        cylinder(d=handle_thickness, h=1.0);
                    translate([socket_outer_diameter/2 + transition_flare - handle_thickness/2, 0, 0])
                        cylinder(d=handle_thickness, h=1.0);
                }

            translate([0, 0, handle_height + shaft_length - 1.0])
                cylinder(d=socket_outer_diameter, h=1.0);
        }

        // Socket outer body with chamfer on the top outside edge
        translate([0, 0, handle_height + shaft_length]) {
            cylinder(d=socket_outer_diameter, h=socket_depth - outer_chamfer);
            translate([0, 0, socket_depth - outer_chamfer])
                cylinder(r1=socket_outer_diameter/2, r2=socket_outer_diameter/2 - outer_chamfer, h=outer_chamfer);
        }
    }

    // 2. Subtract the hex socket cavity
    translate([0, 0, total_height - socket_depth])
        hexagon(effective_hex, socket_depth + 0.1);

    // 3. Subtract the lead-in chamfer at the mouth of the socket
    translate([0, 0, total_height - socket_chamfer_height])
        cylinder(
            r1 = (effective_hex / 2) / cos(30),
            r2 = ((effective_hex / 2) / cos(30)) + socket_chamfer_height,
            h = socket_chamfer_height + 0.05
        );

    // 4. Subtract the lanyard hole (if enabled)
    if (enable_lanyard_hole) {
        // Place the lanyard hole in the flat wing area, safely clear of the central transition shaft
        lanyard_x = handle_width / 2 - handle_thickness - 2;
        translate([lanyard_x, 0, handle_height / 2])
            rotate([90, 0, 0])
                cylinder(d=lanyard_hole_diameter, h=handle_thickness + 2, center=true);
    }

    // 5. Subtract the recessed text label (if enabled)
    if (enable_text) {
        // Center the text on the front face of the handle
        // The front face of the handle is at Y = -handle_thickness / 2
        translate([0, -handle_thickness / 2 + text_depth, handle_height / 2])
            rotate([90, 0, 0])
                linear_extrude(height = text_depth + 0.1)
                    text(label_text, size = text_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
    }
}
