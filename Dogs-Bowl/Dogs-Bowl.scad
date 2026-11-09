// ==========================================
// Parametric Feeding Bowl for Bajensi
// Version: 0.22
// ==========================================

// --- Parameters ---
version = 0.22;

// Food portion configuration (74g per meal target)
target_food_grams = 74;
kibble_density = 0.45; // g/cm^3 (approximate density for dry dog food)

// Bowl geometry parameters (in mm)
base_diameter = 120;
top_diameter = 110;
bowl_height = 45;
base_thickness = 6;
wall_thickness = 5.0;
edge_radius = 2.0;        // Outer top edge radius
bottom_edge_radius = 1.0; // Outer bottom edge radius
inner_rim_radius = 2.0;   // Inner top (rim) edge radius
$fn = 240;                // Mesh resolution for revolved/cylindrical surfaces

// Engraved label on the outside wall (read from the +X side)
text_str = "Foxy";
text_font = "Z003";
text_size = 10;           // em size (mm)
text_recess = 1.5;        // engraving depth (mm)
text_z = 26;              // vertical center of the label (mm)

// Calculated internal metrics
required_volume_cm3 = target_food_grams / kibble_density;

module rim_fillet(fillet_base_r, top_z, fr) {
    // Rounds the corner between the cavity wall and the top rim:
    // an annular corner block from which a revolved disc (a torus with
    // major radius fillet_base_r + fr and minor radius fr, centered at
    // height top_z - fr) is removed, leaving a smooth quarter-arc
    // fillet surface of radius fr. Built with plain CSG so no trigonometry
    // is involved.
    difference() {
        difference() {
            translate([0, 0, top_z - fr])
                cylinder(r = fillet_base_r + fr, h = fr);
            translate([0, 0, top_z - fr])
                cylinder(r = fillet_base_r, h = fr);
        }
        translate([0, 0, top_z - fr])
            rotate_extrude()
                translate([fillet_base_r + fr, 0])
                    circle(r = fr, $fn = 60);
    }
}

module wall_text() {
    // Aligns a flat text slab to the tapered outer wall on the +X side and
    // subtracts it, engraving a recessed label. The slab is first stood up so
    // it reads circumferentially (Z rotation by 90), then tilted so its
    // extrusion axis follows the wall's outward normal (Y rotation by
    // 90 - the wall slope angle). Single-axis rotations only, since this
    // OpenSCAD build does not provide the multimatrix module.
    side_h = bowl_height - 2 * edge_radius;
    r_base = (base_diameter - 2 * bottom_edge_radius) / 2;
    r_top = (top_diameter - 2 * edge_radius) / 2;
    slope = (r_top - r_base) / side_h;
    r0 = r_base + 2 * sqrt(1 + slope ^ 2);  // offset outer radius at z = 0
    r_at_zc = r0 + slope * text_z;          // offset outer radius at label height
    tilt = atan(1 / abs(slope));            // slab tilt matching the wall normal

    translate([r_at_zc, 0, text_z])
        rotate([0, tilt, 0])
            rotate([0, 0, 90])
                translate([0, 0, -text_recess])
                    linear_extrude(text_recess + 2)
                        text(text_str, font = text_font, size = text_size,
                             halign = "center", valign = "center");
}

module bajensi_bowl() {
    inner_r_top = (top_diameter / 2) - wall_thickness;
    inner_height = bowl_height - base_thickness;

    // Top face level of the outer body (the Minkowski round consumes edge_radius)
    top_z = bowl_height - edge_radius;

    // Inner cavity wall radius inner_rim_radius below the rim (fillet start)
    fillet_base_r = inner_r_top * sqrt(1 - ((bowl_height - (top_z - inner_rim_radius)) / inner_height) ^ 2);

    difference() {
        // 1. Outer body with rounded top edge + rounded outer bottom edge
        union() {
            minkowski() {
                cylinder(
                    h = bowl_height - (2 * edge_radius), 
                    d1 = base_diameter - (2 * bottom_edge_radius), 
                    d2 = top_diameter - (2 * edge_radius)
                );
                sphere(r = edge_radius, $fn = 40);
            }
            // Revolved disc at the base edge; fully inside the Minkowski
            // bottom round, so inert at small bottom_edge_radius
            rotate_extrude()
                translate([base_diameter / 2 - bottom_edge_radius, 0, 0])
                    circle(r = bottom_edge_radius);
        }

        // 2. Smooth curved inner cavity with rounded rim edge
        union() {
            translate([0, 0, bowl_height])
                scale([1, 1, inner_height / inner_r_top])
                    sphere(r = inner_r_top);
            // Rim fillet ring: rounds the inner edge where the cavity
            // meets the top rim (quarter arc, radius inner_rim_radius)
            rim_fillet(fillet_base_r, top_z, inner_rim_radius);
        }

        // 3. Recessed label engraved on the outside wall (+X side)
        //wall_text();
    }
}

// Render bowl
bajensi_bowl();

// Console output
echo(str("--- Bajensi Feeding Bowl v", version, " ---"));
echo(str("Target food weight: ", target_food_grams, "g"));
echo(str("Approximate food volume: ", required_volume_cm3, " cm^3"));
