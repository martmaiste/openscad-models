/* CT Holder - Version 0.12
   Method: Subtractive with nested difference.
   Modification: Bolt center 10mm from end, round head pocket.
*/

// --- Parameetrid ---
ct_od = 31;
ct_id = 17;
ct_h = 16;           // CT paksus (laius)
wall_t = 5;          // Alumise lapi paksus
bolt_d = 3.4;        // M3 poldi ava
bolt_head_d = 6.0;   // M3 ümarpea läbimõõt
$fn = 80;

block_l = 40;
block_h = 13;
block_w = 10;        // Hoidiku laius (läheb läbi CT ava)

// Arvutatud väärtused
ct_r_in = ct_id / 2; // 8.5mm
cutout_h = 8;        // Sisselõike kõrgus

module ct_holder() {
    difference() {
        // 1. Algne põhiplokk
        cube([block_l, block_w, block_h]);

        // 2. Poldi lapi tekitamine (parem ülemine lõige)
        translate([block_l - 15, -1, wall_t]) // Pikendasime sisselõiget, et polt mahuks
            cube([16, block_w + 2, block_h + 1]);

        // 3 ja 6 kombineerituna: CT pesa + kumeruse säilitamine
        translate([5, -1, 0]) {
            difference() {
                // Kandiline sisselõige
                cube([ct_h, block_w + 2, cutout_h + 1]);
                
                // KURV: CT siseava raadius
                translate([0, (block_w + 2) / 2, ct_od/2])
                    rotate([0, 90, 0])
                        cylinder(h = ct_h, r = ct_r_in);
            }
        }
            
        // 4. Poldi ava (Kese 10mm otsast)
        translate([block_l - 10, block_w / 2, -1])
            cylinder(h = wall_t + 2, d = bolt_d);
            
        // 5. Poldipea süvend (Ümarpea jaoks sirge silinder)
        translate([block_l - 10, block_w / 2, wall_t - 2.5])
            cylinder(h = 3, d = bolt_head_d);
    }
}

ct_holder();