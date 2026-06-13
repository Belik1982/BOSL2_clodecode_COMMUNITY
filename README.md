# Parametric Enclosure Generator v14.0

**Generate ready-to-print 3D enclosures for electronics in minutes.**  
One `.scad` file · 130+ parameters · OpenSCAD Customizer · No CAD skills needed

**Генеруйте готові до друку 3D-корпуси для електроніки за лічені хвилини.**  
Один файл `.scad` · 130+ параметрів · Customizer в OpenSCAD · Без знань CAD

---

> **This is the developer source repository.**  
> It contains all modules with edition-switching logic (`_EDITION = "community"` / `"pro"`).  
> For ready-to-use distributions see the [repositories table](#repositories--репозиторії) below.
>
> **Це репозиторій розробника.**  
> Містить усі модулі з логікою перемикання редакції (`_EDITION = "community"` / `"pro"`).  
> Готові дистрибутиви — у [таблиці репозиторіїв](#repositories--репозиторії) нижче.

---

## How It Works / Як це працює

Open `enclosure.scad` in OpenSCAD. The **Customizer** panel opens on the right.  
Set dimensions → pick connectors → choose fastening → press **F6** → export STL.  
No scripting. No CAD experience required. Just sliders and dropdowns.

Відкрийте `enclosure.scad` в OpenSCAD. Праворуч з'явиться панель **Customizer**.  
Задайте розміри → виберіть роз'єми → вкажіть кріплення → натисніть **F6** → експортуйте STL.  
Без скриптів. Без досвіду CAD. Тільки слайдери і випадаючі меню.

---

## What You Can Build / Що можна зробити

| Example / Приклад | Preset / Пресет | Key features / Ключові функції |
|---|---|---|
| Arduino Nano box | Mini-Gauge 100×60×25 | USB-C, PCB standoffs, heat-set M3 |
| Raspberry Pi 4 case | Gadget 120×80×40 | USB-C + HDMI + RJ45, fan 40 mm, honeycomb |
| IoT sensor node | Sensor 85×50×21 | RJ45, wire gland M16, keyhole slots |
| Audio DI box | Project 115×75×40 | XLR + Jack 6.35 + IEC C8 |
| Industrial controller | Automation 200×120×55 | DIN rail TS-35, snap-fit, IP54 gasket |
| Field instrument | Handheld 115×70×35 | Magnets, DB9, rubber feet, PETG |

---

## FREE vs PRO

| Feature / Функція | 🆓 Community (FREE) | 🔒 PRO |
|---|:---:|:---:|
| Enclosure size 20–400 mm / Розмір корпусу 20–400 мм | ✅ | ✅ |
| Self-tapping screw fastening / Кріплення саморізами | ✅ | ✅ |
| Flat joint / З'єднання Плоске | ✅ | ✅ |
| Top / Bottom ventilation slots / Вентиляція верх/низ | ✅ | ✅ |
| 6 connectors: USB-C/A, DC Jack, Jack 3.5, RJ45, HDMI | ✅ | ✅ |
| 5 size presets / 5 пресетів розміру | ✅ | ✅ |
| 2 text label fields, 3 fonts / 2 поля тексту, 3 шрифти | ✅ | ✅ |
| PLA / PETG with shrinkage compensation | ✅ | ✅ |
| Internal dividers X / Y / Внутрішні перегородки X / Y | ✅ | ✅ |
| Wire cutouts / Прорізи для кабелів | ✅ | ✅ |
| Preview colors / Кольори в превью | ✅ | ✅ |
| **Snap-fit, magnets, heat-set inserts, hex nuts** | — | ✅ |
| **Lip / Ledge joint profiles / З'єднання Губа / Сходинка** | — | ✅ |
| **IP54 gasket groove / Паз під ущільнювач IP54** | — | ✅ |
| **All 26 connector types / Усі 26 типів роз'ємів** | — | ✅ |
| **All 15 size presets / Усі 15 пресетів** | — | ✅ |
| **Side wall ventilation + honeycomb / Бокова вентиляція + стільники** | — | ✅ |
| **Cooling fan mounts 30/40/60/80/120 mm / Кріплення вентилятора** | — | ✅ |
| **DIN rail TS-35 clip / Защіпка DIN TS-35** | — | ✅ |
| **VESA 75×75 / 100×100** | — | ✅ |
| **Mounting ears / Монтажні вушки** | — | ✅ |
| **Keyhole wall slots / Пазові прорізи під шурупи** | — | ✅ |
| **Rubber feet / Гумові ніжки** | — | ✅ |
| **Removable side panels (tongue-and-groove) / Знімні стінки (шип-паз)** | — | ✅ |
| **PCB standoffs M2 / M2.5 / M3 / Стійки під PCB** | — | ✅ |
| **4 text fields, 12 fonts / 4 поля тексту, 12 шрифтів** | — | ✅ |
| **LED light pipes / Світловоди для LED** | — | ✅ |
| **ABS / ASA / Custom material / Матеріал ABS / ASA / Довільний** | — | ✅ |
| **Cable glands M12 / M16 / M20 / Кабельні вводи** | — | ✅ |
| **Bill of materials + print hints / Специфікація + підказки для друку** | — | ✅ |

---

## Quick Start / Швидкий старт

```
EN:
1. Install OpenSCAD (2021.01 or newer — dev snapshot recommended)
2. Open enclosure.scad
3. Press Ctrl+Shift+C to open the Customizer panel
4. Adjust parameters (groups 01–17)
5. Press F5 for preview, F6 for full render
6. File → Export → Export as STL

UA:
1. Встановіть OpenSCAD (2021.01 або новіший — рекомендується dev-збірка)
2. Відкрийте enclosure.scad
3. Натисніть Ctrl+Shift+C — відкриється панель Customizer
4. Налаштуйте параметри (групи 01–17)
5. F5 — превью, F6 — повний рендер
6. File → Export → Export as STL
```

**Tip / Порада:** Use the **Manifold** rendering backend — it renders complex geometry 10–50× faster than CGAL.  
Увімкніть бекенд **Manifold** (Edit → Preferences → Features → manifold) — рендерить в 10–50 разів швидше за CGAL.

---

## Connector Reference / Довідник роз'ємів (26 types / типів)

**USB:** USB-A, USB-A Dual Stack, USB-B, USB-C, Micro-USB, Mini-USB  
**Video / Data:** HDMI, Mini-HDMI, RJ45  
**D-Sub:** DB9 (DE-9), DB15 (DA-15), DB25  
**Audio:** XLR 3-pin, XLR 5-pin, Speakon NL4, Jack 3.5 mm, Jack 6.35 mm, MIDI DIN-5  
**Power:** DC Jack M8, DC Jack M11, XT30, XT60, IEC C14, IEC C8  
**Circular / Авіаційні:** GX16 Aviation, GX20 Aviation

All cutout dimensions verified against manufacturer datasheets (IEC 60320, EIA-574, ISO 273).  
Розміри всіх вирізів перевірені за даташитами виробників (IEC 60320, EIA-574, ISO 273).

---

## Supported Materials / Матеріали

| Material / Матеріал | Shrinkage / Усадка | Best For / Підходить для |
|---|:---:|---|
| PLA | 0.3% | Indoor, prototypes / Приміщення, прототипи |
| PETG | 0.5% | Moisture-resistant, impact / Вологостійкість, удари |
| ABS 🔒 | 0.8% | Heat-resistant, industrial / Жаростійкість, промисловість |
| ASA 🔒 | 0.6% | UV-resistant, outdoor / УФ-стійкість, вулиця |
| Custom 🔒 | 0–3.0% | Specialty filaments / Спеціальні філаменти |

---

## System Requirements / Системні вимоги

| | Minimum / Мінімум | Recommended / Рекомендовано |
|---|---|---|
| OpenSCAD | 2021.01 | 2024 dev snapshot |
| RAM | 4 GB | 16 GB |
| OS | Windows 10 / macOS 11 / Ubuntu 20.04 | Windows 11 |
| Slicer / Слайсер | Any STL-compatible / Будь-який STL | Bambu Studio 1.9+ |

---

## File Structure / Структура файлів

```
enclosure.scad          ← open this in OpenSCAD / відкрийте в OpenSCAD
modules/                ← 13 implementation modules / 13 модулів реалізації
  constants.scad
  base_lid.scad
  panels.scad
  assembly.scad
  ... (9 more / ще 9)
BOSL2/                  ← library (included, no extra install / бібліотека, вже включена)
tests/                  ← automated tests / автоматичні тести
DOCUMENTATION_EN.md     ← full parameter reference (English)
DOCUMENTATION_UA.md     ← повний довідник параметрів (Українська)
DOCUMENTATION_RU.md     ← полный справочник параметров (Русский)
PRODUCT_SHEET.md        ← one-page feature overview / короткий огляд функцій
```

---

## License / Ліцензія

**CC BY-NC-ND 4.0** — Attribution · Non-Commercial · No Derivatives  
**CC BY-NC-ND 4.0** — Із зазначенням авторства · Некомерційне · Без похідних творів

---

## Repositories / Репозиторії

| Edition / Редакція | Link / Посилання | Who Is It For / Для кого |
|---|---|---|
| 🆓 Community (FREE) | https://github.com/Belik1982/BOSL2_clodecode_COMMUNITY | Hobbyists, learning, non-commercial / Хобі, навчання, некомерційне |
| 🔒 PRO | https://github.com/Belik1982/BOSL2_clodecode_PRO | Professional use, full feature set / Комерційне використання, повний набір функцій |
| 🛠 Developer Source | *this repository / цей репозиторій* | Developers, contributors / Розробники, контрибутори |
