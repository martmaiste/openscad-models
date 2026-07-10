# Vertical D-Fruit USB HUB Wall Mount / Holder

A highly refined, fully parametric, and customizer-friendly vertical wall mount for the **D-Fruit USB Hub**. 

This sleek holder consists of two distinct, minimalist parts that securely cradle the hub's symmetrical curved $15.8 \times 8.4\text{ mm}$ aluminum profile while completely hiding all mounting screws behind the device.

![D-Fruit USB HUB Wall Mount Preview](preview.png)

---

## 🛠️ Design Features

* **Sleek Hidden-Screw Mount**: All screws are recessed inside the back walls of the internal pockets. When the hub is slid in, the mounting hardware is 100% invisible.
* **Seamless Outer Profile**: The outer body of both parts is designed using a 2D hull bridge. The side walls are perfectly flat and smooth, merging tangentially into the rounded front face with no notches, grooves, or joint lines.
* **Easy Installation Access**:
  * **Top Guide Collar ($20\text{ mm}$)**: Features an $8.7\text{ mm}$ front-access hole coaxial with the screw hole. You can slide the screw and screwdriver straight through the front wall to secure it. The inserted hub completely covers this hole.
  * **Bottom Support Cup ($15\text{ mm}$)**: Uses the front-facing slot as a natural access pathway for its mounting screw.
* **Split-Shelf & U-Shaped Cable Channel**: The bottom cup features left/right shelves ($3.8\text{ mm}$ wide) that support the hub, with a center U-shaped slot ($8.5\text{ mm}$ wide) centered exactly on the cable exit. This prevents any clipping into the curved back wall of the pocket and lets the 45-degree, $5\text{ mm}$ strain relief slide in friction-free.
* **Open-Port Accessibility**: The top collar is open at both ends, keeping the top USB-A socket fully usable. The $110\text{ mm}$ exposed middle section leaves all side USB ports completely unobstructed.

---

## ⚙️ Parametric Configurations (OpenSCAD Customizer)

You can easily adjust all variables inside the OpenSCAD Customizer panel:

| Parameter | Default Value | Description |
| :--- | :--- | :--- |
| `hub_width` | `15.8 mm` | Larger dimension of the hub cross-section |
| `hub_thickness` | `8.4 mm` | Symmetrical center thickness of the hub |
| `hub_face_radius`| `50.0 mm` | Curvature radius of the wider faces (`curved_lens`) |
| `hub_corner_radius`| `2.0 mm` | Corner radius of the narrow ends |
| `clearance_bottom`| `0.3 mm` | Tolerance in the bottom cup (snug rest) |
| `clearance_top` | `0.8 mm` | Tolerance in the top collar (easy slide-in/tilt) |
| `cable_slot_width`| `8.5 mm` | Width of the bottom U-shaped cable channel |
| `back_wall_thickness`| `6.0 mm` | Rear wall thickness supporting recessed screw head |
| `screw_diameter` | `3.5 mm` | Mounting screw shaft diameter |
| `screw_head_diameter`| `7.5 mm` | Mounting screw head pocket diameter |

---

## 🖨️ 3D Printing Guidelines

To achieve the best results, use the following print settings:

* **Slicer Orientation**:
  * **Bottom Cup**: Prints upright in its default orientation.
  * **Top Collar**: **Flipped automatically in the script** (`part = "top"` or `part = "both"`). The completely flat top lip sits on the print bed, placing the flared guide chamfer at the top of the print. This guarantees **excellent bed adhesion** and a **completely support-free print** (as the flared entry prints as a clean $45^\circ$ self-supporting overhang!).
* **Supports**: **Disabled** (100% support-free design).
* **Layer Height**: `0.2 mm` (or `0.15 mm` for a smoother curve resolution).
* **Infill**: `20% - 30%` (Gyroid or Grid recommended for structural strength).
* **Wall Lines**: `3` minimum (to ensure the screw pockets and vertical walls are solid and strong).
* **Material**: **PETG** (recommended for toughness and slight flexibility) or **PLA**.

---

## 🚀 How to Use in OpenSCAD

1. Open `D-Fruit-USB-HUB-Holder.scad` in OpenSCAD.
2. In the **Render Options / part** customizer dropdown, select:
   * `preview`: To inspect the complete assembly vertically mounted on the wall with a 3D model of your hub.
   * `bottom`: To export the bottom cup for printing.
   * `top`: To export the top collar for printing.
   * `both`: To render both parts side-by-side on the build plate for a single-print run.
3. Press `F6` to render, then click `STL` to export your files!
