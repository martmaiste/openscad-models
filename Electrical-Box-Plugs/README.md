# Parametric Electrical Box Plugs and Nuts

A fully parametric, 3D-printing optimized OpenSCAD model to generate watertight blanking plugs and matching nuts for closing empty holes in electrical junction boxes.

![Electrical Box Plug & Nut Preview](Electrical-Box-Plugs.png)

---

## 🛠️ Key Mechanical & Design Features

* **360° Polar-Wedge Sawtooth Threads:** Built using a mathematically precise polar-wedge sweep. Unlike typical 2D Cartesian sweeps which result in unprintable, paper-thin threads, this method maps angular widths directly to axial pitch. It produces a **continuous, sharp sawtooth V-thread profile** (with a flat root and sharp crest width of exactly $0.5 \times \text{pitch}$) that perfectly matches standard industrial Metric and PG fittings.
* **100% Support-Free Printing (Zero Overhangs):**
  * **The Plug** is printed **head-down, thread-up**. Its wide, flat hexagonal head sits flat on the build plate for maximum bed adhesion. The thread rises vertically, requiring zero support material.
  * **The Nut** is printed **flange-down, hex-up**. The flat circular sealing flange sits directly on the build plate, ensuring the mating face is printed perfectly flat with no overhangs.
* **Watertight Gasket Retention:** 
  * **Plug Recess:** Features an optional circular seal recess on the underside of the hex head to hold rubber O-rings or flat gaskets, preventing them from squeezing outwards under tension.
  * **Nut Flange:** Features an integrated round circular flange on the flat mating face. This flange acts as a built-in washer face, distributing clamping force evenly across gaskets and preventing sharp hex corners from pinching or tearing the rubber when tightened.
* **Ergonomics & Ergonomic Bevels:**
  * **Rounded Corners:** Vertical hex flats have a customizer-controlled corner-rounding radius (default $1.0\text{ mm}$), making handling highly comfortable. Wrench sizing remains 100% exact.
  * **Horizontal Edge Chamfers:** The top and bottom horizontal faces of the hexagon are beveled at $45^\circ$, removing sharp lips and creating beautiful circular arches on the flats (identical to professional machined fasteners).

---

## 📐 Supported Size Profiles

The file contains pre-defined profiles for common electrical conduit fitting sizes. Selecting a profile automatically sets the thread diameter ($D$), pitch ($P$), sealing width, and wrench size:

| Profile | Thread Diameter ($D$) | Thread Pitch ($P$) | Sealing Flange Dia | Hex Wrench size | Use Case |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **M12** | 12.0 mm | 1.500 mm (Fine) | 16 mm | 14 mm | M12 Gland Hole |
| **M16** | 16.0 mm | 1.500 mm (Fine) | 20 mm | 18 mm | M16 Gland Hole |
| **M20** | **20.0 mm** | **1.500 mm (Fine)** | **25 mm** | **22 mm** | **Standard M20 Junction Box** |
| **M25** | 25.0 mm | 1.500 mm (Fine) | 30 mm | 27 mm | M25 Gland Hole |
| **M32** | 32.0 mm | 1.500 mm (Fine) | 38 mm | 34 mm | M32 Gland Hole |
| **PG7** | 12.5 mm | 1.270 mm | 16 mm | 14 mm | PG7 Hole |
| **PG9** | **15.2 mm** | **1.411 mm (18 TPI)** | **19 mm** | **17 mm** | **PG9 Junction Box Hole** |
| **PG11**| 18.6 mm | 1.411 mm (18 TPI) | 23 mm | 20 mm | PG11 Hole |
| **PG13.5**| 20.4 mm| 1.411 mm (18 TPI) | 25 mm | 22 mm | PG13.5 Hole |
| **PG16**| 22.5 mm | 1.411 mm (18 TPI) | 27 mm | 24 mm | PG16 Hole |
| **PG21**| 28.3 mm | 1.588 mm (16 TPI) | 34 mm | 30 mm | PG21 Hole |
| **Custom**| User Defined | User Defined | User Defined | User Defined | Fully custom dimensions |

---

## ⚙️ Customization (OpenSCAD Customizer)

1. Open `Electrical-Box-Plugs.scad` in [OpenSCAD](https://openscad.org/).
2. Open the **Customizer** panel on the right.
3. Configure your variables:
   * **`part`**: Choose to render `plug`, `nut`, or `both` side-by-side.
   * **`size_profile`**: Select one of the pre-loaded profiles or set to `Custom`.
   * **`clearance`**: Adjust the thread clearance for the nut's internal thread (default `0.3mm` is highly recommended for FDM).
   * **`seal_recess`**: Toggle the gasket groove on/off.
   * **`corner_rounding` & `edge_chamfer`**: Tweak the hex aesthetics and comfort.

---

## 🖨️ 3D Printing Recommendations

* **Material:** PETG or ASA are highly recommended for electrical boxes (PETG is chemical/UV resistant and slightly elastic, which improves thread sealing and strength).
* **Layer Height:** `0.15mm` or `0.20mm`. Fine layer heights are recommended to print smooth, high-accuracy threads.
* **Perimeters (Walls):** At least `3` or `4` walls to ensure the threads are solid and leakproof.
* **Infill:** `30% - 50%` Gyroid or Grid.
* **Supports:** **None (Disable supports).** The models are engineered to print completely support-free.
* **Sealing:** For IP65/IP68 watertight seals, place a flat neoprene or rubber gasket into the plug's recess (or flush against the nut flange) before tightening.
