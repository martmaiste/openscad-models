// =====================================================================
// Simple C-Shaped Gate Handle (3-Cube Version) - V0.18
// 45-degree chamfers on all edges except the door-contact edges
// Inner C-opening corner chamfers miter: each bevel runs up to the
// neighboring bevel plane, so the two faces meet along one clean
// diagonal miter line (no overlap, no end-cap faces, no sliver)
// =====================================================================

version = 0.18;

// --- Parameters ---
bolt_distance = 90;      // Distance between bolt centers (mm)
post_width    = 25;      // Width (X) of posts and grip bar
post_depth    = 50;      // Depth from door to front face (Y)
post_height   = 25;      // Height (Z) of the mounting posts
grip_thickness= 25;      // Thickness (Y) of the middle grip bar

bolt_dia      = 6.4;     // M6 bolt clearance hole diameter (with tolerance)
head_dia      = 12.5;    // M6 countersunk head diameter
cs_depth      = 4.0;     // Countersink depth

chamfer       = 5.0;     // 45-degree chamfer size on all non-door edges (mm)

$fn = 64;

// --- Base Solid (Union of exactly three clean cubes) ---
module base_solid() {
    union() {
        // 1. Bottom Post Cube (Back face flush at Y = 0)
        translate([0, post_depth/2, 0])
            cube([post_width, post_depth, post_height], center = true);

        // 2. Top Post Cube (Back face flush at Y = 0, centered at Z = bolt_distance)
        translate([0, post_depth/2, bolt_distance])
            cube([post_width, post_depth, post_height], center = true);

        // 3. Middle Grip Bar Cube (Spans full height between post outer edges, flush front)
        translate([0, post_depth - grip_thickness/2, bolt_distance / 2])
            cube([post_width, grip_thickness, bolt_distance + post_height], center = true);
    }
}

// --- 45-degree Chamfer Wedge ---
// Canonical right-triangular prism: one leg of `chamfer` along +X, one leg
// along +Y, extruded along +Z. The chamfered edge runs along +Z from the
// origin and the two legs lie in the two faces that meet at that edge.
// Callers position the edge start with translate() and point X/Y/Z at the
// required directions with rotate()/mirror().
module chamfer_wedge(len) {
    linear_extrude(height = len)
        polygon(points = [[0, 0], [chamfer, 0], [0, chamfer]],
                paths = [[0, 1, 2, 0]]);
}

// --- Convex Edge Chamfers (material removed) ---
// Every convex edge is chamfered except the 8 perimeter edges of the two
// back (Y = 0) mounting faces: those touch the door and stay sharp so the
// handle sits flush. (At the 8 corners of those faces, the chamfer of an
// adjacent edge naturally bevels the corner of the flat face.)
module chamfer_wedges() {
    W     = post_width;
    H     = post_height;
    D     = post_depth;
    gap   = D - grip_thickness;        // Y of the grip back face
    top   = bolt_distance + H/2;       // Outer Z of top post / grip
    bot   = -H/2;                      // Outer Z of bottom post / grip
    z_mid = bolt_distance - H/2;       // Z of top post bottom face

    // Half-space keepers used to miter the inner bevels at the corners.
    // Each is a big box whose boundary face is the neighboring bevel
    // plane and whose body is the kept half-space (400 mm deep, 800 mm
    // wide in-plane). intersection() with a wedge trims the wedge
    // exactly at that plane, so adjacent bevel faces merge into one
    // clean face pair meeting along a single diagonal miter line
    // (no overlap region, no flat end-caps, no sliver).
    module keep_XY_le(c)  { translate([c,0,0])   rotate([0,0,225])  translate([0,-400,-400]) cube([400,800,800]); } // X+Y <= c
    module keep_YX_le(c)  { translate([0,c,0])   rotate([0,0,-45])  translate([0,-400,-400]) cube([400,800,800]); } // Y-X <= c
    module keep_XZ_le(c)  { translate([0,0,c])   rotate([0,135,0])  translate([0,-400,-400]) cube([400,800,800]); } // X+Z <= c
    module keep_XZ_ge(c)  { translate([0,0,c])   rotate([0,-45,0])  translate([0,-400,-400]) cube([400,800,800]); } // X+Z >= c
    module keep_XZd_le(c) { translate([c,0,0])   rotate([0,-135,0]) translate([0,-400,-400]) cube([400,800,800]); } // X-Z <= c
    module keep_XZd_ge(c) { translate([c,0,0])   rotate([0,45,0])   translate([0,-400,-400]) cube([400,800,800]); } // X-Z >= c

    union() {
        // Front face (Y = D) perimeter
        translate([-W/2, D, top]) rotate(90, [0,1,0]) mirror([0,1,0])
            chamfer_wedge(W);                                                 // front top
        translate([-W/2, D, bot]) rotate(180, [1,0,0]) rotate(90, [0,1,0])
            chamfer_wedge(W);                                                 // front bottom
        translate([-W/2, D, bot]) mirror([0,1,0])
            chamfer_wedge(bolt_distance + H);                                 // front left
        translate([ W/2, D, bot]) rotate(180, [0,0,1])
            chamfer_wedge(bolt_distance + H);                                 // front right

        // Top / bottom face side edges
        translate([-W/2, 0, top]) rotate(-90, [1,0,0])
            chamfer_wedge(D);                                                 // top left
        translate([-W/2, 0, bot]) rotate(90, [1,0,0]) mirror([0,0,1])
            chamfer_wedge(D);                                                 // bottom left
        translate([ W/2, 0, top]) rotate(-90, [1,0,0]) mirror([1,0,0])
            chamfer_wedge(D);                                                 // top right
        translate([ W/2, 0, bot]) rotate(90, [1,0,0]) rotate(180, [0,1,0])
            chamfer_wedge(D);                                                 // bottom right

        // Inner edges of the C opening (convex side edges)
        // Every inner bevel is cut exactly at the neighboring bevel
        // plane, so at each corner the two bevel faces share one
        // diagonal miter edge instead of overlapping or ending flat.

        // --- Post top / bottom bevels: run out to the grip-back plane ---
        intersection() {                                                      // bottom post top / left face
            translate([-W/2, 0, H/2]) rotate(-90, [1,0,0])
                chamfer_wedge(gap + chamfer);
            keep_XY_le(-W/2 + gap + chamfer);                                 // trim at grip-back bevel plane
        }
        intersection() {                                                      // bottom post top / right face
            translate([ W/2, 0, H/2]) rotate(-90, [1,0,0]) mirror([1,0,0])
                chamfer_wedge(gap + chamfer);
            keep_YX_le(-W/2 + gap + chamfer);                                 // trim at grip-back bevel plane
        }
        intersection() {                                                      // top post bottom / left face
            translate([-W/2, 0, z_mid]) rotate(90, [1,0,0]) mirror([0,0,1])
                chamfer_wedge(gap + chamfer);
            keep_XY_le(-W/2 + gap + chamfer);                                 // trim at grip-back bevel plane
        }
        intersection() {                                                      // top post bottom / right face
            translate([ W/2, 0, z_mid]) rotate(90, [1,0,0]) rotate(180, [0,1,0])
                chamfer_wedge(gap + chamfer);
            keep_YX_le(-W/2 + gap + chamfer);                                 // trim at grip-back bevel plane
        }

        // --- Grip-back bevels: cut at both post step planes ---
        intersection() {                                                      // grip back / left face
            translate([-W/2, gap, H/2 - chamfer])
                chamfer_wedge(bolt_distance - H + 2*chamfer);
            intersection() {
                keep_XZd_le(-W/2 - H/2 + chamfer);                            // trim at bottom post bevel plane (X-Z = -20)
                keep_XZ_le(-W/2 + z_mid + chamfer);                           // trim at top post step plane
            }
        }
        intersection() {                                                      // grip back / right face
            translate([ W/2, gap, H/2 - chamfer]) mirror([1,0,0])
                chamfer_wedge(bolt_distance - H + 2*chamfer);
            intersection() {
                keep_XZ_ge(W/2 + H/2 - chamfer);                              // trim at bottom post bevel plane (X+Z = 20)
                keep_XZd_ge(W/2 - z_mid - chamfer);                           // trim at top post step plane
            }
        }
    }
}

// --- Concave Edge Chamfers (material added) ---
// The two step edges where the posts' inner faces meet the grip back face
// are concave (inner corners): their 45-degree chamfer is a fillet bead
// that fills the corner.
module chamfer_fillets() {
    W     = post_width;
    H     = post_height;
    gap   = post_depth - grip_thickness;
    z_mid = bolt_distance - H/2;

    union() {
        translate([-W/2, gap, H/2]) rotate(180, [1,0,0]) rotate(90, [0,1,0])
            chamfer_wedge(W);                                                 // bottom post top / grip back
        translate([-W/2, gap, z_mid]) rotate(90, [0,1,0]) mirror([0,1,0])
            chamfer_wedge(W);                                                 // top post bottom / grip back
    }
}

// --- Main Module ---
module gate_handle() {
    difference() {
        union() {
            base_solid();

            // --- 45-degree fillets on the two concave (inner) edges ---
            //chamfer_fillets();  // disabled for now: inner corners use blended chamfers
        }

        // --- 45-degree chamfers on the 14 convex non-door edges ---
        chamfer_wedges();

        // --- Bottom Mounting Hole & Countersink ---
        translate([0, 0, 0])
            mounting_hole();

        // --- Top Mounting Hole & Countersink ---
        translate([0, 0, bolt_distance])
            mounting_hole();
    }
}

// --- Corrected Mounting Hole Module ---
module mounting_hole() {
    rotate([-90, 0, 0]) {
        // Straight clearance hole from back (Y = 0) to front
        cylinder(h = post_depth, r = bolt_dia/2);
        
        // Countersink cone starting inside the front face and widening outwards
        translate([0, 0, post_depth - cs_depth])
            cylinder(h = cs_depth + 0.1, r1 = bolt_dia/2, r2 = head_dia/2);
    }
}

// Render the handle
gate_handle();

// Version logging
echo(str("Rendering Gate Handle Version: ", version));
