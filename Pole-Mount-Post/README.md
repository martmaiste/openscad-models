# Parametric Symmetrical Dual-Pipe Pole Mount

This project provides a fully parametric, 3D-printable OpenSCAD design for a robust dual-pipe pole mount. 

## Purpose

The primary function of this model is to securely attach two horizontal pipes to a single vertical post. It works as a symmetrical clam-shell clamp: you print two identical halves and bolt them together around the post. Because both sides of the printed part are identical, each half of the clamp natively provides one pipe socket, resulting in a dual-pipe configuration when fully assembled.

## Features

- **100% Symmetrical Design:** Only one unique part is required. Print it twice, flip one over, and they fit together perfectly.
- **Continuous Cylindrical Profile:** When bolted together, the exterior outline forms a sleek, continuous cylinder that neatly hugs the post.
- **Chamfered Edges:** Top and bottom outer edges are beveled at 45 degrees to remove sharp corners and improve aesthetics, while maintaining the ability to print perfectly flat without supports.
- **Auto-Locking Hex Nut Sockets:** The design features a round counterbored hole on one flange and a hexagonal channel on the opposite flange. When the two identical halves face each other, the round holes align with the hex channels, allowing standard M6 nuts to drop in and lock against spinning while tightening.
- **Fully Parametric:** Entirely driven by OpenSCAD variables. Changing the pipe or post diameter mathematically updates the structural dimensions, wall thicknesses, and chamfers automatically.

## Default Dimensions

* **Vertical Post Diameter:** 89mm
* **Horizontal Pipe Diameter:** 30mm
* **Pipe Socket Depth:** 20mm
* **Fasteners:** Two M6 bolts and nuts
* **Overall Clamped Diameter:** 149mm
* **Overall Height:** 50mm

## Printing Guidelines

1. **Orientation:** The STL should be printed standing upright on its flat bottom edge.
2. **Supports:** Standard build supports are recommended for the horizontal 30mm pipe sockets and the tops of the counterbored bolt/nut channels.
3. **Infill / Walls:** High wall counts (e.g., 4 to 6 perimeters) and high infill (30-50% cubic or gyroid) are recommended for mechanical strength.
4. **Material:** PETG, ASA, or ABS is recommended, particularly if the mount will be used outdoors. 

## Customization

To modify the model, open `Pole-Mount-Post.scad` in OpenSCAD. Edit the variables in the `--- Core Parameters ---` section at the top of the script.
