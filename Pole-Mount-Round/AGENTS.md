# Project: Pole-Mount-Round

This project focuses on the parametric design and generation of circular wall-mounted pipe/pole holders. The designs are implemented in OpenSCAD and exported as STL/3MF files for 3D printing.

## Agentic Workflow Overview

This project utilizes an agentic development workflow to maintain and evolve the parametric model. The core of the project is `Pole-Mount-Round.scad`.

### Project Structure
- `Pole-Mount-Round.scad`: The source OpenSCAD script containing all parametric logic.
- `Pole-Mount-Round-Open.*`: Exported assets for the "open" mount configuration.
- `Pole-Mount-Round-Closed.*`: Exported assets for the "closed" mount configuration.

### Agent Responsibilities

#### 1. CAD Engineer Agent
- **Task**: Modify `Pole-Mount-Round.scad` to implement new features or fix geometry issues.
- **Context**: Understands OpenSCAD syntax, CSG (Constructive Solid Geometry), and 3D printing constraints (chamfers, tolerances, screw hole clearances).
- **Constraints**: Maintain parameterization so users can easily change `pipe_diameter`, `disk_diameter`, and `block_thickness`.

#### 2. Validation Agent
- **Task**: Ensure the generated geometry is manifold and printable.
- **Checks**: 
    - Verify `$fn` resolution is sufficient for smooth circles.
    - Check that `screw_offset_padding` prevents thin walls.
    - Ensure `dowel_washer_recess` doesn't collide with screw head recesses for thin disks.

#### 3. Documentation Agent
- **Task**: Keep `AGENTS.md` and file metadata up to date.
- **Context**: Versioning (current: 1.16) and feature lists.

## Technical Parameters
Agents should be aware of the following key parameters in `Pole-Mount-Round.scad`:
- `mount_type`: Toggles between a full ring ("closed") and a U-bracket ("open").
- `universal_chamfer`: Controls the aesthetic and functional smoothing of edges.
- `screw_head_type`: Supports both `countersink` and `counterbore` mounting hardware.