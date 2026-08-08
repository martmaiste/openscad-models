// ==========================================
// Parametric Soap Refill Funnel
// Version: v0.01
// ==========================================

/* [Dimensions] */
// Diameter of the wide top part
d_wide = 45;
// Length of the wide top part
h_wide = 40;

// Diameter of the thin bottom part
d_thin = 18;
// Length of the thin bottom part
h_thin = 20;

/* [Settings] */
// Wall thickness
wall = 2.0;

// Rounding radius for smooth edges (max half of wall thickness)
smooth_r = 0.8;

/* [Hidden] */
$fn = 120;

module soap_funnel() {
    // Calculate radii
    r_wide = d_wide / 2;
    r_thin = d_thin / 2;

    // 45-degree transition means the transition height equals the difference in radii
    h_trans = r_wide - r_thin;

    // Calculate the vertical shift for the inner 45-degree wall
    // to maintain constant perpendicular wall thickness.
    dy = wall * (sqrt(2) - 1);

    // Ensure smoothing radius doesn't break the geometry
    // Maximum allowed smoothing is slightly less than half the wall thickness
    safe_r = min(smooth_r, wall / 2 - 0.01);

    // Generate the funnel by revolving a 2D profile
    rotate_extrude() {
        // Apply smoothing trick:
        // 1. expand (rounds outer convex edges)
        // 2. shrink heavily (rounds inner concave edges)
        // 3. expand back (restores size & rounds the remaining sharp edges)
        offset(r = safe_r)
        offset(delta = -2 * safe_r)
        offset(r = safe_r) {
            polygon(points = [
                // Outer profile (bottom to top)
                [r_thin, 0],
                [r_thin, h_thin],
                [r_wide, h_thin + h_trans],
                [r_wide, h_thin + h_trans + h_wide],

                // Inner profile (top to bottom)
                [r_wide - wall, h_thin + h_trans + h_wide],
                [r_wide - wall, h_thin + h_trans + dy],
                [r_thin - wall, h_thin + dy],
                [r_thin - wall, 0]
            ]);
        }
    }
}

// Render the funnel
soap_funnel();
