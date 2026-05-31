/*
 * Parametric RayFoil E-Foil Mast Support Stand
 * Version: v0.15
 *
 * This design creates a stand that allows the e-foil mast to rest
 * horizontally on the ground with its leading edge facing downwards.
 * It provides a wide base to prevent the mast from tipping over.
 */

// --- Parameters ---

/* [Render Options] */
// What part to generate?
part_to_render = "stand"; // [stand: 3D Support Stand, profile: 2D Mast Profile]

/* [Mast Dimensions] */
// Maximum width/thickness of the mast profile (mm)
mast_thickness = 35;
// Estimated total chord length of the mast cross-section (mm)
mast_chord = 140;

/* [Mast Calibration Profile] */
// How far from the front the mast reaches its max thickness (mm)
// (Looking at the photo, max thickness happens in the middle of the recessed slot)
max_t_pos = 65;
// Distance from leading edge where you took a measurement (mm)
measured_dist = 40;
// The measured thickness at that distance (mm)
measured_thickness = 29.5;
// Adjusts the bluntness of the very front tip while still passing exactly through your measurements! (1.0 = Sharper/Wedge, 2.0 = Elliptical/Round, 3.0 = Blunt/Square)
nose_roundness = 1.8;
// Thickness at the very trailing edge (mm)
tail_thickness = 3.0;

/* [Mounting Holes] */
// Add optional holes to mount the stand to a board or plate?
add_mounting_holes = true;
// Hole diameter for M6 bolts (6.5mm provides good clearance)
hole_diameter = 6.5;
// Distance between the centers of the two holes (mm)
hole_spacing = 60;
// Distance from the flat back wall to the holes (mm)
hole_offset_from_back = 25;
// Diameter of the counterbore recess (12mm for M6 socket head)
head_diameter = 12;
// Depth of the counterbore recess (mm)
head_depth = 30;

/* [End Cutouts] */
// Add circular cradles on the top and bottom faces (for motor & propeller clearance)?
add_side_cutouts = true;
// Radius of the top cutout (e.g. propeller guard clearance) (mm)
top_cyl_radius = 250.0;
// Radius of the bottom cutout (e.g. motor casing rest) (mm)
bottom_cyl_radius = 32.75;
// Depth of both side cutouts (mm)
side_cutout_depth = 5.0;

/* [Stand Dimensions] */
// Total width of the stand, transverse to the mast (mm)
stand_width = 118;
// Total length/depth of the stand, along the mast's chord direction (mm)
stand_length = 50;
// How deep the mast's leading edge goes into the stand (mm)
cut_depth = 40;
// Extrusion height of the stand, along the mast's span direction (mm)
stand_height = 50;

/* [Tolerances] */
// Gap to ensure the mast fits easily without being too tight (mm)
tolerance = 0.1;

// --- Computed Variables ---
wall_thickness = stand_length - cut_depth;

// --- Modules ---

// Custom hydrodynamic strut profile generator (symmetric)
// Uses an analytical power-curve approach to guarantee a perfect, zero-tangent
// smooth transition at max width while perfectly hitting your calibration points.
module mast_profile_2d(chord, thickness, resolution=400) {
    t_max = thickness / 2;
    tail_w = tail_thickness / 2;
    target_y = measured_thickness / 2;

    // --- Front Section Power Math ---
    // We analytically solve for the exponent needed to hit the user's measurement
    u_front = 1 - (measured_dist / max_t_pos);
    target_y_ratio = target_y / t_max;
    front_power = ln(1 - pow(target_y_ratio, nose_roundness)) / ln(u_front);

    // Generate points for the top half

    // 1. Front Section (Analytically scaled super-ellipse)
    points_front = [ for (i = [0 : resolution])
        let(
            x = max_t_pos * i / resolution,
            y = t_max * pow(max(0, 1 - pow(1 - x/max_t_pos, front_power)), 1/nose_roundness)
        )
        [x, y]
    ];

    // 2. Rear Section (Smooth polynomial taper)
    points_rear = [ for (i = [1 : resolution])
        let(
            nx = i / resolution, // normalized from 0 to 1
            x = max_t_pos + nx * (chord - max_t_pos),
            // (1 - nx^1.5) guarantees a zero-slope start at max_t_pos for a seamless blend
            y = tail_w + (t_max - tail_w) * (1 - pow(nx, 1.5))
        )
        [x, y]
    ];

    points_top = concat(points_front, points_rear);

    // Generate points for the bottom half by mirroring Y
    points_bottom = [ for (i = [len(points_top)-2 : -1 : 1])
        let(pt = points_top[i])
        [pt[0], -pt[1]]
    ];

    polygon(concat(points_top, points_bottom));
}

// 2. 2D Profile of the stand block minus the mast
module stand_2d() {
    difference() {
        // Main block with slightly rounded corners for better feel
        offset(r = 2)
            offset(r = -2)
                translate([-wall_thickness, -stand_width/2])
                    square([stand_length, stand_width]);

        // Cutout for the mast with added tolerance for 3D printing
        // Offset expands the profile slightly outwards
        offset(r = tolerance)
            mast_profile_2d(chord = mast_chord, thickness = mast_thickness);
    }
}

// 3. 3D Extrusion and Orientation for 3D Printing
module stand_3d() {
    difference() {
        // Rotate [0, -90, 0] so the flat back of the stand is perfectly on the build plate (Z=0)
        // and the opening faces UP (+Z) for support-free printing.
        translate([0, 0, wall_thickness])
            rotate([0, -90, 0])
                linear_extrude(height = stand_height, center = true, convexity = 3)
                    stand_2d();

        // Subtract the vertical through-holes and counterbores
        if (add_mounting_holes) {
            for (y_pos = [hole_spacing/2, -hole_spacing/2]) {
                translate([0, y_pos, 0]) {
                    // Vertical M6 Through-Hole (Z=0 to top)
                    translate([0, 0, -1])
                        cylinder(h = stand_length + 2, d = hole_diameter, $fn=60);

                    // Counterbore for bolt head (top down)
                    translate([0, 0, stand_length - head_depth])
                        cylinder(h = head_depth + 1, d = head_diameter, $fn=60);
                }
            }
        }

        // Subtract the side cutouts on the left and right outer faces (oriented along the Z-axis, parallel to the mast)
        if (add_side_cutouts) {
            // Cutout 1 (on the left face, running vertically)
            // Center is calculated so the cylinder cuts exactly side_cutout_depth into the left face
            left_cyl_x = -stand_height/2 + side_cutout_depth - top_cyl_radius;

            translate([left_cyl_x, 0, -1])
                cylinder(h = stand_length + 2, r = top_cyl_radius, $fn = top_cyl_radius * 10);

            // Cutout 2 (on the right face, running vertically)
            // Center is calculated so the cylinder cuts exactly side_cutout_depth into the right face
            right_cyl_x = stand_height/2 - side_cutout_depth + bottom_cyl_radius;

            translate([right_cyl_x, 0, -1])
                cylinder(h = stand_length + 2, r = bottom_cyl_radius, $fn = bottom_cyl_radius * 10);
        }
    }
}

// Render the final part based on user selection
$fn = 300; // Ultra smooth curves

if (part_to_render == "stand") {
    stand_3d();
} else if (part_to_render == "profile") {
    // Show just the 2D mast profile, colored for visibility
    color("LightBlue")
        mast_profile_2d(chord = mast_chord, thickness = mast_thickness);
}
