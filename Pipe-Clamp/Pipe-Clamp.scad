// Parametric Modular Wall Mount Plate & Clamp for Angled Pipe
// Version: 0.09

/* [Pipe Parameters] */
pipe_diameter = 18.0;      // Outer diameter of the pipe in mm
pipe_angle = 5.0;          // Downward pipe angle in degrees (5 - 10)
wall_clearance = 0.4;      // Tolerance for printing fits

/* [Hole & Flange Parameters] */
wall_hole_w = 20.0;        // Width of the wall hole in mm
wall_hole_h = 40.0;        // Height of the wall hole in mm
sleeve_extra_w = 2.0;      // Extra width added to sleeve (makes sleeve wider)
sleeve_depth = 0.0;        // Depth of the inner boss extending into the wall
flange_thickness = 15.0;   // Thickness of the main plate against the wall
flange_margin = 15.0;      // Margin around the hole for wall coverage
corner_radius = 5.0;       // Outer corner rounding radius
edge_chamfer = 1.0;        // Front chamfer for smooth top edges

/* [Mounting Screws & Counterbores] */
screw_hole_dia = 4.5;      // Diameter for wall mounting screw shank
screw_head_dia = 10.0;     // Outer diameter of the counterbore pocket (fits screw head + driver)
counterbore_depth = 7.0;  // How deep the screw pocket goes into the block (leaves remaining wall thickness)
countersink_dia = 8.5;     // Diameter for screw head countersink at the bottom of the bore

$fn = 64;

// Calculated Dimensions
sleeve_width = wall_hole_w + sleeve_extra_w;
flange_width = wall_hole_w + (flange_margin * 2);
flange_height = wall_hole_h + (flange_margin * 2);

// Equalized edge distance for screws
screw_margin = flange_margin / 2;

module rounded_plate(w, h, t, r) {
    hull() {
        translate([r, r, 0]) cylinder(r = r, h = t);
        translate([w - r, r, 0]) cylinder(r = r, h = t);
        translate([w - r, h - r, 0]) cylinder(r = r, h = t);
        translate([r, h - r, 0]) cylinder(r = r, h = t);
    }
}

module pipe_cutout() {
    translate([flange_width / 2, flange_height / 2, 0])
        rotate([pipe_angle, 0, 0])
            cylinder(r = (pipe_diameter + wall_clearance) / 2, h = (sleeve_depth + flange_thickness) * 4, center = true);
}

module counterbored_screw_hole() {
    union() {
        // Full clearance hole through the entire block
        cylinder(r = screw_hole_dia / 2, h = flange_thickness * 3, center = true);
        
        // Counterbore pocket recessed from the top face
        translate([0, 0, flange_thickness - counterbore_depth]) {
            // Main wide cylinder pocket
            cylinder(r = screw_head_dia / 2, h = counterbore_depth + 1);
            
            // Countersink transition at bottom of pocket
            translate([0, 0, -1.5])
                cylinder(r1 = screw_hole_dia / 2, r2 = countersink_dia / 2, h = 1.6);
        }
    }
}

module full_mount_raw() {
    union() {
        // Main Flange Plate
        rounded_plate(flange_width, flange_height, flange_thickness, corner_radius);
        
        // Inner Wall Sleeve Boss
        if (sleeve_depth > 0) {
            translate([(flange_width - sleeve_width) / 2, (flange_height - wall_hole_h) / 2, flange_thickness])
                rounded_plate(sleeve_width, wall_hole_h, sleeve_depth, 2.0);
        }
    }
}

module full_mount() {
    difference() {
        full_mount_raw();
        
        // Front top edge chamfer/bevel
        translate([0, 0, flange_thickness]) {
            difference() {
                translate([-1, -1, -edge_chamfer])
                    cube([flange_width + 2, flange_height + 2, edge_chamfer * 2]);
                
                translate([0, 0, -edge_chamfer])
                    rounded_plate(flange_width, flange_height, edge_chamfer * 2, corner_radius);
            }
        }

        // Angled Pipe Cutout
        pipe_cutout();
            
        // Left Screw Mounting Holes
        translate([screw_margin, flange_height - screw_margin, 0])
            counterbored_screw_hole();
        translate([screw_margin, screw_margin, 0])
            counterbored_screw_hole();

        // Right Screw Mounting Holes
        translate([flange_width - screw_margin, flange_height - screw_margin, 0])
            counterbored_screw_hole();
        translate([flange_width - screw_margin, screw_margin, 0])
            counterbored_screw_hole();
    }
}

full_mount();