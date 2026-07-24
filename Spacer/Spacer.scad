// Spacer.scad
// Version: v0.03
// Description: Parametric cylindrical spacer

/* [Dimensions] */
// Inner diameter (mm, ignored if bolt_size is not None)
id = 5.0;

/* [Bolt Settings] */
// Select bolt size to automatically set inner diameter
bolt_size = "None"; // ["None", "M2", "M2.5", "M3", "M4", "M5", "M6", "M8", "M10"]

// Fit type for the bolt (Clearance = loose, Tap = tight for self-tapping, Threaded = 3D printed threads)
bolt_fit = "Clearance"; // ["Clearance", "Tap", "Threaded"]

// Tolerance for 3D printed threads (mm, increases hole size for easier fit)
thread_tolerance = 0.2;

// Outer diameter (mm)
od = 20.0;

// Length/Height (mm)
length = 10.0;

/* [Features] */
// Outer edge chamfer (mm, 0 for no chamfer)
outer_chamfer = 1.0;

// Inner edge chamfer (mm, 0 for no chamfer)
inner_chamfer = 0.5;

/* [Settings] */
// Resolution (higher value for smoother curves)
$fn = 100;

module spacer(inner_d, outer_d, h, out_chamfer, in_chamfer) {
    r_in = inner_d / 2;
    // Ensure outer radius is strictly larger than inner radius to avoid invalid geometry
    r_out = max(outer_d / 2, r_in + 0.01);

    // Prevent chamfers from overlapping or exceeding dimensions
    oc = max(0, min(out_chamfer, h / 2, (r_out - r_in) / 2));
    ic = max(0, min(in_chamfer, h / 2, (r_out - r_in) / 2));

    rotate_extrude() {
        polygon([
            [r_in + ic, 0],
            [r_out - oc, 0],
            [r_out, oc],
            [r_out, h - oc],
            [r_out - oc, h],
            [r_in + ic, h],
            [r_in, h - ic],
            [r_in, ic]
        ]);
    }
}

function get_bolt_pitch(size) =
    size == "M2"   ? 0.4 :
    size == "M2.5" ? 0.45 :
    size == "M3"   ? 0.5 :
    size == "M4"   ? 0.7 :
    size == "M5"   ? 0.8 :
    size == "M6"   ? 1.0 :
    size == "M8"   ? 1.25 :
    size == "M10"  ? 1.5 : 0;

function get_bolt_nominal_dia(size) =
    size == "M2"   ? 2.0 :
    size == "M2.5" ? 2.5 :
    size == "M3"   ? 3.0 :
    size == "M4"   ? 4.0 :
    size == "M5"   ? 5.0 :
    size == "M6"   ? 6.0 :
    size == "M8"   ? 8.0 :
    size == "M10"  ? 10.0 : 0;

// Calculate actual inner diameter based on bolt size and fit
function get_bolt_dia(size, fit) =
    let (
        nom = get_bolt_nominal_dia(size),
        pitch = get_bolt_pitch(size)
    )
    fit == "Clearance" ? (
        size == "M2"   ? 2.2 :
        size == "M2.5" ? 2.7 :
        size == "M3"   ? 3.2 :
        size == "M4"   ? 4.2 :
        size == "M5"   ? 5.2 :
        size == "M6"   ? 6.2 :
        size == "M8"   ? 8.4 :
        size == "M10"  ? 10.5 : id
    ) :
    fit == "Tap" ? (
        size == "M2"   ? 1.6 :
        size == "M2.5" ? 2.05 :
        size == "M3"   ? 2.5 :
        size == "M4"   ? 3.3 :
        size == "M5"   ? 4.2 :
        size == "M6"   ? 5.0 :
        size == "M8"   ? 6.8 :
        size == "M10"  ? 8.5 : id
    ) :
    fit == "Threaded" ? (
        // For threaded, the basic hole is the minor diameter of the thread including tolerance
        nom > 0 ? (nom + thread_tolerance) - 1.082532 * pitch : id
    ) : id;

actual_id = bolt_size == "None" ? id : get_bolt_dia(bolt_size, bolt_fit);

module thread_cutter(d, pitch, length, tol) {
    r_maj = (d + tol) / 2;
    r_min = r_maj - 0.54127 * pitch;
    segments = $fn > 0 ? max($fn, 12) : 36;

    z_start = -0.1;
    z_end = length + 0.1;
    cut_length = z_end - z_start;

    turns = cut_length / pitch;
    steps = ceil(turns * segments);
    dz = cut_length / steps;
    da = 360 / segments;

    function r_at(phase) =
        let(p = phase < 0 ? phase - floor(phase) : phase - floor(phase))
        p < 0.5 ? r_min + (r_maj - r_min) * (p * 2)
                : r_maj - (r_maj - r_min) * ((p - 0.5) * 2);

    function pt(j, i) = j*segments + i;

    bot_center = (steps + 1) * segments;
    top_center = bot_center + 1;

    vertices = [
        for (j=[0:steps])
            for (i=[0:segments-1])
                let(
                    z = z_start + j * dz,
                    theta = i * da,
                    phase = z / pitch - theta / 360,
                    r = r_at(phase)
                )
                [r * cos(theta), r * sin(theta), z],
        [0, 0, z_start],
        [0, 0, z_end]
    ];

    faces_side = [
        for (j=[0:steps-1])
            for (i=[0:segments-1])
                let(n = (i+1)%segments)
                each [
                    [pt(j, i), pt(j+1, n), pt(j, n)],
                    [pt(j+1, i), pt(j+1, n), pt(j, i)]
                ]
    ];

    faces_bottom = [
        for (i=[0:segments-1])
            let(n = (i+1)%segments)
            [bot_center, pt(0, i), pt(0, n)]
    ];

    faces_top = [
        for (i=[0:segments-1])
            let(n = (i+1)%segments)
            [top_center, pt(steps, n), pt(steps, i)]
    ];

    polyhedron(points=vertices, faces=concat(faces_side, faces_bottom, faces_top), convexity=10);
}

// Generate the spacer
if (bolt_size != "None" && bolt_fit == "Threaded") {
    difference() {
        spacer(inner_d=actual_id, outer_d=od, h=length, out_chamfer=outer_chamfer, in_chamfer=inner_chamfer);
        thread_cutter(d=get_bolt_nominal_dia(bolt_size), pitch=get_bolt_pitch(bolt_size), length=length, tol=thread_tolerance);
    }
} else {
    spacer(inner_d=actual_id, outer_d=od, h=length, out_chamfer=outer_chamfer, in_chamfer=inner_chamfer);
}
