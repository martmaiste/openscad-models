// Locker-Washer.scad
// Version: v0.01
// Description: Parametric locker washer for M3 bolts (tight fit)

/* [Washer Parameters] */
// Width across parallel flats (M3 standard is 5.5)
nut_flats = 5.5;
// Thickness of the washer (M3 standard is 2.4)
nut_thickness = 2.4;

/* [Thread Parameters] */
// Nominal bolt diameter (M3 = 3.0)
bolt_diameter = 3.0;
// Thread pitch (M3 standard = 0.5)
thread_pitch = 0.5;
// Clearance offset. Negative = tighter fit, Positive = looser fit.
// Default -0.1 creates a strong friction fit on most FDM printers.
thread_clearance = -0.1;

/* [Resolution] */
// Number of segments for the nut and threads
$fn = 60;

// Internal variables
epsilon = 0.05;

module locker_washer() {
    difference() {
        // Main hex nut body with chamfers
        nut_body(nut_flats, nut_thickness);

        // Subtract the threaded rod
        translate([0, 0, -epsilon])
            threaded_rod(
                diam = bolt_diameter + thread_clearance,
                pitch = thread_pitch,
                length = nut_thickness + 2*epsilon
            );
    }
}

module nut_body(flats, thickness) {
    r_in = flats / 2;
    r_out = flats / sqrt(3);
    chamfer_depth = (r_out - r_in) * tan(30);

    intersection() {
        // Hexagonal prism
        cylinder(r = r_out, h = thickness, $fn = 6);

        // Chamfered profile to trim the corners
        rotate_extrude($fn = $fn)
        polygon([
            [0, 0],
            [r_in, 0],
            [r_out, chamfer_depth],
            [r_out, thickness - chamfer_depth],
            [r_in, thickness],
            [0, thickness]
        ]);
    }
}

module threaded_rod(diam, pitch, length) {
    r_major = diam / 2;
    r_minor = r_major - pitch * 5 / 8;

    union() {
        // Central core hole
        cylinder(r = r_minor, h = length);

        // Thread spiral grooves
        thread_spiral(r_major, r_minor, pitch, length);
    }
}

module thread_spiral(r_major, r_minor, pitch, length) {
    facets = $fn > 0 ? $fn : 36;
    turns = length / pitch;
    steps = ceil(turns * facets);

    points = [
        for (i = [0 : steps])
            let (a = i * 360 / facets, z = i * pitch / facets)
            for (pt = [
                [r_minor * cos(a), r_minor * sin(a), z - pitch/2],
                [r_major * cos(a), r_major * sin(a), z - pitch/8],
                [r_major * cos(a), r_major * sin(a), z + pitch/8],
                [r_minor * cos(a), r_minor * sin(a), z + pitch/2]
            ]) pt
    ];

    faces_side = [
        for (i = [0 : steps-1])
            for (j = [0 : 3])
                for (t = [0 : 1])
                    let (
                        p1 = 4*i + j,
                        p2 = 4*i + (j+1)%4,
                        p3 = 4*(i+1) + (j+1)%4,
                        p4 = 4*(i+1) + j
                    )
                    t == 0 ? [p1, p2, p3] : [p1, p3, p4]
    ];

    N = 4 * steps;
    faces_caps = [
        [0, 3, 2], [0, 2, 1], // Bottom cap
        [N, N+1, N+2], [N, N+2, N+3] // Top cap
    ];

    polyhedron(points=points, faces=concat(faces_side, faces_caps), convexity=10);
}

// Generate the washer
locker_washer();
