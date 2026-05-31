========================================================================
PARAMETRIC RAYFOIL E-FOIL MAST SUPPORT STAND & MOTOR CRADLE
========================================================================
Version: v0.15
Author: Zed AI Coding Agent

This project contains a parametric, fully-customizable OpenSCAD design
for a multi-functional RayFoil e-foil mast support stand.

------------------------------------------------------------------------
1. PROJECT STRUCTURE
------------------------------------------------------------------------
* RayFoil-Stand.scad (v0.15)
  The main 3D-printable mast support block. Includes built-in vertical
  mounting holes and double-sided horizontal cradles.

------------------------------------------------------------------------
2. DESIGN FEATURES
------------------------------------------------------------------------
* Multi-Functional Dual Cradles:
  - Top face (ears) has a smooth horizontal cradle (radius 250mm) to hold
    a propeller guard or mast base curve.
  - Bottom face (flat back) has a vertical cylinder cutout (radius 32.75mm)
    to act as a horizontal cradle for a standard 65.5mm e-foil motor.

* Parametric Mast Profile:
  An analytically scaled curve (utilizing nose_roundness = 1.8) that
  guarantees a perfect, flush hug of your RayFoil mast based on custom
  thickness and depth measurements.

* Support-Free 3D Printing:
  The file is pre-oriented to lie flat on the print bed for optimal,
  support-free FDM printing.

* Clearance Bolt Holes:
  Vertical counterbored slots for M6 bolts allow you to flush-bolt the
  stand to a board or trailer floor.

------------------------------------------------------------------------
3. CUSTOMIZER SETTINGS (RayFoil-Stand.scad)
------------------------------------------------------------------------
Open the .scad file in OpenSCAD and modify these parameters on the fly:

--- Render Options ---
* part_to_render: Select "stand" to view/export the 3D block, or "profile"
  to view the 2D mast cross-section template.

--- Mast Dimensions ---
* mast_thickness (Default: 35mm): Max thickness of your mast.
* mast_chord (Default: 140mm): Total chord length.

--- Calibration ---
* max_t_pos (Default: 65mm): How far back from the front nose the mast
  is at its maximum thickness.
* measured_dist (Default: 40mm): Point along the chord where you took
  a physical measurement.
* measured_thickness (Default: 29.5mm): The actual measured thickness
  at measured_dist.
* nose_roundness (Default: 1.8): Sharpness of the leading nose (1.0 is
  wedge, 2.0 is rounded ellipse).

--- End Cutouts ---
* add_side_cutouts (Default: true): Toggle the curved side-cradles.
* top_cyl_radius (Default: 250.0mm): Curvature radius for the propeller
  guard clearance on the top ears.
* bottom_cyl_radius (Default: 32.75mm): Curvature radius for the motor
  casing on the bottom flat back.
* side_cutout_depth (Default: 5mm): Depth of both cutout pockets.

------------------------------------------------------------------------
4. 3D PRINTING RECOMMENDATIONS
------------------------------------------------------------------------
* Material: PETG, ABS, or TPU (recommended for a soft, non-scratching
  grip on your mast).
* Infill: 20-30% Gyroid or Grid infill for strong structural rigidity.
* Walls/Perimeters: 4 or 5 walls to ensure the side ears and mounting
  holes are solid.
* Supports: None required. The file is fully optimized to print flat.
========================================================================
