# Cargo Strap Saddle Guide (19mm Tape Mount)

A professionally engineered, fully parameterized 3D-printable cargo strap saddle guide. This design is optimized to be secured using standard **19mm wide double-sided tape** (like 3M VHB) on the bottom, while the cargo strap runs directly over the top of the guide. 

The strap rests inside a **1.5mm deep groove**, and is held securely in place by the strap's own tension (clamping force). This design eliminates the need for a closed ceiling tunnel, creating a strong, low-profile guide that keeps the tape under constant compression (maximizing tape adhesion!).

![Cargo Strap Saddle Guide](Cargo-Strap-Guide.png)

## Design Features (v0.06 - Perfected Chamfered Edition)
- **Flat-Faceted Chamfers**: Transformed all outer and key structural edges into beautiful, crisp, **45-degree flat chamfers (bevels)**. This completely avoids slow-rendering curved primitives (spheres, cylinders, circles) and Minkowski functions.
- **Top Groove Chamfers**: 
  - The **top side** of the groove floor directly underneath the strap (at `z = 1.5mm`) is beautifully beveled (chamfered) along its left and right sides (`x = 0` and `x = 19mm`). This allows the strap to slide smoothly in and out sideways without rubbing against any sharp plastic corners.
  - The **bottom side** of the guide block (at `z = 0`) remains perfectly flat and square-edged, guaranteeing 100% contact area and robust adhesion with your 19mm mounting tape.
- **Square Groove Walls**: The base of the shoulders inside the groove (at `y = 10mm` and `y = 36mm`) is designed with a **perfectly flat, 90-degree square corner** (no fillets, no wedges). This allows the strap to lie completely flat against the floor and wall interfaces without riding up.
- **Massive Performance Optimization**: Compiles virtually instantly (under 10 milliseconds). The 3D model complexity consists of only **60 vertices and 116 facets**, making it extremely lightweight and fast to slice.
- **Strict Dimensional Fit**: 
  - **Width**: Exactly `19mm` to match the width of standard 19mm double-sided tape.
  - **Thickness**: Exactly `3.0mm` at the shoulders.
  - **Length**: `strap_width + 20mm` (default `46mm` for a `26mm` strap).
  - **Groove Depth**: Exactly `1.5mm` deep, leaving a solid `1.5mm` thick floor.
- **Zero-Support Printing**: The 45-degree flat bevels are perfect for FDM printers, enabling clean, supportless overhangs with flawless surface finish.

---

## 3D Printing Guidelines

| Slicer Parameter | Recommended Value | Why? |
| :--- | :--- | :--- |
| **Print Orientation** | Flat on the build plate | No supports needed, maximum layer adhesion. |
| **Material** | **PETG**, **ASA**, or **ABS** | Highly recommended over PLA due to outdoor UV resistance, high mechanical strength, and vehicle heat tolerance. |
| **Wall Loops/Perimeters**| `4` or more | Ensures the entire perimeter of the shoulders and groove is solid plastic. |
| **Infill Density** | `30% - 50%` | High density ensures the guide won't crush under heavy strapping loads. |
| **Infill Pattern** | Gyroid or Grid | Offers uniform strength in all axes. |
| **Supports** | **None** | Fully optimized for supportless printing. |

---

## Mounting Instructions

1. **Clean the Surfaces**: Wipe both the bottom face of the printed strap guide and the mounting surface with isopropyl alcohol (IPA) to remove oils and dust.
2. **Apply the Tape**: Cut a strip of `19mm` wide double-sided tape (e.g., 3M VHB 5952) matching the length of the guide (`46mm` by default). Press it firmly onto the bottom face of the guide.
3. **Mount to Surface**: Peel the backing liner off the tape, align the guide, and press down with firm pressure for at least 30 seconds.
4. **Cure Time**: For maximum adhesion (especially with 3M VHB), let the adhesive cure for **24 hours** before threading and tensioning the cargo strap over it.

---

## OpenSCAD Customization

The model is parameterized using OpenSCAD's Customizer interface. You can open `Cargo-Strap-Guide.scad` in OpenSCAD and adjust:

- **`strap_width`**: Default `26mm` (perfect for standard 1" straps).
- **`strap_clearance`**: Default `1.0mm` (adds wiggle room inside the groove).
- **`block_width`**: Default `19mm` (adjust if using different tape widths, e.g., 12mm or 25mm).
- **`block_height`**: Default `3.0mm`.
- **`groove_depth`**: Default `1.5mm`.
- **`shoulder_length`**: Default `10.0mm` (length of the raised shoulders on each side of the groove).
- **`chamfer_size`**: Default `1.0mm` (controls all outer, top-inner, and groove floor edge bevels).

---

## File Versioning
* **v0.06** (2026-07-28): Restored flat 45-degree chamfers to the top side of the groove floor (z=1.5mm) along the sides (x=0 and x=19), while keeping the bottom (z=0) flat and the shoulder walls perfectly square (90 degrees).
* **v0.05** (2026-07-28): Simplified by removing all chamfers/wedges from the groove floor.
* **v0.04** (2026-07-28): Transformed design to use 45-degree flat chamfers (bevels) on all edges.
* **v0.03** (2026-07-28): Solid union-based round model utilizing capsule fillets and custom extruded 2D-rounded profiles to eliminate sharp CSG intersections.
* **v0.02** (2026-07-28): Revised open-top saddle style with strap-clamping force retention.
* **v0.01** (2026-07-28): Initial release (closed tunnel design).
