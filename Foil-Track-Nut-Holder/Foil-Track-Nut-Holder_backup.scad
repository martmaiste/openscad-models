// Wing-Foil Mast Nut Spacer/Holder
// Version: 0.13

/* [General Settings] */
// Distance between bolt centers
nut_spacing = 165.0;

/* [Track & Nut Dimensions] */
shaft_width = 9.0;
nut_length = 28.5;
nut_thickness = 5.5;
bolt_hole_dia = 8.0;

/* [Holder Design Features] */
base_thickness = 3.0;
bridge_thickness = 4.0;
spring_bow = 7.0;
guide_height = 9.0;
stop_length = 8.0;

// The diameter of the cylinder used for the bottom bump
bottom_bump_dia = 18.0;
// Percent of the cylinder radius to protrude (0.3 = 30%)
bump_profile_percent = 0.3;
// Whether to include the bump
bump = true;

/* [Hidden] */
$fn = 60;
lip_thickness = base_thickness + nut_thickness * 0.3;

module extruded_bridge(w, span, t, bow, overlap=0.4) {
    R = (span*span)/(8*bow) + bow/2;
    rotate([90, 0, 90])
    linear_extrude(w, center=true)
    intersection() {
        translate([0, -bow])
            square([span + overlap, 2*R], center=true);
        translate([0, R - bow])
            difference() {
                // By translating the same circle vertically, we ensure the ends are flat
                // instead of being perpendicular to the curve.
                circle(r=R, $fn=420);
                translate([0, t]) circle(r=R, $fn=420);
            }
    }
}

module complete_spacer() {
    difference() {
        union() {
            for (dir = [1, -1]) {
                nut_y = dir * nut_spacing/2;

                // 1. Base platform (wider with circular cutout)
                platform_width = 15.0; // Width at center of the platform
                platform_depth = nut_length;
                platform_height = base_thickness;

                // Create a wider base with circular cutout at center
                translate([0, nut_y, platform_height/2])
                    difference() {
                        cube([platform_width, platform_depth, platform_height], center=true);
                        // Circular cutout at center
                        translate([0, 0, platform_height/2])
                            #cylinder(h=platform_height + 1, d=shaft_width, center=true);
                    }

                // 2. Outer Vertical Guide Wall (Centering)
                outer_pos = nut_y + dir * (nut_length/2 + stop_length/2);
                translate([0, outer_pos, guide_height/2])
                    cube([shaft_width, stop_length, guide_height], center=true);

                // Rounded tip
                extreme_end = nut_y + dir * (nut_length/2 + stop_length);
                translate([0, extreme_end, guide_height/2])
                    scale([1, 0.5, 1]) cylinder(h=guide_height, d=shaft_width, center=true);

                // 3. Inner Transition (Vertical wall + Slope)
                inner_start = nut_y - dir * nut_length/2;
                inner_end = inner_start - dir * stop_length;

                hull() {
                    translate([0, inner_start - dir*0.1, lip_thickness/2])
                        cube([shaft_width, 0.2, lip_thickness], center=true);
                    translate([0, inner_end, bridge_thickness/2])
                        cube([shaft_width, 0.2, bridge_thickness], center=true);
                }
            }

            // 4. Continuous Spring Bridge
            bridge_span = nut_spacing - nut_length - (stop_length * 2);
            extruded_bridge(w=shaft_width, span=bridge_span, t=bridge_thickness, bow=spring_bow, overlap=0.2);

            // 5. Recessed 30% Bump
            // Positioned so it is cut inside the body and only protrudes from the bottom
            if (bump) {
                bump_radius = bottom_bump_dia / 2;
                protrusion_height = bump_radius * bump_profile_percent;

                translate([0, 0, -spring_bow + bridge_thickness/2])
                intersection() {
                    // The Cylinder
                    translate([0, 0, bump_radius - protrusion_height])
                        rotate([0, 90, 0])
                        cylinder(h=shaft_width, d=bottom_bump_dia, center=true);

                    // The Shaving Cube: Limits the bump to the bridge's vertical volume
                    // This ensures the bump never pokes out the top of the bridge
                    translate([0, 0, -protrusion_height])
                        cube([shaft_width + 1, bottom_bump_dia, bridge_thickness + protrusion_height * 2], center=true);
                }
            }
        }

        // Bolt holes
        for (dir = [1, -1]) {
            nut_y = dir * nut_spacing/2;
            translate([0, nut_y, -1])
                cylinder(h=guide_height + 20, d=bolt_hole_dia);
        }
    }
}

// Final assembly positioning
translate([0, 0, spring_bow])
    complete_spacer();
