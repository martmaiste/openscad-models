// PCB Kate / PCB Cover
// Version: 0.10
// Last Modified: 2026-02-16
// Muudatus: Klipi pikkus 5mm, asukoht 5-10mm otstest

/* [Peamised mõõdud] */
pcb_width = 30;         
pcb_length = 58;        
inner_height = 15;      
wall_thickness = 2.5;     
pcb_thickness = 1.6;    

/* [Kinnitusnupud] */
bump_radius = 0.8;      
bump_length = 5;        // Klipi pikkus on nüüd 5mm
clip_offset = 5;        // Kaugus karbi otstest on 5mm

/* [Otsmised tugevdusribid] */
rib_thickness = wall_thickness;    
rib_depth = 2.5;        

$fn = 32;

module pcb_cover_v0_10() {
    total_height = pcb_thickness + inner_height + wall_thickness;

    // Keskmestamine
    translate([-(pcb_width + 2 * wall_thickness)/2, -pcb_length/2, 0]) {
        
        // 1. Pealmine kaas
        translate([0, 0, total_height - wall_thickness])
            cube([pcb_width + 2 * wall_thickness, pcb_length, wall_thickness]);

        // 2. Külgseinad
        cube([wall_thickness, pcb_length, total_height]);
        translate([pcb_width + wall_thickness, 0, 0])
            cube([wall_thickness, pcb_length, total_height]);

        // 3. Otsmised tugevdusribid
        // Esimene ots
        translate([wall_thickness, 0, total_height - wall_thickness - rib_depth])
            cube([pcb_width, rib_thickness, rib_depth]);
            
        // Tagumine ots
        translate([wall_thickness, pcb_length - rib_thickness, total_height - wall_thickness - rib_depth])
            cube([pcb_width, rib_thickness, rib_depth]);

        // 4. Kinnitusmummud (asuvad vahemikus 5-10mm ja pcb_length-10 kuni pcb_length-5)
        for(y_pos = [clip_offset, pcb_length - clip_offset - bump_length]) {
            // Vasak sein
            translate([wall_thickness, y_pos, 0]) 
                flush_bump_pair();
            
            // Parem sein
            translate([pcb_width + wall_thickness, y_pos, 0]) 
                mirror([1, 0, 0]) 
                flush_bump_pair();
        }
    }
}

module flush_bump_pair() {
    // Alumine poolsilinder
    translate([0, 0, bump_radius]) rotate([-90, 0, 0]) half_cylinder();
    
    // Ülemine poolsilinder (pcb_thickness vahega)
    translate([0, 0, bump_radius * 2 + pcb_thickness]) rotate([-90, 0, 0]) half_cylinder();
}

module half_cylinder() {
    difference() {
        cylinder(r = bump_radius, h = bump_length);
        translate([-bump_radius*2, -bump_radius, -0.1])
            cube([bump_radius*2, bump_radius*2, bump_length+0.2]);
    }
}

// Renderdamine
pcb_cover_v0_10();