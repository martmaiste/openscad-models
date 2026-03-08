/* [General Dimensions] */

// The exact ID of your vacuum and nozzle (mm)
Base_Diameter = 32.0; 

// Thickness of the walls (mm)
Wall_Thickness = 2.5; 

// How deep the adapter should slide into the tools (mm)
Insertion_Length = 30; 

// How much the diameter shrinks toward the tips (mm)
Taper_Amount = 1.0; 

/* [Flange Settings] */

// Width of the center stop ring (mm)
Flange_Diameter = 40; 

// Thickness of the center stop ring (mm)
Flange_Thickness = 3; 

/* [Smoothing & Airflow] */

// Size of the lead-in chamfers (mm)
Bevel_Size = 1.5; 

// Level of detail (higher = smoother circles)
$fn = 100; // [50:150]

/* [Preview] */

// Show a cut-away view to see internal airflow?
Part_Preview = "Full Model"; // [Full Model, Cross Section]
//Part_Preview = "Cross Section"; // [Full Model, Cross Section]
// --- Logic ---

Total_Height = (Insertion_Length * 2) + Flange_Thickness;
Airway_Dia = Base_Diameter - (Wall_Thickness * 2);

module adapter_core() {
    difference() {
        // --- OUTER SHAPE ---
        union() {
            // Lower Half
            hull() {
                translate([0,0,0.5]) 
                    cylinder(h = Insertion_Length-0.5, d1 = Base_Diameter - Taper_Amount, d2 = Base_Diameter);
                cylinder(h = 0.1, d = Base_Diameter - Taper_Amount - Bevel_Size); 
            }
            
            // Middle Flange
            translate([0, 0, Insertion_Length])
                cylinder(h = Flange_Thickness, d = Flange_Diameter);
            
            // Upper Half
            hull() {
                translate([0, 0, Insertion_Length + Flange_Thickness])
                    cylinder(h = Insertion_Length - 0.5, d1 = Base_Diameter, d2 = Base_Diameter - Taper_Amount);
                translate([0, 0, Total_Height - 0.1])
                    cylinder(h = 0.1, d = Base_Diameter - Taper_Amount - Bevel_Size);
            }
        }

        // --- INNER AIRWAY ---
        union() {
            // Main bore
            translate([0, 0, -1])
                cylinder(h = Total_Height + 2, d = Airway_Dia);
            
            // Internal chamfer at bottom
            translate([0,0,-0.1])
                cylinder(h = Bevel_Size, d1 = Airway_Dia + Bevel_Size, d2 = Airway_Dia);
                
            // Internal chamfer at top
            translate([0,0, Total_Height - Bevel_Size + 0.1])
                cylinder(h = Bevel_Size, d1 = Airway_Dia, d2 = Airway_Dia + Bevel_Size);
        }
    }
}

// --- Rendering Logic ---

if (Part_Preview == "Full Model") {
    adapter_core();
} else {
    difference() {
        adapter_core();
        translate([0, -Flange_Diameter/2, -1]) 
            cube([Flange_Diameter, Flange_Diameter, Total_Height + 2]);
    }
}