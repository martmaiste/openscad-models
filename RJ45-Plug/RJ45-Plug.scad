// --- PROJECT INFO ---
/* RJ45 Dust Cap with Clip Hole Coverage & Contact Relief
   Version: 1.2
   Description: Covers the port and clip notch, with a cutout for internal pins.
*/

// --- USER PARAMETERS ---

/* [Dimensions] */
// Width of the RJ45 plug (mm)
plug_width = 11.6; 
// Height of the RJ45 plug (mm)
plug_height = 6.6; 
// Depth into the socket (mm)
plug_depth = 8.0;   

/* [Cap Settings] */
// Thickness of the outer plate (mm)
cap_thickness = 1.5;
// How much the cap overlaps the socket edges (mm)
cap_overhang = 1.5; 

/* [Clip Cover] */
// Width of the clip notch cover (mm)
clip_cover_width = 6.5; 
// Height of the clip notch cover (mm)
clip_cover_height = 4.0; 

/* [Internal Relief] */
// Depth of the cutout for internal pins (mm)
contact_cutout_depth = 2.0;
// Width of the contact cutout (mm)
contact_cutout_width = 8.0;

/* [Friction & Fit] */
// Size of the friction bumps on sides (mm)
bump_radius = 0.4;
// Chamfer size for easy insertion (mm)
tip_chamfer = 1.2;

/* [Technical] */
$fn = 64;

// --- MODEL CONSTRUCTION ---

module rj45_full_coverage_cap() {
    union() {
        // 1. OUTER FACE PLATE
        translate([0, 0, cap_thickness / 2])
        hull() {
            rounded_plate(plug_width + cap_overhang*2, plug_height + cap_overhang*2, cap_thickness, 1.0);
            
            translate([0, (plug_height/2) + clip_cover_height/2, 0])
                rounded_plate(clip_cover_width, clip_cover_height, cap_thickness, 0.5);
        }

        // 2. INSERTION PLUG
        translate([0, 0, cap_thickness]) {
            difference() {
                // Main body
                translate([-plug_width/2, -plug_height/2, 0])
                    cube([plug_width, plug_height, plug_depth]);
                
                // --- CONTACT RELIEF CUTOUT ---
                // This removes material where the socket pins are located
                translate([-contact_cutout_width/2, -plug_height/2 - 0.1, 0])
                    cube([contact_cutout_width, contact_cutout_depth, plug_depth + 0.1]);

                // Chamfered edges for smooth insertion
                translate([0, -plug_height/2, plug_depth]) rotate([45, 0, 0]) cube([plug_width+1, tip_chamfer, tip_chamfer], center=true);
                translate([0, plug_height/2, plug_depth]) rotate([45, 0, 0]) cube([plug_width+1, tip_chamfer, tip_chamfer], center=true);
                translate([-plug_width/2, 0, plug_depth]) rotate([0, 45, 0]) cube([tip_chamfer, plug_height+1, tip_chamfer], center=true);
                translate([plug_width/2, 0, plug_depth]) rotate([0, 45, 0]) cube([tip_chamfer, plug_height+1, tip_chamfer], center=true);
            }
            
            // Friction bumps
            translate([plug_width/2, 0, plug_depth*0.5]) sphere(r=bump_radius);
            translate([-plug_width/2, 0, plug_depth*0.5]) sphere(r=bump_radius);
        }
    }
}

// Helper module for rounded rectangles
module rounded_plate(w, h, thick, rad) {
    hull() {
        translate([(w/2)-rad, (h/2)-rad, 0]) cylinder(h=thick, r=rad, center=true);
        translate([-(w/2)+rad, (h/2)-rad, 0]) cylinder(h=thick, r=rad, center=true);
        translate([(w/2)-rad, -(h/2)+rad, 0]) cylinder(h=thick, r=rad, center=true);
        translate([-(w/2)+rad, -(h/2)+rad, 0]) cylinder(h=thick, r=rad, center=true);
    }
}

rj45_full_coverage_cap();