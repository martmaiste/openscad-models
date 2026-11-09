/* Parametric Block
   Default: 7 x 5 x 40 mm
   Tweak the parameters below; everything derives from them. */

/* ---------- Parameters ---------- */

// Width along X (mm)
block_width = 7;

// Depth along Y (mm)
block_depth = 5;

// Height along Z (mm)
block_height = 40;

// Chamfer on all 12 edges (mm, 0 = none)
edge_chamfer = 0.5;

// Corner rounding on vertical edges (mm, 0 = sharp; ignored if edge_chamfer > 0)
corner_radius = 0;

// Resolution for curved surfaces ($fn)
$fn = 64;

/* ---------- Derived helpers ---------- */

// Safe chamfer: clamp to half the smallest dimension
ch = min(edge_chamfer, block_width / 2, block_depth / 2, block_height / 2);

// Safe corner radius
cr = min(corner_radius, block_width / 2, block_depth / 2);

/* ---------- Modules ---------- */

// Octahedron used to generate exact 45-degree chamfers via minkowski
module octahedron(r) {
    polyhedron(
        points = [
            [ r, 0, 0], [-r, 0, 0],
            [ 0, r, 0], [ 0,-r, 0],
            [ 0, 0, r], [ 0, 0,-r]
        ],
        faces = [
            [0, 2, 4], [2, 1, 4], [1, 3, 4], [3, 0, 4],
            [2, 0, 5], [1, 2, 5], [3, 1, 5], [0, 3, 5]
        ]
    );
}

// Block with all 12 edges chamfered by c (corners become small triangles)
module chamfered_block(w, d, h, c) {
    minkowski() {
        cube([w - 2*c, d - 2*c, h - 2*c]);
        octahedron(c);
    }
}

// Block with rounded vertical edges (sharp top/bottom edges)
module rounded_block(w, d, h, r) {
    linear_extrude(height = h)
        offset(r = r)
            offset(delta = -r)
                square([w, d]);
}

/* ---------- Model ---------- */

if (ch > 0) {
    chamfered_block(block_width, block_depth, block_height, ch);
} else if (cr > 0) {
    rounded_block(block_width, block_depth, block_height, cr);
} else {
    cube([block_width, block_depth, block_height]);
}