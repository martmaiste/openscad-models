/* =====================================================================
 *  Wing-Foil Mast Shim - Universal, Parametric, Lightweight
 *  
 *  VERSION HISTORY:
 *  v0.01 (2026-10-08) - Initial version. 
 *  v0.02 (2026-10-08) - Open slots & through-surface cavities.
 *  v0.03 (2026-10-08) - Parametric 110mm minimum longitudinal bolt spacing.
 *  v0.04 (2026-10-08) - Width updated to 128mm. Added side offramps.
 *  v0.05 (2026-10-08) - Solidified outer side bands.
 *  v0.06 (2026-10-08) - Symmetrical, centered hex grid (no partial holes).
 *  v0.07 (2026-10-08) - Halved front ramp length (12.5mm) and doubled offramp angle.
 *  v0.08 (2026-10-08) - Added 5mm clearance at both front and rear of mast plate.
 *  v0.09 (2026-10-08) - Added 0.2mm deep imprint of shim angle on front ramp.
 *  v0.10 (2026-10-08) - Fixed text 3D positioning on ramp face.
 *  v0.11 (2026-10-08) - Rotated text 90 degrees and added degree symbol.
 *  v0.12 (2026-10-08) - Increased cut depth to 0.5mm.
 *  v0.13 (2026-10-08) - Replaced font unicode degree character with native CSG ring.
 *  v0.14 (2026-10-08) - Fixed rotation order for perpendicular cutting plane.
 *  v0.15 (2026-10-08) - Fixed degree symbol overlap by left-aligning text.
 *  v0.16 (2026-10-08) - Shifted degree ring to X = +3.6mm to cleanly clear digit '5'.
 *  v0.17 (2026-10-08) - Concatenated degree symbol directly into text string.
 *  v0.18 (2026-10-08) - Increased imprint text size to 10.
 *  v0.19 (2026-10-08) - Added parametric imprint_size and set imprint_depth = 0.2mm.
 *  v0.20 (2026-10-08) - Rotated text 180 degrees (rotate([0, 0, -90])) so it is right-side up.
 *  v0.21 (2026-10-08) - Added entry fillets to slot mouth corners.
 * =====================================================================
 */

// --- PARAMETERS ---

version = "0.21";

// Angle & Core Dimensions
    angle = 1.0;             // Angle of the shim in degrees (thicker at front)
min_thick = 1.5;         // Minimum thickness at the trailing edge (mm)
plate_len = 190;         // Length of the nominal mast plate
plate_clearance = 5;     // Extra clearance/wiggle room at front & rear (mm)
width = 128;             // Total width of the shim (128mm)
ramp_len = 12.5;         // Length of the hydrodynamic front ramp
corner_r = 10;           // Radius of the outside corners

// Side Offramps (Hydrodynamic lateral bevels)
side_ramp_w = 3;         // Width of the side offramp along left/right edges (mm)
side_ramp_edge_h = 0.5;  // Outer edge thickness at the sides (mm)

// Mounting Slots (Universal Open-Ended)
slot_dist_y = 90;        // Track width spacing (Standard = 90mm)
slot_width = 8.5;        // Width of the slots (M8 hardware clearance)
min_bolt_dist_x = 110;   // Minimum distance between front and rear bolts (mm)
slot_entry_r = 3.0;      // Fillet radius at outer slot entry corners

// Lightweighting (Hexagonal Through-Holes)
hex_size = 14;           // Size of the hexagonal cavities (flat to flat)
hex_wall = 3;            // Thickness of the walls between cavities
border_wall = 6;         // Solid border thickness around perimeter and slots

// Imprint Parameters
imprint_depth = 0.2;     // Deboss depth for 3D printing readability (mm)
imprint_size = 10;       // Text size for the angle imprint on the ramp


// --- CALCULATED VALUES ---
// Effective extended length including 5mm front and 5mm rear clearance
length = plate_len + (2 * plate_clearance); 

// Center of the main plate area along X
plate_center_x = length / 2;

// Auto-calculate slot inner ends based on min 110mm bolt distance (+ 5mm margin)
front_slot_end = plate_center_x - (min_bolt_dist_x / 2) + 5; 
rear_slot_start = plate_center_x + (min_bolt_dist_x / 2) - 5; 

// Thickness at the front (X=0) based on total length and angle
front_thick = min_thick + length * tan(angle);
max_height = front_thick;


// --- RENDER RESOLUTION ---
$fn = 64;


// --- MAIN ASSEMBLY ---
shim();

module shim() {
    difference() {
        // 1. Solid outer body with filleted slot entry corners on the outer footprint
        main_body_solid();
        
        // 2. Subtract centered full hexagonal cavities
        hex_cavities();
        
        // 3. Subtract straight open-ended slots
        slots();
        
        // 4. Subtract angle imprint aligned precisely to the ramp plane
        angle_imprint();
    }
}


// --- MODULES ---

// Outer solid body intersected with top/side profiles
module main_body_solid() {
    intersection() {
        // 2D Footprint extruded tall
        linear_extrude(height = max_height + 10) 
            outline();
        
        // Longitudinal profile (X-Z) for 1.5 deg taper and front ramp
        translate([0, width/2, 0]) 
            rotate([90, 0, 0])
                linear_extrude(height = width) 
                    shim_profile();
                    
        // Lateral profile (Y-Z) for side offramps
        translate([-ramp_len - 10, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height = length + ramp_len + 20)
                    side_profile();
    }
}

// 2D Outer boundary incorporating outer corner radii and slot entry fillets
module outline() {
    difference() {
        // Outer rounded footprint
        hull() {
            translate([-ramp_len + corner_r, width/2 - corner_r]) circle(r=corner_r);
            translate([-ramp_len + corner_r, -width/2 + corner_r]) circle(r=corner_r);
            translate([length - corner_r, width/2 - corner_r]) circle(r=corner_r);
            translate([length - corner_r, -width/2 + corner_r]) circle(r=corner_r);
        }
        
        // Round the inner entry corners where slots exit the perimeter
        for (y = [-slot_dist_y/2, slot_dist_y/2]) {
            // Front slot entry corner fillets
            translate([-ramp_len, y + slot_width/2]) 
                slot_entry_corner(dir_x = -1, dir_y = 1);
            translate([-ramp_len, y - slot_width/2]) 
                slot_entry_corner(dir_x = -1, dir_y = -1);

            // Rear slot entry corner fillets
            translate([length, y + slot_width/2]) 
                slot_entry_corner(dir_x = 1, dir_y = 1);
            translate([length, y - slot_width/2]) 
                slot_entry_corner(dir_x = 1, dir_y = -1);
        }
    }
}

// Corner subtraction tool for generating concave entry fillets
module slot_entry_corner(dir_x, dir_y) {
    r = slot_entry_r;
    translate([dir_x > 0 ? -r : 0, dir_y > 0 ? 0 : -r]) {
        difference() {
            square([r, r]);
            translate([dir_x > 0 ? 0 : r, dir_y > 0 ? r : 0]) circle(r = r);
        }
    }
}

// The exact longitudinal side profile (X-Z)
module shim_profile() {
    polygon([
        [-ramp_len, 0],              // Top front of ramp (board surface)
        [length, 0],                 // Top rear (board surface)
        [length, min_thick],         // Bottom rear (mast plate surface)
        [0, front_thick],            // Bottom front (mast plate surface ends here)
        [-ramp_len, 1]               // Ramp tapers down to a smooth 1mm edge
    ]);
}

// Lateral profile for side offramps (Y-Z plane)
module side_profile() {
    polygon([
        [-width/2, 0],
        [-width/2, side_ramp_edge_h],
        [-width/2 + side_ramp_w, max_height + 10],
        [width/2 - side_ramp_w, max_height + 10],
        [width/2, side_ramp_edge_h],
        [width/2, 0]
    ]);
}

// Hex cavity generator (full cut-through with discrete whole-hex placement)
module hex_cavities() {
    translate([0, 0, -1])
        linear_extrude(height = max_height + 10)
            centered_full_hex_grid();
}

// Generates only FULL, non-clipped hexagons perfectly centered in the middle bay
module centered_full_hex_grid() {
    cav_min_x = 5 + border_wall;                          // Behind front ramp
    cav_max_x = length - border_wall;                     // Trailing edge boundary
    cav_max_y = (slot_dist_y / 2) - (slot_width / 2) - border_wall; // Inner slot boundary
    
    hex_r = hex_size / sqrt(3);                           // Outer radius of hex
    x_step = hex_size + hex_wall;
    y_step = x_step * sin(60);
    
    bay_center_x = (cav_min_x + cav_max_x) / 2;
    
    cols = floor((cav_max_x - cav_min_x) / x_step) + 2;
    rows = floor((2 * cav_max_y) / y_step) + 2;
    
    for (i = [-cols : cols]) {
        for (j = [-rows : rows]) {
            hx = bay_center_x + i * x_step + (abs(j) % 2 == 1 ? x_step/2 : 0);
            hy = j * y_step;
            
            if (hx - hex_r >= cav_min_x && 
                hx + hex_r <= cav_max_x && 
                hy - hex_r >= -cav_max_y && 
                hy + hex_r <= cav_max_y) {
                
                translate([hx, hy]) 
                    rotate([0, 0, 30]) 
                        circle(d = hex_r * 2, $fn = 6);
            }
        }
    }
}

// Universal Open-Ended Mounting Slots
module slots() {
    for (y = [-slot_dist_y/2, slot_dist_y/2]) {
        // Front slot
        hull() {
            translate([-ramp_len - 10, y, -1]) cylinder(d=slot_width, h=max_height+10);
            translate([front_slot_end, y, -1]) cylinder(d=slot_width, h=max_height+10);
        }
        // Rear slot
        hull() {
            translate([rear_slot_start, y, -1]) cylinder(d=slot_width, h=max_height+10);
            translate([length + 10, y, -1]) cylinder(d=slot_width, h=max_height+10);
        }
    }
}

// Debossed text directly on the sloped front ramp plane
module angle_imprint() {
    ramp_center_x = -ramp_len / 2;                        // Midpoint of ramp
    ramp_mid_z = (front_thick + 1.0) / 2;                 // Midpoint Z on ramp face
    ramp_angle = atan2(front_thick - 1.0, ramp_len);      // Slope angle (~26.5°)
    
    translate([ramp_center_x, 0, ramp_mid_z]) {
        rotate([0, -ramp_angle, 0]) {
            rotate([0, 0, -90]) {
                translate([0, 0, -imprint_depth]) {
                    linear_extrude(height = imprint_depth + 2.0) {
                        text(
                            str(angle, "°"), 
                            size = imprint_size, 
                            halign = "center", 
                            valign = "center", 
                            font = "Liberation Sans:style=Bold"
                        );
                    }
                }
            }
        }
    }
}