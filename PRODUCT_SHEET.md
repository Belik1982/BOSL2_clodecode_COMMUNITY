# Parametric Enclosure Generator v14.0
### One file. 130+ parameters. Any enclosure you need.

---

## The Problem It Solves

Designing an enclosure for a custom PCB means hours in CAD: drawing walls, modeling connector cutouts, placing standoffs, figuring out lid fastening. Do it once and it takes half a day. Do it for ten different projects and it becomes a bottleneck.

This generator solves that. Set your parameters, hit render, print.

---

## How Fast Is It?

| Task | Manual CAD | This Generator |
|------|-----------|----------------|
| Basic box with one connector | 2–4 hours | 3 minutes |
| Box with PCB standoffs + 3 connectors + fan | 6–10 hours | 8 minutes |
| Iterate on lid joint clearance | 30 min/iteration | 10 sec/iteration |
| Generate BOM for ordering | Manual counting | Automatic |

---

## Feature Overview

### Dimensions & Shape
- Any size from **20 × 20 × 10 mm** to **400 × 400 × 300 mm**
- **15 one-click presets** from Micro-Dongle (50×35×22) to Maxi (250×180×100) 🔒
- Adjustable wall thickness, floor/ceiling thickness, corner rounding, bottom chamfer

### Lid Fastening (5 types)
- **Self-tapping screws** — simplest, no hardware needed 🆓
- **Snap-fits** — tool-less, three profile styles (trapezoid, rounded, triangle) 🔒
- **Magnets** — instant tool-less access, configurable press-fit tolerance 🔒
- **Heat-set inserts (Ruthex M2–M5)** — professional, reusable, longest service life 🔒
- **Hex nuts** — maximum strength, industrial use 🔒

### Joint Profiles
- **Flat** — minimal, clean aesthetic 🆓
- **Lip** — overlap joint, standard for most enclosures 🔒
- **Ledge** — recessed ring, highest IP-rating potential 🔒
- **IP54 gasket groove** — O-ring channel on any joint profile 🔒

### Connectors (26 types)
Place up to **8 connectors** on any face. All cutouts are geometrically accurate per datasheets.

**FREE (6 types):** USB-C, USB-A, DC Jack M8, Jack 3.5 mm, RJ45, HDMI

**PRO adds (20 types):** USB-A Dual, USB-B, Micro/Mini-USB, Mini-HDMI, DB9/15/25, XLR 3/5-pin, Speakon, Jack 6.35, MIDI, DC Jack M11, XT30, XT60, IEC C14, IEC C8, GX16, GX20 🔒

### Ventilation & Cooling
- Top and bottom ventilation: **slots, holes, honeycomb** patterns
  - Slots (top/bottom) 🆓 · Holes and honeycomb 🔒
- **Side wall ventilation** on any of 4 walls 🔒
- **Cooling fan mounts**: 30 / 40 / 60 / 80 / 120 mm with 5 grill styles 🔒

### PCB Support 🔒
- **Standoffs** M2 / M2.5 / M3, height 2–60 mm
- 2, 3, 4, or 6 standoffs in corner or grid layout
- Optional separate printing (PCB_Fused_To_Base = false)
- Self-tapping holes with correct diameter coefficients

### Removable Side Panels 🔒
- Full-length **tongue-and-groove** joint on top and bottom edges
- Trapezoidal tongue profile — draft angle for smooth slide-in
- Auto-sized to floor/ceiling thickness with configurable clearance
- Any combination: front+back, left+right, or all 4 walls

### Mounting & Installation
- **Mounting ears** (2 or 4), configurable size and hole diameter 🔒
- **Keyhole slots** for wall mounting without tools 🔒
- **Rubber feet** recesses or pads 🔒
- **DIN rail TS-35** clip (EN 60715) 🔒
- **VESA 75×75 / 100×100** (MIS-D standard) 🔒

### Cable Management
- **Wire cutouts**: circle or slot, any face, adjustable position 🆓
- **Cable glands M12 / M16 / M20**: clearance or threaded (IP54–IP68) 🔒
- Internal **dividers** (X or Y axis) with optional wire routing hole 🆓

### Text & Labeling
- **2 fields, 3 fonts** — FREE 🆓
- **4 independent fields, 12 fonts** — PRO 🔒
- Any face (top, bottom, front, back, left, right)
- Emboss (raised) or deboss (engraved)
- Rotation, X/Y offset

### Materials
- **PLA / PETG** with automatic XY shrinkage compensation 🆓
- **ABS / ASA / Custom** (0–3.0% custom shrinkage coefficient) 🔒

### Console Output 🔒
Every render prints to the OpenSCAD console:
- Recommended screw length for current configuration
- Bill of materials (fasteners, inserts, quantities)
- Bambu Studio print settings as JSON
- Snap-fit strain analysis (for snap configurations)

---

## Physically Correct Geometry

Cutout dimensions verified against manufacturer specifications:
- **IEC C14**: 28.2 × 22.8 mm per IEC 60320
- **Fan mounting holes**: Ø 4.5 mm (M4 clearance, ISO 273)
- **Heat-set inserts**: Ruthex M2–M5 datasheet dimensions
- **DIN rail**: TS-35 per EN 60715
- **VESA**: MIS-D 75 × 75 and 100 × 100 mm

---

## Printer Compatibility

Designed for **FDM printing**. Zero supports required — all geometry is self-supporting.

Tested on: Bambu Lab P1S, P2S, X1C, A1, A1 mini.  
Works with any FDM printer. Generates Bambu Studio hints automatically.

---

## Version History

**v14.0** (June 2026) — Modular architecture (13 files), tongue-and-groove removable panels, 108 automated tests, Manifold backend support, 26 connectors, 15 presets.

---

*OpenSCAD + BOSL2 · CC BY-NC-ND 4.0*
