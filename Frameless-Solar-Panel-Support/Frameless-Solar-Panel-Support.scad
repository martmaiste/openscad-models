// =====================================================================
// Parametric Vertical Support for Frameless Solar Panels
// Version: 0.45
// =====================================================================

// --- Parameters ---
version = 0.45;

// Panel specifications
panel_thickness = 3.2;       // Thickness of the solar panels (mm)
panel_gap = 10.0;            // Gap between adjacent panels (mm)

// Support body dimensions
support_height = 35.0;       // Total height of the support (mm)
support_width = 30.0;        // Total width of the base plate (mm)

// Single-panel edge configuration (raised center section always stays intact;
// everything left/right of it, including the base plate, is cut away. The
// centerline bosses always remain.)
// "both"  = center support between two panels
// "left"  = support the left panel only, right side cut off
// "right" = support the right panel only, left side cut off
single_side = "both";
base_thickness = 3.0;        // Thickness of the wall mounting base (mm)

// Raised middle section (width matches panel gap = 10mm, thickness matches panel thickness = 3.5mm)
raised_width = panel_gap;
raised_thickness = panel_thickness;
raised_depth = base_thickness + raised_thickness; // Total projection from back wall = 7.5mm

// Panel resting lip & front retention ridge configuration
lip_height = 0.0;            // Vertical height position of the resting lip (at the bottom)
ridge_thickness = 2.0;       // Thickness (depth) of the retention ridge
lip_depth = raised_depth + ridge_thickness; // Total lip depth (9.5mm) so ridge sits right against the central section
lip_thickness = 5.0;         // Thickness of the resting lip (mm)
lip_ridge_height = 3.0;      // Height of the raised lip at the front edge to secure the panel face
ridge_chamfer = 1.0;         // Exact 1mm 45-degree chamfer size for top & bottom outer edges

// Bottom mounting bosses (matched to strip holes: 5.3mm diameter, 10mm apart)
boss_diameter = 6.0;         // Diameter of the locating bosses matching strip holes (mm)
boss_length = 4.0;           // Total length of the boss (embedded + protruding) (mm)
boss_spacing = 12.0;         // Center-to-center distance matching the 10mm hole pitch (mm)
boss_first_z = 8;          // Absolute height (from z=0) of the lowest boss center; subsequent bosses stack upward by boss_spacing

// Off-center round locking groove parameters (positioned at the bottom of each boss base)
groove_thickness = 0.8;      // 0.8 mm thick groove radial width
groove_depth = 1.0;          // 1 mm deep groove into the base
groove_offset = 0.8;         // Off-center shift towards the bottom of the boss base

// Render smoothness
$fn = 64;

// --- Modules ---
module locking_boss(z_pos) {
    translate([0, 0, z_pos])
        rotate([90, 0, 0])
            cylinder(d = boss_diameter, h = boss_length);
}

module locking_groove(z_pos) {
    // Shifted towards the bottom of the boss base (using + groove_offset)
    translate([0, 0, z_pos + groove_offset])
        rotate([90, 0, 0])
            difference() {
                // Outer diameter of the groove ring
                cylinder(d = boss_diameter + (2 * groove_thickness), h = groove_depth);
                // Inner core matching boss diameter
                translate([0, 0, -0.1])
                    cylinder(d = boss_diameter, h = groove_depth + 0.2);
            }
}

module raised_center_section() {
    hull() {
        translate([-raised_width / 2, 0, 0])
            cube([raised_width, raised_depth, support_height - raised_thickness]);

        translate([-raised_width / 2, 0, support_height - 0.1])
            cube([raised_width, base_thickness, 0.1]);
    }
}

module retention_ridge() {
    // Simple block; the top/bottom front chamfers are cut in solar_support()
    translate([-support_width / 2, lip_depth - ridge_thickness, lip_height])
        cube([support_width, ridge_thickness, lip_thickness + lip_ridge_height]);
}

module chamfer_wedge(c, length = support_width + 2) {
    // 45-degree triangular prism centered on the X axis.
    // Legs of length c run along -Y and -Z from the origin.
    rotate([0, 90, 0])
        linear_extrude(center = true, height = length)
            polygon([[0, 0], [0, -c], [c, 0]]);
}

module side_cut() {
    // Keeps only the requested side; cut plane sits at the side faces of the
    // (intact) raised center section
    if (single_side == "left")
        difference() {
            children();
            translate([raised_width / 2, -10, -10])
                cube([support_width, lip_depth + 20, support_height + 20]);
        }
    else if (single_side == "right")
        difference() {
            children();
            translate([-raised_width / 2 - support_width, -10, -10])
                cube([support_width, lip_depth + 20, support_height + 20]);
        }
    else
        children();
}

module solar_support() {
    difference() {
        union() {
            // 1-4. Base plate + panel-facing geometry (cut to one side for
            // single-panel edge use; the raised center section is never cut)
            side_cut() {
                // 1. Main Wall-Mount Base Plate
                translate([-support_width / 2, 0, 0])
                    cube([support_width, base_thickness, support_height]);

                // 3. Horizontal Resting Lip spanning full width
                translate([-support_width / 2, 0, lip_height])
                    cube([support_width, lip_depth, lip_thickness]);

                // 4. Front retention ridge (chamfers cut below)
                retention_ridge();
            }

            // 2. Raised Central Section with 45-degree slope for rain shedding
            // (always intact, also acts as the cut boundary in single-side modes)
            raised_center_section();

            // 5. Locating Bosses starting at boss_first_z, stacked by boss_spacing
            locking_boss(boss_first_z);                    // Lower boss
            locking_boss(boss_first_z + boss_spacing);     // Middle boss
            locking_boss(boss_first_z + 2 * boss_spacing); // Upper boss
        }

        // --- Subtractions for Off-center Locking Grooves at the bottom of each boss ---
        locking_groove(boss_first_z);
        locking_groove(boss_first_z + boss_spacing);
        locking_groove(boss_first_z + 2 * boss_spacing);

        // --- 45-degree chamfers on the front edges of the ridge/lip ---
        // Top front edge of the ridge
        translate([0, lip_depth, lip_height + lip_thickness + lip_ridge_height])
            chamfer_wedge(ridge_chamfer);

        // Bottom front edge (front face of ridge is coplanar with the lip,
        // so the visible bottom chamfer sits at the bottom of the lip)
        translate([0, lip_depth, lip_height])
            mirror([0, 0, 1])
                chamfer_wedge(ridge_chamfer);

        // Top side edges of the base plate (right & left), along its depth
        translate([support_width / 2, base_thickness / 2, support_height])
            rotate([0, 0, -90])
                chamfer_wedge(ridge_chamfer, base_thickness + 2);

        translate([-support_width / 2, base_thickness / 2, support_height])
            rotate([0, 0, 90])
                chamfer_wedge(ridge_chamfer, base_thickness + 2);

        // Top side edges of the ridge (right & left), along the ridge depth
        translate([support_width / 2, lip_depth - ridge_thickness / 2, lip_height + lip_thickness + lip_ridge_height])
            rotate([0, 0, -90])
                chamfer_wedge(ridge_chamfer, ridge_thickness);

        translate([-support_width / 2, lip_depth - ridge_thickness / 2, lip_height + lip_thickness + lip_ridge_height])
            rotate([0, 0, 90])
                chamfer_wedge(ridge_chamfer, ridge_thickness);

        // Bottom side edges (right & left), running along the full lip depth
        translate([support_width / 2, lip_depth / 2, lip_height])
            rotate([0, 0, -90])
                mirror([0, 0, 1])
                    chamfer_wedge(ridge_chamfer, lip_depth + 2);

        translate([-support_width / 2, lip_depth / 2, lip_height])
            rotate([0, 0, 90])
                mirror([0, 0, 1])
                    chamfer_wedge(ridge_chamfer, lip_depth + 2);

        // Bottom edge of the single-side cut plane (matches the side chamfers)
        if (single_side == "left") {
            translate([raised_width / 2, lip_depth / 2, lip_height])
                rotate([0, 0, -90])
                    mirror([0, 0, 1])
                        chamfer_wedge(ridge_chamfer, lip_depth + 2);
            // Top edge of the cut plane (base plate & ridge top)
            translate([raised_width / 2, base_thickness / 2, support_height])
                rotate([0, 0, -90])
                    chamfer_wedge(ridge_chamfer, base_thickness + 2);
            translate([raised_width / 2, lip_depth - ridge_thickness / 2, lip_height + lip_thickness + lip_ridge_height])
                rotate([0, 0, -90])
                    chamfer_wedge(ridge_chamfer, ridge_thickness);
        } else if (single_side == "right") {
            translate([-raised_width / 2, lip_depth / 2, lip_height])
                rotate([0, 0, 90])
                    mirror([0, 0, 1])
                        chamfer_wedge(ridge_chamfer, lip_depth + 2);
            // Top edge of the cut plane (base plate & ridge top)
            translate([-raised_width / 2, base_thickness / 2, support_height])
                rotate([0, 0, 90])
                    chamfer_wedge(ridge_chamfer, base_thickness + 2);
            translate([-raised_width / 2, lip_depth - ridge_thickness / 2, lip_height + lip_thickness + lip_ridge_height])
                rotate([0, 0, 90])
                    chamfer_wedge(ridge_chamfer, ridge_thickness);
        }
    }
}

// --- Render ---
solar_support();

// Display version info in OpenSCAD console
echo(str("Rendering Solar Support Version: ", version));
