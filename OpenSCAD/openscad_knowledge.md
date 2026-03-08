# OpenSCAD Expert Knowledge & Style Guide

## 1. Top-Level Principles
* **Parametric Design:** Never hardcode dimensions. Use descriptive variables at the top of the file.
* **Robust Booleans:** To prevent "Z-fighting" (flickering or overlapping surfaces), always use a small epsilon constant `eps = 0.01`. Holes must be slightly longer than the material (`height + 2*eps`) and translated by `-eps` to ensure a clean, manifold cut.
* **Standard Quality:** Always set `$fn = 60` or higher for circular shapes to ensure smooth 3D prints and renders.

## 2. Professional Geometry Patterns (The "Gold Standard")

### Tapered Slots (Knife Guides)
Instead of combining multiple cubes and hull operations, use `linear_extrude` with a 2D `polygon`. This is computationally efficient and precise.

**Example for a sushi-style knife slot:**
```openscad
module knife_slot(h, w_mid, w_bot, w_top, depth) {
    h_bot_taper = h * 0.2;
    h_top_taper = h * 0.8;
    
    translate([0, 0, 0])
    rotate([90, 0, 90])
    linear_extrude(height = depth, center = true)
    polygon(points=[
        [-w_bot/2, 0], 
        [-w_mid/2, h_bot_taper], 
        [-w_mid/2, h_top_taper], 
        [-w_top/2, h],
        [w_top/2, h], 
        [w_mid/2, h_top_taper], 
        [w_mid/2, h_bot_taper], 
        [w_bot/2, 0]
    ]);
}
```
### Symmetrical Distribution

Always calculate offsets mathematically to center parts on the board or object.

-   `num_pieces = floor(total_length / interval);`
-   `total_span = (num_pieces - 1) * interval;`
-   `start_offset = (total_length - total_span) / 2;`
    

## 3. Critical Syntax & Logic Reminders

-   **Variable Scope:** Variables are set at compile-time. If you change a variable inside a loop, it does not affect the global value.
-   **Transformations:** `translate()`, `rotate()`, and `scale()` only apply to the **next** immediate object or the following `{}` block.
-   **Modules:** Wrap repeatable parts in `module name() { ... }` to keep the code clean and reusable.
    

## 4. Forbidden Mistakes

-   **No naked cubes in difference:** The first object in a `difference()` block must always be the main body from which others are subtracted.
    
-   **Avoid Minkowski for complex shapes:** It is extremely slow. Use it only for final rounding of simple base blocks or use `offset()` in 2D before extruding.
    
-   **Manifold Geometry:** Ensure all subtracted objects fully penetrate the surfaces they are cutting to avoid 0-thickness walls.
    

## 5. Output Requirements

-   Always start code with `// START` and end with `// END`.
-   Always include a Version header (e.g., `// Version: 0.01`).
-   Output **ONLY** code, no conversational filler or explanations unless specifically asked

## 6. Centering and Global Coordinates
* **Consistency:** If you use `center = true` for the main body, all sub-elements (holes, cutouts) must be calculated relative to the center (0,0,0).
* **Robust Alignment:** Instead of manual `translate([..., -eps])`, always use variables to define the Z-start.
  * Correct Pattern for Centered Objects:
    `hole_z_start = -(plate_height/2) - eps;`
    `hole_total_h = plate_height + 2*eps;`
    `translate([x, y, hole_z_start]) cylinder(h = hole_total_h...);`

## 7. Mathematical Sanity Checks
* **Corner Offsets:** If a plate is 50x50 and centered, the corners are at +/- 25. An offset of 5mm from corners means holes should be at +/- 20, not +/- 5.
* **Always verify:** `hole_position = (size/2) - offset`.

