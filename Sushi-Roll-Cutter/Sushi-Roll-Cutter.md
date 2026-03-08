# Sushi Cutting Guide Generator Prompt

Act as an expert OpenSCAD programmer. Create a clean, parametric, and symmetrical sushi roll cutting guide based on the following specifications:

### 1. Parameters
* `roll_length`: Total length of the board (e.g., 250mm).
* `piece_width`: Distance between cuts (e.g., 20mm).
* `roll_diameter`: Diameter of the sushi roll (e.g., 45mm).
* `bottom_thickness`: Solid base thickness below the roll (5mm).
* `guide_clearance`: Extra height of side walls above the roll to guide the knife before contact (10mm).
* `wall_thickness`: Thickness of the sides (5mm).
* `edge_radius`: All external body edges must be rounded (1mm).
* `slot_width`: Standard middle-section width of the knife slot (2mm).
* `bottom_slot_width`: Tapered width at the very bottom (1mm).
* `top_guide_extra_width`: Added width at the top entry point for easy knife insertion.

### 2. Geometry Requirements
* **Body:** A rectangular block with all external edges rounded using a Minkowski sum with a sphere.
* **Cradle:** A cylindrical horizontal cutout to hold the roll without deformation.
* **Top Opening:** A rectangular cutout extending from the center of the cylinder to the top of the block, matching the roll diameter width.
* **Slots:** * Must be vertical and cut through the entire width.
    * Must be distributed symmetrically along the `roll_length` based on `piece_width`.
    * **Tapering Profile:** Use a 2D polygon and linear extrusion. The bottom 20% of the slot height should taper from `bottom_slot_width` to `slot_width`. The middle 60% is constant `slot_width`. The top 20% should taper wider by `top_guide_extra_width`.

### 3. Code Quality
* Ensure the design is centered and symmetrical.
* Use `$fn = 60` for smooth curves.
* Include a version comment at the top (e.g., `// Version: 0.10`).
* Ensure there are no "ghost" faces or non-manifold issues by using small offsets (e.g., `+2` or `-1`) for subtractive parts.
