// =================================================================================================
// Electric Camper Van Layout
// Version: v0.01
// Date: 2026-07-26
// Description: Parametric OpenSCAD model of a Citroen e-Jumper / Stellantis L3H3 electric camper van.
// Includes a modular layout with a rear double bed, garage electrical system, swiveling seats,
// a custom diagonal shower/WC wet bath, kitchen counter, and dinette.
// =================================================================================================

/* [Render Options] */
// Quality of circles/curves ($fn)
render_quality = 32; // [16, 32, 64, 128]
// Show the transparent van body walls and roof
show_van_body = true;
// Show driver and passenger cab seats
show_cab_seats = true;
// Show the 2000x1600 bed
show_bed = true;
// Show the under-bed garage contents (V2L power box, water tank)
show_garage_systems = true;
// Show the shower / WC cabinet
show_shower_cabinet = true;
// Show the cassette toilet inside the cabinet
show_toilet = true;
// Show the kitchen block next to the sliding door
show_kitchen = true;
// Show the Lagun swivel table attached to the shower cabinet wall
show_lagun_table = true;

/* [Van Dimensions (Citroen Jumper L3H3)] */
// Cargo area interior length
cargo_length = 3705;
// Cargo area interior width (at widest point)
cargo_width = 1870;
// Cargo area interior height (H3 super high roof)
cargo_height = 2050;
// Thickness of insulated walls
wall_thickness = 50;

/* [Bed Parameters] */
bed_length = 2000;
bed_width = 1600;
// Height of bed frame platform from floor (defines garage space height)
bed_height = 850;
bed_mattress_thickness = 150;
// Longitudinal offset from rear doors
bed_x_offset = 20;

/* [Shower / WC Cabinet Parameters] */
shower_length = 1200;
shower_width = 700;
// Amount of diagonal narrowing at the front corridor
shower_narrowing = 200;
shower_height = 1950;
// Longitudinal offset from rear (placed right next to the bed)
shower_x_offset = 2020;

/* [Cab Seats & Swivels] */
// Left-Hand Drive driver seat X position (cab area)
driver_seat_x = 4250;
// Driver seat Y position (left side)
driver_seat_y = 500;
// Rotation angle for driver seat swivel (0 is facing forward (+X))
driver_swivel_angle = -120; // [-180:180]

// Passenger seat X position (cab area)
passenger_seat_x = 4250;
// Passenger seat Y position (right side)
passenger_seat_y = -500;
// Rotation angle for passenger seat swivel (0 is facing forward (+X))
passenger_swivel_angle = 120; // [-180:180]

/* [Sliding Side Door Parameters] */
sliding_door_width = 1250;
sliding_door_height = 1750;
// Distance of sliding door opening from the rear wall
sliding_door_x = 2350;
// How far the sliding door is slid open (percentage)
sliding_door_open_pct = 100; // [0:100]

/* [Rear Doors Parameters] */
// Open angle for Left Rear Door (outward, degrees)
left_rear_door_open_angle = 90; // [0:180]
// Open angle for Right Rear Door (outward, degrees)
right_rear_door_open_angle = 90; // [0:180]

/* [Kitchen Counter Parameters] */
kitchen_length = 850;
kitchen_width = 500;
kitchen_height = 900;
// Longitudinal offset from rear doors (aligned in front of bed and overlapping sliding door)
kitchen_x_offset = 2030;

/* [Lagun Table Parameters] */
// Table length
table_length = 650;
// Table width
table_width = 500;
// Table height
table_height = 730;

// Global rendering configuration
$fn = render_quality;

// ==========================================
// MAIN ASSEMBLY
// ==========================================

// Coordinate system layout:
// X-axis: Length of the van. X=0 at the rear doors, X=3705 at the cargo/cab partition.
// Y-axis: Width of the van. Y=0 at the center line, Left side is +Y (driver side LHD), Right side is -Y (passenger side).
// Z-axis: Height. Z=0 at the metal floor cargo level.

union() {
    // 1. Van Shell (insulated walls, floor, wheel arches, rear doors, glass window)
    if (show_van_body) {
        van_shell();
    }

    // 2. Sliding Door (parametric opening)
    sliding_door();

    // 3. Driver & Passenger Seats (with swivels)
    if (show_cab_seats) {
        // Driver's Seat (LHD - Left Side (+Y))
        translate([driver_seat_x, driver_seat_y, 0])
            rotate([0, 0, driver_swivel_angle])
                seat(color_fabric="DarkSlateGray", color_base="Black");

        // Passenger's Seat (Right Side (-Y))
        translate([passenger_seat_x, passenger_seat_y, 0])
            rotate([0, 0, passenger_swivel_angle])
                seat(color_fabric="DarkSlateGray", color_base="Black");
    }

    // 4. Large Rear Bed (centered transversely)
    if (show_bed) {
        translate([bed_x_offset, 0, 0])
            bed();
    }

    // 5. Shower / WC Cabinet (Left side, next to bed, narrowing at front)
    if (show_shower_cabinet) {
        translate([shower_x_offset, cargo_width/2, 0])
            shower_wc_cabinet();
    }

    // 6. Kitchen Counter (Right side, facing the sliding door)
    if (show_kitchen) {
        translate([kitchen_x_offset, -cargo_width/2, 0])
            kitchen_counter();
    }

    // 7. Lagun Swivel Table (mounted on the forward-facing shower cabinet outer wall)
    if (show_lagun_table) {
        // Mounted on the flat portion of the forward-facing shower wall: X = shower_x_offset + shower_length (3220)
        // Wall Y range is Y = 435 to 935. Center of this wall is Y = 685.
        translate([shower_x_offset + shower_length, 685, 0])
            lagun_table();
    }
}

// ==========================================
// MODULES DEFINITIONS
// ==========================================

// --- Helper: Rounded Box ---
// Simple and high performance rounded box along Z-axis
module rounded_box(size, r, center=false) {
    x = size[0];
    y = size[1];
    z = size[2];

    offset_val = center ? [-x/2, -y/2, -z/2] : [0, 0, 0];

    translate(offset_val) {
        hull() {
            translate([r, r, 0]) cylinder(h=z, r=r);
            translate([x-r, r, 0]) cylinder(h=z, r=r);
            translate([r, y-r, 0]) cylinder(h=z, r=r);
            translate([x-r, y-r, 0]) cylinder(h=z, r=r);
        }
    }
}

// --- Module: Van Shell ---
module van_shell() {
    // Colors
    color_floor = "DimGray";
    color_metal = "LightGray";
    color_glass = [0.2, 0.5, 0.6, 0.4]; // transparent teal
    color_wheel = "Black";
    color_ev_battery = "DarkSlateGray";

    // EV Traction Battery under floor (e-Jumper characteristic)
    color(color_ev_battery) {
        translate([1000, -cargo_width/2 + 200, -120])
            cube([2200, cargo_width - 400, 100]);
    }

    // Floor
    color(color_floor) {
        // Cargo floor
        translate([0, -cargo_width/2, -10])
            cube([cargo_length, cargo_width, 10]);
        // Cab floor extension
        translate([cargo_length, -cargo_width/2, -10])
            cube([1200, cargo_width, 10]);
    }

    // Left Wall (+Y)
    color(color_metal, 0.4) {
        translate([-wall_thickness, cargo_width/2, 0])
            cube([cargo_length + wall_thickness, wall_thickness, cargo_height]);
    }

    // Right Wall (-Y) with cutout for sliding door
    color(color_metal, 0.4) {
        difference() {
            translate([-wall_thickness, -cargo_width/2 - wall_thickness, 0])
                cube([cargo_length + wall_thickness, wall_thickness, cargo_height]);

            // Sliding door cutout
            translate([sliding_door_x, -cargo_width/2 - wall_thickness - 10, 0])
                cube([sliding_door_width, wall_thickness + 20, sliding_door_height]);
        }
    }

    // Bulkhead panel behind cab (partially removed for walk-through)
    color(color_metal, 0.5) {
        // Left side bulkhead pillar
        translate([cargo_length, cargo_width/2 - 250, 0])
            cube([50, 250, cargo_height]);
        // Right side bulkhead pillar
        translate([cargo_length, -cargo_width/2, 0])
            cube([50, 250, cargo_height]);
        // Over-cab storage shelf / head-liner
        translate([cargo_length - 400, -cargo_width/2, cargo_height - 150])
            cube([800, cargo_width, 50]);
    }

    // Wheel arches (internal cargo box spaces)
    color(color_wheel) {
        // Left Wheel Arch
        translate([1050, cargo_width/2 - 250, 0])
            rounded_box([800, 250, 380], 20);
        // Right Wheel Arch
        translate([1050, -cargo_width/2, 0])
            rounded_box([800, 250, 380], 20);
    }

    // Front Cab Glazing (Windshield and dashboard visual guide)
    color(color_glass) {
        // Windshield (raised and moved forward to line up with front dashboard edge)
        translate([cargo_length + 1150, -cargo_width/2, 550])
            rotate([0, -35, 0])
                cube([20, cargo_width, 1100]);
        // Left Cab window
        translate([cargo_length + 200, cargo_width/2 - 10, 500])
            cube([700, 10, 600]);
        // Right Cab window
        translate([cargo_length + 200, -cargo_width/2, 500])
            cube([700, 10, 600]);
    }

    // Cab Dashboard
    color("Black") {
        translate([cargo_length + 850, -cargo_width/2, 400])
            cube([300, cargo_width, 350]);
        // Steering wheel
        translate([cargo_length + 830, driver_seat_y, 750])
            rotate([0, 60, 0])
                cylinder(h=40, r=180, center=true);
    }

    // Rear Doors (visual guide - open outward around side hinges)
    color(color_metal, 0.5) {
        // Left Rear Door (hinged at Y = cargo_width/2)
        translate([0, cargo_width/2, 0])
            rotate([0, 0, -left_rear_door_open_angle])
                translate([-40, -cargo_width/2, 0])
                    cube([40, cargo_width/2, cargo_height - 50]);

        // Right Rear Door (hinged at Y = -cargo_width/2)
        translate([0, -cargo_width/2, 0])
            rotate([0, 0, right_rear_door_open_angle])
                translate([-40, 0, 0])
                    cube([40, cargo_width/2, cargo_height - 50]);
    }
}

// --- Module: Sliding Side Door ---
module sliding_door() {
    // Calculate current X position based on percentage open
    door_shift_x = (sliding_door_width * sliding_door_open_pct / 100);
    door_x_pos = sliding_door_x - door_shift_x;
    // Slid slightly outward when open to simulate van rail tracking
    door_y_pos = -cargo_width/2 - wall_thickness - (sliding_door_open_pct > 0 ? 15 : 2);

    color("LightGray", 0.7) {
        translate([door_x_pos, door_y_pos, 5])
            cube([sliding_door_width, 25, sliding_door_height - 10]);
    }

    // Door window
    color([0.2, 0.5, 0.6, 0.4]) {
        translate([door_x_pos + 150, door_y_pos - 5, 800])
            cube([sliding_door_width - 300, 35, 600]);
    }
}

// --- Module: Swivel Cab Seat ---
module seat(color_fabric="DarkSlateGray", color_base="Black") {
    // Pedestal base
    color(color_base) {
        cylinder(h=220, r=130);
        // Swivel plate details
        translate([0, 0, 220])
            cylinder(h=20, r=150, center=true);
    }

    // Seat Cushion assembly (centered on swivel)
    translate([0, 0, 230]) {
        color(color_fabric) {
            // Main cushion
            translate([-220, -240, 0])
                rounded_box([460, 480, 120], 30);
            // Armrests
            translate([-50, 245, 150])
                rounded_box([280, 50, 60], 15);
            translate([-50, -295, 150])
                rounded_box([280, 50, 60], 15);

            // Seat Backrest (slightly reclined 12 degrees)
            translate([-180, -220, 100])
                rotate([0, -12, 0])
                    rounded_box([100, 440, 650], 35);

            // Headrest
            translate([-220, -120, 740])
                rotate([0, -12, 0])
                    rounded_box([80, 240, 160], 25);
        }
    }
}

// --- Module: Bed (with Garage and Electric Power Systems) ---
module bed() {
    color_wood = "BurlyWood";
    color_sheets = "WhiteSmoke";
    color_mattress = "AliceBlue";

    // Bed Support Sides (Garage walls - moved to outer walls)
    color(color_wood) {
        // Left partition board (longitudinal)
        translate([0, cargo_width/2 - 20, 0])
            cube([bed_length, 20, bed_height]);
        // Right partition board (longitudinal)
        translate([0, -cargo_width/2, 0])
            cube([bed_length, 20, bed_height]);

        // Main bed platform (slats/board - now spanning full width)
        translate([0, -cargo_width/2, bed_height - 20])
            cube([bed_length, cargo_width, 20]);
    }

    // Bed Mattress
    color(color_mattress) {
        translate([10, -bed_width/2 + 10, bed_height])
            rounded_box([bed_length - 20, bed_width - 20, bed_mattress_thickness], 40);
    }

    // Cozy Bed Details (Pillows & Blanket)
    color(color_sheets) {
        // Large Blanket folding
        translate([500, -bed_width/2 + 12, bed_height + bed_mattress_thickness])
            cube([bed_length - 520, bed_width - 24, 15]);

        // Pillows at the rear (L3H3 bed orientation: sleeping transversely or longitudinally)
        // Since bed is 2000 long, sleeping longitudinally has pillows at the rear (X=100)
        translate([80, -bed_width/2 + 100, bed_height + bed_mattress_thickness])
            rotate([0, -10, 0])
                rounded_box([450, 600, 80], 20);
        translate([80, bed_width/2 - 700, bed_height + bed_mattress_thickness])
            rotate([0, -10, 0])
                rounded_box([450, 600, 80], 20);
    }

    // Under-bed Garage Systems (Direct EV Power System & Fresh Water - pushed to outer walls)
    if (show_garage_systems) {
        // Direct EV Power Integration (high-voltage orange conduit from under-floor traction pack)
        color("Orange") {
            // Conduit rising from the floor
            translate([180, cargo_width/2 - 40, 0])
                cylinder(h=250, r=12);
        }

        // Sleek EV AC/DC Power Distribution Panel & Fuse Cabinet (230V AC & 12V DC)
        color("SlateGray") {
            translate([200, cargo_width/2 - 100, 100])
                cube([280, 80, 320]);
        }

        // V2L Interface Outlets & Fuse Details
        color("Black") {
            // Dual 230V AC Outlets Panel (direct from EV built-in inverter)
            translate([240, cargo_width/2 - 102, 300])
                cube([80, 4, 60]);
            // 12V DC fuse block (for lights, fridge, pump)
            translate([360, cargo_width/2 - 102, 160])
                cube([80, 4, 100]);
        }

        color("Silver") {
            // Sockets contact circles
            translate([260, cargo_width/2 - 104, 330]) rotate([90, 0, 0]) cylinder(h=4, r=10);
            translate([300, cargo_width/2 - 104, 330]) rotate([90, 0, 0]) cylinder(h=4, r=10);
        }

        // 12V DC distribution cables running along the wall
        color("Red") {
            translate([440, cargo_width/2 - 80, 200]) rotate([0, 90, 0]) cylinder(h=300, r=4);
        }
        color("Black") {
            translate([440, cargo_width/2 - 60, 200]) rotate([0, 90, 0]) cylinder(h=300, r=4);
        }

        // Polyethylene Fresh Water Tank (placed on the other side of garage against right wall)
        color([0.9, 0.9, 0.9, 0.7]) { // Semi-transparent white plastic
            translate([200, -cargo_width/2 + 20, 50])
                rounded_box([800, 400, 550], 15);
        }
        // Water Pump
        color("DarkSlateGray") {
            translate([1050, -cargo_width/2 + 80, 50])
                cube([150, 120, 120]);
        }
    }
}

// --- Module: Shower & WC Cabinet (The Wet Bath) ---
// Custom geometry: 1200x700 cabinet, with diagonal door section narrowing the corridor.
module shower_wc_cabinet() {
    // Geometry coordinates based on rear-left corner as local (0, 0, 0)
    // Wall layout is drawn using 2D polygon and vertically extruded
    // Left side of van cargo is at Y = +935. Left wall of shower is here, so we go -Y (inwards) by shower_width.

    points_outer = [
        [0, 0],                                             // Rear-Left (at wall)
        [shower_length, 0],                                 // Front-Left (at wall)
        [shower_length, -shower_width + shower_narrowing],  // Front-Right (narrowed corridor point)
        [shower_length/2, -shower_width],                   // Mid-Right (start of diagonal angle)
        [0, -shower_width]                                  // Rear-Right (deep corner next to bed)
    ];

    // Extruded Cabinet Walls (with 15mm partition thickness)
    color("White", 0.95) {
        linear_extrude(height = shower_height) {
            difference() {
                polygon(points_outer);
                offset(r = -15) polygon(points_outer);
            }
        }
    }

    // Shower Floor Tray
    color("LightGray") {
        linear_extrude(height = 30) {
            offset(r = -15) polygon(points_outer);
        }
    }

    // Cassette Toilet (WC) inside, located at the rear of the cabinet next to the bed wall
    if (show_toilet) {
        color("Ivory") {
            // Toilet base
            translate([100, -shower_width + 50, 30])
                rounded_box([420, 350, 400], 25);
            // Toilet seat lid
            translate([100, -shower_width + 50, 430])
                rounded_box([420, 350, 30], 25);
            // Flushing unit backrest / tank
            translate([20, -shower_width + 50, 430])
                cube([80, 350, 350]);
        }
    }

    // Shower fixtures & sink
    color("Silver") {
        // Shower mixer bar & rail (located in the front half)
        translate([shower_length - 80, -shower_width + shower_narrowing + 60, 1800])
            sphere(r=25);
        translate([shower_length - 80, -shower_width + shower_narrowing + 60, 400])
            cylinder(h=1500, r=8);
        // Flexible hose and head
        translate([shower_length - 120, -shower_width + shower_narrowing + 100, 1750])
            cube([40, 40, 150]);

        // Small corner-mounted sink
        translate([shower_length - 300, -180, 850])
            cylinder(h=150, r=120);
        // Faucet
        translate([shower_length - 200, -100, 1000])
            cylinder(h=100, r=10);
    }

    // Sliding Tambour door on the diagonal face of the cabinet
    // Diagonal starts at X=600, Y=-700 and ends at X=1200, Y=-500.
    color("Silver", 0.6) {
        // Draw the door partially open
        translate([shower_length/2 + 200, -shower_width + 66, 100])
            rotate([0, 0, atan(shower_narrowing / (shower_length/2))])
                cube([300, 10, shower_height - 200]);
    }
}

// --- Module: Kitchen Counter ---
module kitchen_counter() {
    color_cabinet = "SlateGray";
    color_wood_top = "BurlyWood";
    color_sink = "Silver";
    color_induction = "Black";

    // Main Counter Base Cabinet
    color(color_cabinet) {
        translate([50, 20, 0])
            rounded_box([kitchen_length - 50, kitchen_width - 20, kitchen_height - 30], 15);
    }

    // Solid Wood Countertop
    color(color_wood_top) {
        translate([0, 0, kitchen_height - 30])
            rounded_box([kitchen_length, kitchen_width, 30], 10);
    }

    // In-Counter Sink & Faucet
    color(color_sink) {
        // Deep square sink
        translate([150, kitchen_width/2 - 120, kitchen_height - 32])
            cube([300, 240, 20]);
        // Modern swan-neck folding kitchen faucet
        translate([100, kitchen_width/2, kitchen_height]) {
            cylinder(h=250, r=8);
            rotate([90, 0, 0]) cylinder(h=120, r=8);
        }
    }

    // Sleek Electric Induction Cooktop (Electric Van signature - no LPG!)
    color(color_induction) {
        translate([kitchen_length - 350, kitchen_width/2 - 150, kitchen_height + 2])
            cube([250, 300, 4]);
        // Two cooktop burner rings
        color("Crimson") {
            translate([kitchen_length - 275, kitchen_width/2, kitchen_height + 6.1])
                cylinder(h=1, r=65, center=true);
            translate([kitchen_length - 170, kitchen_width/2, kitchen_height + 6.1])
                cylinder(h=1, r=50, center=true);
        }
    }

    // Under-counter Fridge door and drawers (facing the aisle)
    color("LightGray") {
        // 12V Compressor Fridge Front
        translate([450, kitchen_width - 15, 100])
            cube([300, 15, 600]);
        // Drawer fronts
        translate([100, kitchen_width - 15, 450])
            cube([300, 15, 250]);
        translate([100, kitchen_width - 15, 150])
            cube([300, 15, 250]);
    }
}

// --- Module: Lagun Swivel Table (Wall Mounted) ---
module lagun_table() {
    color_chrome = "Silver";
    color_table = "BurlyWood";
    color_black = "Black";

    // Wall mounting bracket (bolted to the shower wall at X=0, local coords)
    color(color_black) {
        translate([-10, -40, 150])
            cube([15, 80, 120]);
    }

    // Vertical mounting tube
    color(color_chrome) {
        translate([15, 0, 100])
            cylinder(h=500, r=18);

        // Swivel arm joint & handle lever
        translate([15, 0, 580])
            cylinder(h=40, r=25, center=true);

        // Horizontal swiveling arm (pointing slightly towards the center of the van)
        rotate([0, 0, -20]) {
            translate([15, 0, 580])
                rotate([0, 90, 0])
                    cylinder(h=240, r=15);

            // Table bracket under table
            translate([255, 0, 580]) {
                cylinder(h=120, r=20);
                translate([-100, -100, 100])
                    cube([200, 200, 15]);
            }
        }
    }

    // Tabletop (swivels around the end of the arm at Z = 705)
    color(color_table) {
        rotate([0, 0, -20]) { // aligns table angle with swiveled arm
            translate([255, 0, 715])
                rounded_box([table_length, table_width, 25], 20, center=true);
        }
    }
}
