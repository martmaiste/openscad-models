# EasyDrive Box Stops

**Version:** v0.01  
**License:** MIT  

A parametric, 3D-printable OpenSCAD design for **EasyDrive Box stops**. These stops are designed to be glued using 20mm double-sided tape onto an inflatable or rigid wing-foil board. They form a snug, rigid `[`-bracket that wraps around the corners of the cargo box, preventing it from sliding side-to-side or front-to-back, while cargo straps pass over the box to keep it firmly pressed down onto the board.

---

## Features

- **Feet-Friendly & Safe:** Stepping on these stops with bare feet won't hurt! The design features a substantial **1.5mm top fillet** and fully rounded vertical corners to remove any sharp edges.
- **Robust Tape Mounting:** Designed to match standard **20mm-wide heavy-duty double-sided tape** (like 3M VHB). A flat bottom with a minor **0.5mm fillet** ensures maximum tape adhesion and stress relief.
- **High-Performance Slicing:** Uses a custom, mathematically precise layer-by-layer slicing technique in OpenSCAD. This allows for beautifully smooth top and bottom fillets without resorting to slow `minkowski` operations or suffering from non-convex `hull` bridging.
- **Symmetric & Mirrored rendering:** Easily export either the **Left** or **Right** stop centered at the origin, or render **Both** to preview the full assembly.
- **Rich 3D Visualization Scenery:** When viewed in OpenSCAD preview mode, the script generates a semi-transparent mockup of the wing-foil board, the cargo box, and the orange tie-down strap, adjusting dynamically as you change dimensions.

---

## Parameters

You can easily adjust the following parameters inside OpenSCAD's **Customizer** panel:

### 1. Dimensions
- `box_depth` (Default: `95mm`): Depth of the box along the board's longitudinal axis.
- `stop_width` (Default: `20mm`): Width of the profile, matching your double-sided tape.
- `stop_height` (Default: `5mm`): Overall thickness/height of the stops.
- `end_length` (Default: `15mm`): How far the ends of the `[` bracket wrap around the front/back of the box.

### 2. Smoothing
- `bottom_smoothing` (Default: `0.5mm`): Radius of the bottom edge rounding.
- `top_smoothing` (Default: `1.5mm`): Radius of the top edge rounding (protects feet).
- `corner_radius_inner` (Default: `2.0mm`): Corner radius of the inner corners in XY plane. Fits rounded box corners perfectly.
- `corner_radius_outer` (Default: `4.0mm`): Corner radius of the outer corners in XY plane for a sleek look.

---

## Printing Guide

To make the stops highly durable and resistant to the marine environment:

### 1. Material Choice
- **Recommended:** **TPU (Hardness 95A or 98A)** or **ASA / PETG**.
  - **TPU** is highly recommended because it is semi-flexible, absorbs impact, has excellent UV resistance, does not degrade in seawater, and feels incredibly soft if stepped on.
  - **ASA** offers excellent UV and weather resistance with rigid structural support.
  - **PETG** is a good alternative if ASA is unavailable. Avoid PLA as it degrades under continuous UV exposure and high heat in summer.

### 2. Print Settings
- **Orientation:** Print flat on the build plate (Z-axis up, matching the OpenSCAD orientation).
- **Layer Height:** `0.15mm` to `0.20mm`.
- **Infill:** `30% - 50%` with a strong pattern (Gyroid or Grid).
- **Wall Loops:** at least `4` or `5` perimeters to make the screwless bracket extremely strong against shear forces.

### 3. Tape Application
- Use a high-quality outdoor double-sided tape (e.g., **3M VHB 4991** or similar conformable acrylic foam tape).
- Clean both the bottom of the printed stop and the board surface with **Isopropyl Alcohol (IPA)** before applying the tape.
- Apply firm pressure and allow **24 hours** for the adhesive to cure fully before mounting the box and hitting the water.
