"""
Convert selected gallery images to base64 data URIs and
inject them into landing.html as an inline gallery.
"""
import base64, io, os, re
from pathlib import Path
from PIL import Image

BASE     = Path(__file__).parent.parent
HTML_IN  = BASE / "landing.html"
MAX_W    = 640
QUALITY  = 72

PICKS = [
    ("gallery/01_basic_assembled.png",    "render", "gi01"),
    ("gallery/03_fan_rings.png",          "render", "gi03"),
    ("gallery/19_honeycomb_full.png",     "render", "gi19"),
    ("gallery/08_pcb_standoffs.png",      "render", "gi08"),
    ("gallery/10_snap_fit.png",           "render", "gi10"),
    ("gallery/18_audio_di_box.png",       "render", "gi18"),
    ("images/hero_assembled_exploded.jpg","ui",     "gui01"),
    ("images/feature_ajar_fan_vent.jpg",  "ui",     "gui04"),
    ("images/feature_removable_panels.jpg","ui",    "gui06"),
]

def to_b64(fp):
    img = Image.open(fp).convert("RGB")
    w, h = img.size
    if w > MAX_W:
        img = img.resize((MAX_W, int(h * MAX_W / w)), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, "JPEG", quality=QUALITY, optimize=True)
    data = buf.getvalue()
    kb   = len(data) // 1024
    b64  = base64.b64encode(data).decode()
    print(f"  {fp.name:40s} {img.size[0]}x{img.size[1]}  {kb}KB -> b64 {len(b64)//1024}KB")
    return f"data:image/jpeg;base64,{b64}"

print("Encoding images...")
items_html = ""
for relpath, cat, i18n_key in PICKS:
    fp = BASE / Path(relpath)
    data_uri = to_b64(fp)
    items_html += f'''
      <div class="gal-item break-inside-avoid" data-cat="{cat}">
        <img src="{data_uri}" alt="{i18n_key}" loading="lazy" class="gal-img rounded-lg w-full">
        <div class="gal-label" data-i18n="{i18n_key}">...</div>
      </div>'''

# Replace the gal-grid content in landing.html
html = HTML_IN.read_text(encoding="utf-8")

# Replace everything between <!-- ── 3D Renders ── --> and </div><!-- /gal-grid -->
pattern = r'(id="gal-grid"[^>]*>)[\s\S]*?(</div><!-- /gal-grid -->)'
replacement = r'\g<1>' + items_html + '\n\n    ' + r'\g<2>'
html_new = re.sub(pattern, replacement, html)

if html_new == html:
    print("ERROR: pattern not matched in HTML!")
else:
    HTML_IN.write_text(html_new, encoding="utf-8")
    total_kb = sum(len(items_html.encode())) // 1024
    print(f"\nDone! Gallery block: ~{len(items_html)//1024}KB")
    print(f"Total HTML: {len(html_new)//1024}KB")
