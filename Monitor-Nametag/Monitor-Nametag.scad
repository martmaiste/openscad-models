/*
 * Monitor Name Tag - Birthday Gift for Andri
 * Version: 0.10
 * Description: T-profile with rounded corners on both vertical and horizontal parts.
 * Recessed (engraved) text.
 */

// --- Parameetrid ---
tekst = "Proudly Assisted by Juta";
sildi_korgus = 20;       
lip_sygavus = 20;        
alumine_aste = 3;        
seina_paksus = 3;        
teksti_suurus = 7.5;     
fondi_stiil = "Inter:style=Bold"; 
kylje_padding = 10;      
tahevahe = 1.05;
nurga_raadius = 2.5;
syvise_sygavus = 1.0;    
$fn = 64;

// Laiuse arvutamine
sildi_laius = (len(tekst) * (teksti_suurus * 0.75) * tahevahe) + (kylje_padding * 2);

module ymar_ristkylik(l, p, k, r) {
    hull() {
        translate([r, 0, r]) rotate([-90, 0, 0]) cylinder(h=p, r=r);
        translate([l-r, 0, r]) rotate([-90, 0, 0]) cylinder(h=p, r=r);
        translate([r, 0, k-r]) rotate([-90, 0, 0]) cylinder(h=p, r=r);
        translate([l-r, 0, k-r]) rotate([-90, 0, 0]) cylinder(h=p, r=r);
    }
}

module horisontaalne_kandur(l, s, p, r) {
    // Teeme kanduri, millel on ainult tagumised nurgad ümarad
    hull() {
        // Esimene serv (ühenduskoht), peab olema täislaiuses ja sirge
        translate([0, 0, 0]) cube([l, 0.1, p]);
        
        // Tagumised nurgad (ümarad)
        translate([r, s-r, 0]) cylinder(h=p, r=r);
        translate([l-r, s-r, 0]) cylinder(h=p, r=r);
    }
}

module monitori_t_silt() {
    difference() {
        // PÕHIKUJU
        union() {
            // 1. Vertikaalne esiplaat (Ümarate nurkadega)
            color("#222222")
            ymar_ristkylik(sildi_laius, seina_paksus, sildi_korgus, nurga_raadius);

            // 2. Horisontaalne kandur (Ümarate taganurkadega)
            color("#333333")
            translate([0, seina_paksus, alumine_aste])
            horisontaalne_kandur(sildi_laius, lip_sygavus, seina_paksus, nurga_raadius);
        }

        // LÕIGATAV OSA (Süvistatud tekst)
        translate([sildi_laius / 2, syvise_sygavus - 0.1, sildi_korgus / 2])
        rotate([90, 0, 0])
        linear_extrude(height = syvise_sygavus + 0.1)
        text(tekst, size = teksti_suurus, font = fondi_stiil, halign = "center", valign = "center", spacing = tahevahe);
    }
}

monitori_t_silt();