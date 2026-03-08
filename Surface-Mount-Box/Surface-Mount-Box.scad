// --- Global Variables ---
l = 86;               // Length (outer)
w = 86;               // Width (outer)
h = 35;               // Height (outer)
wall = 3;             // Wall thickness
r = 4;                // Corner radius
boss_hole = 3;        // Diameter for switch mounting holes (Default: 3mm)
mounting_hole = 4;    // Wall mouning hole diameter
delta = 1;            // Clearance for trough holes

// Cable inlet D-Hole Dimension
hole = 9.5; 

$fn = 64;

// Module for rounded box
module rounded_box(x, y, z, radius) {
    hull() {
        for(ix = [-1, 1], iy = [-1, 1]) {
            translate([ix * (x/2 - radius), iy * (y/2 - radius), 0])
            cylinder(r = radius, h = z);
        }
    }
}

difference() {
    // 1. THE MAIN STRUCTURE (Shell + Pillars + Ribs)
    union() {
        // Outer Shell
        difference() {
            rounded_box(l, w, h, r);
            // Interior Cavity
            translate([0, 0, wall])
            rounded_box(l - wall*2, w - wall*2, h + 1, max(0.1, r - wall));
        }
        
        // Add the BOSSES and RIBS
        for(iy = [-1, 1]) {
            // The Pillar (Solid)
            translate([0, iy * 30, 0])
            cylinder(h = h - 1, d = 8);
            
            // The Rib (Connects pillar to wall)
            translate([-4, (iy > 0) ? 30 : -w/2 + wall, 0])
            cube([8, (w/2 - wall) - 30, h - 1]);
        }
    }

    // 2. THE SUBTRACTIONS (Holes and Cutouts)
    
    // Switch mounting holes
    for(iy = [-delta, delta]) {
        translate([0, iy * 30, 5]) 
        cylinder(h = h, d = boss_hole);
    }
    
    // 4 Wall Mounting Holes
    for(ix = [-1, 1], iy = [-1, 1]) {
        translate([ix * (l/2-15), iy * (w/2-15), -delta]) 
        cylinder(h = wall + delta*2, d = mounting_hole);
    }

    // C. D-SHAPED CABLE HOLE (On X+ axis)
    translate([l/2+delta, 0, 0]) 
    rotate([0, -90, 0]) 
    linear_extrude(height = wall + delta*2) {
        translate([wall, -hole/2]) 
        square([hole/2, hole]);
        
        translate([hole/2+wall, 0])
        circle(d = hole);
    }
}