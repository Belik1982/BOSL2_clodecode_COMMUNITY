#!/usr/bin/env python3
"""
Gumroad Product Thumbnail Generator
====================================
Renders a fresh set of hero images from OpenSCAD (PRO version),
then composes them into a square 1200×1200 px thumbnail.

Layout — 2×2 grid, each cell 600×600, dark background:

  ┌──────────────┬──────────────┐
  │  Fan 80mm    │  Full honey- │
  │  ring grill  │  comb vents  │
  ├──────────────┼──────────────┤
  │  PCB stand-  │  Snap-fit +  │
  │  offs + USB  │  connectors  │
  └──────────────┴──────────────┘

A title bar is overlaid at the bottom.

Usage:
    python scripts/make_thumbnail.py
    python scripts/make_thumbnail.py --out images/thumbnail_gumroad.png
    python scripts/make_thumbnail.py --size 1200   # square side px
    python scripts/make_thumbnail.py --no-render   # skip OpenSCAD, use cached PNGs
"""

import subprocess, sys, os, io, json, argparse, time
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    print("ERROR: Pillow not found. Run: pip install Pillow")
    sys.exit(1)

# ── Paths ──────────────────────────────────────────────────────────────────────
SCRIPT_DIR    = Path(__file__).parent
COMMUNITY_DIR = SCRIPT_DIR.parent
CACHE_DIR     = COMMUNITY_DIR / "gallery" / "_thumb_cache"

PRO_SCAD_CANDIDATES = [
    COMMUNITY_DIR.parent / "BOSL2_clodecode_PRO" / "enclosure.scad",
    COMMUNITY_DIR.parent / "BOSL2_clodecode"     / "enclosure.scad",
    COMMUNITY_DIR / "enclosure.scad",
]

OPENSCAD_PATHS = [
    r"C:\Program Files\OpenSCAD (Nightly)\openscad.exe",
    r"C:\Program Files\OpenSCAD\openscad.exe",
    "openscad-nightly",
    "openscad",
]

# ── Hero render configs ────────────────────────────────────────────────────────
# Four visually distinct scenes — each rendered at CELL×CELL px.

HERO_CONFIGS = [
    {
        "name": "th_fan_ring",
        "camera": "--camera=0,0,0,28,0,335,680",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 160,
            "Width_Shyryna":   120,
            "Height_Vysota":   110,
            "Fan_Face_Gran":   "Спереду (Front)",
            "Fan_Size_Rozmir": "80x80",
            "Fan_Grill_Style": "Кільця (Rings)",
            "Fan_Offset_1":    0,
            "Fan_Offset_2":    0,
            "Vent_Top_Dakh":   "Соти (Honeycomb)",
            "Radius_Kutiv":    4.0,
            "Render_Quality":  "Normal",
        },
    },
    {
        "name": "th_honeycomb",
        "camera": "--camera=0,0,0,50,0,300,680",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 140,
            "Width_Shyryna":   95,
            "Height_Vysota":   45,
            "Vent_Top_Dakh":   "Соти (Honeycomb)",
            "Vent_Bottom_Dno": "Соти (Honeycomb)",
            "Vent_Side_Face":  "Зліва та Справа (Left & Right)",
            "Vent_Side_Style": "Соти (Honeycomb)",
            "Radius_Kutiv":    4.0,
            "Render_Quality":  "Normal",
        },
    },
    {
        "name": "th_pcb_connectors",
        "camera": "--camera=0,0,0,45,0,315,560",
        "params": {
            "_EDITION":          "pro",
            "Part_Chastyna":     "База (Base)",
            "Length_Dovzhyna":   120,
            "Width_Shyryna":     75,
            "Height_Vysota":     35,
            "PCB_Enable_Stiyky": True,
            "PCB_Count_Kilkist": 4,
            "PCB_Height_Vysota": 6.0,
            "PCB_Screw_Gvynt":   "M3",
            "PCB_X_Vidstup":     12.0,
            "PCB_Y_Vidstup":     12.0,
            "Port_1_Type":       "USB-C",
            "Port_1_Face":       "Спереду (Front)",
            "Port_2_Type":       "HDMI",
            "Port_2_Face":       "Ззаду (Back)",
            "Render_Quality":    "Normal",
        },
    },
    {
        "name": "th_snapfit_multi",
        "camera": "--camera=0,0,0,42,0,320,620",
        "params": {
            "_EDITION":             "pro",
            "Part_Chastyna":        "Всі деталі (All)",
            "Length_Dovzhyna":      130,
            "Width_Shyryna":        80,
            "Height_Vysota":        35,
            "Fastening_Kriplennya": "Защіпки (Snaps)",
            "Snap_X_Kilkist":       2,
            "Snap_Y_Kilkist":       1,
            "Joint_Styk":           "Губа (Lip)",
            "Port_1_Type":          "USB-C",
            "Port_1_Face":          "Спереду (Front)",
            "Port_2_Type":          "RJ45 Ethernet",
            "Port_2_Face":          "Ззаду (Back)",
            "Render_Quality":       "Normal",
        },
    },
]

# ── Design constants ────────────────────────────────────────────────────────────
BG_COLOR      = (18, 18, 24)       # near-black background
GRID_GAP      = 6                  # px gap between cells
TITLE_H_RATIO = 0.115              # title bar height as fraction of total size
TITLE_BG      = (24, 24, 36)      # slightly lighter than bg
ACCENT_COLOR  = (255, 144, 232)    # Gumroad pink — matches badge in README
TEXT_COLOR    = (240, 240, 240)
SUB_COLOR     = (160, 160, 180)

# ── Helpers ────────────────────────────────────────────────────────────────────

def find_openscad():
    for p in OPENSCAD_PATHS:
        if os.path.isfile(p):
            return p
        try:
            r = subprocess.run(["where", p], capture_output=True, text=True, shell=True)
            if r.returncode == 0 and r.stdout.strip():
                return r.stdout.strip().split("\n")[0].strip()
        except Exception:
            pass
    return None


def find_scad():
    for c in PRO_SCAD_CANDIDATES:
        if c.is_file():
            return c
    raise FileNotFoundError("enclosure.scad not found")


def render_hero(openscad, cfg, output_png, cell_px, scad_file):
    output_png.parent.mkdir(parents=True, exist_ok=True)
    w = h = cell_px
    cmd = [
        openscad,
        "--backend=manifold", "--render",
        f"--imgsize={w},{h}",
        cfg.get("camera", "--camera=0,0,0,45,0,315,600"),
        "--colorscheme=Tomorrow Night",
        "--projection=perspective",
    ]
    for key, val in cfg["params"].items():
        if isinstance(val, str):
            cmd += ["-D", f'{key}="{val}"']
        elif isinstance(val, bool):
            cmd += ["-D", f"{key}={'true' if val else 'false'}"]
        else:
            cmd += ["-D", f"{key}={val}"]
    cmd += ["-o", str(output_png), str(scad_file)]

    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=180,
                       cwd=scad_file.parent, encoding="utf-8", errors="replace")
    elapsed = round(time.time() - t0, 1)
    ok = r.returncode == 0 and output_png.exists() and output_png.stat().st_size > 0
    marker = "OK" if ok else "FAIL"
    print(f"  {marker} [{elapsed}s] {cfg['name']}")
    if not ok:
        for line in r.stderr.strip().split("\n")[-3:]:
            if line.strip():
                print(f"      {line}")
    return ok


def load_font(size):
    """Try to load a nice font; fall back gracefully."""
    candidates = [
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/verdana.ttf",
    ]
    from PIL import ImageFont
    for path in candidates:
        if os.path.isfile(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                pass
    return ImageFont.load_default()


def compose_thumbnail(cell_images, total_px):
    """Compose 4 images into a square thumbnail with title bar."""
    title_h   = int(total_px * TITLE_H_RATIO)
    grid_area = total_px - title_h
    cell      = (grid_area - GRID_GAP) // 2   # cell side in the grid

    canvas = Image.new("RGB", (total_px, total_px), BG_COLOR)

    # ── Place 4 cells ──────────────────────────────────────────────────────────
    positions = [
        (0,             0),
        (cell + GRID_GAP, 0),
        (0,             cell + GRID_GAP),
        (cell + GRID_GAP, cell + GRID_GAP),
    ]
    for img, (x, y) in zip(cell_images, positions):
        # crop to square from center, resize to cell
        w, h = img.size
        side = min(w, h)
        left = (w - side) // 2
        top  = (h - side) // 2
        img  = img.crop((left, top, left + side, top + side))
        img  = img.resize((cell, cell), Image.LANCZOS)
        canvas.paste(img, (x, y))

    # ── Title bar ──────────────────────────────────────────────────────────────
    bar_y = grid_area
    draw  = ImageDraw.Draw(canvas)
    draw.rectangle([(0, bar_y), (total_px, total_px)], fill=TITLE_BG)

    # Thin accent line above title bar
    draw.rectangle([(0, bar_y), (total_px, bar_y + 3)], fill=ACCENT_COLOR)

    font_title = load_font(int(title_h * 0.44))
    font_sub   = load_font(int(title_h * 0.27))

    title_text = "Parametric Enclosure Generator"
    sub_text   = "130+ parameters · 26 connectors · OpenSCAD"

    # Center title
    bbox = draw.textbbox((0, 0), title_text, font=font_title)
    tw   = bbox[2] - bbox[0]
    tx   = (total_px - tw) // 2
    ty   = bar_y + int(title_h * 0.08)
    draw.text((tx, ty), title_text, font=font_title, fill=TEXT_COLOR)

    # Center subtitle
    bbox2 = draw.textbbox((0, 0), sub_text, font=font_sub)
    sw    = bbox2[2] - bbox2[0]
    sx    = (total_px - sw) // 2
    sy    = ty + (bbox[3] - bbox[1]) + int(title_h * 0.07)
    draw.text((sx, sy), sub_text, font=font_sub, fill=SUB_COLOR)

    # PRO badge — top-right corner
    badge_text = "PRO"
    badge_font = load_font(int(title_h * 0.32))
    bb = draw.textbbox((0, 0), badge_text, font=badge_font)
    bw, bh = bb[2] - bb[0], bb[3] - bb[1]
    pad    = int(title_h * 0.15)
    bx     = total_px - bw - pad * 3
    by_pos = bar_y + (title_h - bh) // 2 - int(title_h * 0.05)
    # badge pill background
    draw.rounded_rectangle(
        [(bx - pad, by_pos - pad // 2),
         (bx + bw + pad, by_pos + bh + pad // 2)],
        radius=int(bh * 0.35),
        fill=ACCENT_COLOR,
    )
    draw.text((bx, by_pos), badge_text, font=badge_font, fill=(20, 10, 30))

    return canvas


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Generate Gumroad product thumbnail")
    parser.add_argument("--out",       default=str(COMMUNITY_DIR / "images" / "thumbnail_gumroad.png"),
                        help="Output file path (PNG or JPG)")
    parser.add_argument("--size",      type=int, default=1200, help="Square side in px (default 1200)")
    parser.add_argument("--no-render", action="store_true",   help="Skip OpenSCAD, use cached PNGs")
    args = parser.parse_args()

    cell_px   = args.size  # render at full size, will be cropped to cell in compose step
    out_path  = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # ── Step 1: Render hero PNGs ───────────────────────────────────────────────
    cached_paths = []
    if not args.no_render:
        openscad = find_openscad()
        if not openscad:
            print("ERROR: OpenSCAD not found.")
            sys.exit(1)
        try:
            scad_file = find_scad()
        except FileNotFoundError as e:
            print(f"ERROR: {e}")
            sys.exit(1)

        print(f"Rendering {len(HERO_CONFIGS)} hero images at {cell_px}x{cell_px}...")
        print(f"SCAD: {scad_file}\n")

        for cfg in HERO_CONFIGS:
            png = CACHE_DIR / f"{cfg['name']}.png"
            ok  = render_hero(openscad, cfg, png, cell_px, scad_file)
            if not ok:
                print(f"\nFailed to render {cfg['name']}. Aborting.")
                sys.exit(1)
            cached_paths.append(png)
    else:
        print("--no-render: loading cached PNGs from", CACHE_DIR)
        for cfg in HERO_CONFIGS:
            png = CACHE_DIR / f"{cfg['name']}.png"
            if not png.exists():
                print(f"ERROR: cached PNG not found: {png}")
                sys.exit(1)
            cached_paths.append(png)

    # ── Step 2: Load images ────────────────────────────────────────────────────
    print("\nComposing thumbnail...")
    cell_images = [Image.open(p).convert("RGB") for p in cached_paths]

    # ── Step 3: Compose ────────────────────────────────────────────────────────
    thumb = compose_thumbnail(cell_images, args.size)

    # ── Step 4: Save ──────────────────────────────────────────────────────────
    suffix = out_path.suffix.lower()
    if suffix in (".jpg", ".jpeg"):
        thumb.save(out_path, "JPEG", quality=95, optimize=True)
    else:
        thumb.save(out_path, "PNG", optimize=True)

    size_kb = out_path.stat().st_size // 1024
    print(f"\nSaved: {out_path}  ({args.size}x{args.size} px, {size_kb} KB)")
    print("Ready to upload to Gumroad!")


if __name__ == "__main__":
    main()
