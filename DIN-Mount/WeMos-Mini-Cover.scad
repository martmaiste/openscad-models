// Version: 0.08
// Kirjeldus: Pealt kinnine kaitsekarp juhtmeavaga kinnituskõrvas
// Muudatused: Ühte otsa lisatud 10mm laiune sisselõige juhtmete jaoks

// --- Parameetrid ---
inner_length = 40;
outer_width = 30;
outer_length = 60;
height = 25;
wall_thickness = 2;
ear_thickness = 5;
mount_hole_dist_x = 50; 
mount_hole_dist_y = 20; 
m3_hole_dia = 3.4;
m3_head_dia = 6.0;      
m3_head_depth = 3.0;    

side_cutout_w = 40.4;     
side_cutout_h = 5;      
wire_cutout_width = 12; // Juhtmeava laius otsas

$fn = 64;

difference() {
    union() {
        // Karbi väliskuju
        translate([-outer_length/2, -outer_width/2, 0])
            cube([outer_length, outer_width, height]);
    }

    // 1. Siseosa tühjendamine (Pealt kinnine)
    translate([-inner_length/2, -outer_width/2 + wall_thickness, -0.1])
        cube([inner_length, outer_width - 2*wall_thickness, ear_thickness +0.2]);
    // cutouts for reset ja boot buttons
    translate([-outer_length/2 +14, -outer_width/2 - 0.1, ear_thickness-0.1])
        cube([5, outer_width + 0.2, 6 + 0.1]);

        
    // 2. Avatud otsad
    translate([-mount_hole_dist_x, -outer_width/2 + wall_thickness, ear_thickness])
        cube([mount_hole_dist_x * 2, outer_width - 2*wall_thickness, height - wall_thickness - ear_thickness]);

    // 3. M3 kinnitusaugud ja süvendid
    for (x = [-mount_hole_dist_x/2, mount_hole_dist_x/2]) {
        for (y = [-mount_hole_dist_y/2, mount_hole_dist_y/2]) {
            translate([x, y, -1])
                cylinder(d = m3_hole_dia, h = height + 2);
            
            translate([x, y, ear_thickness - m3_head_depth])
                cylinder(d = m3_head_dia, h = m3_head_depth + 0.1);
        }
    }

    // 4. TÄIELIK ALUMINE VÄLJALÕIGE (Keskosa)
    translate([-side_cutout_w/2, -outer_width/2 - 1, -0.1])
        cube([side_cutout_w, outer_width + 2, side_cutout_h + 0.1]);

    // 5. JUHTMEAVA ÜHES OTSAS (10mm laiune sälk)
    // Lõikame vasakpoolse kinnituskõrva keskelt läbi
    translate([-outer_length/2 - 0.1, -wire_cutout_width/2, -0.1])
        cube([(outer_length - side_cutout_w)/2 + 0.2, wire_cutout_width, ear_thickness + 0.2]);
}