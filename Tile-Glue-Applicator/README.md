# Parametric Tile Glue Applicator

A fully parametric, 3D-printable glue applicator/scraper designed for spreading adhesive when laying ceramic tiles. This project uses OpenSCAD, allowing you to easily customize the dimensions to suit specific tile sizes, glue types, and ergonomic preferences.

## Version
**Current Version:** v0.04

## Features

- **Fully Parametric:** Easily modify all key dimensions via variables or the OpenSCAD Customizer.
- **Auto-Adjusting Width:** The scraper width automatically calculates the perfect dimension to ensure both ends finish with a solid tooth instead of a void.
- **Rounded Teeth:** The corners of the teeth are automatically rounded by 10% of the tooth width for better stress distribution and durability.
- **Adjustable Teeth:** Configure the height, width, and spacing of the teeth to control the amount of adhesive applied.
- **Hanging Hole:** Convenient hole near the top edge for storage on a pegboard or hook.
- **Support-Free Printing:** The completely flat design prints effortlessly flat on the print bed (Z=0), ensuring an easy, support-free printing experience.

## Default Specifications (v0.04)

- **Target Scraper Width:** 100 mm (actual width auto-adjusts to fit whole teeth)
- **Scraper Height:** 80 mm
- **Blade Thickness:** 2.0 mm
- **Tooth Height:** 5.0 mm
- **Tooth Width:** 5.0 mm
- **Tooth Spacing (Gap):** 5.0 mm

## Prerequisites

To view and customize the source files, you need:
- [OpenSCAD](https://openscad.org/) (version 2021.01 or newer recommended)

## Usage

### Customizing the Design

1. Open `Tile-Glue-Applicator.scad` in OpenSCAD.
2. Open the **Customizer** pane (`Window` -> `Customizer`).
3. Adjust the parameters to your liking:
   - **Main Dimensions:** Change the target overall width, height, and blade thickness.
   - **Teeth Configuration:** Modify the tooth height, width, and spacing to match the requirements of your specific tile adhesive.
   - **Hole Configuration:** Adjust the hanging hole diameter and its distance from the top edge.
4. Press `F5` to preview your changes.

### Exporting for 3D Printing

1. Once you are satisfied with the design, press `F6` to render the geometry. (This may take a few seconds depending on the complexity).
2. Press `F7` (or go to `File` -> `Export` -> `Export as STL/3MF`) to save the 3D model.

## 3D Printing Recommendations

- **Orientation:** Print the model flat on the build plate.
- **Material:**
  - **PETG, ABS, or ASA** are highly recommended due to their durability, flexibility, and resistance to wear.
  - **PLA** can be used for light DIY projects or single-use scenarios, but its brittleness means the teeth may wear down or snap off more easily during heavy use.
- **Slicer Settings:**
  - **Perimeters (Walls):** Increase the number of perimeters (e.g., 4 to 6) to increase the stiffness of the blade and the durability of the teeth.
  - **Infill:** 15-20% is generally sufficient, as the strength primarily comes from the perimeters.
  - **Supports:** None required.

## License

This project is open-source. You may use, modify, and distribute it freely.