/*
=============================================================================
README / DOCUMENTATION
=============================================================================
Project: Parametric Tile Glue Applicator / Scraper
Version: v0.04

Description:
This OpenSCAD script generates a 3D-printable scraper used for spreading
adhesive when laying ceramic tiles. The design is fully parametric, allowing
you to adjust the width, height, and teeth configuration to match different
tile sizes and glue requirements.

Modifications in this version:
- Added 10% rounded corners to the teeth cutouts for durability.
- Completely flat design without a thick handle.
- Width is automatically adjusted to ensure the blade starts and ends
  with a solid tooth instead of an empty gap.

How to use:
1. Open this file in OpenSCAD.
2. Use the Customizer pane (Window -> Customizer) to modify dimensions.
3. Press F5 to preview, F6 to render, and F7 to export as STL/3MF for printing.

Printing Tips:
- Print flat on the bed (no supports required).
- Use a durable filament like PETG or ABS/ASA. PLA is acceptable for
  single-use/DIY projects but may wear out faster.
- Increase perimeter count (walls) in your slicer for a stiffer blade.
=============================================================================
*/

// --- Parameters ---

/* [Main Dimensions] */
// Target width of the scraper blade (mm). Actual width auto-adjusts to end with teeth.
target_scraper_width = 100;
// Overall height of the scraper (mm)
scraper_height = 80;
// Thickness of the scraper blade (mm)
blade_thickness = 2.0;

/* [Teeth Configuration] */
// Height of the teeth cutouts (mm)
tooth_height = 5;
// Width of each solid tooth (mm)
tooth_width = 5;
// Spacing between teeth (width of the gap) (mm)
tooth_spacing = 5;

/* [Hole Configuration] */
// Diameter of the hanging hole (set to 0 to disable)
hole_diameter = 8.0;
// Distance of the hole from the top edge (mm)
hole_offset = 15.0;

/* [Hidden] */
$fn = 60;
eps = 0.01;

// Calculations to ensure starts and ends with a tooth
// Calculate how many teeth will fit closest to the target width
num_teeth = max(2, round((target_scraper_width + tooth_spacing) / (tooth_width + tooth_spacing)));
// Calculate the precise width required
actual_width = (num_teeth * tooth_width) + ((num_teeth - 1) * tooth_spacing);

// Calculate rounding radius (10% of tooth width)
round_r = tooth_width * 0.10;

// --- Module Definition ---

module tile_glue_applicator() {
    linear_extrude(height = blade_thickness) {
        difference() {
            // Apply double-offset rounding to the blade and teeth
            // This uniformly rounds both convex (tooth tips) and concave (tooth roots) corners
            offset(r = round_r)
                offset(r = -2 * round_r)
                    offset(r = round_r) {
                        difference() {
                            // Main Scraper Blade (2D)
                            square([actual_width, scraper_height]);

                            // Subtract teeth gaps
                            if (num_teeth > 1) {
                                for (i = [0 : num_teeth - 2]) {
                                    gap_x = tooth_width + i * (tooth_width + tooth_spacing);
                                    translate([gap_x, -eps])
                                        square([tooth_spacing, tooth_height + eps]);
                                }
                            }
                        }
                    }

            // Subtract Hanging Hole (done after offset so it remains perfectly circular)
            if (hole_diameter > 0) {
                translate([actual_width / 2, scraper_height - hole_offset])
                    circle(d = hole_diameter);
            }
        }
    }
}

// --- Render ---
tile_glue_applicator();
