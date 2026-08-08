// ====================================================================================
// Cargo Strap Guide (Saddle / Spacer Mount)
// Version: v0.08
// Date: 2026-07-30
// Revision History:
//   - v0.01: Initial closed-tunnel design.
//   - v0.02: Revised to an open saddle/spacer design.
//   - v0.03: Complete geometry rewrite using a constructive union of rounded blocks.
//   - v0.04: Transformed design to use 45-degree flat chamfers (bevels) on all edges.
//   - v0.05: Simplified by removing all chamfers/wedges from the groove floor.
//   - v0.06: Placed chamfers on the top-left and top-right of the groove floor (z=1.5).
//   - v0.07: Swapped the chamfers on the groove floor block (the plate underneath the
//            strap) so they are on the bottom side of the block (at z=0) and NOT
//            the top side (at z=1.5). The top side of the groove floor (where the
//            strap directly sits) is now 100% flat with sharp square 90-degree edges,
//            while the bottom side has elegant 45-degree bevels along x=0 and x=19.
//   - v0.08: Added a `closed_version` option to provide a secure tunnel, keeping the
//            strap in place even when loose. Maintains the distinct rounded block aesthetic.
//            Added explicit `strap_thickness` and `strap_thickness_clearance` parameters,
//            enabled `closed_version` by default, and added bottom chamfers to the top bridge
//            so the strap easily slides into the tunnel without snagging.
// ====================================================================================

/* [Design Options] */
// Create a closed loop (tunnel) instead of an open saddle
closed_version = true;

// Thickness of the top bridge in the closed version (default 1.5mm)
bridge_thickness = 1.5;


/* [Strap Dimensions] */
// Width of the cargo strap (standard default is 26mm)
strap_width = 25;

// Thickness of the cargo strap (standard default is 1mm)
strap_thickness = 1.5;

// Side clearance inside the groove (width-wise)
strap_clearance = 0.5;

// Vertical clearance inside the groove (thickness-wise)
strap_thickness_clearance = 0.5;


/* [Guide Block Dimensions] */
// Fixed width of the guide block (matches 19mm tape)
block_width = 19;

// Total height of the shoulder blocks
block_height = 3.0;

// Length of the shoulders on each side of the strap groove (default 10mm)
shoulder_length = 10;


/* [Tape Mount Settings] */
// Enable a shallow tape recess on the bottom face (best if block_width is increased)
enable_tape_recess = false;

// Width of the tape recess (must be smaller than block_width, e.g. 17mm)
tape_recess_width = 17.0;

// Depth of the tape recess
tape_recess_depth = 0.5;


/* [Aesthetics & Chamfer Size] */
// Size of the outer flat chamfer (bevel) for the shoulder and floor edges
chamfer_size = 0.5;


// --- Derived Parameters (Internal Math) ---
// Total depth of the groove (strap thickness + vertical clearance)
groove_depth = strap_thickness + strap_thickness_clearance;

block_length = strap_width + 2 * shoulder_length;
groove_floor_height = block_height - groove_depth;

// Groove width between the shoulders
groove_width = strap_width + strap_clearance;

// Overlap length to ensure a solid manifold merge of the floor block inside the shoulders
overlap = 1.0;
groove_floor_length = groove_width + 2 * overlap;

// Safeguards to prevent geometry breakdown due to extreme chamfer inputs
total_height = closed_version ? block_height + bridge_thickness : block_height;
c_out = min(chamfer_size, min(block_width/2 - 0.2, min(block_length/2 - 0.2, total_height - 0.2)));
c_floor = min(chamfer_size, min(block_width/2 - 0.2, groove_floor_height - 0.2));
c_bridge = min(c_out, bridge_thickness/2 - 0.01);


// Generates a 2D octagon (chamfered rectangle)
module chamfered_rectangle(w, l, c) {
    polygon(points = [
        [c, 0], [w - c, 0],
        [w, c], [w, l - c],
        [w - c, l], [c, l],
        [0, l - c], [0, c]
    ]);
}


// Creates a 3D block with chamfered top edges and vertical corners,
// while keeping the bottom face perfectly flat for maximum tape adhesion.
module flat_bottom_chamfered_cube(size, c) {
    w = size[0];
    l = size[1];
    h = size[2];
    hull() {
        // Base prism (vertical walls with chamfered corners up to h - c)
        linear_extrude(height = h - c)
            chamfered_rectangle(w, l, c);

        // Top cap prism (a smaller rectangle at height h to slope the top edges)
        translate([c, c, h - 0.01])
            linear_extrude(height = 0.01)
            chamfered_rectangle(w - 2 * c, l - 2 * c, 0.01);
    }
}


// Generates a 2D profile with chamfered bottom corners and a flat top (for X-Z plane)
module chamfered_bottom_profile(w, h, c) {
    polygon(points = [
        [c, 0], [w - c, 0],
        [w, c], [w, h],
        [0, h], [0, c]
    ]);
}


// Extrudes the chamfered bottom profile along the Y axis
module groove_floor_block_chamfered(w, l, h, c) {
    translate([0, 0, h])
        rotate([270, 0, 0]) // Rotate to map 2D profile (X,Z) to run along Y
        linear_extrude(height = l)
        chamfered_bottom_profile(w, h, c);
}


// Creates a 3D block with chamfered top and bottom edges (for the closed version bridge)
module bridge_block(w, l, h, c) {
    hull() {
        // Middle body
        translate([0, 0, c])
            linear_extrude(height = max(0.01, h - 2 * c))
            chamfered_rectangle(w, l, c);

        // Top cap prism
        translate([c, c, h - 0.01])
            linear_extrude(height = 0.01)
            chamfered_rectangle(w - 2 * c, l - 2 * c, 0.01);

        // Bottom cap prism
        translate([c, c, 0])
            linear_extrude(height = 0.01)
            chamfered_rectangle(w - 2 * c, l - 2 * c, 0.01);
    }
}


module cargo_strap_saddle() {
    difference() {
        union() {
            // 1. Left Shoulder (Chamfered top-inner and top-outer edges)
            translate([0, 0, 0])
                flat_bottom_chamfered_cube([block_width, shoulder_length, total_height], c_out);

            // 2. Right Shoulder
            translate([0, block_length - shoulder_length, 0])
                flat_bottom_chamfered_cube([block_width, shoulder_length, total_height], c_out);

            // 3. Middle Groove Floor Plate
            // Perfectly flat and square-edged on the top side (z=1.5) where the strap rests,
            // with elegant 45-degree chamfers on the bottom side of the block (z=0).
            translate([0, (block_length - groove_floor_length)/2, 0])
                groove_floor_block_chamfered(block_width, groove_floor_length, groove_floor_height, c_floor);

            // 4. Closed Version Top Bridge
            if (closed_version) {
                translate([0, (block_length - groove_floor_length)/2, block_height])
                    bridge_block(block_width, groove_floor_length, bridge_thickness, c_bridge);
            }
        }

        // 5. Optional Tape Recess on Bottom
        if (enable_tape_recess) {
            rec_x = (block_width - tape_recess_width) / 2;
            translate([rec_x, -1, -0.01])
                cube([tape_recess_width, block_length + 2, tape_recess_depth + 0.01]);
        }
    }
}

// Instantiate the smooth, bottom-chamfered model
cargo_strap_saddle();
