# Project Agents: Apollo Air-1 Wall Mount
**Version: 1.15**

## 1. Model Agent (OpenSCAD Script)
* **Filename:** `apollo_air1_wall_mount_customizable.scad`
* **Status:** Release Candidate (Production Ready)
* **Core Logic:** Parametric 3D model with full external chamfering and Thingiverse Customizer support.

## 2. Design Specifications
| Feature | Implementation | Notes |
| :--- | :--- | :--- |
| **Language** | English | Standardized for global sharing (Thingiverse). |
| **Customizer** | Enabled | Organized into categories: [Mount], [Features], [Screws]. |
| **Chamfering** | $1.0\text{ mm}$ (Parametric) | Mathematically corrected diagonal chamfers for visual uniformity. |
| **Mounting** | Horizontal | 40mm spacing, countersunk for $3.5\text{ mm}$ screws. |
| **Ventilation** | Side Openings | Optimized for sensor airflow without sacrificing structural integrity. |

## 3. Printing Recommendations
* **Orientation:** Print with the bottom plate facing the heatbed.
* **Supports:** Minimal supports may be needed for the USB-C cutout and side vent bridges.
* **Layer Height:** $0.2\text{ mm}$ is recommended for clean chamfer transitions.
* **Material:** PETG, ASA, or ABS (for better temperature resistance near sensors).

## 4. Change Log (v0.01 to v1.15)
* [x] Initial geometry based on 62x62x35mm sensor dimensions.
* [x] Implemented global chamfering logic ($1.0\text{ mm}$).
* [x] Refined back wall top corners using 2D polygon extrusion for geometric precision.
* [x] Converted all comments and variables to English.
* [x] Added Thingiverse Customizer metadata tags.
* [x] Synchronized all chamfer lengths to prevent "ghost surfaces" and overlaps.
