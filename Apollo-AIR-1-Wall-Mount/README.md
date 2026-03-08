# OpenSCAD Benchmark Task: Apollo Air-1 Parametric Wall Mount

## 1. Project Overview
Create a fully parametric, customizable wall mount for the **Apollo Air-1** air quality sensor. The final script must be compatible with the **Thingiverse Customizer**.

## 2. Dimensional Requirements
The design must be based on the following default sensor dimensions:
- **Sensor Size:** 62mm (W) x 62mm (H) x 35mm (D).
- **Mount Height:** The internal cavity must cover exactly half of the sensor's height (31mm).
- **Wall Thickness:** Default is 3mm.
- **Tolerance:** Use a variable `tol = 0.25` for a total internal offset of 0.5mm.

## 3. Structural Components
- **Back Wall:** A vertical plate for mounting to a wall.
- **Base Plate:** A horizontal floor with a central cutout for USB-C cable access (22mm side margins).
- **Side Walls:** Vertical sides with large rectangular ventilation cutouts to ensure sensor airflow.
- **Front Grips:** Two vertical "lips" (15mm high) to hold the sensor in place, with a center gap (10mm grip zone) for visibility.

## 4. Mounting Hardware
- **Screw Holes:** Two horizontal holes in the back wall.
- **Positioning:** 40mm apart, centered on the Y-axis.
- **Geometry:** Countersunk for 3.5mm screws (6.5mm head diameter, 2.0mm head depth).

## 5. Geometric Challenge: The Chamfering System
The most critical part of this task is the implementation of a professional **1.0mm chamfer** on all external edges. The model must NOT use `minkowski()`.

### Technical Chamfer Specifications:
1. **Visual Uniformity:** All chamfers must appear identical at 45-degree angles.
2. **Back Wall Top Corners:** Only the two top outer corners of the back wall should be chamfered. Use a 2D `polygon()` with `linear_extrude()` to ensure the diagonal is mathematically corrected ($ch \times 1.414$) to match the visual width of 3D-cut chamfers.
3. **Front Frame:** Chamfer the top, bottom, and vertical outer edges of the front grips.
4. **Side Rails:** Chamfer the top and bottom outer horizontal edges of the side walls.
5. **Precision:** Chamfers must meet perfectly at the corners. The "cutter" cubes used for `difference()` must be carefully positioned to avoid cutting into the back wall's flat mounting surface or leaving "ghost surfaces."

## 6. Code Architecture
- **Language:** English.
- **Thingiverse Customizer:** All user-adjustable variables must be at the top with appropriate comments.
- **Cleanliness:** Use modules for repetitive elements (e.g., screw holes). Use `union()` and `difference()` efficiently.
- **Resolution:** Set `$fn = 64` for high-quality circular elements.

## 7. Expected Outcome
A robust, error-free `.scad` file where any parameter (wall thickness, chamfer size, sensor dimensions) can be changed without breaking the edge-chamfering logic or causing geometric overlaps.
