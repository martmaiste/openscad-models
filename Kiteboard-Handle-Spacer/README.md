# Kiteboard Handle Spacer

A fully parametric OpenSCAD model of a kiteboard handle spacer designed to raise the grab handle by 40mm. This makes the board much easier to grab during board-offs, handle passes, or when carrying it.

The model features a **right-trapezoid side profile** (sloped on the outer face, vertical on the inner face) to seamlessly match the handle's aesthetics, and a **symmetrically-sloped end profile** with smooth rounded edges for ergonomics and safety.

![Rendered Spacer](view1.png)

## Dimensions

The model is configured with the following defaults (based on standard Crazyfly handles):
* **Spacer Height:** 40 mm (raises the handle)
* **Top Width:** 25 mm (along handle length)
* **Bottom Width:** 35 mm (along handle length)
* **Top Length:** 36 mm (transverse to handle)
* **Bottom Length:** 45 mm (transverse to handle)
* **Corner Radius:** 4 mm (vertical edges)
* **Bolt Hole Location:** 20 mm from the flat vertical inner face (fits M6 hardware)

## Files in this Repository

* **`Kiteboard-Handle-Spacer.scad`**: The main parametric OpenSCAD script.
* **`Kiteboard-Handle-Spacer.stl`**: A pre-rendered 3D STL file ready for slicing.
* **`view1.png`**: Preview image of the model.

## Customization

You can open `Kiteboard-Handle-Spacer.scad` in **OpenSCAD** and use the **Customizer panel** to easily adjust:
* Spacer height, length, and width dimensions.
* Bolt hole diameter and placement.
* Corner rounding radius (`corner_radius`).
* **Optional Counterbore:** Enable and configure a top recess for the screw heads/washers.

## Recommended 3D Print Settings

Kiteboarding gear experiences high structural loads, continuous UV exposure, and salt water. For maximum durability, use these settings:

* **Material:** **ASA** (highly recommended for superior UV resistance and strength) or **PETG**. *Avoid PLA*, as it degrades in direct sunlight and can warp in hot cars.
* **Orientation:** Print flat on the bottom face ($z = 0$). **No supports required.**
* **Wall Loops/Perimeters:** **4 or more** (critical for strength around the bolt hole).
* **Infill:** **30% - 40%** (using a strong 3D pattern like **Gyroid** or **Cubic**).

## Hardware Requirements

Since the spacer raises the handle by **40mm**, you will need to replace the original handle screws with longer M6 bolts:
* **Bolt Type:** M6 Marine-Grade Stainless Steel (A4 / 316 grade highly recommended).
* **Bolt Length:** Original Bolt Length + 40 mm.
