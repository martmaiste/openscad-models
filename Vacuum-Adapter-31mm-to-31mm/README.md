# Parametric Vacuum Adapter

A fully parametric, 3D-printable vacuum hose adapter designed in OpenSCAD. This adapter is optimized to connect hoses, nozzles, and tools securely. It features dual-tapered ends to ensure a tight friction fit, a central flange (stop ring) to prevent slipping, and internal lead-in chamfers for smooth airflow and support-free printing.

![Vacuum Adapter Preview](Vacuum-Adapter-31mm-to-31mm.png)

## Features

- **Fully Parametric:** Easily customize the diameters, length, wall thickness, and taper using OpenSCAD's customizer to match any specific hose or tool dimension.
- **Airflow-Optimized:** Internal chamfers reduce airflow resistance and turbulence.
- **Support-Free Printing:** Designed to be printed standing vertically without requiring support material.
- **Central Stop Ring:** A solid flange limits insertion depth and makes it easy to install and remove.

## Default Dimensions

The preconfigured model (`Vacuum-Adapter-31mm-to-31mm.stl` / `.scad`) uses the following default dimensions:

| Parameter | Default Value | Description |
| :--- | :--- | :--- |
| **Base Diameter** | `32.0 mm` | The exact inner/outer mating diameter. |
| **Wall Thickness** | `2.5 mm` | Strength of the shell. |
| **Insertion Length** | `30.0 mm` | How deep the adapter slides into each side. |
| **Taper Amount** | `1.0 mm` | The decrease in diameter towards the ends to ensure a snug fit. |
| **Flange Diameter** | `40.0 mm` | Outer diameter of the middle stop ring. |
| **Flange Thickness** | `3.0 mm` | Width of the middle stop ring. |
| **Bevel Size** | `1.5 mm` | Chamfer size for airflow smoothing and lead-in. |

## How to Customize

1. Open `Vacuum-Adapter-31mm-to-31mm.scad` in **OpenSCAD**.
2. Adjust the variables in the **Customizer panel** on the right (e.g., change `Base_Diameter` to fit your specific tools).
3. Render the model (`F6`).
4. Export as STL (`F7`) and slice for 3D printing.

## 3D Printing Recommendations

- **Orientation:** Print vertically (no supports required).
- **Infill:** 100% infill or high wall count (at least 3-4 perimeters) for maximum strength and an airtight seal.
- **Material:** PETG, ABS, or ASA are recommended for durability and impact resistance, though PLA works perfectly fine for general workshop use.
