# Symmetrical Ergonomic Faucet Valve Handle

A highly ergonomic, fully parametric, and 3D-printable faucet valve handle designed to fit over an existing hard-to-turn **21.5mm hexagonal metal valve knob**. It expands the outer diameter to **50mm** and provides comfortable finger lobes, giving you high leverage and making the faucet effortless to turn.

![Faucet Valve Handle](Faucet-Valve-Handle.png)

---

## 🌟 Features

- **Ergonomic 5-Lobe Profile**: Symmetrical circular lobes spread torque evenly across fingers, providing maximum grip with minimal effort.
- **Double-Sided Chamfering**: Features a 1.5mm 45° chamfer on both the top and bottom outer edges, eliminating sharp corners and preventing "elephant's foot" on your first layer.
- **Hot/Cold Indicator Inlay**: A central **12.0mm through-hole** is designed to hold standard colored snap-in caps (red/blue inserts).
- **Dual-Sided Hole Chamfers**: The center hole features a 1.0mm 45° chamfer on both the top face (for easy cap insertion) and the bottom face (for clean, support-free printing bridges).
- **100% Support-Free Printing**: Designed to print perfectly flat-face down without any supports or overhang issues.
- **Robust Parametric Customizer**: Fully annotated and ready for OpenSCAD's Customizer GUI. You can easily adjust the socket diameter, clearance tolerances, lobe count, height, and chamfer sizes to match any valve.

---

## 🛠️ Parameters

| Parameter | Default Value | Description |
| :--- | :---: | :--- |
| `outer_diameter` | `50.0 mm` | Sizing of the outer handle grip |
| `handle_height` | `20.0 mm` | Thickness of the handle |
| `chamfer_height` / `width` | `1.5 mm` | Top & bottom outer edge bevels |
| `num_lobes` | `5` | Number of ergonomic finger grips |
| `hex_flat_to_flat` | `21.5 mm` | Parallel face distance of your hex stem |
| `socket_depth` | `14.0 mm` | Insertion depth of the hex socket |
| `socket_clearance` | `0.3 mm` | Print tolerance buffer for a perfect press-fit |
| `center_hole_dia` | `12.0 mm` | Through-hole for snap-in red/blue indicator cap |
| `hole_chamfer` | `1.0 mm` | Taper on both sides of the central hole |

---

## 🖨️ 3D Printing Guidelines

- **Orientation**: Place flat-bottom down (default orientation).
- **Supports**: **Disabled** (Not required).
- **Walls/Perimeters**: **4 to 6 loops** (highly recommended to ensure strong mechanical parts under torque).
- **Infill**: **35% - 50%** (Gyroid, Grid, or Honeycomb pattern).
- **Filament**: PETG, ASA, or ABS are recommended for faucet/bathroom environments due to moisture and temperature resistance, though PLA works perfectly for indoor, low-temperature use.
