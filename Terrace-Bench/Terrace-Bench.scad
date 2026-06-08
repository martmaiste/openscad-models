// ==========================================
// Project: Terrace-Bench
// File: Terrace-Bench.scad
// Version: v0.06
// Description: Fully parametric 21mm plywood terrace bench
//              Designed to fit a 276cm wall-to-wall alcove.
//              Fits 4 Ikea SORTERA boxes underneath (2 on left, 2 on right).
//              Fits 62x62cm Ikea garden pillows for seat and backrest.
//              Supports 3 modes: "assembled", "exploded", "parts" (flat lay for CNC).
// Changelog:
//   v0.01 - Initial design
//   v0.02 - Corrected backrest lean, adjusted SORTERA box orientation,
//           added 50mm front reinforcement beam, raised clearance to 530mm
//           (bottom of beam to floor = 480mm), calculated parallel 22-degree
//           toe-kick profile, added 20mm shoulder to hide grooves, and
//           aligned all parts flat on Z=0 plane.
//   v0.03 - Made seat pillow visualization depth dynamically scale with
//           total_depth.
//   v0.04 - Reversed pillow stacking (backrest pillow down first, then seat).
//           Made seat_depth constant (620mm) so the sitting part never changes.
//           When total_depth changes, only the groove slope/position adapts.
//           Increased total_depth to 860mm to keep backrest slope ~14 degrees.
//   v0.05 - Confirmed backrest panel length calculation uses absolute wall distance
//           and touch height, uncoupled from sitting pillow depth.
//   v0.06 - Removed wall-touch-height parameter. Now explicitly defining the
//           backrest panel length (height) and dynamically calculating the slope.
// Author: Zed Coding Agent
// Date: 2026-05-30
// ==========================================

/* [Visualization Options] */
// Mode of display: assembled (3D), exploded (3D), parts (flat lay for CNC export)
mode = "assembled"; // [assembled, exploded, parts]
// Show pillows and Ikea SORTERA boxes
show_accessories = true;

/* [General Dimensions] */
// Wall-to-wall width of the terrace (mm)
total_width = 2720; // [2000:3500]
// Total depth of the bench top (mm) (Increased to 860 to maintain backrest slope)
total_depth = 860; // [750:1100]
// Depth of the sitting area (mm) (Fixed so pillows always fit regardless of total_depth)
seat_depth = 620; // [500:800]
// Thickness of the Ikea garden pillows (mm)
pillow_thickness = 80; // [50:150]
// Clearance height from floor to bottom of bench top (mm) (raised to 530mm so bottom of front apron is 480mm from floor)
clearance_height = 530; // [400:600]
// Plywood sheet thickness (mm)
plywood_thickness = 21; // [12:30]

/* [Compartment Options] */
// Width of the left compartment for SORTERA boxes (mm)
bay_width_left = 850; // [780:1200]
// Width of the right compartment for SORTERA boxes (mm)
bay_width_right = 850; // [780:1200]

/* [Backrest Options] */
// Total length (height) of the backrest wooden panel (mm)
backrest_panel_length = 600; // [400:1000]
// Gap between the backrest panels (mm)
backrest_panel_gap = 2; // [0:10]

/* [Joinery & Details] */
// Height of the toe-kick cutout at bottom-front of supports (mm)
toekick_height = 350; // [0:450]
// Angle of the toe-kick cutout from vertical (degrees) to match Sortera's front slant
toekick_angle = 22; // [0:45]
// Height of the skirting board notch at bottom-back of supports (mm)
skirting_height = 100; // [0:150]
// Depth of the skirting board notch (mm)
skirting_depth = 20; // [0:50]
// Number of tenons per support wall
tenon_count = 3; // [1:5]
// Width of each tenon along the depth of the bench (mm)
tenon_width = 100; // [50:200]
// Height of the structural aprons (stretchers) (mm)
apron_height = 100; // [60:150]
// Height of the vertical front reinforcement apron (mm)
front_apron_height = 50; // [30:100]
// X-coordinate of the middle apron (serves as box stop) (mm)
apron_middle_x = 560; // [400:700]

/* [Groove Options] */
// Whether the groove goes all the way through (through-slot)
groove_through = false;
// Depth of the pocket groove (if not through-slot) (mm)
groove_depth = 15; // [5:20]
// Solid wood shoulder (margin) left at the end of each bay section (mm)
groove_shoulder = 20; // [10:50]
// Tolerance clearance (slop) for joints/grooves (mm)
groove_slop = 1.0; // [0.1:2.0]
// Mortise clearance slop for tenons (mm)
mortise_slop = 0.2; // [0.0:1.0]

/* [Calculated Constants] */
// Middle bay width is calculated automatically to maintain total width
bay_width_middle = total_width - 4 * plywood_thickness - bay_width_left - bay_width_right;

// Calculated toe-kick depth based on height and angle
toekick_depth = toekick_height * tan(toekick_angle);

// Dynamic Backrest Position Logic
// The front of the groove is placed to exactly fit the seat_depth + the thickness of the backrest pillow.
groove_front_x = seat_depth + pillow_thickness;
// The distance from the groove to the back wall dictates the backrest angle.
groove_distance_calc = total_depth - groove_front_x;

// Backrest angle calculation (hypotenuse is backrest_panel_length, opposite is groove_distance_calc)
// Note: This calculates the exact angle required for the top of the panel to touch the back wall.
backrest_angle = asin(groove_distance_calc / backrest_panel_length);
L_total = backrest_panel_length;
groove_width_calc = plywood_thickness / cos(backrest_angle) + groove_slop;

// Apron X positions
apron_back_x = total_depth - plywood_thickness;

// Bay intervals: [start_y, end_y]
bay_intervals = [
    [plywood_thickness, plywood_thickness + bay_width_left],
    [2 * plywood_thickness + bay_width_left, 2 * plywood_thickness + bay_width_left + bay_width_middle],
    [3 * plywood_thickness + bay_width_left + bay_width_middle, total_width - plywood_thickness]
];

// Assembled Y-positions of the 4 support walls
support_y_positions = [
    0,
    plywood_thickness + bay_width_left,
    total_width - 2 * plywood_thickness - bay_width_right,
    total_width - plywood_thickness
];

// Nesting gap for "parts" mode flat lay
nesting_gap = 50;


// ==========================================
// Main Entry Point
// ==========================================

if (mode == "assembled") {
    assembly();
} else if (mode == "exploded") {
    exploded_assembly();
} else if (mode == "parts") {
    flat_lay_parts();
}


// ==========================================
// Modular Components
// ==========================================

// 1. Support Wall
// Local coordinates:
// X: [0, total_depth]
// Y: [0, plywood_thickness]
// Z: [0, clearance_height] (tenons go up to clearance_height + plywood_thickness)
module support_wall() {
    difference() {
        union() {
            // Main rectangular wall panel
            cube([total_depth, plywood_thickness, clearance_height]);

            // Tenons at the top for locking into bench top
            start_x = 120;
            end_x = total_depth - 120;
            for (i = [0 : tenon_count - 1]) {
                x_center = (tenon_count > 1) ?
                    (start_x + i * (end_x - start_x) / (tenon_count - 1)) :
                    (total_depth / 2);
                translate([x_center - tenon_width / 2, 0, clearance_height])
                    cube([tenon_width, plywood_thickness, plywood_thickness]);
            }
        }

        // Toe-kick cutout (diagonal at bottom-front)
        if (toekick_depth > 0 && toekick_height > 0) {
            translate([0, plywood_thickness + 0.05, 0])
                rotate([90, 0, 0])
                linear_extrude(height = plywood_thickness + 0.1)
                polygon([[0, 0], [toekick_depth, 0], [0, toekick_height]]);
        }

        // Skirting board notch (at bottom-back)
        if (skirting_depth > 0 && skirting_height > 0) {
            translate([total_depth - skirting_depth, -0.1, -0.1])
                cube([skirting_depth + 0.2, plywood_thickness + 0.2, skirting_height + 0.1]);
        }

        // Front Apron notch (at top-front vertical reinforcement)
        translate([-0.1, -0.1, clearance_height - front_apron_height])
            cube([plywood_thickness + 0.1, plywood_thickness + 0.2, front_apron_height + 0.1]);

        // Back Apron notch (at top-back)
        translate([apron_back_x, -0.1, clearance_height - apron_height])
            cube([plywood_thickness + 0.1, plywood_thickness + 0.2, apron_height + 0.1]);

        // Middle Apron notch (at top-middle)
        translate([apron_middle_x, -0.1, clearance_height - apron_height])
            cube([plywood_thickness + 0.1, plywood_thickness + 0.2, apron_height + 0.1]);
    }
}

// Helper: Generates tenon mortises for the bench top
module all_support_tenon_mortises() {
    for (y = support_y_positions) {
        translate([0, y, clearance_height]) {
            start_x = 120;
            end_x = total_depth - 120;
            for (i = [0 : tenon_count - 1]) {
                x_center = (tenon_count > 1) ?
                    (start_x + i * (end_x - start_x) / (tenon_count - 1)) :
                    (total_depth / 2);
                translate([
                    x_center - tenon_width / 2 - mortise_slop,
                    -mortise_slop,
                    -0.1
                ])
                    cube([
                        tenon_width + 2 * mortise_slop,
                        plywood_thickness + 2 * mortise_slop,
                        plywood_thickness + 0.2
                    ]);
            }
        }
    }
}

// Helper: Generates backrest grooves in the bench top
module backrest_grooves() {
    for (interval = bay_intervals) {
        y_start = interval[0] + groove_shoulder;
        y_end = interval[1] - groove_shoulder;
        y_len = y_end - y_start;

        translate([
            groove_front_x - groove_slop / 2,
            y_start,
            groove_through ? -0.1 : (plywood_thickness - groove_depth)
        ])
            cube([
                groove_width_calc,
                y_len,
                groove_through ? (plywood_thickness + 0.2) : (groove_depth + 0.1)
            ]);
    }
}

// 2. Bench Top
// Local coordinates:
// X: [0, total_depth]
// Y: [0, total_width]
// Z: [0, plywood_thickness]
module bench_top() {
    difference() {
        // Main flat bench top
        cube([total_depth, total_width, plywood_thickness]);

        // Subtraction of mortises (aligned to bench top height)
        translate([0, 0, -clearance_height])
            all_support_tenon_mortises();

        // Subtraction of grooves
        backrest_grooves();
    }
}

// 3. Structural Aprons (Back & Middle Stretchers)
// Local coordinates:
// X: [0, plywood_thickness]
// Y: [0, total_width]
// Z: [0, apron_height]
module apron() {
    cube([plywood_thickness, total_width, apron_height]);
}

// 3b. Vertical Front Reinforcement Apron
// Local coordinates:
// X: [0, plywood_thickness]
// Y: [0, total_width]
// Z: [0, front_apron_height]
module front_apron() {
    cube([plywood_thickness, total_width, front_apron_height]);
}

// 4. Backrest Panel
// Local coordinates:
// X: [0, plywood_thickness]
// Y: [0, panel_width]
// Z: [-groove_depth, L_total] (slanted)
module backrest_panel(panel_width) {
    // Note: To simplify CNC fabrication, the panel is drawn flat.
    // The bottom edge is perpendicular to its faces. Slit clearance in the groove allows tilting.
    translate([0, 0, -groove_depth])
        cube([plywood_thickness, panel_width, L_total + groove_depth]);
}


// ==========================================
// Assembly Layouts
// ==========================================

// Full 3D Assembled view
module assembly() {
    // Support walls (Wood Color)
    color("burlywood") {
        for (y = support_y_positions) {
            translate([0, y, 0])
                support_wall();
        }
    }

    // Bench Top (Wood Color)
    color("peru") {
        translate([0, 0, clearance_height])
            bench_top();
    }

    // Aprons (Darker wood)
    color("sienna") {
        // Front Apron (Vertical Reinforcement)
        translate([0, 0, clearance_height - front_apron_height])
            front_apron();
        // Back Apron
        translate([apron_back_x, 0, clearance_height - apron_height])
            apron();
        // Middle Apron
        translate([apron_middle_x, 0, clearance_height - apron_height])
            apron();
    }

    // Backrest Panels (Teak Color)
    color("darkgoldenrod") {
        for (interval = bay_intervals) {
            y_start = interval[0] + groove_shoulder;
            y_end = interval[1] - groove_shoulder;
            panel_width = (y_end - y_start) - backrest_panel_gap;

            translate([
                groove_front_x,
                y_start + backrest_panel_gap / 2,
                clearance_height + plywood_thickness
            ])
                rotate([0, backrest_angle, 0])
                backrest_panel(panel_width);
        }
    }

    // Accessories: Sortera boxes and Pillows
    if (show_accessories) {
        place_sortera_boxes();
        place_pillows();
    }
}

// 3D Exploded view to show details and joinery
module exploded_assembly() {
    explode_z = 150;
    explode_y = 50;

    // Support walls (Wood Color) - pushed outward on Y and downward in Z
    color("burlywood") {
        // Support 0 (far left)
        translate([0, -explode_y * 1.5, -explode_z / 2])
            support_wall();
        // Support 1 (left middle)
        translate([0, support_y_positions[1] - explode_y * 0.5, -explode_z / 2])
            support_wall();
        // Support 2 (right middle)
        translate([0, support_y_positions[2] + explode_y * 0.5, -explode_z / 2])
            support_wall();
        // Support 3 (far right)
        translate([0, support_y_positions[3] + explode_y * 1.5, -explode_z / 2])
            support_wall();
    }

    // Bench Top (Wood Color) - lifted up
    color("peru") {
        translate([0, 0, clearance_height + explode_z])
            bench_top();
    }

    // Aprons - pushed downward and outward
    color("sienna") {
        // Front Apron - pushed forward
        translate([-100, 0, clearance_height - front_apron_height - explode_z / 2])
            front_apron();
        // Back Apron - pushed backward
        translate([apron_back_x + 80, 0, clearance_height - apron_height - explode_z / 2])
            apron();
        // Middle Apron - pushed down
        translate([apron_middle_x, 0, clearance_height - apron_height - explode_z])
            apron();
    }

    // Backrest Panels - lifted up along angle
    color("darkgoldenrod") {
        for (interval = bay_intervals) {
            y_start = interval[0] + groove_shoulder;
            y_end = interval[1] - groove_shoulder;
            panel_width = (y_end - y_start) - backrest_panel_gap;

            // Slanted vector translation
            slant_x = explode_z * sin(backrest_angle);
            slant_z = explode_z * cos(backrest_angle) + explode_z;

            translate([
                groove_front_x + slant_x,
                y_start + backrest_panel_gap / 2,
                clearance_height + plywood_thickness + slant_z
            ])
                rotate([0, backrest_angle, 0])
                backrest_panel(panel_width);
        }
    }

    // Accessories are hidden in exploded mode to keep it clear
}

// Flat layout of all panels for CNC toolpath export
module flat_lay_parts() {
    // Nesting Column 0: Bench Top (No rotation needed)
    color("peru") {
        translate([0, 0, 0])
            bench_top();
    }

    // Nesting Column 1: 4 Support Walls (rotated flat to XY plane)
    color("burlywood") {
        wall_height_flat = clearance_height + plywood_thickness;
        for (i = [0 : 3]) {
            translate([
                total_depth + nesting_gap,
                i * (wall_height_flat + nesting_gap),
                0
            ])
                translate([0, wall_height_flat, 0])
                rotate([90, 0, 0])
                support_wall();
        }
    }

    // Nesting Column 2: 3 Backrest Panels (rotated flat to XY plane)
    color("darkgoldenrod") {
        backrest_len_flat = L_total + groove_depth;

        // Panel 0: Left
        y_start_0 = bay_intervals[0][0] + groove_shoulder;
        y_end_0 = bay_intervals[0][1] - groove_shoulder;
        width_0 = (y_end_0 - y_start_0) - backrest_panel_gap;
        translate([
            2 * total_depth + 2 * nesting_gap,
            0,
            0
        ])
            cube([backrest_len_flat, width_0, plywood_thickness]);

        // Panel 1: Middle
        y_start_1 = bay_intervals[1][0] + groove_shoulder;
        y_end_1 = bay_intervals[1][1] - groove_shoulder;
        width_1 = (y_end_1 - y_start_1) - backrest_panel_gap;
        translate([
            2 * total_depth + 2 * nesting_gap,
            width_0 + nesting_gap,
            0
        ])
            cube([backrest_len_flat, width_1, plywood_thickness]);

        // Panel 2: Right
        y_start_2 = bay_intervals[2][0] + groove_shoulder;
        y_end_2 = bay_intervals[2][1] - groove_shoulder;
        width_2 = (y_end_2 - y_start_2) - backrest_panel_gap;
        translate([
            2 * total_depth + 2 * nesting_gap,
            width_0 + width_1 + 2 * nesting_gap,
            0
        ])
            cube([backrest_len_flat, width_2, plywood_thickness]);
    }

    // Nesting Column 3: Aprons (rotated flat)
    color("sienna") {
        // Back Apron
        translate([
            2 * total_depth + (L_total + groove_depth) + 3 * nesting_gap,
            0,
            plywood_thickness
        ])
            rotate([0, 90, 0])
            apron();

        // Middle Apron
        translate([
            2 * total_depth + (L_total + groove_depth) + 3 * nesting_gap + apron_height + nesting_gap,
            0,
            plywood_thickness
        ])
            rotate([0, 90, 0])
            apron();

        // Front Apron (Vertical Reinforcement)
        translate([
            2 * total_depth + (L_total + groove_depth) + 3 * nesting_gap + 2 * apron_height + 2 * nesting_gap,
            0,
            plywood_thickness
        ])
            rotate([0, 90, 0])
            front_apron();
    }
}


// ==========================================
// Accessories (Visualization Helpers)
// ==========================================

// Mock-up of a SORTERA 60L box (550 x 410 x 450 mm)
module sortera_box() {
    color("whitesmoke", 0.75) {
        // Tapered body
        hull() {
            translate([15, 15, 0])
                cube([520, 380, 5]);
            translate([0, 0, 435])
                cube([550, 410, 15]);
        }
        // Lid (with front hinge slope)
        translate([-5, -5, 440])
            difference() {
                cube([560, 420, 15]);
                // Slope cutout on front (at X = 0)
                translate([-1, -1, 15])
                    rotate([0, 12, 0])
                    cube([200, 422, 20]);
            }
    }
}

// Place the 4 SORTERA boxes in left and right bays
module place_sortera_boxes() {
    box_width = 410;
    // Left Bay Boxes
    y_gap_left = (bay_width_left - 2 * box_width) / 3;
    translate([10, plywood_thickness + y_gap_left, 1])
        sortera_box();
    translate([10, plywood_thickness + 2 * y_gap_left + box_width, 1])
        sortera_box();

    // Right Bay Boxes
    y_gap_right = (bay_width_right - 2 * box_width) / 3;
    translate([10, total_width - plywood_thickness - 2 * y_gap_right - box_width, 1])
        sortera_box();
    translate([10, total_width - plywood_thickness - y_gap_right - box_width, 1])
        sortera_box();
}

// Place sitting and backrest cushions
module place_pillows() {
    pillow_width = 620;

    // Automatically space 4 pillows side by side along the terrace bench
    y_gap = (total_width - 4 * pillow_width) / 5;

    for (i = [0 : 3]) {
        y_pos = y_gap + i * (pillow_width + y_gap);

        // Seat cushion (Light Grey) - placed in front of the backrest
        color("silver") {
            translate([0, y_pos, clearance_height + plywood_thickness])
                cube([seat_depth, pillow_width, pillow_thickness]);
        }

        // Backrest cushion (Slightly darker slate blue/grey)
        color("slategray") {
            // Put down the backrest pillow first. It sits directly on the bench top.
            // It leans perfectly against the front of the backrest panel.
            translate([
                groove_front_x,
                y_pos,
                clearance_height + plywood_thickness
            ])
                rotate([0, backrest_angle, 0])
                translate([-pillow_thickness, 0, 0])
                cube([pillow_thickness, pillow_width, 620]); // Standard IKEA backrest pillow height
        }
    }
}
