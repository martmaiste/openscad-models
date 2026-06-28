/*
   MantaFoils Takeoff Standard Charger Wall Mount
   File: Mantafoils-Takeoff-Standar-Charger-Mount.scad
   Version: v0.13 (2026-06-28)
   License: MIT License

   A fully parametric, 3D-printable wall mount for the MantaFoils Takeoff Standard Charger.
   The mount consists of two mirrored pieces that screw vertically to the wall. The charger's
   ears slide into vertical slots that are open at the top and closed at the bottom, allowing
   for easy, tool-free mounting and removal of the charger.

   Changelog:
   - v0.01: Initial design with basic slot bevels and screw countersinks.
   - v0.02: Rethought and optimized bevels using mathematically precise 2D extruded polygons.
            Introduced a large front bevel, a safe non-breaking back bevel, and a major
            left-to-right body centering funnel (inner-top bevel). Added inner-front vertical chamfer.
   - v0.03: Removed wall-facing (Y=0) chamfers on the outer corners/edges to ensure the back
            of the mount remains a perfectly flat plane, maximizing flush contact with the wall.
   - v0.04: Set default slot_bottom_offset to 5.0mm. Created a comprehensive 3D self-centering
            sliding entry system by adding an outer-slot bevel (X-axis flare), enlarging the
            inner-top bevel to 4.0mm, making the front bevel more gradual (10mm height), and
            increasing clearances for frictionless insertion.
   - v0.05: Solved a coordinate translation bug where previous bevels were rendered below the print bed.
            Redesigned all entry bevels using a native-axis hull() system, ensuring they are
            exactly at the top of the mount, 100% visible, and mathematically robust.
   - v0.06: Connected sidewards, frontwards, and backwards leaning bevels into a single, seamless,
            smooth 3D hopper funnel. Removed all 90-degree internal corner seams from the entry pocket
            by utilizing a combined top-to-bottom hull of the pocket boundary.
   - v0.07: Simplified entry system. Removed all 3D funnels and added a simple 45-degree
            bevel on the back and front upper horizontal edges of the slot.
   - v0.08: Added horizontal side-edge chamfers back to the top and bottom of the outer side face,
            while keeping the back vertical wall-mounting plane perfectly flat.
   - v0.09: Added horizontal side-edge chamfers to the top and bottom of the inner side face (X=0)
            as well, achieving complete 3D symmetry while maintaining a flat mounting backplane.
   - v0.10: Changed default slot depth to exactly 10.0mm (ear_extension = 8.5mm, slot_clearance_extension = 1.5mm).
            Screws and visualization scale automatically.
   - v0.11: Removed console-based validation checks and warning echo outputs to keep the console output clean.
   - v0.12: Swapped meanings of "both" and "layout". "both" now shows the side-by-side printable
            objects, while "layout" shows the installed view with the charger mockup.
   - v0.13: Removed author attribution and updated license to MIT License.

   Printing Instructions:
   - Print standing up (Z-axis vertical).
   - Designed to be printed with ZERO supports.
   - Recommended settings: 3+ perimeters, 20%+ gyroid infill, PETG/ABS/ASA for durability.
*/

// --- CUSTOMIZER PARAMETERS ---

/* [ Part Selection ] */
// Which part of the wall mount to render
part = "both"; // [both: Printable Layout (Side-by-Side), left: Left Mount Only, right: Right Mount Only, layout: Installed View with Charger]

// Show a transparent visualization of the charger in the "layout" (Installed) view
show_charger = true;

/* [ Charger Dimensions ] */
// Length of the main aluminum case (excluding ears) in mm
charger_length = 205.0;

// Height of the charger body in mm
charger_height = 104.0;

// Depth of the charger body in mm
charger_depth = 60.0;

/* [ Ear Dimensions ] */
// Thickness of the mounting ears in mm
ear_thickness = 1.5;

// Height of the mounting ears in mm
ear_height = 88.0;

// How far each ear extends outwards from the case sides in mm (overall length 231mm - case 205mm) / 2 = 13mm. Defaulting to 8.5mm here to make slot_depth exactly 10.0mm.
ear_extension = 8.5;

// Offset of the ear from the back of the charger body in mm (0 means flush with the back)
ear_offset_y = 0.0;

/* [ Bevels & Lead-ins ] */
// Size of the simple 45-degree entry bevel on the back and front upper horizontal edges of the slot in mm
slot_bevel = 1.5;

/* [ Wall Mount Dimensions ] */
// Thickness of the mount piece protruding from the wall in mm
mount_thickness = 10.0;

// Total width of each mount piece in mm (must be larger than ear_extension + clearance)
mount_width = 30.0;

// Total height of the mount piece in mm (should be larger than ear_height + slot_bottom_offset)
mount_height = 110.0;

// Offset from the bottom of the mount to the bottom of the slot in mm (solid support base)
slot_bottom_offset = 5.0;

// Offset from the wall to the back of the slot in mm (creates a protective wall-clearance layer)
slot_wall_clearance = 2.0;

/* [ Mounting Screws ] */
// Diameter of the screw shaft in mm (4.2mm is ideal for a loose fit on 4.0mm wood screws)
screw_shaft_dia = 4.2;

// Outer diameter of the countersink head in mm (standard 4mm wood screw head is ~8mm)
screw_head_dia = 8.5;

// Depth of the countersink head in mm
screw_countersink_depth = 3.0;

// Z-offset for the screw holes from the top and bottom of the mount in mm
screw_offset_z = 15.0;

/* [ Tolerances & Clearances ] */
// Extra width added to the slot in the Y-direction (thickness clearance)
slot_clearance_thickness = 0.7;

// Extra depth added to the slot in the X-direction (extension clearance)
slot_clearance_extension = 1.5;

// Extra clearance added to the slot bottom (Z-axis clearance)
slot_clearance_bottom = 0.5;

// Resolution of cylindrical cuts (higher is smoother)
$fn = 64;


// --- CALCULATED VALUES ---

slot_depth = ear_extension + slot_clearance_extension;
slot_thickness = ear_thickness + slot_clearance_thickness;
slot_y = slot_wall_clearance + ear_offset_y;

// Position the screws centered in the remaining solid outer flange
screw_x = -mount_width + (mount_width - slot_depth) / 2;


// --- MAIN RENDERING LOGIC ---

if (part == "left") {
    mount_left();
} else if (part == "right") {
    // Mirrored left mount along the X-axis
    mirror([1, 0, 0]) mount_left();
} else if (part == "both") {
    // Lay both parts flat on the print bed side-by-side with a 10mm clearance gap (ready to print both)
    translate([-5, 0, 0])
        mount_left();

    translate([5, 0, 0])
        mirror([1, 0, 0])
        mount_left();
} else if (part == "layout") {
    // Left mount at its installed position (X = 0 is the inner boundary)
    mount_left();

    // Right mount at its installed position (X = charger_length is the inner boundary)
    translate([charger_length, 0, 0])
        mirror([1, 0, 0])
        mount_left();

    // Optional transparent charger visualization
    if (show_charger) {
        charger_visualization();
    }
}


// --- MODULE DEFINITIONS ---

// Renders the left mount piece (with inner face at X = 0, extending to X = -mount_width)
module mount_left() {
    difference() {
        // 1. Main mount block
        translate([-mount_width, 0, 0])
            cube([mount_width, mount_thickness, mount_height]);

        // 2. The sliding slot (open at top, closed at bottom)
        translate([-slot_depth, slot_y, slot_bottom_offset])
            cube([slot_depth + 0.1, slot_thickness, mount_height - slot_bottom_offset + 0.1]);

        // 3. Simple 45-degree Slot Entry Bevels on the back and front upper horizontal edges
        // Back edge bevel
        hull() {
            translate([-slot_depth - 0.1, slot_y - slot_bevel, mount_height - 0.05])
                cube([slot_depth + 0.2, slot_bevel + 0.1, 0.1]);
            translate([-slot_depth - 0.1, slot_y - 0.05, mount_height - slot_bevel])
                cube([slot_depth + 0.2, 0.1, 0.1]);
        }

        // Front edge bevel
        hull() {
            translate([-slot_depth - 0.1, slot_y + slot_thickness - 0.05, mount_height - 0.05])
                cube([slot_depth + 0.2, slot_bevel + 0.1, 0.1]);
            translate([-slot_depth - 0.1, slot_y + slot_thickness - 0.05, mount_height - slot_bevel])
                cube([slot_depth + 0.2, 0.1, 0.1]);
        }

        // 4. Mounting screw holes (2x countersunk wood screws)
        translate([screw_x, 0, screw_offset_z])
            screw_hole();

        translate([screw_x, 0, mount_height - screw_offset_z])
            screw_hole();

        // 5. Aesthetic and functional chamfers on FRONT & horizontal SIDE edges
        // Outer-front vertical corner (rounds the main outer front vertical edge)
        translate([-mount_width, mount_thickness, mount_height / 2])
            rotate([0, 0, 45])
            cube([3, 3, mount_height + 0.2], center = true);

        // Inner-front vertical corner (rounds the corner facing the user next to the charger)
        translate([0, mount_thickness, mount_height / 2])
            rotate([0, 0, 45])
            cube([3, 3, mount_height + 0.2], center = true);

        // Top-front horizontal edge (rounds the top front edge)
        translate([-mount_width / 2, mount_thickness, mount_height])
            rotate([45, 0, 0])
            cube([mount_width + 0.2, 3, 3], center = true);

        // Bottom-front horizontal edge (rounds the bottom front edge)
        translate([-mount_width / 2, mount_thickness, 0])
            rotate([-45, 0, 0])
            cube([mount_width + 0.2, 3, 3], center = true);

        // Top-outer horizontal edge (rounds the top horizontal outer-side edge)
        translate([-mount_width, mount_thickness / 2, mount_height])
            rotate([0, 45, 0])
            cube([3, mount_thickness + 0.2, 3], center = true);

        // Bottom-outer horizontal edge (rounds the bottom horizontal outer-side edge)
        translate([-mount_width, mount_thickness / 2, 0])
            rotate([0, -45, 0])
            cube([3, mount_thickness + 0.2, 3], center = true);

        // Top-inner horizontal edge (rounds the top horizontal inner-side edge)
        translate([0, mount_thickness / 2, mount_height])
            rotate([0, 45, 0])
            cube([3, mount_thickness + 0.2, 3], center = true);

        // Bottom-inner horizontal edge (rounds the bottom horizontal inner-side edge)
        translate([0, mount_thickness / 2, 0])
            rotate([0, -45, 0])
            cube([3, mount_thickness + 0.2, 3], center = true);
    }
}

// Helper module for a countersunk screw hole oriented to go from front to back (Y-axis)
module screw_hole() {
    rotate([-90, 0, 0]) {
        // Main shaft hole (goes all the way through)
        translate([0, 0, -0.1])
            cylinder(d = screw_shaft_dia, h = mount_thickness + 0.2);

        // Countersink cone (recessed into the front face of the mount)
        translate([0, 0, mount_thickness - screw_countersink_depth])
            cylinder(d1 = screw_shaft_dia, d2 = screw_head_dia, h = screw_countersink_depth + 0.1);
    }
}

// Transparent visualization of the MantaFoils Charger to verify fitment and clearances
module charger_visualization() {
    // Align charger positions based on clearances
    charger_back_y = slot_wall_clearance + ear_offset_y + slot_clearance_thickness / 2;
    charger_bottom_z = slot_bottom_offset + slot_clearance_bottom;

    // Transparent gray for charger body
    color([0.5, 0.5, 0.5, 0.4]) {
        // Extruded aluminum case body
        translate([0, charger_back_y, charger_bottom_z])
            cube([charger_length, charger_depth, charger_height]);
    }

    // Transparent teal/blue for the ears to make them distinct
    color([0.0, 0.6, 0.8, 0.6]) {
        // Left mounting ear
        translate([-ear_extension, charger_back_y, charger_bottom_z])
            cube([ear_extension, ear_thickness, ear_height]);

        // Right mounting ear
        translate([charger_length, charger_back_y, charger_bottom_z])
            cube([ear_extension, ear_thickness, ear_height]);
    }
}
