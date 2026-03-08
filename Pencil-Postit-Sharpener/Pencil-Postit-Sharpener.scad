// --- DOKUMENTATSIOON ---
// Versioon: 1.2
// Kirjeldus: Siledate seintega hoidja kumeramate keskmise osa nurkadega.
// Muudatused:
// - Keskmise osa püstnurgad on kumerad (rounding = 4).
// - Esi- ja tagasein on joondatud ühtseks siledaks pinnaks.

// --- PARAMEETRID ---
$fn = 200; 

height = 150; // Pikk mõõde (X-telg)
wall = 2.5;   
rounding = 4;

post_it_w = 40; 
post_it_d = 12; 

z_high = 70; 
z_low = 30;  
sharpener_d = 42;
lipstick_d = 19; 
cream_d = 29;    

// --- JAOTUSE ARVUTUS ---
side_section_x = max(sharpener_d + wall * 2, post_it_w + wall * 2);
mid_x = height - (2 * side_section_x);
width = (3 * post_it_d) + (5 * wall) + cream_d;

// --- DISAIN ---

difference() {
    // 1. ÜHTNE SILE VÄLISKORPUS
    union() {
        // ALUMINE OSA (Terve pikkus 150mm)
        linear_extrude(height = z_low)
            hull() {
                translate([rounding, rounding]) circle(r=rounding);
                translate([height-rounding, rounding]) circle(r=rounding);
                translate([rounding, width-rounding]) circle(r=rounding);
                translate([height-rounding, width-rounding]) circle(r=rounding);
            }
        
        // KESKMINE OSA (Kumerad püstnurgad)
        // Hull operatsioon kahe nurgapostiga, et hoida esi- ja tagasein sirged
        translate([side_section_x, 0, 0])
        linear_extrude(height = z_high)
            hull() {
                // Eesmine serv (kumerad nurgad)
                translate([rounding, rounding]) circle(r=rounding);
                translate([mid_x - rounding, rounding]) circle(r=rounding);
                // Tagumine serv (kumerad nurgad)
                translate([rounding, width - rounding]) circle(r=rounding);
                translate([mid_x - rounding, width - rounding]) circle(r=rounding);
            }
    }

    // 2. PESADE VÄLJALÕIKAMINE
    
    // VASAK OSA
    translate([side_section_x / 2 - 11, wall + lipstick_d/2 + 2, wall])
        cylinder(d = lipstick_d, h = z_low);
    translate([side_section_x / 2 + 11, wall + lipstick_d/2 + 2, wall])
        cylinder(d = lipstick_d, h = z_low);
    translate([side_section_x / 2, width - (sharpener_d/2 + wall), wall])
        cylinder(d = sharpener_d + 1, h = z_low);

    // KESKOSA (Pliiatsid ristipidi)
    inner_y = width - (wall * 2); 
    pencil_sub_d = (inner_y - (2 * wall)) / 3;
    for (j = [0 : 2]) {
        translate([side_section_x + wall, wall + j * (pencil_sub_d + wall), wall])
            cube([mid_x - wall*2, pencil_sub_d, z_high + 1]);
    }

    // PAREM OSA
    for (i = [0 : 2]) {
        translate([side_section_x + mid_x + (side_section_x - post_it_w)/2, wall + i*(post_it_d + wall), wall])
            cube([post_it_w, post_it_d, z_low + 1]);
    }
    translate([side_section_x + mid_x + side_section_x / 2, width - (cream_d/2 + wall), wall])
        cylinder(d = cream_d, h = z_low + 1);
}