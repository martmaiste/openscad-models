# Slug Trap

A printable slug trap in two parts (base + lid), designed in OpenSCAD. A fermenting sugar-and-yeast mixture in the central cup lures slugs in through the low entry doors, where they eat indigestible ironmax pellets. The raised door sill keeps rain out, the lid screws on with a watertight 90° manifold thread, and a 7 mm central hole lets you stake the trap to the ground with a nail.

Shop: <https://taaralabs.eu/limuka-timukas>

Video: <https://youtu.be/3ELC7s2WZh4>

## Gallery

![Base and lid render](Slug-Trap.png)

_Base and lid render_

![Trap placed on leaf litter](Slug-Trap-1.jpg)

_Trap in the garden_

![Base with blue pellets, lid off](Slug-Trap-2.jpg)

_Base loaded with pellet bait_

![Assembled trap on grass](Slug-Trap-3.jpg)

_Assembled on the lawn_

## How it works

1. **Lure** — a sugar + yeast mix in the central ferment cup (55 mm Ø) starts fermenting on the moisture in the air, and the smell lures the slugs in.
2. **Bait** — they enter through the doors and start eating the indigestible ironmax pellets instead.
3. **Goodbye** — they return home, go to sleep, and never return.

- **Base** — 120 mm outer diameter, 35 mm tall, 3 mm walls. Pentagonal entry doors (24 × 18 mm) sit on an 8 mm door sill that blocks rain; the pellet floor slopes down toward the central ferment cup and drains through 2 mm holes.
- **Lid** — screw-on cap with a matching internal thread (3 mm pitch, 1.5 mm depth, 45°/45° symmetric tooth).
- **Grounding** — a 7 mm hole runs through the base's central tube and the lid, so a nail can be driven through to anchor the trap.

## Files

| File | Description |
| --- | --- |
| `Slug-Trap.scad` | OpenSCAD source (v3.48, 3rd major version) |
| `Slug-Trap-base.stl` / `Slug-Trap-lid.stl` | Ready-to-print STL files |
| `Slug-Trap.png` | Render of base and lid |
| `Slug-Trap-{1,2,3}.jpg` | Photos of a printed trap in use |
| `v1/`, `v2/` | Older design revisions |

## Preview in OpenSCAD

Set `view_mode` at the top of `Slug-Trap.scad`:

- `"base"` — base only
- `"lid"` — lid only
- `"both"` — base and lid side-by-side (default)
- `"assembled"` — assembled
- `"cut"` — assembled cross-section

## License

MIT — see [LICENSE](LICENSE).
