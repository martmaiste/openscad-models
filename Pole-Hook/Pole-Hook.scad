// --- INFO ---
/* [Project] */
// Parametric Heavy-Duty Double Hook
// Version: 1.6 (Restored & Optimized)
// Description: Massive hook with 15mm walls and 4mm rounding.

/* [Hook Dimensions] */
// Inner diameter of the top (closed) ring
d1_inner = 30; // [10:1:200]
// Inner diameter of the bottom (open) ring
d2_inner = 35; // [10:1:200]
// Wall thickness of the rings
wall_thickness = 15; // [2:1:50]
// Total height (thickness) of the object
height = 15; // [2:1:50]
// Radius for edge rounding
rounding_radius = 4; // [0.1:0.1:10]

/* [Advanced] */
// Resolution of the geometry
$fn = 60; 

/* [Hidden] */
adj_h = height - (rounding_radius * 2);
adj_w = wall_thickness - (rounding_radius * 2);

r1_in = d1_inner / 2 + rounding_radius;
r1_out = r1_in + adj_w;

r2_in = d2_inner / 2 + rounding_radius;
r2_out = r2_in + adj_w;

// Distance: R2 outer edge matches R1 inner edge
distance = r1_in + r2_out;

// --- CONSTRUCTION ---

// Applying Minkowski at the top level to round all edges
minkowski() {
    union() {
        // 1. TOP RING (Closed)
        difference() {
            cylinder(r = r1_out, h = adj_h, center = true);
            cylinder(r = r1_in, h = adj_h + 2, center = true);
        }

        // 2. BOTTOM RING (Open)
        translate([distance, 0, 0])
        difference() {
            // Main ring body
            difference() {
                cylinder(r = r2_out, h = adj_h, center = true);
                cylinder(r = r2_in, h = adj_h + 2, center = true);
            }
            // CUTOUT: 90-180 degrees (CCW rotation)
            // Cut is performed inside Minkowski to ensure rounded ends
            rotate([0, 0, 90])
            translate([0, 0, -adj_h])
            cube([r2_out + 10, r2_out + 10, adj_h * 2]);
        }

        // 3. STRAIGHT BRIDGE
        // Connects the bottom-most points of both rings
        hull() {
            translate([0, -r1_out + adj_w/2, 0])
            cube([0.1, adj_w, adj_h], center = true);
            
            translate([distance, -r2_out + adj_w/2, 0])
            cube([0.1, adj_w, adj_h], center = true);
        }
    }
    // The rounding element
    sphere(r = rounding_radius);
}