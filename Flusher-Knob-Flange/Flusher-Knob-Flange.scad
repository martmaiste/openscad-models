// ======================================================================
// Parametric Toilet Flush Button Flange Adapter
// Version: 0.01
// Description: Adapts a 38mm button to a 61.5mm lid hole with a 
//              cylindrical base section on the upper flange to eliminate 
//              sharp/weak edges, plus clearances and chamfers.
// ======================================================================

/* [Dimensions] */
lid_hole_dia   = 61.5;  // Diameter of the toilet tank lid hole (mm)
button_dia     = 38.0;  // Outer diameter of the new button assembly (mm)
insert_depth   = 20.0;  // Height of the lower cylindrical section going into the hole (mm)
flange_height  = 20.0;  // Total height of the upper section (mm)
collar_dia     = 68.0;  // Outer diameter of the base/collar resting on the lid (mm)
top_rim_dia    = 48.0;  // Outer diameter of the top wide edge (mm)
tolerance      = 0.5;   // Clearance tolerance for both the lid fit and button fit (mm)
chamfer_size   = 1.0;   // Size of the chamfers (mm)

/* [Resolution] */
$fn = 120; // Smooth curves

module flush_adapter() {
    lower_outer_dia = lid_hole_dia - tolerance;
    inner_dia = button_dia + tolerance;
    total_height = insert_depth + flange_height;
    
    // Height of the small cylindrical base portion of the flange (e.g., 3mm)
    cyl_base_height = 3.0;
    cone_height = flange_height - cyl_base_height;
    
    difference() {
        union() {
            // 1. Lower cylindrical part (goes into the lid hole)
            cylinder(d = lower_outer_dia, h = insert_depth);
            
            // 2. Upper section:
            translate([0, 0, insert_depth]) {
                // a) Short cylindrical base (removes sharp feathered edge)
                cylinder(d = collar_dia, h = cyl_base_height);
                
                // b) Conical transition from collar diameter up to top rim diameter
                translate([0, 0, cyl_base_height])
                cylinder(d1 = collar_dia, d2 = top_rim_dia, h = cone_height);
            }
        }
        
        // Central through-hole for the button assembly
        translate([0, 0, -1])
        cylinder(d = inner_dia, h = total_height + 2);
        
        // --- Chamfers ---
        
        // 1. Outside edge of the bottom edge
        translate([0, 0, -0.1])
        difference() {
            cylinder(d = lower_outer_dia + 10, h = chamfer_size + 0.2);
            cylinder(d1 = lower_outer_dia - (2 * chamfer_size), d2 = lower_outer_dia, h = chamfer_size + 0.2);
        }
        
        // 2. Internal hole top edge
        translate([0, 0, total_height - chamfer_size])
        cylinder(d1 = inner_dia, d2 = inner_dia + (2 * chamfer_size), h = chamfer_size + 0.1);
        
        // 3. Internal hole bottom edge
        translate([0, 0, -0.1])
        cylinder(d1 = inner_dia + (2 * chamfer_size), d2 = inner_dia, h = chamfer_size + 0.2);
    }
}

// Render the adapter
flush_adapter();

// --- Version & Metadata Info Stamp ---
echo(str("Model: Flush Adapter, Version: 0.01"));