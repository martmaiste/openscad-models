#!/usr/bin/env python3
"""
Thumbnail Gallery Generator for OpenSCAD files
This script generates thumbnail gallery files from OpenSCAD .scad files
and their associated .png renderings.
"""

import os
import subprocess
from pathlib import Path

VERSION = "0.14"


def generate_assets():
    """Generate PNG assets from SCAD files if they don't exist."""
    current_dir = Path.cwd()
    scad_files = []

    print(f"Starting rendering from directory: {current_dir}")

    for root, dirs, files in os.walk(current_dir):
        # Ignore hidden directories
        dirs[:] = [d for d in dirs if not d.startswith(".")]

        for file in files:
            if file.endswith(".scad"):
                full_path = Path(root) / file
                scad_files.append(full_path)

                png_path = full_path.with_suffix(".png")

                # Render only if image doesn't exist
                if not png_path.exists():
                    print(f"Rendering high quality: {png_path.name}")
                    try:
                        subprocess.run(
                            [
                                "openscad",
                                "-o",
                                str(png_path),
                                "--render",
                                "--imgsize=1200,1200",
                                "--colorscheme=Solarized",
                                str(full_path),
                            ],
                            check=True,
                            capture_output=True,
                        )
                    except subprocess.CalledProcessError as e:
                        print(f"Error rendering {file}: {e}")
                else:
                    print(f"Using cached image: {png_path.name}")

    # Sort by modification time (newest first)
    scad_files.sort(key=lambda x: x.stat().st_mtime, reverse=True)
    return scad_files, current_dir


def create_thumbnail_html(scad_files, base_dir):
    """Create HTML thumbnail gallery."""
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>OpenSCAD Thumbnail Gallery v{VERSION}</title>
    <style>
        body {{
            font-family: sans-serif;
            background: #1a1a1a;
            color: #eee;
            padding: 20px;
            margin: 0;
        }}
        .gallery {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
        }}
        .card {{
            background: #2c2c2c;
            border-radius: 12px;
            overflow: hidden;
            transition: transform 0.2s;
            border: 1px solid #444;
            text-align: center;
        }}
        .card:hover {{
            transform: translateY(-5px);
            border-color: #666;
        }}
        .card img {{
            width: 100%;
            aspect-ratio: 1/1;
            object-fit: cover;
            display: block;
        }}
        .card-info {{
            padding: 12px 8px;
            font-size: 13px;
            color: #ccc;
            word-break: break-word;
            min-height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        h1 {{
            text-align: center;
            margin-bottom: 30px;
        }}
        @media (max-width: 768px) {{
            .gallery {{
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 10px;
            }}
        }}
    </style>
</head>
<body>
    <h1>OpenSCAD Thumbnail Gallery v{VERSION}</h1>
    <div class="gallery">
"""

    for scad_path in scad_files:
        rel_png = scad_path.with_suffix(".png").relative_to(base_dir)
        rel_scad = scad_path.relative_to(base_dir)
        # Clean file name for display (remove .scad extension and replace dashes with spaces)
        clean_name = rel_scad.name.replace(".scad", "").replace("-", " ")
        html_content += f"""
        <div class="card">
            <a href="{rel_png}" target="_blank">
                <img src="{rel_png}" loading="lazy" alt="{rel_scad}">
            </a>
            <div class="card-info">{clean_name}</div>
        </div>
    """

    html_content += """
    </div>
</body>
</html>
"""
    (base_dir / "index.html").write_text(html_content, encoding="utf-8")
    print("Generated index.html with thumbnail gallery")


def create_thumbnail_markdown(scad_files, base_dir):
    """Create Markdown thumbnail gallery without tables to avoid alternating backgrounds."""
    markdown_content = f"""# OpenSCAD Thumbnail Gallery v{VERSION}

This gallery contains all OpenSCAD designs in this repository with their visual representations.

## Gallery

<div style="display: flex; flex-wrap: wrap; gap: 15px; justify-content: flex-start;">
"""

    # We use inline-block divs instead of a table.
    # This automatically wraps items to the next line and completely avoids zebra-striping.
    for scad_path in scad_files:
        rel_png = scad_path.with_suffix(".png").relative_to(base_dir)
        rel_scad = scad_path.relative_to(base_dir)
        clean_name = rel_scad.name.replace(".scad", "").replace("-", " ")

        markdown_content += (
            f'<div style="display: inline-block; width: 250px; margin: 10px; vertical-align: top; text-align: center;">\n'
            f'  <a href="{rel_png}">\n'
            f'    <img src="{rel_png}" alt="{clean_name}" width="250" height="250" style="width: 250px; height: 250px; object-fit: cover; border-radius: 12px; margin: 0 auto; display: block;">\n'
            f"  </a>\n"
            f'  <div style="margin-top: 12px; font-size: 14px; word-wrap: break-word; text-align: center;">{clean_name}</div>\n'
            f"</div>\n"
        )

    markdown_content += "</div>\n"

    # Write the markdown file
    (base_dir / "README.md").write_text(markdown_content, encoding="utf-8")
    print("Generated README.md with pure HTML div-based gallery")


if __name__ == "__main__":
    scad_list, base_path = generate_assets()
    if scad_list:
        create_thumbnail_html(scad_list, base_path)
        create_thumbnail_markdown(scad_list, base_path)
        print(f"Successfully created thumbnail gallery files in {base_path}")
    else:
        print("No .scad files found in this directory or subdirectories.")
