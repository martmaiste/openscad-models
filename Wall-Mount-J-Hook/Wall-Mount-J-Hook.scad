// Project Version: 1.37
// J-shaped wall hook - Thingiverse Customizer Compatible
// 25%/75% proportional screw holes with dynamic 90-degree countersink

/* [Hook Dimensions] */
// Diameter of the inside of the hook (mm)
inner_diameter = 25;    
// Total thickness of the material (mm)
thickness = 10;                
// Total width of the hook (mm)
width = 20;                 
// Rounding radius for edges (Minkowski)
rounding = 4;               
// Total height of the mounting plate (mm)
back_plate_height = 40;  

/* [Screw Hole Parameters] */
// Diameter of the screw shank (mm)
screw_d = 4; 
// Multiplier for the head diameter (Standard is 2.0)
head_multiplier = 2.125; 

/* [Hidden] */
$fn = 60; 

// --- DYNAMIC CALCULATIONS ---
// Standard 90-degree countersink: head diameter is derived from shank
countersink_d = (screw_d * head_multiplier);              
// 90-degree angle formula: h = (D - d) / 2
countersink_h = (countersink_d - screw_d) / 2;

// Core dimensions adjusted for Minkowski offset
m_width = width - (rounding * 2);
m_thick = thickness - (rounding * 2);
r_inner = (inner_diameter / 2) + rounding;
r_outer = r_inner + m_thick;

// Proportional hole positions (25% and 75% of height)
hole_pos_low = back_plate_height * 0.25 - rounding;
hole_pos_high = back_plate_height * 0.75 - rounding;

echo("Running OpenSCAD Hook Version: 1.37");
echo("Calculated countersink height:", countersink_h);

difference() {
    // 1. MAIN BODY
    minkowski() {
        // Extrude along the Y-axis (width)
        linear_extrude(height = m_width, center = true) {
            union() {
                // Mounting plate profile
                translate([-m_thick/2, 0])
                    square([m_thick, back_plate_height - (rounding * 2)]);
                
                // Hook arc profile
                translate([m_thick/2 + r_inner, 0])
                difference() {
                    circle(r = r_outer);
                    circle(r = r_inner);
                    // Cut to create J-shape
                    translate([-r_outer * 2, 0])
                        square([r_outer * 4, r_outer * 2]);
                }
            }
        }
        sphere(r = rounding);
    }

    // 2. SCREW HOLES
    for (z_pos = [hole_pos_low, hole_pos_high]) {
        // Position at the front surface
        translate([thickness/2, z_pos, 0]) 
        rotate([0, 90, 0]) {
            
            // Main screw shank hole
            cylinder(d = screw_d, h = thickness * 3, center = true);
            
            // 90-degree countersink
            // Starts from the surface and goes inward by countersink_h
            translate([0, 0, -countersink_h])
                cylinder(d1 = screw_d, d2 = countersink_d, h = countersink_h + 0.1);
                
            // Surface clearance to ensure no thin layers on top
            translate([0, 0, 0])
                cylinder(d = countersink_d, h = 2);
        }
    }
}