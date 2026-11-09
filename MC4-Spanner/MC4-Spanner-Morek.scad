// =====================================================================
// File: MC4-Spanner.scad
// Title: Parametric & Modular MC4 Solar Connector Spanner
// Version: v0.01
// Description: Parametric OpenSCAD model for solar PV connectors.
//              Initial module configured for Morek MC4 1500V.
// =====================================================================

// --- VERSION & METADATA ---
// Version: v0.01

// --- PARAMETERS ---
$fn = 120; // High resolution for smooth curved surfaces

// Spanner body dimensions
spanner_thickness = 5.0;  // Thickness of the wrench body (mm)
handle_length = 95.0;     // Length of the handle (mm)
handle_width = 32.0;      // Width of the handle grip (mm)
head_radius = 18.0;       // Outer radius of the wrench head end (mm)

// Morek MC4 1500V Connector Parameters
connector_od = 20.0;        // Outer diameter (mm)
connector_minor_d = 18.5;   // Minor diameter (mm)
elevated_arc_len = 6.0;     // Elevated section arc length on surface (mm)
num_lobes = 6;              // Repeating locking/grip lobes
tolerance = 0.35;           // 3D printer clearance tolerance (mm)
cable_slot_width = 7.5;     // Side opening slot to slip spanner over cable (mm)

// --- MODULES ---

// Module: Morek MC4 1500V Wrench Head Profile Cutout
module morek_mc4_head_cutout() {
    r_outer = (connector_od / 2) + tolerance;
    r_minor = (connector_minor_d / 2) + tolerance;
    
    // Calculate angular width of the elevated section in degrees
    elevated_angle = (elevated_arc_len / (connector_od / 2)) * (180 / PI);

    union() {
        // Center multi-point socket profile combining minor diameter and elevated teeth
        intersection() {
            circle(r = r_outer + 0.5);
            
            union() {
                // Minor diameter base circle
                circle(r = r_minor);
                
                // Elevated gripping sections (lobes)
                for (i = [0 : num_lobes - 1]) {
                    rotate([0, 0, i * (360 / num_lobes)]) {
                        polygon(points=[
                            [0, 0],
                            [r_outer * cos(-elevated_angle/2), r_outer * sin(-elevated_angle/2)],
                            [r_outer * cos(elevated_angle/2), r_outer * sin(elevated_angle/2)]
                        ]);
                    }
                }
            }
        }
        
        // Cable entry slot to allow sliding sideways onto connector/cable
        translate([0, -r_outer * 2.5, 0])
            square([cable_slot_width, r_outer * 5], center = true);
    }
}

// Module: Main Parametric MC4 Spanner Body
module mc4_spanner() {
    linear_extrude(height = spanner_thickness, convexity = 5) {
        difference() {
            // Ergonomic wrench outline (hull between head and handle grip)
            hull() {
                // Wrench head end
                translate([0, 0, 0])
                    circle(r = head_radius);
                
                // Handle end grip
                translate([handle_length, 0, 0])
                    circle(r = handle_width / 2);
            }
            
            // Subtract connector profile cutout
            morek_mc4_head_cutout();
            
            // Weight-reduction pocket / finger grip slot in handle
            translate([handle_length * 0.55, 0, 0])
                pill_shape(handle_length * 0.4, handle_width * 0.38);
        }
    }
}

// Helper: Pill-shaped cutout for handle weight reduction
module pill_shape(l, w) {
    hull() {
        translate([-l/2 + w/2, 0, 0]) circle(r = w/2);
        translate([l/2 - w/2, 0, 0]) circle(r = w/2);
    }
}

// --- RENDER ---
mc4_spanner();
