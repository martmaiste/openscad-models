// Version: 0.16
// 0.16: the inner cavity now follows the side taper with the same slope as
// the outer wall, so the (angled) side walls keep a constant thickness over
// the full height instead of thickening towards the top; cross dividers flare
// along the whole height to stay embedded in the tapered side walls.
// Parametric Cutlery Organizer Bin, modularly split into:
//   - bin_shell(): outer box with chamfered top collar, tapered side walls,
//     full-height vertical corner-edge chamfers, bottom edge chamfers and a
//     single full inner cavity (no divider is subtracted from the bin anymore)
//   - divider(): a single removable-style divider slab with a chamfered top
//   - dividers(): places N dividers evenly across the bin (in relation to the
//     bottom footprint) in either orientation (lengthwise or crosswise)
//   - cutlery_organizer(): convenience module combining bin + dividers

/* [Dimensions] */
bottom_width = 155;
length = 200;
height = 50;
wall_thickness = 3.0;
bottom_thickness = 3.0;
chamfer_size = 0.5;

// Side Tapers (Extra width added at the top)
right_extra_top = 20;
left_extra_top = 0;

/* [Dividers] */
// Number of separators (0 = none)
num_dividers = 2;
// "lengthwise" = run along the length and split the width (original behavior)
// "crosswise"  = run along the width and split the length
divider_orientation = "lengthwise"; // [lengthwise, crosswise]
divider_thickness = 3.0;

/* [Hidden] */
// Derived taper geometry (shared by bin and dividers)
z_trans = height - chamfer_size;
r_mid = right_extra_top * (z_trans / height);
l_mid = left_extra_top * (z_trans / height);

// Outer polygon of the shell at a given height (accounts for side taper).
// The outer wall tapers linearly over the full height (slope extra_top/h),
// so the row exactly at z_trans already carries the taper offset.
function outer_poly(w, l, z) =
    z < z_trans
        ? [[0, 0], [w, 0], [w, l], [0, l]]
        : [[-l_mid, 0], [w + r_mid, 0], [w + r_mid, l], [-l_mid, l]];

// Outer polygon on the top face (with the chamfer collar inset)
function top_poly(w, l, chamfer) = [
    [-left_extra_top + chamfer, chamfer],
    [w + right_extra_top - chamfer, chamfer],
    [w + right_extra_top - chamfer, l - chamfer],
    [-left_extra_top + chamfer, l - chamfer]
];

// Inner cavity polygon at a given height. It follows the side taper with the
// same slope as the outer wall, so the wall thickness stays constant over the
// full height (a vertical cavity would let the tapered wall thicken towards
// the top).
function cavity_poly(w, l, wall, z, h, r_extra = 0, l_extra = 0) = [
    [wall - l_extra * (z / h), wall],
    [w + r_extra * (z / h) - wall, wall],
    [w + r_extra * (z / h) - wall, l - wall],
    [wall - l_extra * (z / h), l - wall]
];

// A chamfer wedge is the convex hull of its flat-triangle cross-section rows.
// With more than two rows the wedge can bend at a kink (where the side taper
// meets the top collar), so no external library (e.g. chamfer.scad) is needed.
module flat_triangle(p) {
    polyhedron(points = [p[0], p[1], p[2]], faces = [[0, 1, 2], [2, 1, 0]]);
}

module chamfer_wedge(rows) {
    hull() {
        for (row = rows)
            flat_triangle(row);
    }
}

/* [Bin] */
// The bin alone: outer shell with a single full inner cavity.
module bin_shell(
    b_width,
    len,
    h,
    wall,
    b_thick,
    chamfer,
    r_extra = 20,
    l_extra = 0
) {
    z_tr = h - chamfer;
    r_m = r_extra * (z_tr / h);
    l_m = l_extra * (z_tr / h);

    // Taper slopes (dx/dz) of the outer left/right walls below the top collar
    slope_r = r_m / z_tr;
    slope_l = l_m / z_tr;
    len_r = sqrt(1 + slope_r * slope_r);
    len_l = sqrt(1 + slope_l * slope_l);

    // Projected corner-chamfer offsets for the (possibly tapered) corner cuts
    cnr  = chamfer / len_r;
    cnrz = chamfer * slope_r / len_r;
    cnl  = chamfer / len_l;
    cnlz = chamfer * slope_l / len_l;

    difference() {
        // 1. Outer Box Shape with Top Chamfer Collar
        hull() {
            translate([0, 0, 0])
            linear_extrude(height = 0.01)
            polygon(outer_poly(b_width, len, 0));

            translate([0, 0, z_tr])
            linear_extrude(height = 0.01)
            polygon(outer_poly(b_width, len, z_tr));

            translate([0, 0, h])
            linear_extrude(height = 0.01)
            polygon(top_poly(b_width, len, chamfer));
        }

        // 2. Inner Cavity (full interior; dividers are separate modules).
        // The cavity follows the side taper so the wall keeps a constant
        // thickness from the bottom up through the collar.
        hull() {
            translate([0, 0, b_thick])
            linear_extrude(height = 0.01)
            polygon(cavity_poly(b_width, len, wall, b_thick, h, r_extra, l_extra));

            translate([0, 0, z_tr])
            linear_extrude(height = 0.01)
            polygon(cavity_poly(b_width, len, wall, z_tr, h, r_extra, l_extra));

            translate([0, 0, h + 0.1])
            linear_extrude(height = 0.01)
            polygon(cavity_poly(b_width, len, wall, h, h, r_extra, l_extra));
        }

        // 3. Vertical corner wall-edge chamfers (4 corners), full height: each
        // wedge is the hull of three cross-section rows - at the bottom, at the
        // taper/collar kink, and on the top face - so the bevel runs continuously
        // from the bottom all the way through the collar to the top face.
        // The left corners follow the (possibly tapered) left wall, the right
        // corners follow the tapered right wall, so their offset points use the
        // computed taper offsets.
        chamfer_wedge( // front-left
            [
                [[0, 0, 0], [cnl, 0, cnlz], [0, chamfer, 0]],
                [[-l_m, 0, z_tr], [-l_m + cnl, 0, z_tr + cnlz], [-l_m, chamfer, z_tr]],
                [[-l_extra + chamfer, chamfer, h], [-l_extra + 2*chamfer, chamfer, h], [-l_extra + chamfer, 2*chamfer, h]]
            ]
        );
        chamfer_wedge( // back-left
            [
                [[0, len, 0], [cnl, len, cnlz], [0, len - chamfer, 0]],
                [[-l_m, len, z_tr], [-l_m + cnl, len, z_tr + cnlz], [-l_m, len - chamfer, z_tr]],
                [[-l_extra + chamfer, len - chamfer, h], [-l_extra + 2*chamfer, len - chamfer, h], [-l_extra + chamfer, len - 2*chamfer, h]]
            ]
        );
        chamfer_wedge( // front-right
            [
                [[b_width, 0, 0], [b_width - cnr, 0, cnrz], [b_width, chamfer, 0]],
                [[b_width + r_m, 0, z_tr], [b_width + r_m - cnr, 0, z_tr + cnrz], [b_width + r_m, chamfer, z_tr]],
                [[b_width + r_extra - chamfer, chamfer, h], [b_width + r_extra - 2*chamfer, chamfer, h], [b_width + r_extra - chamfer, 2*chamfer, h]]
            ]
        );
        chamfer_wedge( // back-right
            [
                [[b_width, len, 0], [b_width - cnr, len, cnrz], [b_width, len - chamfer, 0]],
                [[b_width + r_m, len, z_tr], [b_width + r_m - cnr, len, z_tr + cnrz], [b_width + r_m, len - chamfer, z_tr]],
                [[b_width + r_extra - chamfer, len - chamfer, h], [b_width + r_extra - 2*chamfer, len - chamfer, h], [b_width + r_extra - chamfer, len - 2*chamfer, h]]
            ]
        );

        // 4. Horizontal bottom edge chamfers (4 edges).
        chamfer_wedge( // front
            [
                [[0, 0, 0], [0, chamfer, 0], [0, 0, chamfer]],
                [[b_width, 0, 0], [b_width, chamfer, 0], [b_width, 0, chamfer]]
            ]
        );
        chamfer_wedge( // back
            [
                [[0, len, 0], [0, len - chamfer, 0], [0, len, chamfer]],
                [[b_width, len, 0], [b_width, len - chamfer, 0], [b_width, len, chamfer]]
            ]
        );
        chamfer_wedge( // left
            [
                [[0, 0, 0], [chamfer, 0, 0], [0, 0, chamfer]],
                [[0, len, 0], [chamfer, len, 0], [0, len, chamfer]]
            ]
        );
        chamfer_wedge( // right
            [
                [[b_width, 0, 0], [b_width - chamfer, 0, 0], [b_width, 0, chamfer]],
                [[b_width, len, 0], [b_width - chamfer, len, 0], [b_width, len, chamfer]]
            ]
        );
    }
}

/* [Dividers] */
// Small overlap used to bury the divider's ends/floor into the bin walls so
// the union stays manifold (no coplanar face contacts).
eps = 0.01;

// One divider slab. Its top is chamfered along the edges exposed to the
// compartments; the ends that merge into the bin walls are not chamfered.
// `pos` is the divider center measured along the axis it
// divides (x for lengthwise, y for crosswise), in relation to the bottom
// footprint. Crosswise dividers flare outward in the collar region to follow
// the side-wall taper; lengthwise dividers end in the (untapered) front/back
// walls.
module divider(
    orientation,
    pos,
    b_width,
    len,
    h,
    wall,
    b_thick,
    chamfer,
    t,
    r_extra = 20,
    l_extra = 0
) {
    z_tr = h - chamfer;
    zb = b_thick - eps;

    lengthwise = orientation == "lengthwise";

    // Taper offsets of the (tapered) side walls at a given height
    function r0(z) = l_extra * (z / h);
    function r1(z) = r_extra * (z / h);

    // Cross-section rectangles [a0, a1] along the divided axis and
    // [b0, b1] along the divider length, at the bottom/kink and top rows.
    // Along the divided axis: constant for lengthwise dividers (their sides
    // are exposed to the compartments); crosswise dividers follow the
    // side-wall taper at every height so their ends stay embedded in the
    // (now also tapered) side walls.
    a0b = lengthwise ? pos - t/2 : wall - eps - r0(zb);
    a1b = lengthwise ? pos + t/2 : b_width - wall + eps + r1(zb);
    a0m = lengthwise ? pos - t/2 : wall - eps - r0(z_tr);
    a1m = lengthwise ? pos + t/2 : b_width - wall + eps + r1(z_tr);
    a0t = lengthwise ? pos - t/2 : wall - eps - r0(h);
    a1t = lengthwise ? pos + t/2 : b_width - wall + eps + r1(h);

    // Along the divider length: the ends are buried eps into the front/back
    // (or left/right) walls at every height.
    b0 = lengthwise ? wall - eps : pos - t/2;
    b1 = lengthwise ? len - wall + eps : pos + t/2;

    // Bottom row is a thin slab biting into the floor
    hull() {
        translate([0, 0, zb])
        linear_extrude(height = 0.02)
        polygon([[a0b, b0], [a1b, b0], [a1b, b1], [a0b, b1]]);

        // Mid row (at the taper/collar kink)
        translate([0, 0, z_tr])
        linear_extrude(height = 0.01)
        polygon([[a0m, b0], [a1m, b0], [a1m, b1], [a0m, b1]]);
    }

    // Top section with chamfered edges, hung from the mid row
    hull() {
        translate([0, 0, z_tr])
        linear_extrude(height = 0.01)
        polygon([[a0m, b0], [a1m, b0], [a1m, b1], [a0m, b1]]);

        // Ends at h + 0.01 to sit exactly flush with the rim top face (the
        // shell hull's top slab likewise extrudes 0.01 above h). Only the
        // edges exposed to the compartments are chamfered; the ends that join
        // the bin walls run full-width into them (no chamfer notch there).
        translate([0, 0, h])
        linear_extrude(height = 0.01)
        polygon([
            [lengthwise ? a0t + chamfer : a0t, lengthwise ? b0 : b0 + chamfer],
            [lengthwise ? a1t - chamfer : a1t, lengthwise ? b0 : b0 + chamfer],
            [lengthwise ? a1t - chamfer : a1t, lengthwise ? b1 : b1 - chamfer],
            [lengthwise ? a0t + chamfer : a0t, lengthwise ? b1 : b1 - chamfer]
        ]);
    }
}

// Places `count` dividers so the compartments are evenly spaced in relation to
// the bottom footprint: the inner bottom span is divided into count + 1 equal
// sections and each divider is centered on a section boundary.
module dividers(
    count,
    orientation,
    b_width,
    len,
    h,
    wall,
    b_thick,
    chamfer,
    t,
    r_extra = 20,
    l_extra = 0
) {
    if (count > 0) {
        lengthwise = orientation == "lengthwise";
        span = (lengthwise ? b_width : len) - 2 * wall;
        section = span / (count + 1);

        if (section - t < 0)
            echo("WARNING: num_dividers too high for this bin - compartments are narrower than the divider thickness.");

        for (i = [1 : count])
            divider(
                orientation = orientation,
                pos = wall + section * i,
                b_width = b_width,
                len = len,
                h = h,
                wall = wall,
                b_thick = b_thick,
                chamfer = chamfer,
                t = t,
                r_extra = r_extra,
                l_extra = l_extra
            );
    }
}

/* [Assembly] */
// Convenience module: bin shell plus its dividers
module cutlery_organizer(
    b_width,
    len,
    h,
    wall,
    b_thick,
    chamfer,
    count = 1,
    orientation = "lengthwise",
    t = 2.0,
    r_extra = 20,
    l_extra = 0
) {
    bin_shell(b_width, len, h, wall, b_thick, chamfer, r_extra, l_extra);
    dividers(count, orientation, b_width, len, h, wall, b_thick, chamfer, t, r_extra, l_extra);
}

// Render the assembly (bin and dividers are unioned for printing as one part;
// call bin_shell() or dividers() directly to output them separately)
cutlery_organizer(
    b_width = bottom_width,
    len = length,
    h = height,
    wall = wall_thickness,
    b_thick = bottom_thickness,
    chamfer = chamfer_size,
    count = num_dividers,
    orientation = divider_orientation,
    t = divider_thickness,
    r_extra = right_extra_top,
    l_extra = left_extra_top
);
