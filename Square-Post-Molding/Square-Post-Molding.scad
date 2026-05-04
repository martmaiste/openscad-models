// Version: 0.05
// Description: Parametric dovetail molding with fixed subtraction logic.
// Post: 100x100mm (R10), Height: 20mm, Taper: 20mm (bottom) to 15mm (top).
// Printer: Bambulab A1, Basic PLA, Profile: 0.2mm Strength @BBLA1

// --- Main Parameters ---
post_width = 100;
post_radius = 12;
mold_height = 20;
thick_bottom = 20;
thick_top = 15;
taper_start = 5;

// --- Parametric Dovetail Settings ---
dt_depth = 5;          
dt_neck_width = 7;     
dt_flare_width = 9;    
joint_tol = 0.35;       
tolerance = 1;       

// Centering the dovetail in the bottom thickness
dovetail_x_pos = (post_width + tolerance) / 2 + (thick_bottom / 2);

$fn = 64;

// --- Modules ---
module rounded_square(w, r) {
    hull() {
        translate([-w/2 + r, -w/2 + r]) circle(r);
        translate([ w/2 - r, -w/2 + r]) circle(r);
        translate([-w/2 + r,  w/2 - r]) circle(r);
        translate([ w/2 - r,  w/2 - r]) circle(r);
    }
}

module male_dovetail() {
    linear_extrude(height = mold_height)
        polygon([
            [-dt_neck_width/2, 0.01], 
            [dt_neck_width/2, 0.01], 
            [dt_flare_width/2, -dt_depth], 
            [-dt_flare_width/2, -dt_depth]
        ]);
}

module female_dovetail() {
    // We use joint_tol to make the hole slightly larger than the male part
    // The cut goes from Y=0 into the positive Y direction
    translate([0, 0, -1])
        linear_extrude(height = mold_height + 2)
            polygon([
                [-(dt_neck_width/2 + joint_tol), -0.01],
                [(dt_neck_width/2 + joint_tol), -0.01],
                [(dt_flare_width/2 + joint_tol), dt_depth + joint_tol],
                [-(dt_flare_width/2 + joint_tol), dt_depth + joint_tol]
            ]);
}

module half_molding() {
    union() {
        difference() {
            // 1. Outer Shell
            union() {
                linear_extrude(height = taper_start)
                    rounded_square(post_width + tolerance + 2*thick_bottom, post_radius + thick_bottom);
                
                translate([0, 0, taper_start])
                    hull() {
                        linear_extrude(height = 0.01)
                            rounded_square(post_width + tolerance + 2*thick_bottom, post_radius + thick_bottom);
                        translate([0, 0, mold_height - taper_start - 0.01])
                            linear_extrude(height = 0.01)
                                rounded_square(post_width + tolerance + 2*thick_top, post_radius + thick_top);
                    }
            }
            
            // 2. Inner Post Void
            translate([0, 0, -1])
                linear_extrude(height = mold_height + 2)
                    rounded_square(post_width + tolerance, post_radius);
            
            // 3. Cut the whole thing in half along the X axis at Y=0
            translate([-500, -1000, -10]) 
                cube([1000, 1000, mold_height + 20]);
                
            // 4. Female Dovetail Cut (Right side)
            // Positioned at dovetail_x_pos, cutting "up" into the material (Positive Y)
            translate([dovetail_x_pos, 0, 0])
                female_dovetail();
        }
        
        // 5. Add Male Dovetail (Left side)
        // Positioned at -dovetail_x_pos, protruding "down" (Negative Y)
        translate([-dovetail_x_pos, 0, 0])
            male_dovetail();
    }
}

half_molding();
