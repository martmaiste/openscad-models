# M6 Bolt End Cap (Foil Track Protector)

A high-precision, parametric OpenSCAD model of a protective cap designed to screw onto the protruding end of M6 mast-mounting bolts. This prevents the metal bolt tip from digging into and damaging the bottom of your wing-foil track box (US box) when tightening your foil.

![Cross Section Preview](Bolt-End-Cap.png)

## Features

- **Mathematically Accurate Threads**: Real helical M6 internal threads modeled using a robust, triangulated polyhedron manifold that renders flawlessly in OpenSCAD's F6 CGAL engine.
- **Track-Safe Outer Profile**: A perfect 8mm round outer diameter with $1.0\text{mm}$ ($45^\circ$) outer chamfers on both the top and bottom to slide smoothly through the tracks without catching.
- **Self-Centering Entry**: The bottom chamfer naturally forms a tapered guide, making it effortless to align and screw onto your bolts.
- **3D Printing Optimized**:
  - Parametric thread clearance (default $+0.25\text{mm}$) to compensate for filament expansion.
  - Exactly $3\text{mm}$ of internal threads and $2\text{mm}$ of solid bottom material to cushion the bolt end.

## How to Customize & Print

1. Open `Bolt-End-Cap.scad` in [OpenSCAD](https://openscad.org/).
2. Adjust the parameters (e.g., `clearance` for your printer's tolerances, or `material_thickness` for more cushioning) in the Customizer panel.
3. Render (**F6**) and export as an **STL** (**F7**).
4. Slice and print!

### Recommended Print Settings
- **Material**: **PETG**, **ASA**, or **95A TPU** (semi-flexible TPU is ideal for cushioning and durability).
- **Layer Height**: `0.12mm` to `0.16mm` (smaller layer heights help resolve internal threads accurately).
- **Infill**: `100%` (solid) for maximum strength and protection.
- **Orientation**: Print with the flat chamfered bottom on the print bed (no supports needed).
