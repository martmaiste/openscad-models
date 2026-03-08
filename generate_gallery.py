import os
import subprocess
from pathlib import Path

VERSION = "0.04"

def generate_assets():
    current_dir = Path.cwd()
    scad_files = []
    
    print(f"Alustan renderdamist kaustas: {current_dir}")

    for root, dirs, files in os.walk(current_dir):
        # Ignoreerime peidetud kaustu
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        for file in files:
            if file.endswith(".scad"):
                full_path = Path(root) / file
                scad_files.append(full_path)
                
                png_path = full_path.with_suffix(".png")
                
                # Renderdame ainult siis, kui pilti veel pole
                if not png_path.exists():
                    print(f"Renderdan (kvaliteetne): {png_path.name}")
                    try:
                        subprocess.run([
                            "openscad", 
                            "-o", str(png_path), 
                            "--render",
                            "--imgsize=1200,1200", 
                            "--colorscheme=Solarized",
                            str(full_path)
                        ], check=True, capture_output=True)
                    except subprocess.CalledProcessError as e:
                        print(f"Viga renderdamisel {file}: {e}")
                else:
                    print(f"Sain pildi vahemälust: {png_path.name}")

    return sorted(scad_files), current_dir

def create_index_html(scad_files, base_dir):
    html_content = f"""
    <!DOCTYPE html>
    <html lang="et">
    <head>
        <meta charset="UTF-8">
        <title>OpenSCAD Detailne Vaade v{VERSION}</title>
        <script src="https://cdn.jsdelivr.net/npm/markdown-it@13.0.1/dist/markdown-it.min.js"></script>
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #fdfdfd; padding: 20px; color: #333; }}
            nav {{ background: #eee; padding: 10px; border-radius: 5px; margin-bottom: 20px; }}
            nav a {{ margin-right: 15px; text-decoration: none; color: #007acc; font-weight: bold; }}
            table {{ width: 100%; border-collapse: collapse; background: white; }}
            th, td {{ border: 1px solid #e0e0e0; padding: 15px; vertical-align: top; }}
            th {{ background: #f5f5f5; position: sticky; top: 0; z-index: 100; }}
            .scad-code {{ background: #1e1e1e; color: #d4d4d4; padding: 12px; max-height: 500px; overflow: auto; white-space: pre; font-family: 'Consolas', 'Monaco', monospace; font-size: 13px; border-radius: 4px; }}
            img {{ max-width: 100%; height: auto; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }}
            .md-render {{ max-height: 500px; overflow-y: auto; line-height: 1.6; }}
            .path-text {{ font-size: 11px; color: #888; display: block; margin-bottom: 5px; }}
        </style>
    </head>
    <body>
        <nav>
            <a href="index.html">Detailvaade</a>
            <a href="thumbs.html">Galerii</a>
        </nav>
        <h1>Projektid: {base_dir.name}</h1>
        <table>
            <thead>
                <tr>
                    <th style="width: 300px;">Eelvaade</th>
                    <th>OpenSCAD kood</th>
                    <th style="width: 25%;">Info (.md)</th>
                </tr>
            </thead>
            <tbody>
    """

    for scad_path in scad_files:
        rel_scad = scad_path.relative_to(base_dir)
        rel_png = scad_path.with_suffix(".png").relative_to(base_dir)
        rel_md = scad_path.with_suffix(".md").relative_to(base_dir)
        
        try:
            code = scad_path.read_text(encoding='utf-8', errors='ignore').replace('<', '&lt;').replace('>', '&gt;')
        except:
            code = "Viga faili lugemisel."

        md_html = ""
        if (base_dir / rel_md).exists():
            try:
                md_raw = (base_dir / rel_md).read_text(encoding='utf-8', errors='ignore').replace('').replace('$', '\\$')
                md_html = f'<div class="md-data" data-content="{md_raw}"></div>'
            except:
                md_html = "Viga MD faili lugemisel."

        html_content += f"""
            <tr>
                <td>
                    <span class="path-text">{rel_scad}</span>
                    <a href="{rel_png}" target="_blank"><img src="{rel_png}"></a>
                </td>
                <td><div class="scad-code">{code}</div></td>
                <td class="md-render">{md_html if md_html else "—"}</td>
            </tr>
        """

    html_content += """
            </tbody>
        </table>
        <script>
            const md = window.markdownit();
            document.querySelectorAll('.md-data').forEach(div => {
                div.innerHTML = md.render(div.dataset.content);
            });
        </script>
    </body>
    </html>
    """
    (base_dir / "index.html").write_text(html_content, encoding="utf-8")

def create_thumbs_html(scad_files, base_dir):
    html_content = f"""
    <!DOCTYPE html>
    <html lang="et">
    <head>
        <meta charset="UTF-8">
        <title>Galerii v{VERSION}</title>
        <style>
            body {{ font-family: sans-serif; background: #1a1a1a; color: #eee; padding: 20px; }}
            nav {{ margin-bottom: 30px; border-bottom: 1px solid #444; padding-bottom: 10px; }}
            nav a {{ color: #4dabf7; text-decoration: none; font-weight: bold; margin-right: 15px; }}
            .gallery {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }}
            .card {{ background: #2c2c2c; border-radius: 8px; overflow: hidden; transition: transform 0.2s; border: 1px solid #444; }}
            .card:hover {{ transform: translateY(-5px); border-color: #666; }}
            .card img {{ width: 100%; aspect-ratio: 1/1; object-fit: cover; display: block; }}
            .card-info {{ padding: 10px; font-size: 12px; text-align: center; color: #ccc; }}
        </style>
    </head>
    <body>
        <nav>
            <a href="index.html">Detailvaade</a>
            <a href="thumbs.html">Galerii</a>
        </nav>
        <h1>Visuaalne ülevaade</h1>
        <div class="gallery">
    """

    for scad_path in scad_files:
        rel_png = scad_path.with_suffix(".png").relative_to(base_dir)
        html_content += f"""
            <div class="card">
                <a href="{rel_png}" target="_blank">
                    <img src="{rel_png}" loading="lazy">
                </a>
                <div class="card-info">{scad_path.name}</div>
            </div>
        """

    html_content += """
        </div>
    </body>
    </html>
    """
    (base_dir / "thumbs.html").write_text(html_content, encoding="utf-8")

if __name__ == "__main__":
    scad_list, base_path = generate_assets()
    if scad_list:
        create_index_html(scad_list, base_path)
        create_thumbs_html(scad_list, base_path)
        print(f"Edukalt loodud index.html ja thumbs.html kausta {base_path}")
    else:
        print("Selles kaustas ja selle alamkaustades ei leidu .scad faile.")
