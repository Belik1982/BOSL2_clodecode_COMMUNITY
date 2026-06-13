#!/usr/bin/env python3
"""
Parametric Enclosure Generator — Portfolio Gallery Renderer
===========================================================
Automatically renders a set of showcase configurations to PNG images
using OpenSCAD's command-line export.

Usage:
    python scripts/render_gallery.py
    python scripts/render_gallery.py --output gallery --size 1280x960
    python scripts/render_gallery.py --config only:iot_sensor,audio_box
    python scripts/render_gallery.py --dry-run

Requirements:
    - OpenSCAD 2024+ dev snapshot in PATH or configured below
    - ~2 GB free disk space for full gallery run

Output:
    gallery/
      iot_sensor.png
      audio_box.png
      ... (one PNG per config)
      index.md    ← Markdown gallery page with all images
"""

import subprocess, os, sys, json, argparse, time, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")
from pathlib import Path
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

# ── Configuration ─────────────────────────────────────────────────────────────

SCRIPT_DIR   = Path(__file__).parent
PROJECT_DIR  = SCRIPT_DIR.parent
SCAD_FILE    = PROJECT_DIR / "enclosure.scad"

OPENSCAD_PATHS = [
    r"C:\Program Files\OpenSCAD (Nightly)\openscad.exe",
    r"C:\Program Files\OpenSCAD\openscad.exe",
    "openscad-nightly",
    "openscad",
]

DEFAULT_OUTPUT = PROJECT_DIR / "gallery"
DEFAULT_SIZE   = "1280x960"
CAMERA_PARAMS  = "--camera=0,0,0,45,0,315,550"   # isometric-style view
COLORSCHEME    = "--colorscheme=Tomorrow Night"
TIMEOUT        = 180   # seconds per render

# ── Showcase configurations ────────────────────────────────────────────────────
# Each entry produces one PNG.  Add/remove entries freely.
# Parameters follow OpenSCAD -D syntax (strings must be quoted with \").

CONFIGS = [
    # ── Basic shapes ──────────────────────────────────────────────────────────
    {
        "name": "01_basic_assembled",
        "title": "Basic Box — Assembled",
        "desc": "Default 100×60×30 mm box, lip joint, assembled view",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Length_Dovzhyna": 100,
            "Width_Shyryna": 60,
            "Height_Vysota": 30,
            "Joint_Styk": "Губа (Lip)",
            "Radius_Kutiv": 4.0,
            "Render_Quality": "Normal",
        },
    },
    {
        "name": "02_basic_exploded",
        "title": "Basic Box — All Parts",
        "desc": "Base and lid side by side",
        "params": {
            "Part_Chastyna": "Всі деталі (All)",
            "Length_Dovzhyna": 100,
            "Width_Shyryna": 60,
            "Height_Vysota": 30,
            "Radius_Kutiv": 4.0,
        },
    },
    # ── IoT / sensor boxes ────────────────────────────────────────────────────
    {
        "name": "03_iot_sensor",
        "title": "IoT Sensor Node",
        "desc": "85×50×21 mm, USB-C front, RJ45 back, honeycomb top",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "5 Sensor 85x50x21",
            "Port_1_Type": "USB-C",
            "Port_1_Face": "Спереду (Front)",
            "Port_2_Type": "RJ45 Ethernet",
            "Port_2_Face": "Ззаду (Back)",
            "Vent_Top_Dakh": "Соти (Honeycomb)",
            "Fastening_Kriplennya": "Саморізи (Self-tap)",
            "Render_Quality": "Normal",
        },
    },
    {
        "name": "04_arduino_nano",
        "title": "Arduino Nano Box",
        "desc": "100×60×25 mm, USB-C, PCB standoffs, ledge joint",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "4 Mini-Gauge 100x60x25",
            "Port_1_Type": "USB-C",
            "Port_1_Face": "Спереду (Front)",
            "Vent_Top_Dakh": "Слоти (Slots)",
            "Joint_Styk": "Сходинка (Ledge)",
            "Render_Quality": "Normal",
        },
    },
    # ── Audio / studio ────────────────────────────────────────────────────────
    {
        "name": "05_audio_di_box",
        "title": "Audio DI Box",
        "desc": "115×75×40 mm, XLR front, Jack 6.35 front, USB-C back",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "7 Project 115x75x40",
            "Port_1_Type": "XLR 3-pin",
            "Port_1_Face": "Спереду (Front)",
            "Port_2_Type": "Jack 6.35mm",
            "Port_2_Face": "Спереду (Front)",
            "Port_3_Type": "USB-C",
            "Port_3_Face": "Ззаду (Back)",
            "Feet_Type": "Пази під гумові ніжки (Recesses)",
            "Render_Quality": "Normal",
        },
    },
    {
        "name": "06_midi_controller",
        "title": "MIDI Controller Box",
        "desc": "120×80×40 mm, MIDI DIN-5, USB-B, Jack 3.5 mm",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "8 Gadget 120x80x40",
            "Port_1_Type": "MIDI DIN-5",
            "Port_1_Face": "Ззаду (Back)",
            "Port_2_Type": "USB-B",
            "Port_2_Face": "Ззаду (Back)",
            "Port_3_Type": "Jack 3.5mm",
            "Port_3_Face": "Спереду (Front)",
            "Render_Quality": "Normal",
        },
    },
    # ── Industrial / networking ────────────────────────────────────────────────
    {
        "name": "07_network_router",
        "title": "Network Router Box",
        "desc": "140×90×35 mm, RJ45 ×2, honeycomb sides + top",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "10 Router 140x90x35",
            "Port_1_Type": "RJ45 Ethernet",
            "Port_1_Face": "Спереду (Front)",
            "Port_2_Type": "RJ45 Ethernet",
            "Port_2_Face": "Ззаду (Back)",
            "Vent_Top_Dakh": "Соти (Honeycomb)",
            "Vent_Side_Face": "Зліва та Справа (Left & Right)",
            "Vent_Side_Style": "Слоти (Slots)",
            "Render_Quality": "Normal",
        },
    },
    {
        "name": "08_psu_box",
        "title": "PSU / Power Box",
        "desc": "160×110×60 mm, IEC C14 inlet, ventilation slots",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "12 PSU-Box 160x110x60",
            "Port_1_Type": "IEC AC 220V",
            "Port_1_Face": "Ззаду (Back)",
            "Port_2_Type": "XT60",
            "Port_2_Face": "Спереду (Front)",
            "Vent_Side_Face": "Зліва та Справа (Left & Right)",
            "Vent_Side_Style": "Слоти (Slots)",
            "Vent_Top_Dakh": "Слоти (Slots)",
            "Render_Quality": "Normal",
        },
    },
    # ── Ventilation showcase ───────────────────────────────────────────────────
    {
        "name": "09_honeycomb_all",
        "title": "Full Honeycomb",
        "desc": "120×80×40 mm, honeycomb on top + sides",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "8 Gadget 120x80x40",
            "Vent_Top_Dakh": "Соти (Honeycomb)",
            "Vent_Bottom_Dno": "Отвори (Holes)",
            "Vent_Side_Face": "Зліва та Справа (Left & Right)",
            "Vent_Side_Style": "Соти (Honeycomb)",
            "Render_Quality": "Normal",
        },
    },
    {
        "name": "10_slots_top_side",
        "title": "Ventilation Slots",
        "desc": "115×70×35 mm, slot ventilation top + back side",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "6 Handheld 115x70x35",
            "Vent_Top_Dakh": "Слоти (Slots)",
            "Vent_Side_Face": "Ззаду (Back)",
            "Vent_Side_Style": "Слоти (Slots)",
            "Render_Quality": "Normal",
        },
    },
    # ── Connectors showcase ────────────────────────────────────────────────────
    {
        "name": "11_multi_connector",
        "title": "Multi-Connector Panel",
        "desc": "4 connectors on 4 different faces",
        "params": {
            "Part_Chastyna": "База (Base)",
            "Enclosure_Preset": "11 Mainframe 150x100x50",
            "Port_1_Type": "USB-C",
            "Port_1_Face": "Спереду (Front)",
            "Port_2_Type": "HDMI",
            "Port_2_Face": "Ззаду (Back)",
            "Port_3_Type": "RJ45 Ethernet",
            "Port_3_Face": "Зліва (Left)",
            "Port_4_Type": "IEC AC 220V",
            "Port_4_Face": "Справа (Right)",
            "Render_Quality": "Normal",
        },
    },
    # ── Text labels showcase ───────────────────────────────────────────────────
    {
        "name": "12_text_labels",
        "title": "Text Labels",
        "desc": "Deboss text on front, emboss on top",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "8 Gadget 120x80x40",
            "Text_1_Custom_Tekst": "MY DEVICE",
            "Text_1_Face_Gran": "Спереду (Front)",
            "Text_1_Depth_Glybyna": -1.0,
            "Text_1_Size_Rozmir": 10.0,
            "Text_2_Custom_Tekst": "v1.0",
            "Text_2_Face_Gran": "Дах (Top)",
            "Text_2_Depth_Glybyna": 0.8,
            "Text_2_Size_Rozmir": 8.0,
            "Render_Quality": "Normal",
        },
    },
    # ── Joint types showcase ───────────────────────────────────────────────────
    {
        "name": "13_joint_lip",
        "title": "Lip Joint",
        "desc": "100×60×30 mm, lip (губа) joint profile",
        "params": {
            "Part_Chastyna": "Всі деталі (All)",
            "Length_Dovzhyna": 100,
            "Width_Shyryna": 60,
            "Height_Vysota": 30,
            "Joint_Styk": "Губа (Lip)",
            "Render_Quality": "Normal",
        },
    },
    {
        "name": "14_joint_ledge",
        "title": "Ledge Joint",
        "desc": "100×60×30 mm, ledge (сходинка) joint profile",
        "params": {
            "Part_Chastyna": "Всі деталі (All)",
            "Length_Dovzhyna": 100,
            "Width_Shyryna": 60,
            "Height_Vysota": 30,
            "Joint_Styk": "Сходинка (Ledge)",
            "Render_Quality": "Normal",
        },
    },
    # ── Sizes showcase ────────────────────────────────────────────────────────
    {
        "name": "15_size_micro",
        "title": "Micro-Dongle",
        "desc": "Smallest preset: 50×35×22 mm",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "1 Micro-Dongle 50x35x22",
            "Render_Quality": "Normal",
        },
    },
    {
        "name": "16_size_maxi",
        "title": "Maxi Box 250×180",
        "desc": "Largest preset: 250×180×100 mm  🔒 PRO",
        "camera": "--camera=0,0,0,45,0,315,900",
        "params": {
            "Part_Chastyna": "Зібраний (Assembled)",
            "Enclosure_Preset": "15 Maxi 250x180x100",
            "Vent_Top_Dakh": "Соти (Honeycomb)",
            "Render_Quality": "Draft",
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


def build_cmd(openscad, cfg, output_png, size):
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
    cmd += ["-o", str(output_png), str(SCAD_FILE)]
    return cmd


def render_one(openscad, cfg, output_dir, size):
    name = cfg["name"]
    output_png = output_dir / f"{name}.png"
    cmd = build_cmd(openscad, cfg, output_png, size)
    start = time.time()
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True,
            timeout=TIMEOUT, cwd=PROJECT_DIR,
            encoding="utf-8", errors="replace"
        )
        elapsed = round(time.time() - start, 1)
        ok = result.returncode == 0 and output_png.exists() and output_png.stat().st_size > 0
        with _lock:
            marker = "✓" if ok else "✗"
            print(f"  {marker} [{elapsed:5.1f}s] {name}")
            if not ok and result.stderr:
                for line in result.stderr.strip().split("\n")[-3:]:
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
    lines = [
        "# Parametric Enclosure Generator — Gallery",
        "",
        f"*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')} · "
        f"{sum(1 for r in results if r['ok'])}/{len(results)} renders OK*",
        "",
    ]
    # Group by 2 for table layout
    ok_results = [r for r in results if r["ok"]]
    it = iter(ok_results)
    pairs = list(zip(it, it))
    remainder = ok_results[len(pairs)*2:]

    lines.append('<table>')
    for a, b in pairs:
        ca = configs_map[a["name"]]
        cb = configs_map[b["name"]]
        lines.append('<tr>')
        lines.append(f'<td width="50%">\n\n![{ca["title"]}]({a["name"]}.png)\n\n**{ca["title"]}**  \n{ca["desc"]}\n\n</td>')
        lines.append(f'<td width="50%">\n\n![{cb["title"]}]({b["name"]}.png)\n\n**{cb["title"]}**  \n{cb["desc"]}\n\n</td>')
        lines.append('</tr>')
    if remainder:
        lines.append('<tr>')
        r = remainder[0]
        cr = configs_map[r["name"]]
        lines.append(f'<td width="50%">\n\n![{cr["title"]}]({r["name"]}.png)\n\n**{cr["title"]}**  \n{cr["desc"]}\n\n</td>')
        lines.append('<td width="50%"></td>')
        lines.append('</tr>')
    lines.append('</table>')
    lines += [
        "",
        "---",
        "",
        "## Get the PRO Version",
        "",
        "[![Get PRO on Gumroad](https://img.shields.io/badge/PRO%20Version-Gumroad-ff90e8?logo=gumroad&style=for-the-badge)](https://belik.gumroad.com/l/idxwoz)",
        "",
        "*26 connectors · 15 presets · Fan mounts · Removable panels · DIN rail · VESA · PCB standoffs*",
    ]
    (output_dir / "index.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"\n  index.md written → {output_dir / 'index.md'}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Render gallery PNGs via OpenSCAD CLI")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="Output folder")
    parser.add_argument("--size", default=DEFAULT_SIZE, help="Image size WxH (default 1280x960)")
    parser.add_argument("--parallel", type=int, default=2, help="Parallel renders (default 2)")
    parser.add_argument("--config", default=None, help="Comma-separated names to render, prefix 'only:' to skip others")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without rendering")
    args = parser.parse_args()

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
    print(f"Rendering {len(configs)} configurations → {output_dir}")
    print(f"OpenSCAD: {openscad}")
    print(f"Image size: {args.size}  Parallel: {args.parallel}\n")

    if args.dry_run:
        for cfg in configs:
            cmd = build_cmd(openscad or "openscad", cfg, output_dir / f"{cfg['name']}.png", args.size)
            print("DRY-RUN:", " ".join(str(x) for x in cmd))
        return

    start_total = time.time()
    results = []

    if args.parallel > 1:
        with ThreadPoolExecutor(max_workers=args.parallel) as ex:
            futures = {ex.submit(render_one, openscad, cfg, output_dir, args.size): cfg for cfg in configs}
            for f in as_completed(futures):
                results.append(f.result())
        results.sort(key=lambda r: r["name"])
    else:
        for i, cfg in enumerate(configs, 1):
            print(f"  [{i}/{len(configs)}] {cfg['name']}...", end=" ", flush=True)
            r = render_one(openscad, cfg, output_dir, args.size)
            results.append(r)

    elapsed_total = round(time.time() - start_total, 1)
    ok_count = sum(1 for r in results if r["ok"])
    print(f"\n{'='*50}")
    print(f"Done: {ok_count}/{len(results)} OK in {elapsed_total}s")

    build_index_md(results, output_dir, configs_map)

    # Save render log
    log_path = output_dir / "render_log.json"
    log_path.write_text(json.dumps({
        "timestamp": datetime.now().isoformat(),
        "openscad": openscad,
        "size": args.size,
        "total_sec": elapsed_total,
        "results": results,
    }, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  render_log.json → {log_path}")


if __name__ == "__main__":
    main()
