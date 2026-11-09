/*
 * ============================================================================
 *  MC4 SPANNER - parametric & modular OpenSCAD model
 * ============================================================================
 *  Version history
 *  ---------------
 *  v0.01  2026-11-04  Initial parametric modular model.
 *                     - Connector-profile registry (add one module + one
 *                       registry entry per connector family).
 *                     - First profile: Morek MC4 1500V
 *                         * outer diameter        20.0 mm
 *                         * minor diameter        18.5 mm (gap floor)
 *                         * elevated sections: 6 mm arc measured on the
 *                           OD (20 mm) surface
 *                         * notches (gaps):    ~4 mm arc measured on the
 *                           OD (20 mm) surface  -> 6 sections/cycle
 *                     - Socket ring with inward teeth engaging the gaps,
 *                       handle with finger hole, optional short lever arm.
 *  v0.02  2026-11-04  Cable opening.
 *                     - Snap-on slot through the socket wall so the tool can
 *                       be placed on the connector with the cable already
 *                     - Slot is centered between two teeth
 *                       (default 150 deg) -> all 6 tooth drive faces stay
 *                       intact; the slot only trims bore clearance surfaces.
 *  v0.03  2026-11-04  Cable slot moved onto the X axis (180 deg, opposite
 *                     the handle) so the two C-arms of the ring are mirror
 *                     symmetric -> both sides equally strong and the load
 *                     path handle->slot is collinear.
 *                     - New `socket_phase` parameter: rotates the tooth /
 *                       bore pattern 30 deg so a LOBE (not a tooth) sits on
 *                       the slot axis; the slot then lands exactly between
 *                       the teeth at 150/210 deg and cuts no drive face.
 *  v0.04  2026-11-04  Stiffness revision (less flex):
 *                     - wall 3 -> 5 mm: C-ring bending stiffness scales with
 *                       wall^3 -> ~4.6x stiffer arm.
 *                     - socket_h 8 -> 10 mm: more tooth bearing area and a
 *                       taller ring cross-section (stiffness ~ proportional).
 *                     - neck is extruded at full socket height, so handle
 *                       force enters the tall ring directly instead of
 *                       through an 8 mm step.
 *                     - handle thickness stays 8 mm (grippability, weight).
 *                     Overall in-plane ring flex: ~5.8x lower than v0.03.
 *  v0.06  2026-11-04  Uniform thickness for 3D printing.
 *                     - socket_h + handle_t merged into ONE parameter
 *                       `tool_t` (default 10 mm): socket, teeth, gussets,
 *                       handle and lever all share the same height, so the
 *                       part prints as a single flat layer stack with
 *                       uniform walls (no perimeters overhangs, no uneven
 *                       cooling / warping).
 *  v0.05  2026-11-04  Yoke / gusset handle-to-socket joint.
 *                     - The narrow trapezoid neck is replaced by two
 *                       shoulder gussets: the handle joins the socket along
 *                       the ring OD on BOTH sides (up to +-55 deg from the
 *                       handle axis), spreading the load into the widest
 *                       part of the socket instead of one small neck.
 *                       Gusset back edge follows a circle inside the ring
 *                       wall -> the bore can never be blocked.
 *                       Mirror-symmetric about the X axis; lever gets the
 *                       same gusset when enabled.
 *
 *  Architecture
 *  ------------
 *   CONFIG block          user parameters (customizer-friendly)
 *   conn_profile_*()      connector registry / profile dispatch
 *   connector_profile_*() cross-section of a connector (master "negative")
 *   tool_socket()         ring + engagement teeth derived from a profile
 *   tool_handle()         lever / grip
 *   tool()                final tool  <-- render this
 *   demo_connector()      visual aid only (do NOT print)
 *
 *  To add a new connector shape:
 *   1. write a connector_profile_<name>() module (cross-section in XY),
 *   2. add its key numbers to conn_profile(),
 *   3. add a dispatch branch in conn_profile_shape().
 *
 *  Notes
 *  -----
 *  * The 6 mm elevated-section length and 4 mm notch length are interpreted
 *    as arcs on the 20 mm OD surface (as measured "on the surface of the
 *    curve"); the datasheet does not give the lobe count, so it defaults to
 *    the classic MC4 value of 6.
 *  * Print with the XY layers: socket ring + handle lie flat in one plane.
 * ============================================================================
 */


// ============================================================================
// CONFIG  (v0.01)
// ============================================================================
$fn = 96;

/* [Connector] */
// Which connector profile to build the tool for
conn_key = "morek_mc4_1500v";    // [morek_mc4_1500v]

/* [Fit] */
// radial clearance between tool and connector [mm]
fit_clr        = 0.25;
// radial engagement of each tooth into a gap [mm]
tooth_engage   = 0.7;
// angular clearance per flank of a tooth [deg]
tooth_clr_ang  = 0.6;

/* [Tool] */
// uniform thickness of the whole tool [mm]
// (v0.06) single flat height for clean single-layer-stack 3D printing;
// (v0.04 rationale) taller ring = stiffer ring + longer tooth bearing
// surface
tool_t         = 10;
// wall thickness of the socket ring [mm]
// (v0.04) ring stiffness ~ wall^3: 5 mm is ~4.6x stiffer than 3 mm
wall           = 5;
// handle length, measured from the tool center [mm]
handle_len     = 60;
// handle width [mm]
handle_w       = 18;
// finger-hole diameter [mm]
finger_hole_d  = 12;
// show a short lever arm opposite the handle (ratchet clearance!)
show_lever     = false;
// lever arm length from center [mm]
lever_len      = 32;

/* [Cable slot] */
// open the socket wall so the tool snaps on around the cable
show_cable_slot = true;
// slot width = max cable diameter + clearance [mm]
cable_slot_w    = 8;
// slot center angle [deg]: 180 = on the X axis, opposite the handle ->
// mirror-symmetric ring, both sides equally strong
cable_slot_ang  = 180;
// phase of the tooth/bore pattern vs the handle axis [deg]:
// 30 puts a lobe center on the slot axis so the slot sits between teeth
socket_phase    = 30;

/* [Demo] */
// show the connector inside the tool (visual check only)
show_demo      = false;


// ============================================================================
// CONNECTOR REGISTRY  (v0.01)
// ============================================================================
// Every profile returns the same vector layout:
// [r_outer, r_minor, n, lobe_arc, gap_arc, lobe_ang_deg, gap_ang_deg]
//
//  r_outer   radius of the elevated sections (OD/2)
//  r_minor   radius at the bottom of the gaps  (minor/2)
//  n         number of elevated sections per revolution
//  lobe_arc  arc length of the flat top of one lobe, measured at r_outer
//  gap_arc   arc length of one gap,          measured at r_outer
//  lobe_ang  angular width of the lobe flat  [deg]
//  gap_ang   angular width of one gap        [deg]
function conn_profile(key) =
    key == "morek_mc4_1500v" ? morek_mc4_1500v_profile()
                             : undef;

function conn_p(key, i) = conn_profile(key)[i];

// portable pi (some builds only know PI, newer ones $pi; never both reliably)
PI_ = 3.141592653589793;

function deg2rad(d) = d * PI_ / 180;
function rad2deg(r) = r * 180 / PI_;

// ---- Morek MC4 1500V -------------------------------------------------------
// OD 20 mm, minor 18.5 mm, 6 mm elevated arcs, ~4 mm gap arcs (at OD).
function morek_mc4_1500v_profile() = morek_profile_core(20/2, 18.5/2, 6, 6, 4);

function morek_profile_core(r_out, r_min, n, lobe_arc, gap_arc) =
    let(lobe_ang = 180 * lobe_arc / (PI_ * 2 * r_out),   // arc -> angle at OD
        gap_ang  = 180 * gap_arc  / (PI_ * 2 * r_out))
    [r_out, r_min, n, lobe_arc, gap_arc, lobe_ang, gap_ang];


// ============================================================================
// CONNECTOR PROFILES (cross-sections in XY - the "master" negative) (v0.01)
// ============================================================================
module conn_profile_shape(key) {
    if (key == "morek_mc4_1500v")
        connector_profile_morek_mc4_1500v();
    else
        echo(str("ERROR: unknown connector profile '", key, "'"));
}

// Closed CCW polygon of a generic lobed ring, built from one repeating
// period: gap floor -> rising flank -> lobe flat -> falling flank.
// Gaps are centered on multiples of 360/n; lobe centers sit in between.
// Returns [x,y] points; shared by the demo profile and the tool bore.
function lobed_poly(r_out, r_min, n, lobe_ang, gap_ang, n_f=8, n_g=4) =
    let(
        pitch     = 360 / n,
        lobe_h    = lobe_ang / 2,          // half-angle of the flat top
        gap_h     = gap_ang / 2,           // half-angle of the gap floor
        rise_end  = pitch/2 - lobe_h,      // angle where the flat begins
        period    = concat(
            // gap floor (CCW across the gap center)
            [ for (i=[0:n_g-1]) [r_min, -gap_h + 2*gap_h * i/n_g] ],
            // rising flank (straight chord floor -> OD)
            [ for (i=[1:n_f])
                  [r_out, gap_h + (rise_end - gap_h) * i/n_f] ],
            // lobe flat top
            [ for (i=[1:n_f])
                  [r_out, pitch/2 - lobe_h + 2*lobe_h * i/n_f] ],
            // falling flank back down to the next gap floor
            [ [r_min, pitch - gap_h] ]
        )
    )
    [ for (k=[0:n-1], q=period) polar_to_xy(q[0], q[1] + k * pitch) ];

// Generic lobed ring module (extrudes lobed_poly).
module lobed_profile(r_out, r_min, n, lobe_ang, gap_ang) {
    linear_extrude(height=20, center=true)
        polygon(lobed_poly(r_out, r_min, n, lobe_ang, gap_ang));
}

// Radial outward offset of a [r,angle]-built polygon (good enough for
// star-convex connector cross-sections like MC4 lobed rings).
function polygon_offset(pts, d) = [
    for (p = pts) let(a = atan2(p[1], p[0]), r = norm(p))
        [ (r + d) * cos(a), (r + d) * sin(a) ]
];

function polar_to_xy(r, a_deg) = [r * cos(a_deg), r * sin(a_deg)];

// ---- Morek MC4 1500V profile ------------------------------------------------
module connector_profile_morek_mc4_1500v() {
    p = morek_mc4_1500v_profile();
    lobed_profile(p[0], p[1], p[2], p[5], p[6]);
}


// ============================================================================
// TOOL SOCKET  (v0.01)
// ============================================================================
// Ring whose bore is the connector profile + fit clearance, with teeth that
// stick inward by `tooth_engage` at every gap center -> positive drive on the
// elevated sections via the gap notches.
module tool_socket(key) {
    p       = conn_profile(key);
    r_out   = p[0];
    r_min   = p[1];
    n       = p[2];
    gap_ang = p[6];
    pitch   = 360 / n;

    r_bore  = r_out + fit_clr;              // bore over the lobes
    // tooth tip bites `tooth_engage` below the bore circle, but never past
    // the notch floor (keep clearance there):
    r_tooth = max(r_min + fit_clr + 0.2, r_bore - tooth_engage);
    tooth_h = gap_ang/2 - tooth_clr_ang;    // tooth half-angle

    // v0.03: whole bore/tooth pattern is phased by socket_phase so that a
    // lobe center (not a tooth) lies on the slot axis. The connector can be
    // applied in any of the n positions, so the phase is free.
    rotate(socket_phase)
    difference() {
        union() {
            // base ring
            difference() {
                cylinder(h=tool_t, r=r_bore + wall, center=true);
                cylinder(h=tool_t + 2, r=r_bore, center=true);
            }
            // engagement teeth
            for (i=[0:n-1])
                rotate(i * pitch)
                    socket_tooth(r_bore, r_tooth, tooth_h);
        }
        // bore = connector cross-section offset by fit_clr (radial offset,
        // valid for these star-convex shapes; see polygon_offset())
        tool_bore(key);
    }
}

// Exact profile bore: reuse lobed_poly, offset it radially by fit_clr, and
// extrude it through the socket.
module tool_bore(key) {
    p = conn_profile(key);
    linear_extrude(height=tool_t + 4, center=true)
        polygon(polygon_offset(
            lobed_poly(p[0], p[1], p[2], p[5], p[6], n_f=16, n_g=8),
            fit_clr));
}

// one tooth: trapezoid, wide at the ring side, narrower toward the tip
module socket_tooth(r_bore, r_tip, half_ang) {
    r_wide = r_bore + wall/2;               // anchor well into the ring wall
    poly   = [
        polar_to_xy(r_tip,  -half_ang * 0.55),
        polar_to_xy(r_bore, -half_ang),
        polar_to_xy(r_wide, -half_ang),
        polar_to_xy(r_wide,  half_ang),
        polar_to_xy(r_bore,  half_ang),
        polar_to_xy(r_tip,   half_ang * 0.55),
    ];
    linear_extrude(height=tool_t, center=true)
        polygon(poly);
}


// ============================================================================
// HANDLE  (v0.01)
// ============================================================================
// v0.05: handle joins the socket through two shoulder gussets, so its load
// enters the ring along the widest part of the OD on BOTH sides.
// The gusset polygon spans an arc of the ring wall (radius arc_r, safely
// inside the wall so it can never intrude into the bore) and the full handle
// width at its front edge -> a wide yoke instead of a small neck.
module tool_gusset(r_socket, rot=0) {
    gusset_ang = 55;                       // reach around the ring [deg]
    arc_r      = r_socket - wall * 0.5;    // anchor circle (mid wall)
    x1         = r_socket + 12;            // blend length along the handle

    rotate(rot)
        linear_extrude(height=tool_t, center=true)
            polygon(concat(
                [for (a=[-gusset_ang:10:gusset_ang]) polar_to_xy(arc_r, a)],
                [[x1,  handle_w/2],
                 [x1, -handle_w/2]]
            ));
}

// Handle starts at the ring outer wall (does not cover the socket center,
// so the cable path stays clear); v0.04 full-height joint, v0.05 yoke.
module tool_handle(r_socket) {
    union() {
        translate([r_socket, -handle_w/2, -tool_t/2])
            cube([handle_len - r_socket, handle_w, tool_t]);
        tool_gusset(r_socket, 0);
        // rounded end
        translate([handle_len, 0, 0])
            cylinder(h=tool_t, r=handle_w/2, center=true);
    }
}

module tool_lever(r_socket) {
    union() {
        translate([-lever_len, -handle_w/2, -tool_t/2])
            cube([lever_len - r_socket, handle_w, tool_t]);
        tool_gusset(r_socket, 180);
        translate([-lever_len, 0, 0])
            cylinder(h=tool_t, r=handle_w/2, center=true);
    }
}


// ============================================================================
// FINAL TOOL  (render this)  (v0.01)
// ============================================================================
module tool(key=conn_key) {
    r_bore = conn_p(key, 0) + fit_clr;
    // v0.06: uniform `tool_t` everywhere -> all cutters span tool_t

    difference() {
        union() {
            tool_socket(key);
            tool_handle(r_bore + wall);
            if (show_lever) tool_lever(r_bore + wall);
        }
        // keep the cable entry/exit clear: remove material only inside the
        // minor diameter (connector body region), never touching the teeth
        translate([0, 0, -tool_t/2 - 1])
            cylinder(h=tool_t + 2, r=conn_p(key, 1), center=false);
        // finger hole
        translate([handle_len - finger_hole_d/2 - 5, 0, -tool_t/2 - 1])
            cylinder(h=tool_t + 2, d=finger_hole_d);
        // cable slot (v0.02): straight channel from the bore out through the
        // wall. Centered at cable_slot_ang (default 150 deg = exactly between
        // the teeth at 120 and 180 deg), so with the default 8 mm width it
        // only grazes the outermost tooth-tip corners, never a drive flank.
        // v0.03: slot on the X axis (180 deg). With socket_phase=30 the
        // nearest teeth are at 150/210 deg, so the 8 mm slot grazes only
        // tooth-tip corners and the ring is mirror-symmetric about X.
        if (show_cable_slot)
            rotate(cable_slot_ang)
                translate([0, -cable_slot_w/2, -tool_t/2 - 1])
                    cube([r_bore + wall + 2, cable_slot_w, tool_t + 2]);
    }
}


// ============================================================================
// DEMO (visual check only - do not print)  (v0.01)
// ============================================================================
module demo_connector() {
    // transparent color (instead of %) so it also shows in CLI renders;
    // matches the phased socket so the demo shows the real engagement
    color("steelblue", 0.4)
        rotate(socket_phase) conn_profile_shape(conn_key);
}


// ============================================================================
// MAIN
// ============================================================================
if (show_demo) {
    color("steelblue") demo_connector();
    color("goldenrod") tool();
} else {
    tool();
}
