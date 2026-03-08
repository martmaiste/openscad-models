// Makita DCL180 Seinakinnitus
// Versioon: 1.23
// Taastatud stabiilne geomeetria: 10mm plaat, 1mm süvend, 120mm vahe

/* [Põhiparameetrid] */
hoidiku_korgus = 50;
avause_laius = 45; 
seinapaksus = 8; 
plaadi_paksus = 10; 
faasi_suurus_plaat = 10; 
sisestus_faas = 5; 

// Sisemise koonuse parameetrid
koonus_alumine_d = 83; 
koonus_ulemine_d = 100;

// Välimise koonuse arvutus
valis_alumine_d = koonus_alumine_d + (seinapaksus * 2);
valis_ulemine_d = koonus_ulemine_d + (seinapaksus * 2);

/* [Kinnitused] */
kruvi_ava_d = 4.5;
kruvi_pea_d = 10;
kruvi_pea_syvendi_sygavus = 1; 
kruvide_vahe = 120; 
kinnitusplaadi_laius = kruvide_vahe + 16;

/* [Peenus] */
$fn = 100;

difference() {
    // PÕHIKORPUS
    union() {
        // 1. Välimine koonus
        cylinder(h = hoidiku_korgus, d1 = valis_alumine_d, d2 = valis_ulemine_d);
        
        // 2. Tagumine kinnitusplaat (kaheksanurkne profiil)
        translate([0, -valis_ulemine_d/2 + plaadi_paksus/2, hoidiku_korgus/2])
        rotate([90, 0, 0])
        linear_extrude(height = plaadi_paksus, center = true)
        hull() {
            square([kinnitusplaadi_laius - 2*faasi_suurus_plaat, hoidiku_korgus], center = true);
            square([kinnitusplaadi_laius, hoidiku_korgus - 2*faasi_suurus_plaat], center = true);
        }
            
        // 3. Eestvaates kooniline lisatugevdus
        hull() {
            translate([-valis_alumine_d/2, -valis_ulemine_d/2, 0])
                cube([valis_alumine_d, valis_ulemine_d/2, 0.1]);
            
            translate([-valis_ulemine_d/2, -valis_ulemine_d/2, hoidiku_korgus - 0.1])
                cube([valis_ulemine_d, valis_ulemine_d/2, 0.1]);
        }
    }

    // SISEMINE KOONILINE PESA
    translate([0, 0, -1])
        cylinder(h = hoidiku_korgus + 2, d1 = koonus_alumine_d, d2 = koonus_ulemine_d);

    // C-KUJULINE AVAUS KOOS SISEMISE ÜLASERVA FAASIGA
    union() {
        translate([-avause_laius/2, 0, -1])
            cube([avause_laius, valis_ulemine_d, hoidiku_korgus + 2]);
        
        for(i = [-1, 1]) {
            translate([i * avause_laius/2, 0, hoidiku_korgus])
            rotate([0, i * 45, 0])
            translate([-5, 0, -5])
                cube([10, valis_ulemine_d, 10]);
        }
    }

    // KRUVIAUGUD - Kontrollitud läbivus ja süvend
    for(i = [-1, 1]) {
        // Liigutame augu punkti, kus plaat lõppeb (seina poolne külg)
        translate([i * kruvide_vahe/2, -valis_ulemine_d/2 + plaadi_paksus, hoidiku_korgus/2])
            rotate([-90, 0, 0]) {
                // Peenike ava läbib plaadi täielikult
                translate([0, 0, -plaadi_paksus - 1])
                    cylinder(h = plaadi_paksus + 2, d = kruvi_ava_d);
                
                // Süvend on 1mm sügavune ja algab täpselt plaadi välispinnalt
                translate([0, 0, -kruvi_pea_syvendi_sygavus])
                    cylinder(h = kruvi_pea_syvendi_sygavus + 0.1, d = kruvi_pea_d);
            }
    }
}