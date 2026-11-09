/*
    Frameless Solar Panel Washer — Separator Washer
    ------------------------------------------------
    Parametric & modular separator washer:

      * Annular washer body: ID 5 mm, OD 25 mm, thickness 2 mm
      * Top:    a strip running across the full diameter (through the
                center) from one end to the other, 10 mm wide, protruding
                3 mm above the top face. Its ends follow the OD curve.
      * Bottom: a channel running in the same direction (full diameter,
                through the center), 12 mm wide, cut 1 mm deep into the
                bottom face.
      * When fill_one_side = true (single solar panel on one side):
                the whole side of the washer outboard of the strip (+Y)
                is filled solid from the bottom face up to the top of
                the strip, and the channel is only cut on the open side.

    The washer is symmetric, so only one fill side is modeled — flip the
    printed part 180 degrees for the opposite orientation.

    All dimensions are parameters — adjust at the top. Set $fn/$fa/$fs
    via quality parameters or command-line overrides.

    Example overrides:
        openscad -D id=6 -D od=32 -o out.stl model.scad
*/

// ============================================================
// Parameters
// ============================================================

// --- Washer body ---
id              = 5;    // inner (hole) diameter       [mm]
od              = 25;   // outer diameter              [mm]
thickness       = 2;    // washer body thickness       [mm]

// --- Top strip (same direction as channel, along X) ---
strip_width     = 10;   // strip width (Y)             [mm]
strip_height    = 3;    // strip height above top face [mm]
strip_length    = od;   // strip span (X) — default: full OD

// --- Bottom channel (along X) ---
channel_width   = 13.2; // channel width (Y)           [mm]
channel_depth   = 1;    // channel depth from bottom   [mm]
channel_length  = od;   // channel span (X) — default: full OD

// --- Single-panel option ---
fill_one_side   = false; // true: everything on the +Y side of the strip
                        //       (outboard of strip_width/2, up to the
                        //       OD curve) is solid up to the top of the
                        //       strip; channel cut only on -Y side.
                        // false: channel open on both sides of strip

// --- Modeling / quality ---
$fa             = 2;    // fragment angle  [deg]
$fs             = 0.2;  // fragment size   [mm]


// ============================================================
// Sanity checks (fail fast on impossible geometry)
// ============================================================

assert(id > 0,                 "id must be positive");
assert(od > id,                "od must be greater than id");
assert(thickness > 0,          "thickness must be positive");
assert(channel_depth < thickness,
                               "channel would cut through the top face");
assert(strip_width <= od,      "strip_width cannot exceed od");
assert(channel_width <= od,    "channel_width cannot exceed od");
assert(!fill_one_side || channel_width > strip_width,
                               "fill_one_side requires channel_width > strip_width");

// ============================================================
// Top level
// ============================================================

module separator_washer() {
    difference() {
        union() {
            washer_body();
            top_strip();
            channel_fill();
        }
        center_hole();
        bottom_channel();
    }
}

// ============================================================
// Modules
// ============================================================

// Annular body: cylinder from z = 0 to z = thickness
module washer_body() {
    cylinder(h = thickness, d = od, center = false);
}

// Central through-hole (cut last so it stays open everywhere)
module center_hole() {
    eps = 0.01;
    translate([0, 0, -eps])
        cylinder(h = thickness + strip_height + channel_depth + 2*eps,
                 d = id, center = false);
}

// Strip on top face, spanning the full diameter along X; protrudes
// strip_height above the top face. Ends are trimmed to the washer's
// circular footprint, so they follow the OD curve.
module top_strip() {
    translate([0, 0, thickness])
        intersection() {
            cylinder(h = strip_height, d = od, center = false);
            translate([-strip_length/2, -strip_width/2, 0])
                cube([strip_length, strip_width, strip_height]);
        }
}

// Channel cut into the bottom face along X (same direction as strip).
// When one side is filled, the cut is limited to the open (-Y) side.
module bottom_channel() {
    eps = 0.01;
    y1 = fill_one_side ? strip_width/2 : channel_width/2;
    translate([-channel_length/2, -channel_width/2, -eps])
        cube([channel_length, channel_width/2 + y1, channel_depth + eps]);
}

// Solid fill of the +Y side outboard of the strip, from the bottom face
// up to the top of the strip. Outer end follows the OD curve.
module channel_fill() {
    if (fill_one_side) {
        intersection() {
            cylinder(h = thickness + strip_height, d = od, center = false);
            translate([-channel_length/2, strip_width/2, 0])
                cube([channel_length, od, thickness + strip_height]);
        }
    }
}

// ============================================================
// Render
// ============================================================

// Bottom face of the washer sits at z = 0 (channel is cut *into* it),
// so the model is already print-ready on the build plate.
separator_washer();
