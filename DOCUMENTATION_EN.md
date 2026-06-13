# Parametric Enclosure Generator v14.0 — COMMUNITY EDITION (FREE) EDITION (FREE)

> **Platform:** OpenSCAD 2021.01+ (dev snapshot recommended)  
> **Library:** BOSL2 (included)  
> **Export:** STL · 3MF · AMF

**Legend:**  
🆓 Available in Community (FREE) edition  
🔒 PRO edition only  
✅ Available in both editions

---

## Table of Contents

1. [Installation](#1-installation)
2. [First Steps](#2-first-steps)
3. [Customizer Groups Overview](#3-customizer-groups-overview)
4. [Parameter Reference](#4-parameter-reference)
5. [Connector Types](#5-connector-types)
6. [Size Presets](#6-size-presets)
7. [Fastening Comparison](#7-fastening-comparison)
8. [Ventilation Guide](#8-ventilation-guide)
9. [Materials & Shrinkage](#9-materials--shrinkage)
10. [Workflow: Parameters to Print](#10-workflow-parameters-to-print)
11. [Bambu Studio Settings](#11-bambu-studio-settings)
12. [FAQ](#12-faq)
13. [Appendix: Console Output](#13-appendix-console-output)
14. [Appendix: Keyboard Shortcuts](#14-appendix-keyboard-shortcuts)

---

## 1. Installation

### Step 1 — Install OpenSCAD

Download from [openscad.org](https://openscad.org/downloads.html).  
The **development snapshot** (2024.xx) is strongly recommended — it includes the **Manifold** rendering backend which is 10–50× faster than the default CGAL.

After installing the dev snapshot:
1. Go to **Edit → Preferences → Features**
2. Enable **"manifold"**
3. Restart OpenSCAD


> ⚠️ **Important:** The full path to the project folder must contain **Latin characters only**.  
> Cyrillic or other non-ASCII characters in any parent folder name will cause OpenSCAD to fail loading `BOSL2/` and `modules/` with "Can't open include file" errors.  
> ✅ `C:\Projects\enclosure` — works  
> ❌ `C:\Проекты\enclosure` — fails

> ⚠️ **Important:** The full path to the project folder must contain **Latin characters only**.  
> Cyrillic or other non-ASCII characters in any parent folder name will cause OpenSCAD to fail loading `BOSL2/` and `modules/` with "Can't open include file" errors.  
> ✅ `C:\Projects\enclosure` — works  
> ❌ `C:\Projects_Кириллица\enclosure` — fails

### Step 2 — Open the Project

1. Launch OpenSCAD
2. **File → Open** → select `enclosure.scad`
3. Press **Ctrl+Shift+C** to open the Customizer panel
4. Press **F5** for a quick preview

### Step 3 — Set Your Edition

At the top of `enclosure.scad`, line 12:
```scad
_EDITION = "community";   // change to "pro" for PRO edition
```

---

## 2. First Steps

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **F5** | Quick preview (fast, for navigation) |
| **F6** | Full render (accurate, for STL export) |
| **F7** | Export to file after F6 |
| **Ctrl+Shift+C** | Open / close Customizer |
| **Ctrl+4 / 5** | Top view / isometric view |
| **PageUp / Down** | Zoom |

### Render Modes

Set `Part_Chastyna` in group 01 to display what you need:

| Value | Shows |
|-------|-------|
| `Всі деталі (All)` | Base + lid side by side (for printing layout) |
| `База (Base)` | Base only |
| `Кришка (Lid)` | Lid only |
| `Зібраний (Assembled)` | Assembled enclosure |
| `Напіввідкритий (Ajar)` | Lid slightly open (inspect joint fit) |
| `Стійки PCB (PCB Standoffs)` | Standoffs only (print separately) 🔒 |
| `Панель X (X-Panel)` | Left/right removable panel 🔒 |
| `Панель Y (Y-Panel)` | Front/back removable panel 🔒 |

### Typical Workflow

1. Start with group **02** (dimensions) — set L × W × H
2. Group **03** — wall thickness
3. Group **04** — joint profile
4. Group **05** — lid fastening type
5. Groups **07–14** — optional features (panels, PCB, connectors, ventilation...)
6. Group **15** — text labels
7. **F5** after each change to preview
8. **F6 → F7** to export STL

---

## 3. Customizer Groups Overview

| Group | Name | Edition |
|-------|------|---------|
| 01 | Display & Render | ✅ |
| 02 | Main Dimensions | ✅ |
| 03 | Walls & Corners | ✅ |
| 04 | Joint Profile & Sealing | ✅/🔒 |
| 05 | Lid Fastening | ✅/🔒 |
| 06 | Snap-Fit Settings | 🔒 |
| 07 | Removable Side Panels | 🔒 |
| 08 | Internal Dividers | ✅ |
| 09 | PCB Standoffs | 🔒 |
| 10 | Wire Cutouts & Cable Glands | ✅/🔒 |
| 11 | Connectors (up to 8 slots) | ✅/🔒 |
| 12 | LED Light Pipes | 🔒 |
| 13 | Ventilation & Cooling | ✅/🔒 |
| 14 | Mounting & Feet | 🔒 |
| 14b | DIN Rail / VESA | 🔒 |
| 15 | Text & Labeling | ✅/🔒 |
| 16 | Material & Shrinkage | ✅/🔒 |
| 17 | System Settings (colors) | ✅ |
| 18 | Advanced Tolerances | ✅ |

---

## 4. Parameter Reference

### Group 02 — Main Dimensions ✅

| Parameter | Range | Default | Description |
|-----------|-------|---------|-------------|
| `Length_Dovzhyna` | 20–400 mm | 100 | External length (X axis) |
| `Width_Shyryna` | 20–400 mm | 60 | External width (Y axis) |
| `Height_Vysota` | 10–300 mm | 30 | Total external height |
| `Split_Proportsiya` | 10–90 % | 70 | Base share of total height |
| `Enclosure_Preset` | 15 presets | Custom | Size preset (overrides L/W/H) — presets 1–5 🆓, 6–15 🔒 |

> When a preset is selected, `Length`, `Width`, `Height` values are overwritten automatically.

### Group 03 — Walls & Corners ✅

| Parameter | Range | Default | Description |
|-----------|-------|---------|-------------|
| `Wall_Stinka` | 0.8–8.0 mm | 3.0 | Side wall thickness |
| `Bottom_Dno` | 0.8–8.0 mm | 2.0 | Base floor thickness |
| `Top_Dakh` | 0.8–8.0 mm | 2.0 | Lid ceiling thickness |
| `Radius_Kutiv` | 0–40 mm | 4.0 | External corner rounding |
| `Chamfer_Faska` | 0–3.0 mm | 0.4 | Bottom edge chamfer |

**Recommended wall thickness (0.4 mm nozzle):**

| Use Case | Thickness | Perimeters |
|----------|-----------|------------|
| Decorative / lightweight | 1.6 mm | 4 |
| General purpose | 2.4–3.0 mm | 6–7 |
| Heavy-duty / industrial | 4.0+ mm | 10+ |

### Group 04 — Joint Profile & Sealing

| Parameter | Values | Default | Edition |
|-----------|--------|---------|---------|
| `Joint_Styk` | Flat / Lip / Ledge | Lip | Flat 🆓, Lip 🔒, Ledge 🔒 |
| `Lip_Height_Vysota` | 1.0–10.0 mm | 2.5 | 🔒 |
| `Lip_Thick_Tovshchyna` | 0.4–4.0 mm | 1.6 | 🔒 |
| `Clearance_Zazor` | 0.05–0.60 mm | 0.15 | ✅ |
| `Gasket_Groove_Enable` | true/false | false | 🔒 |
| `Gasket_Groove_Width` | 1.0–5.0 mm | 2.0 | 🔒 |
| `Gasket_Groove_Depth` | 0.5–4.0 mm | 1.5 | 🔒 |

**Joint type comparison:**

| Type | Description | IP Rating |
|------|-------------|-----------|
| **Flat** | Simple butt joint, no overlap | None |
| **Lip** 🔒 | Overlap tongue on base, fits into lid | — |
| **Ledge** 🔒 | Recessed ring, most precise mating | IP54 with gasket |

### Group 05 — Lid Fastening

| Parameter | Values | Default | Edition |
|-----------|--------|---------|---------|
| `Fastening_Kriplennya` | 5 types | Nuts | Self-tap 🆓, others 🔒 |
| `Screw_Gvynt` | M2 / M2.5 / M3 / M4 / M5 | M3 | ✅ |
| `Head_Golovka` | Socket / Button / CSK | CSK | ✅ |
| `Offset_Vidstup` | 2.0–30.0 mm | 8.0 | ✅ |
| `Magnet_Dia_Diametr` | 1.0–20.0 mm | 4.2 | 🔒 |
| `Magnet_Thick_Tovshchyna` | 0.5–10.0 mm | 1.8 | 🔒 |
| `Magnet_Press_Fit` | -0.30…+0.10 mm | -0.10 | 🔒 |

> `Offset_Vidstup` 2–4 mm: boss merges with corner wall.  
> `Offset_Vidstup` 6–10 mm: floating boss with gusset ribs for extra rigidity.

### Group 06 — Snap-Fit Settings 🔒

*Active only when `Fastening_Kriplennya = "Защіпки (Snaps)"`*

| Parameter | Range | Default | Description |
|-----------|-------|---------|-------------|
| `Snap_Style_Styl` | 3 profiles | Trapezoid | Snap cross-section shape |
| `Snap_X_Kilkist` | 0–5 | 2 | Snap count along X axis |
| `Snap_Y_Kilkist` | 0–5 | 1 | Snap count along Y axis |
| `Snap_Width_Shyryna` | 2–30 mm | 15.0 | Snap arm width |
| `Snap_Depth_Glybyna` | 0.3–3.0 mm | 0.8 | Engagement depth |
| `Snap_Clearance` | 0.05–0.50 mm | 0.15 | Clearance between snap halves |
| `Snap_Tongue_Enable` | true/false | true | Cantilever relief cuts |

### Group 07 — Removable Side Panels 🔒

Panels slide in from the open side (before lid is placed) and lock via a full-length trapezoidal tongue-and-groove joint.

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `Panel_Enable` | true/false | false | Enable removable panels |
| `Panel_Walls` | Front+Back / Left+Right / All 4 | Front+Back | Which walls are removable |
| `Panel_Cl` | 0.1–0.5 mm | 0.2 | Sliding clearance |

> Tongue height and width auto-calculated from wall and floor thickness. Lid locks panels in place — panels can only be removed with the lid off.

### Group 08 — Internal Dividers ✅

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `Divider_Type` | None / X-Axis / Y-Axis | None | Divider orientation |
| `Divider_Pos_Offset` | -150…+150 mm | 0.0 | Offset from center |
| `Divider_Thickness` | 0.8–5.0 mm | 1.6 | Wall thickness |
| `Divider_Height` | 2.0–150.0 mm | 15.0 | Height from floor |
| `Divider_Wire_Hole` | true/false | false | Wire routing hole |
| `Divider_Wire_Hole_Dia` | 4.0–30.0 mm | 8.0 | Hole diameter |

### Group 09 — PCB Standoffs 🔒

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `PCB_Enable_Stiyky` | true/false | false | Enable standoffs |
| `PCB_Fused_To_Base` | true/false | true | Fused to base (false = print separately) |
| `PCB_Count_Kilkist` | 2 / 3 / 4 / 6 | 4 | Standoff count |
| `PCB_X_Vidstup` | 2–100 mm | 10.0 | X offset from inner wall |
| `PCB_Y_Vidstup` | 2–100 mm | 10.0 | Y offset from inner wall |
| `PCB_Height_Vysota` | 2–60 mm | 5.0 | Standoff height |
| `PCB_Screw_Gvynt` | M2 / M2.5 / M3 | M3 | PCB screw size |
| `PCB_Layout_Mode` | Corners / Grid | Corners | Placement mode |
| `PCB_Grid_Cols` | 2–6 | 2 | Grid columns (Grid mode) |
| `PCB_Grid_Rows` | 2–6 | 2 | Grid rows (Grid mode) |

> `PCB_Fused_To_Base = false` → use `Part_Chastyna = "Стійки PCB"` to render and export standoffs separately for printing with different material or settings.

### Group 10 — Wire Cutouts & Cable Glands

| Parameter | Values | Default | Edition |
|-----------|--------|---------|---------|
| `Wire_Face_Gran` | Front/Back/Left/Right/None | None | Cutout face |
| `Wire_Shape_Forma` | Circle / Slot / Glands | Slot | Cutout shape |
| `Wire_Size1_Rozmir` | 2–50 mm | 12.0 | Diameter (circle) or width (slot) |
| `Wire_Size2_Rozmir` | 2–50 mm | 6.0 | Slot height |
| `Wire_X_Zmishennya` | -100…+100 mm | 0.0 | Horizontal offset |
| `Wire_Z_Vysota` | 0–100 mm | 5.0 | Z height from floor |

Circle and Slot: 🆓 · Cable glands: 🔒

**Cable gland types 🔒:**

| Type | Thread | Cable Range |
|------|--------|-------------|
| M12 Clearance | — | Simple Ø12 mm hole |
| M16 Clearance | — | Simple Ø16 mm hole |
| M20 Clearance | — | Simple Ø20 mm hole |
| M12 Threaded | M12×1.5 | IP54–IP68 gland fitting |
| M16 Threaded | M16×1.5 | Cables Ø4–8 mm |
| M20 Threaded | M20×1.5 | Cables Ø6–12 mm |

### Group 11 — Connectors (1–8 Slots)

Set `Port_Count` (1–8) to define how many connectors are active.  
For each slot N (1–8):

| Parameter | Values | Edition |
|-----------|--------|---------|
| `Port_N_Type` | 26 connector types | 6 types 🆓, all 26 🔒 |
| `Port_N_Face` | Front / Back / Left / Right | ✅ |
| `Port_N_Offset_1` | -150…+150 mm | ✅ |
| `Port_N_Offset_2` | -100…+100 mm | ✅ |
| `Port_N_Rot_Kut` | 0–359° | ✅ |
| `Port_Clearance` | 0.0–1.0 mm | ✅ |

### Group 12 — LED Light Pipes 🔒

| Parameter | Range | Default | Description |
|-----------|-------|---------|-------------|
| `LightPipe_Enable` | true/false | false | Enable light pipes |
| `LightPipe_Face` | 4 faces | Front | Face |
| `LightPipe_Count` | 1–8 | 2 | Number of pipes |
| `LightPipe_Spacing` | 4–30 mm | 10.0 | Spacing |
| `LightPipe_Outer_Dia` | 2–12 mm | 5.0 | Outer diameter (lens) |
| `LightPipe_Inner_Dia` | 1–8 mm | 3.0 | Inner channel (LED clearance) |
| `LightPipe_Socket_Depth` | 2–10 mm | 4.0 | Socket depth |
| `LightPipe_Offset_X` | -100…+100 mm | 0.0 | X offset |
| `LightPipe_Z` | 2–100 mm | 8.0 | Z height |

### Group 13 — Ventilation & Cooling

| Parameter | Values | Edition |
|-----------|--------|---------|
| `Vent_Top_Dakh` | None / Slots / Holes / Honeycomb | None & Slots 🆓, Holes & Honeycomb 🔒 |
| `Vent_Bottom_Dno` | None / Slots / Holes / Honeycomb | None & Slots 🆓, Holes & Honeycomb 🔒 |
| `Vent_Size_Rozmir` | 1.0–15.0 mm | ✅ |
| `Vent_Spacing_Krok` | 0.5–10.0 mm | ✅ |
| `Vent_Side_Face` | None / Front / Back / Left / Right | 🔒 |
| `Vent_Side_Style` | None / Slots / Holes / Honeycomb | 🔒 |
| `Fan_Face_Gran` | Top / Front / Back / Left / Right | 🔒 |
| `Fan_Size_Rozmir` | 30 / 40 / 60 / 80 / 120 mm | 🔒 |
| `Fan_Grill_Style` | 5 styles | 🔒 |

**Fan mounting hole pitch (ISO 273 M4 clearance Ø 4.5 mm):**

| Fan | Hole Pitch |
|-----|-----------|
| 30×30 mm | 24 mm |
| 40×40 mm | 32 mm |
| 60×60 mm | 50 mm |
| 80×80 mm | 71.5 mm |
| 120×120 mm | 105 mm |

### Group 14 — External Mounting & Feet 🔒

**Mounting ears:** `Ears_Type`, `Ears_Count` (2/4), `Ears_Width`, `Ears_Length`, `Ears_Hole_Dia`, `Ears_Rounding`

**Keyhole slots:** `Keyholes_Bottom_Enable`, `Keyholes_Bottom_Count` (1–4), `Keyholes_Screw_Size` (M3–M6), `Keyholes_Std_Spacing`

**Rubber feet:** `Feet_Type` (Pads/Recesses), `Feet_Diameter`, `Feet_Height_Depth`, `Feet_Offset`

### Group 14b — DIN Rail / VESA 🔒

`DIN_Rail_Enable` — TS-35 clip (EN 60715)  
`VESA_Mount_Enable`, `VESA_Size` — 75×75 mm or 100×100 mm (MIS-D)

### Group 15 — Text & Labeling

| Feature | Community 🆓 | PRO 🔒 |
|---------|:-----------:|:-----:|
| Text fields | 2 | 4 |
| Fonts | 3 | 12 |
| Faces | Any | Any |
| Emboss / Deboss | ✅ | ✅ |
| Rotation | ✅ | ✅ |
| Offset X/Y | ✅ | ✅ |

For each field N: `Text_N_Custom_Tekst`, `Text_N_Face_Gran`, `Text_N_Font_Shryft`, `Text_N_Size_Rozmir`, `Text_N_Depth_Glybyna` (negative = deboss), `Text_N_Offset_1`, `Text_N_Offset_2`, `Text_N_Rot_Kut`

### Group 16 — Material & Shrinkage

| Material | Shrinkage | Edition |
|----------|:---------:|---------|
| PLA | 0.3% | 🆓 |
| PETG | 0.5% | 🆓 |
| ABS | 0.8% | 🔒 |
| ASA | 0.6% | 🔒 |
| Custom | 0.0–3.0% | 🔒 |

Shrinkage is applied automatically as `scale()` on XY axes. Z axis is not scaled.

### Group 17 — System Settings ✅

`Printer_Model` — select your printer for optimized console hints  
`C_BASE`, `C_LID`, `C_BOSS`, `C_SNAP`, `C_TEXT` — HEX color codes for preview (no effect on STL)  
`Auto_Optimization` — enforces minimum safe dimensions (recommended: true)

### Group 18 — Advanced Tolerances ✅

> ⚠️ **Do not change these unless you have a specific calibration reason.**

| Parameter | Default | Description |
|-----------|---------|-------------|
| `Coeff_Clearance_Hole` | 1.10 | Screw clearance hole multiplier |
| `Coeff_PCB_OD` | 2.5 | PCB boss outer diameter multiplier |
| `Coeff_Selftap_Hole` | 0.85 | Self-tapping pilot hole multiplier |
| `Coeff_Heatset_Dia` | 1.30 | Heat-set insert hole multiplier |
| `Coeff_Heatset_Depth` | 1.50 | Heat-set insert depth multiplier |

---

## 5. Connector Types

### FREE Edition (6 types) 🆓
USB-C · USB-A · DC Jack M8 · Jack 3.5 mm · RJ45 · HDMI

### PRO Edition — Full List (26 types) 🔒

**USB:** USB-A, USB-A Dual Stack, USB-B, USB-C, Micro-USB, Mini-USB

**Video / Data:** HDMI, Mini-HDMI, RJ45

**D-Sub (EIA-574 trapezoidal profile):**
DE-9 / DB9 (9-pin) · DA-15 / DB15 (15-pin) · DB-25 (25-pin)

**Audio:**
XLR 3-pin (Ø23.5) · XLR 5-pin (Ø23.5) · Speakon NL4 (Ø28.5)  
Jack 3.5 mm (Ø9.5) · Jack 6.35 mm (Ø13.0) · MIDI DIN-5 (Ø16.0)

**Power:**
DC Jack M8 (Ø8.0) · DC Jack M11 (Ø11.0)  
XT30 (17×11) · XT60 (22×11.2)  
IEC C14 / 220V (28.2×22.8, IEC 60320) · IEC C8 Fig-8 (13×9)

**Circular:** GX16 Aviation (Ø16) · GX20 Aviation (Ø20)

---

## 6. Size Presets

Presets 1–5: 🆓 · Presets 6–15: 🔒

| # | Name | L×W×H | Typical Use |
|---|------|-------|-------------|
| 1 | Micro-Dongle | 50×35×22 | USB dongle, adapter |
| 2 | Pocket | 64×41×20 | Pocket device |
| 3 | KeyFob | 80×45×16 | Remote control |
| 4 | Mini-Gauge | 100×60×25 | Small instrument |
| 5 | Sensor | 85×50×21 | Sensor module |
| 6 🔒 | Handheld | 115×70×35 | Handheld device |
| 7 🔒 | Project | 115×75×40 | General project box |
| 8 🔒 | Gadget | 120×80×40 | Hub / gadget |
| 9 🔒 | Desktop-S | 130×70×45 | Small desktop unit |
| 10 🔒 | Router | 140×90×35 | Network device |
| 11 🔒 | Mainframe | 150×100×50 | Central controller |
| 12 🔒 | PSU-Box | 160×110×60 | Power supply unit |
| 13 🔒 | Automation | 200×120×55 | Industrial controller |
| 14 🔒 | Console | 200×150×75 | Control panel |
| 15 🔒 | Maxi | 250×180×100 | Large instrument |

---

## 7. Fastening Comparison

| Type | Tools Needed | Reusable | Strength | IP Capable | Edition |
|------|:------------:|:--------:|:--------:|:----------:|---------|
| Self-tapping screws | Screwdriver | ✦ | ★★★ | — | 🆓 |
| Snap-fits | None | ✦✦ | ★★★★ | — | 🔒 |
| Magnets | None | ✦✦✦ | ★★ | — | 🔒 |
| Heat-set inserts | Soldering iron | ✦✦✦ | ★★★★★ | ✅ (with gasket) | 🔒 |
| Hex nuts | Wrench | ✦✦✦ | ★★★★★ | ✅ (with gasket) | 🔒 |

**When to use what:**
- **Prototype** → Snap-fits (fast iteration, no hardware)
- **Production** → Heat-set inserts (Ruthex M3, most durable)
- **Field access needed** → Magnets (instant open/close)
- **Industrial** → M4–M5 hex nuts with lock washers

---

## 8. Ventilation Guide

| Style | Airflow Area | Structural Strength | Look |
|-------|:-----------:|:-------------------:|------|
| Slots | High | Medium | Industrial |
| Holes 🔒 | Medium | High | Clean |
| Honeycomb 🔒 | Maximum | Maximum | Technical/premium |

Top and bottom **Slots** are available in the FREE edition.  
**Holes**, **Honeycomb**, and all **Side ventilation** require PRO.

---

## 9. Materials & Shrinkage

| Material | Bed | Nozzle | XY Shrinkage | Notes | Edition |
|----------|-----|--------|:------------:|-------|---------|
| PLA | 55–65°C | 210–230°C | 0.3% | Indoor, rigid | 🆓 |
| PETG | 70–85°C | 230–250°C | 0.5% | Impact, moisture | 🆓 |
| ABS | 100–110°C | 240–260°C | 0.8% | Heat-resistant | 🔒 |
| ASA | 100–110°C | 240–260°C | 0.6% | UV-resistant, outdoor | 🔒 |
| Custom | varies | varies | 0–3.0% | Specialty filaments | 🔒 |

Shrinkage compensation is applied automatically as `scale()` on XY. Not applied to Z (negligible in FDM).

---

## 10. Workflow: Parameters to Print

```
1. CONFIGURE
   Open Customizer → work through groups 02–17 in order
   Press F5 after each group to check visually

2. VERIFY
   Part = "Зібраний" → inspect assembled view
   Part = "Напіввідкритий" → inspect interior and joint
   Check BOM output in the console (PRO)

3. RENDER & EXPORT
   F6 → full render (1–60 seconds depending on complexity)
   File → Export → Export as STL
   Export Base and Lid separately (set Part_Chastyna accordingly)

4. SLICE (Bambu Studio recommended)
   Base: flat bottom face down, no supports
   Lid: flat top face down, no supports
   Wall loops: 5–7
   Top/Bottom layers: 8
   Infill: 20–40%

5. PRINT & ASSEMBLE
   Install heat-set inserts before assembly (if Heatset mode)
   Press-fit magnets (interference fit, Magnet_Press_Fit ≈ -0.10)
   Mount PCB, close lid
```

---

## 11. Bambu Studio Settings

The generator outputs print hints to the OpenSCAD console on every render 🔒:

```json
{"printer":"Bambu Lab P2S","filament":"PLA","layer_height":0.2,"wall_loops":5,"support_needed":false}
```

**Recommended settings:**

| Parameter | Value | Why |
|-----------|-------|-----|
| Wall loops | 5–7 | Boss thread strength |
| Top/Bottom layers | 8 | Surface quality, watertightness |
| Supports | Off | All geometry is self-supporting |
| Brim | 3–5 mm | Large enclosures > 150 mm |
| XY Compensation | Per material table | Filament shrinkage |
| Speed | Quality / Standard | Precise hole dimensions |

---

## 12. FAQ

**Q: I changed a parameter but nothing changed in the preview.**  
A: Press F5 to refresh. If still no change, check that `Port_Count` is ≥ the slot number you edited, and that the relevant feature is enabled (e.g., `Panel_Enable = true`).

**Q: F6 render takes very long (minutes).**  
A: Enable the **Manifold** backend: Edit → Preferences → Features → manifold. It is 10–50× faster. Also set `Render_Quality = "Draft"` for intermediate iterations.

**Q: The joint doesn't close properly — gap visible.**  
A: Increase `Clearance_Zazor` (try 0.20–0.25 mm). Depends on your printer's first-layer calibration.

**Q: How do I export only the base or lid?**  
A: Set `Part_Chastyna = "База (Base)"` → F6 → F7. Repeat for lid.

**Q: How do I print PCB standoffs separately?**  
A: Set `PCB_Fused_To_Base = false`, then `Part_Chastyna = "Стійки PCB"` → F6 → F7. 🔒

**Q: Connector cutout doesn't appear on the face I selected.**  
A: Check that the connector is not placed beyond the face edge. Use `Port_N_Offset_1 = 0` to center it, then adjust.

**Q: How to achieve IP54 rating?**  
A: Enable `Gasket_Groove_Enable = true` + use `Joint_Styk = "Сходинка (Ledge)"` + install an O-ring. 🔒

**Q: Where do I find recommended screw lengths?**  
A: In the OpenSCAD console after F5/F6: `INFO: Recommended screw length = XX mm`. 🔒

**Q: OpenSCAD shows "Can't open include file 'BOSL2/std.scad'" after moving the project.**  
A: The project folder path contains non-Latin (Cyrillic, Chinese, etc.) characters. Move the project to a path with Latin characters only, e.g. `C:\Projects\enclosure`. OpenSCAD cannot resolve include paths that contain non-ASCII characters.

**Q: OpenSCAD shows "Can't open include file 'BOSL2/std.scad'" after moving the project.**  
A: The project folder path contains non-Latin characters (Cyrillic, Chinese, etc.). Move the project to a path with Latin characters only, e.g. `C:\Projects\enclosure`. OpenSCAD cannot resolve include paths that contain non-ASCII characters.

**Q: Can I use Cyrillic text in labels?**  
A: Yes. Use `Liberation Sans:style=Bold` font (included in OpenSCAD) for best Cyrillic support.

**Q: Does this work with PrusaSlicer / OrcaSlicer?**  
A: Yes. Export STL from OpenSCAD and import into any slicer. Bambu Studio is recommended but not required.

---

## 13. Appendix: Console Output

Every F5/F6 render outputs to the OpenSCAD console 🔒:

```
INFO: Recommended screw length = 32 mm (M3)

=== BILL OF MATERIALS ===
Enclosure: 100 x 60 x 30 mm  (PLA, shrinkage 0.3%)
FASTENERS: M3 × 32 mm socket cap — 4 pcs
HEAT-SET INSERTS: Ruthex M3 (L=4 mm) — 4 pcs
=========================

--- BAMBU STUDIO HINTS ---
{"printer":"Bambu Lab P2S","layer_height":0.2,"wall_loops":5,"support_needed":false}
--------------------------
```

---

## 14. Appendix: Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `F5` | Quick preview |
| `F6` | Full render |
| `F7` | Export after F6 |
| `Ctrl+Shift+C` | Customizer panel |
| `Ctrl+4` | Top view |
| `Ctrl+5` | Isometric view |
| `PageUp / Down` | Zoom |
| `F9` | Show axes |

---

*Parametric Enclosure Generator v14.0 · OpenSCAD + BOSL2 · CC BY-NC-ND 4.0*
