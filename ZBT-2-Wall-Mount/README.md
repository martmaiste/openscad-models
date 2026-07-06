# Home Assistant ZBT-2 Wall Mount (Parametric OpenSCAD Model)

A fully parametric, 3D-printable, high-performance wall-mount bracket designed specifically for the **Home Assistant Connect ZBT-2** Zigbee/Matter wireless gateway.

This project is customizer-ready and has been optimized for maximum structural integrity, clean cable management, and high visual fidelity.

---

## Device Specifications (Default)

The model is designed around the official physical dimensions of the Connect ZBT-2:
- **Base**: $83 \times 83$ mm square with highly rounded **$20$ mm corner radiuses** (creating a gorgeous "squircle" footprint).
- **Base Thickness**: $20$ mm.
- **Silicone Feet**: Has $4$ circular silicone feet at the bottom, **$1$ mm high** (the device sits elevated by $1$ mm, resting perfectly on its feet on the bracket's bottom shelf).
- **Antenna**: $160$ mm long, **$24$ mm diameter** cylindrical whip extending from the center of the base, ending in a **flat top face**.
- **Fillet Connection**: A smooth, curved **$23$ mm radius** concave fillet transition blending the base smoothly into the antenna.

---

## Wall Bracket Features

- **High-Back Wall Mounting (Recommended/Default)**:
  - Extends the back plate to **twice the pocket height** ($32$ mm).
  - Houses **two spaced countersunk screw holes** ($50$ mm spacing) directly in this back plate above the device pocket.
  - Slices the side and front walls diagonally, forming **triangular structural bracing gussets** that resist pulling forces while keeping screw installation 100% accessible to any screwdriver or drill from the front.
- **Front-Loading U-Slot**:
  - Features a **$74$ mm wide front cutout** that clears the $70$ mm diameter curved fillet transition.
  - Allows the device to slide vertically into the bracket from above, leaving the antenna completely unhindered while keeping the base locked in place securely on all sides with a solid $4.75$ mm lip.
- **Dual Side USB-C Ports**:
  - Features custom rounded-rectangle cutout clearance holes ($14 \times 8$ mm) on both the left and right side walls, centered exactly **$10$ mm from the bottom shelf**.
  - Allows you to easily plug in a USB-C power or data cable from either side, making your wall outlet setup fully versatile.
- **Universal Dual-Orientation Mounting**:
  - Features a **$71$ mm central hole** in the bottom shelf with a **$26$ mm front-loading slot** running to the front.
  - **Right Side Up Mounting**: The device sits in its standard orientation, resting on its $1$ mm silicone feet on the bottom shelf, with any cables routed cleanly downwards through the slot.
  - **Upside Down Mounting**: Slipped in upside down, the $24$ mm diameter antenna slides horizontally into the bottom shelf from the front. Because the curved $23$ mm fillet transition meets the base at a $70$ mm diameter ($2 \times [12\text{mm antenna radius} + 23\text{mm fillet radius}] = 70$ mm), sizing the bottom shelf hole at **$71$ mm** allows the entire fillet transition to pass completely through the bottom hole. This lets the **flat bottom of the $83 \times 83$ mm square base rest directly and flatly against the bottom shelf of the bracket!**
- **Additional Mounting Styles Supported**:
  - `ears_sides`: Horizontally aligned tabs with countersunk holes.
  - `ears_top_bottom`: Vertically aligned top/bottom tabs.
  - `flat`: A completely flat back wall, optimized for double-sided adhesive strips (e.g. Command strips).

---

## How to Customize in OpenSCAD

1. Open `ZBT-2-Wall-Mount.scad` in [OpenSCAD](https://openscad.org/).
2. On the right-hand panel, use the **Customizer** window to adjust:
   - **Render Options**: Toggle between `bracket` (renders only the wall mount for STL exporting), `device` (renders only the ZBT-2 device mock), or `assembly` (renders the device seated inside the bracket).
   - **Visual Lift**: Increase `assembly_device_lift` to visually "slide" the device out of the bracket.
   - **Tolerances & Walls**: Change `wall_thickness` or adjust slide-in `fit_tolerance` to match your printer's calibration.
   - **Screw Sizes**: Customize `screw_diameter` and `screw_head_diameter` to fit your specific mounting hardware.
3. Once satisfied, set the **Render Mode** to `bracket`.
4. Press `F6` to render, then click the **STL** icon to export your print file.

---

## 3D Printing Recommendations

- **Material**: PETG, ABS, or ASA are recommended for thermal resistance and durability, though PLA is perfectly fine for indoor wall mounting.
- **Orientation**: Print the bracket flat on its back (the back plate flat against the build plate). This requires **zero support structures** and maximizes the structural strength of the mounting holes and bracing.
- **Perimeters/Walls**: Use 3 walls (perimeters) for robust screw holes and solid bracing gussets.
- **Infill**: 15% to 20% infill is highly sufficient.
- **Layer Height**: `0.20mm` is recommended for clean vertical walls and sloped profiles.

---

## Versioning & Changelog

- **v0.11** (2026-07-06): Reinforced the default bottom shelf thickness `bottom_shelf_thickness` from 2.0mm to 4.0mm to provide extreme mechanical strength. This ensures the bracket easily holds the device's full resting weight in either orientation and fully resists cord tension.
- **v0.10** (2026-07-06): Calculated bottom hole clearance to allow flat-base resting. Sized the bottom shelf central hole to 71.0mm (which accommodates the 70.0mm outer diameter of the 23mm fillet transition). This allows the fillet to pass completely through, letting the flat part of the square base rest flatly against the bottom shelf of the bracket in both standard and upside-down mounting modes.
- **v0.09** (2026-07-06): Added Dual-Orientation upside-down mounting support by widening the bottom shelf's front-loading slot from 12mm to 26mm. This allows the 24mm diameter antenna to slide horizontally into the bottom shelf from the front, while its smooth 23mm fillet shoulder rests securely on the circular 30mm opening as a self-centering seat.
- **v0.08** (2026-07-06): Set default bracket pocket height `bracket_height` to 18.0mm, establishing a beautiful, low-profile reveal that leaves the top 2mm of the device's 20mm base and the elegant 23mm fillet curve fully exposed above the bracket walls.
- **v0.07** (2026-07-06): Updated default device base thickness to 20mm and set the bracket pocket height to 24mm to ensure snug vertical retention. Modeled 4 circular silicone feet (1mm high, 10mm diameter) on the bottom of the device mock and translated the main plastic body up by 1mm so it rests perfectly on its feet. Simplified the antenna to have a flat top circle face, removing the hemispherical tip.
- **v0.06** (2026-07-06): Complete simplification. Removed V1 stick support and streamlined the entire codebase to focus exclusively on a clean, dedicated, prefix-free design for the Connect ZBT-2.
- **v0.05** (2026-07-06): Added dual side-mounted USB-C cutout holes centered exactly at 10mm from the bottom shelf. Integrated high-fidelity silver and dark grey 3D representations of the USB-C side-ports into the visual ZBT-2 device mock.
- **v0.04** (2026-07-06): Added high-performance `high_back` mounting style as the new default. Extends the back plate to twice the pocket height and places countersunk screw holes inside it. Cuts the side walls diagonally to form structural bracing gussets, adding maximum resistance to bending while leaving screwdriving access fully unobstructed. Added the dynamic `back_screw_spacing` parameter.
- **v0.03** (2026-07-06): Adjusted default corner radius of the ZBT-2 square base to 20mm (yielding a beautiful "squircle" look). The wall bracket profile automatically tracks this and maintains constant thickness.
- **v0.02** (2026-07-06): Major design extension. Added support for the ZBT-2 form-factor with its 83x83mm square base, 160mm antenna, and a smooth 23mm fillet curve. Implemented a custom 2D-to-3D rotational fillet profiles module (`transition_fillet`) to construct a perfect high-fidelity mock. Added a front-loading U-slot bracket design for the v2 device.
- **v0.01** (2026-07-06): Initial release. Parametric pocket bracket with front viewing window and integrated cable channel for the v1 USB stick.

---

*Designed with ❤️ for the Home Assistant Community.*
