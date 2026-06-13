#!/usr/bin/env python3
"""
Parametric Enclosure Generator — Portfolio Gallery Renderer
===========================================================
Renders showcase configurations to PNG using OpenSCAD CLI.
By default renders from the PRO version to show all features.

Usage:
    python scripts/render_gallery.py
    python scripts/render_gallery.py --scad path/to/enclosure.scad
    python scripts/render_gallery.py --output gallery --size 1920x1440
    python scripts/render_gallery.py --config only:03_fan_80mm,04_pcb_standoffs
    python scripts/render_gallery.py --parallel 4
    python scripts/render_gallery.py --dry-run

Output:
    gallery/
      01_basic_assembled.png
      ...
      index.md    <- Markdown gallery page
      render_log.json
"""

import subprocess, os, sys, json, argparse, time, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")
from pathlib import Path
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

# ── Paths ──────────────────────────────────────────────────────────────────────

SCRIPT_DIR  = Path(__file__).parent
COMMUNITY_DIR = SCRIPT_DIR.parent   # this repo — output goes here

# PRO enclosure is in a sibling folder; fall back to community if not found.
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

DEFAULT_OUTPUT  = COMMUNITY_DIR / "gallery"
DEFAULT_SIZE    = "1280x960"
CAMERA_PARAMS   = "--camera=0,0,0,45,0,315,550"
COLORSCHEME     = "--colorscheme=Tomorrow Night"
TIMEOUT         = 180   # seconds per render

# ── Showcase configurations ────────────────────────────────────────────────────
# 🆓 = rendered from community version  |  🔒 PRO = needs _EDITION="pro"
# Each entry → one PNG.

CONFIGS = [

    # ── 01-02  Basic shapes (FREE) ─────────────────────────────────────────────
    {
        "name": "01_basic_assembled",
        "title": "Basic Box — Assembled",
        "desc": "100×60×30 mm, lip joint, rounded corners — straight from the Customizer",
        "params": {
            "Part_Chastyna":    "Зібраний (Assembled)",
            "Length_Dovzhyna":  100,
            "Width_Shyryna":    60,
            "Height_Vysota":    30,
            "Joint_Styk":       "Губа (Lip)",
            "Radius_Kutiv":     4.0,
            "Render_Quality":   "Normal",
        },
    },
    {
        "name": "02_basic_all_parts",
        "title": "Basic Box — All Parts",
        "desc": "Base and lid side-by-side ready for STL export",
        "params": {
            "Part_Chastyna":   "Всі деталі (All)",
            "Length_Dovzhyna": 100,
            "Width_Shyryna":   60,
            "Height_Vysota":   30,
            "Radius_Kutiv":    4.0,
            "Render_Quality":  "Normal",
        },
    },

    # ── 03-07  Fan mounts — all 5 grill styles 🔒 ─────────────────────────────
    # Camera: front face clearly visible — 30° tilt, slight right, close-up
    {
        "name": "03_fan_rings",
        "title": "Fan Grill — Rings 🔒",
        "desc": "80 mm fan, concentric ring grill — classic look",
        "camera": "--camera=0,0,0,30,0,340,560",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 120,
            "Width_Shyryna":   80,
            "Height_Vysota":   50,
            "Fan_Face_Gran":   "Спереду (Front)",
            "Fan_Size_Rozmir": "80x80",
            "Fan_Grill_Style": "Кільця (Rings)",
            "Vent_Top_Dakh":   "Соти (Honeycomb)",
            "Radius_Kutiv":    3.0,
            "Render_Quality":  "Normal",
        },
    },
    {
        "name": "04_fan_honeycomb",
        "title": "Fan Grill — Honeycomb 🔒",
        "desc": "60 mm fan, honeycomb grill — maximum airflow",
        "camera": "--camera=0,0,0,30,0,340,520",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 100,
            "Width_Shyryna":   70,
            "Height_Vysota":   45,
            "Fan_Face_Gran":   "Спереду (Front)",
            "Fan_Size_Rozmir": "60x60",
            "Fan_Grill_Style": "Соти (Honeycomb)",
            "Vent_Top_Dakh":   "Слоти (Slots)",
            "Radius_Kutiv":    3.0,
            "Render_Quality":  "Normal",
        },
    },
    {
        "name": "05_fan_slots",
        "title": "Fan Grill — Slots 🔒",
        "desc": "40 mm fan, horizontal slot grill — compact case",
        "camera": "--camera=0,0,0,30,0,340,480",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 85,
            "Width_Shyryna":   60,
            "Height_Vysota":   45,
            "Fan_Face_Gran":   "Спереду (Front)",
            "Fan_Size_Rozmir": "40x40",
            "Fan_Grill_Style": "Слоти (Slots)",
            "Vent_Top_Dakh":   "Отвори (Holes)",
            "Radius_Kutiv":    2.0,
            "Render_Quality":  "Normal",
        },
    },
    {
        "name": "06_fan_holes",
        "title": "Fan Grill — Holes 🔒",
        "desc": "80 mm fan, circular holes grill pattern",
        "camera": "--camera=0,0,0,30,0,340,560",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 120,
            "Width_Shyryna":   80,
            "Height_Vysota":   50,
            "Fan_Face_Gran":   "Спереду (Front)",
            "Fan_Size_Rozmir": "80x80",
            "Fan_Grill_Style": "Отвори (Holes)",
            "Vent_Side_Face":  "Зліва та Справа (Left & Right)",
            "Vent_Side_Style": "Слоти (Slots)",
            "Radius_Kutiv":    3.0,
            "Render_Quality":  "Normal",
        },
    },
    {
        "name": "07_fan_open",
        "title": "Fan Grill — Open 🔒",
        "desc": "120 mm fan, open cut-out — maximum airflow, minimal resistance",
        "camera": "--camera=0,0,0,30,0,340,620",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 140,
            "Width_Shyryna":   140,
            "Height_Vysota":   60,
            "Fan_Face_Gran":   "Спереду (Front)",
            "Fan_Size_Rozmir": "120x120",
            "Fan_Grill_Style": "Відкритий (Open)",
            "Vent_Top_Dakh":   "Соти (Honeycomb)",
            "Radius_Kutiv":    4.0,
            "Render_Quality":  "Normal",
        },
    },

    # ── 08  PCB Standoffs 🔒 ────────────────────────────────────────────────────
    {
        "name": "08_pcb_standoffs",
        "title": "PCB Standoffs 🔒",
        "desc": "100×60×30 mm, 4× M3 standoffs, USB-C front, base only view",
        "params": {
            "_EDITION":          "pro",
            "Part_Chastyna":     "База (Base)",
            "Length_Dovzhyna":   100,
            "Width_Shyryna":     60,
            "Height_Vysota":     30,
            "PCB_Enable_Stiyky": True,
            "PCB_Count_Kilkist": 4,
            "PCB_Height_Vysota": 5.0,
            "PCB_Screw_Gvynt":   "M3",
            "PCB_X_Vidstup":     10.0,
            "PCB_Y_Vidstup":     10.0,
            "Port_1_Type":       "USB-C",
            "Port_1_Face":       "Спереду (Front)",
            "Render_Quality":    "Normal",
        },
    },

    # ── 09  DIN Rail TS-35 🔒 ────────────────────────────────────────────────────
    {
        "name": "09_din_rail",
        "title": "DIN Rail TS-35 🔒",
        "desc": "Industrial controller 130×80×60 mm, DIN snap-on clip, DB9 + DC Jack",
        "params": {
            "_EDITION":         "pro",
            "Part_Chastyna":    "Зібраний (Assembled)",
            "Length_Dovzhyna":  130,
            "Width_Shyryna":    80,
            "Height_Vysota":    60,
            "DIN_Rail_Enable":  True,
            "Port_1_Type":      "DB9 (DE-9)",
            "Port_1_Face":      "Спереду (Front)",
            "Port_2_Type":      "DC Jack M8",
            "Port_2_Face":      "Спереду (Front)",
            "Fastening_Kriplennya": "Термозакладки (Heatset)",
            "Render_Quality":   "Normal",
        },
    },

    # ── 10  Snap-fit 🔒 ─────────────────────────────────────────────────────────
    {
        "name": "10_snap_fit",
        "title": "Snap-Fit Clips 🔒",
        "desc": "Cantilever snap clips on X + Y sides — no screws needed",
        "params": {
            "_EDITION":             "pro",
            "Part_Chastyna":        "Всі деталі (All)",
            "Length_Dovzhyna":      100,
            "Width_Shyryna":        65,
            "Height_Vysota":        30,
            "Fastening_Kriplennya": "Защіпки (Snaps)",
            "Snap_X_Kilkist":       2,
            "Snap_Y_Kilkist":       1,
            "Joint_Styk":           "Губа (Lip)",
            "Render_Quality":       "Normal",
        },
    },

    # ── 11  Magnets 🔒 ──────────────────────────────────────────────────────────
    {
        "name": "11_magnets",
        "title": "Magnetic Closure 🔒",
        "desc": "Flush magnet pockets in base and lid corners",
        "params": {
            "_EDITION":             "pro",
            "Part_Chastyna":        "Всі деталі (All)",
            "Length_Dovzhyna":      110,
            "Width_Shyryna":        70,
            "Height_Vysota":        25,
            "Fastening_Kriplennya": "Магніти (Magnets)",
            "Magnet_Dia_Diametr":   6.0,
            "Magnet_Thick_Tovshchyna": 2.0,
            "Joint_Styk":           "Губа (Lip)",
            "Render_Quality":       "Normal",
        },
    },

    # ── 12  Mounting ears 🔒 ────────────────────────────────────────────────────
    {
        "name": "12_mounting_ears",
        "title": "Mounting Ears 🔒",
        "desc": "Panel-mount flanges with M4 holes on all 4 sides",
        "params": {
            "_EDITION":       "pro",
            "Part_Chastyna":  "Зібраний (Assembled)",
            "Length_Dovzhyna": 120,
            "Width_Shyryna":   80,
            "Height_Vysota":   35,
            "Ears_Type":      "Зліва та Справа (Left & Right)",
            "Ears_Count":     4,
            "Ears_Width":     15.0,
            "Ears_Hole_Dia":  4.5,
            "Fastening_Kriplennya": "Гайки (Nuts)",
            "Render_Quality": "Normal",
        },
    },

    # ── 13  LED Light Pipes 🔒 ──────────────────────────────────────────────────
    {
        "name": "13_led_lightpipes",
        "title": "LED Light Pipes 🔒",
        "desc": "4 integrated light guides on front face for status LEDs",
        "params": {
            "_EDITION":           "pro",
            "Part_Chastyna":      "База (Base)",
            "Length_Dovzhyna":    100,
            "Width_Shyryna":      60,
            "Height_Vysota":      30,
            "LightPipe_Enable":   True,
            "LightPipe_Count":    4,
            "LightPipe_Spacing":  10.0,
            "LightPipe_Outer_Dia": 5.0,
            "LightPipe_Face":     "Спереду (Front)",
            "LightPipe_Z":        8.0,
            "Port_1_Type":        "USB-C",
            "Port_1_Face":        "Спереду (Front)",
            "Render_Quality":     "Normal",
        },
    },

    # ── 14  IP54 + Heat-set 🔒 ──────────────────────────────────────────────────
    {
        "name": "14_ip54_heatset",
        "title": "IP54 Gasket + Heat-set 🔒",
        "desc": "O-ring gasket groove for sealed enclosure, M3 heat-set inserts",
        "params": {
            "_EDITION":             "pro",
            "Part_Chastyna":        "Всі деталі (All)",
            "Length_Dovzhyna":      120,
            "Width_Shyryna":        80,
            "Height_Vysota":        40,
            "Fastening_Kriplennya": "Термозакладки (Heatset)",
            "Gasket_Groove_Enable": True,
            "Gasket_Groove_Width":  2.0,
            "Gasket_Groove_Depth":  1.5,
            "Joint_Styk":           "Сходинка (Ledge)",
            "Port_1_Type":          "GX16 Aviation",
            "Port_1_Face":          "Спереду (Front)",
            "Port_2_Type":          "GX20 Aviation",
            "Port_2_Face":          "Ззаду (Back)",
            "Render_Quality":       "Normal",
        },
    },

    # ── 15  Cable Glands 🔒 ─────────────────────────────────────────────────────
    {
        "name": "15_cable_glands",
        "title": "M16 Cable Glands 🔒",
        "desc": "Industrial wire entries M16 threaded on left & right faces",
        "params": {
            "_EDITION":       "pro",
            "Part_Chastyna":  "Зібраний (Assembled)",
            "Length_Dovzhyna": 130,
            "Width_Shyryna":   80,
            "Height_Vysota":   50,
            "Wire_Shape_Forma": "M16 Gland (Threaded)",
            "Wire_Face_Gran":   "Зліва (Left)",
            "DIN_Rail_Enable":  True,
            "Render_Quality":  "Normal",
        },
    },

    # ── 16  Removable panels (tongue-and-groove) 🔒 ────────────────────────────
    {
        "name": "16_removable_panels",
        "title": "Removable Side Panels 🔒",
        "desc": "Tongue-and-groove slide-in walls — tool-free access, front+back",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Всі деталі (All)",
            "Length_Dovzhyna": 120,
            "Width_Shyryna":   80,
            "Height_Vysota":   40,
            "Panel_Enable":    True,
            "Panel_Walls":     "Перед+Зад (Front+Back)",
            "Fastening_Kriplennya": "Саморізи (Self-tap)",
            "Render_Quality":  "Normal",
        },
    },
    {
        "name": "17_removable_panels_all4",
        "title": "Removable Panels — All 4 Sides 🔒",
        "desc": "All four walls removable — slide-in from the sides",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Всі деталі (All)",
            "Length_Dovzhyna": 130,
            "Width_Shyryna":   90,
            "Height_Vysota":   45,
            "Panel_Enable":    True,
            "Panel_Walls":     "Всі 4 (All 4)",
            "Fastening_Kriplennya": "Саморізи (Self-tap)",
            "Render_Quality":  "Normal",
        },
    },

    # ── 18  Audio DI box 🔒 ─────────────────────────────────────────────────────
    {
        "name": "18_audio_di_box",
        "title": "Audio DI Box 🔒",
        "desc": "115×75×40 mm, XLR 3-pin + Jack 6.35 mm + USB-C, rubber feet",
        "params": {
            "_EDITION":       "pro",
            "Part_Chastyna":  "Зібраний (Assembled)",
            "Enclosure_Preset": "7 Project 115x75x40",
            "Port_1_Type":    "XLR 3-pin",
            "Port_1_Face":    "Спереду (Front)",
            "Port_2_Type":    "Jack 6.35mm",
            "Port_2_Face":    "Спереду (Front)",
            "Port_3_Type":    "USB-C",
            "Port_3_Face":    "Ззаду (Back)",
            "Feet_Type":      "Пази під гумові ніжки (Recesses)",
            "Render_Quality": "Normal",
        },
    },

    # ── 19  Full honeycomb ventilation 🔒 ───────────────────────────────────────
    {
        "name": "19_honeycomb_full",
        "title": "Full Honeycomb Ventilation 🔒",
        "desc": "Honeycomb top + bottom + both sides — maximum airflow",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 120,
            "Width_Shyryna":   80,
            "Height_Vysota":   40,
            "Vent_Top_Dakh":   "Соти (Honeycomb)",
            "Vent_Bottom_Dno": "Соти (Honeycomb)",
            "Vent_Side_Face":  "Зліва та Справа (Left & Right)",
            "Vent_Side_Style": "Соти (Honeycomb)",
            "Render_Quality":  "Normal",
        },
    },

    # ── 20  Text labels (FREE) ──────────────────────────────────────────────────
    {
        "name": "20_text_labels",
        "title": "Custom Text Labels",
        "desc": "Deboss on front face, emboss on top — any font, any face",
        "params": {
            "Part_Chastyna":       "Зібраний (Assembled)",
            "Length_Dovzhyna":     120,
            "Width_Shyryna":       80,
            "Height_Vysota":       40,
            "Text_1_Custom_Tekst": "MY DEVICE",
            "Text_1_Face_Gran":    "Спереду (Front)",
            "Text_1_Depth_Glybyna": -1.2,
            "Text_1_Size_Rozmir":  11.0,
            "Text_2_Custom_Tekst": "v2.0",
            "Text_2_Face_Gran":    "Дах (Top)",
            "Text_2_Depth_Glybyna": 0.8,
            "Text_2_Size_Rozmir":  9.0,
            "Render_Quality":      "Normal",
        },
    },

    # ── 21  IoT Sensor (FREE) ───────────────────────────────────────────────────
    {
        "name": "21_iot_sensor",
        "title": "IoT Sensor Node",
        "desc": "85×50×21 mm, USB-C front, RJ45 back, honeycomb top",
        "params": {
            "Part_Chastyna":     "Зібраний (Assembled)",
            "Enclosure_Preset":  "5 Sensor 85x50x21",
            "Port_1_Type":       "USB-C",
            "Port_1_Face":       "Спереду (Front)",
            "Port_2_Type":       "RJ45 Ethernet",
            "Port_2_Face":       "Ззаду (Back)",
            "Vent_Top_Dakh":     "Соти (Honeycomb)",
            "Fastening_Kriplennya": "Саморізи (Self-tap)",
            "Render_Quality":    "Normal",
        },
    },

    # ── 22  Micro-Dongle (FREE) ─────────────────────────────────────────────────
    {
        "name": "22_size_micro",
        "title": "Micro-Dongle — 50×35 mm",
        "desc": "Smallest preset — USB dongle / BLE module size",
        "params": {
            "Part_Chastyna":    "Зібраний (Assembled)",
            "Enclosure_Preset": "1 Micro-Dongle 50x35x22",
            "Port_1_Type":      "USB-C",
            "Port_1_Face":      "Спереду (Front)",
            "Render_Quality":   "Normal",
        },
    },

    # ── 23  VESA mount 🔒 ───────────────────────────────────────────────────────
    {
        "name": "23_vesa_75",
        "title": "VESA 75×75 Mount 🔒",
        "desc": "Wall/monitor mount pattern 75×75 mm — bolt directly to VESA bracket",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Length_Dovzhyna": 120,
            "Width_Shyryna":   90,
            "Height_Vysota":   30,
            "VESA_Mount_Enable": True,
            "VESA_Size":       "75x75",
            "Render_Quality":  "Normal",
        },
    },

    # ── 24  Maxi box 🔒 ─────────────────────────────────────────────────────────
    {
        "name": "24_size_maxi",
        "title": "Maxi Box 250×180 mm 🔒",
        "desc": "Largest preset: 250×180×100 mm, honeycomb lid, side slots",
        "camera": "--camera=0,0,0,45,0,315,950",
        "params": {
            "_EDITION":        "pro",
            "Part_Chastyna":   "Зібраний (Assembled)",
            "Enclosure_Preset": "15 Maxi 250x180x100",
            "Vent_Top_Dakh":   "Соти (Honeycomb)",
            "Vent_Side_Face":  "Зліва та Справа (Left & Right)",
            "Vent_Side_Style": "Слоти (Slots)",
            "Render_Quality":  "Draft",
        },
    },
]

# ── Helpers ────────────────────────────────────────────────────────────────────

_lock = threading.Lock()


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


def find_scad_file(override=None):
    """Return path to enclosure.scad, preferring PRO version."""
    if override:
        p = Path(override)
        if p.is_file():
            return p
        raise FileNotFoundError(f"--scad path not found: {override}")
    for candidate in PRO_SCAD_CANDIDATES:
        if candidate.is_file():
            return candidate
    raise FileNotFoundError(
        "enclosure.scad not found. Pass --scad path/to/enclosure.scad"
    )


def build_cmd(openscad, cfg, output_png, size, scad_file):
    w, h = size.split("x")
    camera = cfg.get("camera", CAMERA_PARAMS)
    cmd = [
        openscad,
        "--backend=manifold",
        "--render",
        f"--imgsize={w},{h}",
        camera,
        COLORSCHEME,
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
    return cmd


def render_one(openscad, cfg, output_dir, size, scad_file):
    name = cfg["name"]
    output_png = output_dir / f"{name}.png"
    cmd = build_cmd(openscad, cfg, output_png, size, scad_file)
    start = time.time()
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True,
            timeout=TIMEOUT, cwd=scad_file.parent,
            encoding="utf-8", errors="replace"
        )
        elapsed = round(time.time() - start, 1)
        ok = result.returncode == 0 and output_png.exists() and output_png.stat().st_size > 0
        with _lock:
            marker = "✓" if ok else "✗"
            print(f"  {marker} [{elapsed:5.1f}s] {name}")
            if not ok and result.stderr:
                for line in result.stderr.strip().split("\n")[-4:]:
                    if line.strip():
                        print(f"           {line}")
        return {"name": name, "ok": ok, "elapsed": elapsed, "path": str(output_png)}
    except subprocess.TimeoutExpired:
        with _lock:
            print(f"  ✗ [TIMEOUT] {name}")
        return {"name": name, "ok": False, "elapsed": TIMEOUT, "error": "timeout"}
    except Exception as e:
        with _lock:
            print(f"  ✗ [ERROR] {name}: {e}")
        return {"name": name, "ok": False, "elapsed": 0, "error": str(e)}


def build_index_md(results, output_dir, configs_map):
    ok_results = [r for r in results if r["ok"]]
    lines = [
        "# Parametric Enclosure Generator — Gallery",
        "",
        f"*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')} "
        f"· {len(ok_results)}/{len(results)} renders OK*",
        "",
        "> **\U0001f512 PRO** label = feature available in the PRO version. "
        "[Get PRO on Gumroad](https://belik.gumroad.com/l/idxwoz)",
        "",
    ]

    it = iter(ok_results)
    pairs = list(zip(it, it))
    remainder = ok_results[len(pairs) * 2:]

    lines.append("<table>")
    for a, b in pairs:
        ca, cb = configs_map[a["name"]], configs_map[b["name"]]
        lines.append("<tr>")
        lines.append(
            f'<td width="50%">\n\n'
            f'![{ca["title"]}]({a["name"]}.png)\n\n'
            f'**{ca["title"]}**  \n{ca["desc"]}\n\n</td>'
        )
        lines.append(
            f'<td width="50%">\n\n'
            f'![{cb["title"]}]({b["name"]}.png)\n\n'
            f'**{cb["title"]}**  \n{cb["desc"]}\n\n</td>'
        )
        lines.append("</tr>")
    if remainder:
        r = remainder[0]
        cr = configs_map[r["name"]]
        lines.append("<tr>")
        lines.append(
            f'<td width="50%">\n\n'
            f'![{cr["title"]}]({r["name"]}.png)\n\n'
            f'**{cr["title"]}**  \n{cr["desc"]}\n\n</td>'
        )
        lines.append('<td width="50%"></td>')
        lines.append("</tr>")
    lines.append("</table>")

    lines += [
        "",
        "---",
        "",
        "## Get the Full Feature Set",
        "",
        "[![Get PRO on Gumroad](https://img.shields.io/badge/PRO%20Version-Gumroad-ff90e8?"
        "logo=gumroad&style=for-the-badge)](https://belik.gumroad.com/l/idxwoz)",
        "",
        "*26 connectors · 15 presets · Fan mounts · Snap-fit · Magnets · "
        "PCB standoffs · DIN rail · VESA · Mounting ears · IP54 gasket · "
        "LED light pipes · Cable glands*",
    ]
    out = output_dir / "index.md"
    out.write_text("\n".join(lines), encoding="utf-8")
    print(f"\n  index.md written -> {out}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Render gallery PNGs via OpenSCAD CLI")
    parser.add_argument("--scad",     default=None, help="Path to enclosure.scad (default: auto-detect PRO)")
    parser.add_argument("--output",   default=str(DEFAULT_OUTPUT), help="Output folder")
    parser.add_argument("--size",     default=DEFAULT_SIZE, help="Image size WxH (default 1280x960)")
    parser.add_argument("--parallel", type=int, default=2, help="Parallel renders (default 2)")
    parser.add_argument("--config",   default=None, help="Comma-separated names; prefix 'only:' to skip others")
    parser.add_argument("--dry-run",  action="store_true", help="Print commands without rendering")
    args = parser.parse_args()

    try:
        scad_file = find_scad_file(args.scad)
    except FileNotFoundError as e:
        print(f"ERROR: {e}")
        sys.exit(1)

    openscad = find_openscad()
    if not openscad and not args.dry_run:
        print("ERROR: OpenSCAD not found. Install it or add to PATH.")
        sys.exit(1)

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    configs = CONFIGS
    if args.config:
        names_filter = set(args.config.lstrip("only:").split(","))
        configs = [c for c in configs if c["name"] in names_filter]

    configs_map = {c["name"]: c for c in configs}

    pro_count  = sum(1 for c in configs if "_EDITION" in c.get("params", {}))
    free_count = len(configs) - pro_count

    print(f"Rendering {len(configs)} configurations -> {output_dir}")
    print(f"SCAD file : {scad_file}")
    print(f"OpenSCAD  : {openscad}")
    print(f"Image size: {args.size}  Parallel: {args.parallel}")
    print(f"Configs   : {free_count} FREE + {pro_count} PRO\n")

    if args.dry_run:
        for cfg in configs:
            cmd = build_cmd(openscad or "openscad", cfg,
                            output_dir / f"{cfg['name']}.png", args.size, scad_file)
            print("DRY-RUN:", " ".join(str(x) for x in cmd))
        return

    start_total = time.time()
    results = []

    if args.parallel > 1:
        with ThreadPoolExecutor(max_workers=args.parallel) as ex:
            futures = {
                ex.submit(render_one, openscad, cfg, output_dir, args.size, scad_file): cfg
                for cfg in configs
            }
            for f in as_completed(futures):
                results.append(f.result())
        results.sort(key=lambda r: r["name"])
    else:
        for cfg in configs:
            r = render_one(openscad, cfg, output_dir, args.size, scad_file)
            results.append(r)

    elapsed_total = round(time.time() - start_total, 1)
    ok_count = sum(1 for r in results if r["ok"])
    print(f"\n{'='*55}")
    print(f"Done: {ok_count}/{len(results)} OK in {elapsed_total}s")

    if ok_count < len(results):
        failed = [r["name"] for r in results if not r["ok"]]
        print(f"Failed: {', '.join(failed)}")

    build_index_md(results, output_dir, configs_map)

    log_path = output_dir / "render_log.json"
    log_path.write_text(json.dumps({
        "timestamp":  datetime.now().isoformat(),
        "scad_file":  str(scad_file),
        "openscad":   openscad,
        "size":       args.size,
        "total_sec":  elapsed_total,
        "ok":         ok_count,
        "total":      len(results),
        "results":    results,
    }, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  render_log.json -> {log_path}")


if __name__ == "__main__":
    main()
