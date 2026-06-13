// =============================================================================
// PARAMETRIC ENCLOSURE GENERATOR v14.0 MODULAR (BOSL2 Edition)
// =============================================================================
// Open this file in OpenSCAD and use Customizer (Ctrl+Shift+C).
// All parameters are defined below (inline for Customizer compatibility).
// Implementation modules are in modules/ directory.
// =============================================================================
include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// Edition: "community" or "pro"
_EDITION = "community";

/* [01. Рендер та Відображення (Display & Render)] */
// Вибір деталі для рендеру / Select part to render
Part_Chastyna = "Всі деталі (All)"; // ["Всі деталі (All)", "База (Base)", "Кришка (Lid)", "Зібраний (Assembled)", "Напіввідкритий (Ajar)", "Стійки PCB (PCB Standoffs)", "Панель X (X-Panel)", "Панель Y (Y-Panel)"]
// Якість геометрії (деталізація округлень) / Render quality (circle/arc resolution)
Render_Quality = "Normal"; // ["Draft", "Normal", "Fine"]

/* [02. Основні Габарити Корпусу (Main Enclosure Dimensions)] */
// Зовнішня довжина корпусу / Outer length of the enclosure
Length_Dovzhyna = 100.0; // [20.0 : 1.0 : 400.0]
// Зовнішня ширина корпусу / Outer width of the enclosure
Width_Shyryna  =  60.0; // [20.0 : 1.0 : 400.0]
// Загальна зовнішня висота / Total outer height
Height_Vysota = 30.0; // [10.0 : 1.0 : 300.0]
// Пропорція розділення (База % від висоти) / Split proportion (Base % of height)
Split_Proportsiya = 70; // [10 : 1 : 90]
// Пресет габаритів / Enclosure size preset (overrides L/W/H when not Custom)
Enclosure_Preset = "Custom"; // ["Custom","1 Micro-Dongle 50x35x22","2 Pocket 64x41x20","3 KeyFob 80x45x16","4 Mini-Gauge 100x60x25","5 Sensor 85x50x21","6 Handheld 115x70x35","7 Project 115x75x40","8 Gadget 120x80x40","9 Desktop-S 130x70x45","10 Router 140x90x35","11 Mainframe 150x100x50","12 PSU-Box 160x110x60","13 Automation 200x120x55","14 Console 200x150x75","15 Maxi 250x180x100"]

/* [03. Товщина Стінок та Радіуси (Walls, Floors & Corners)] */
// Товщина бокових стінок / Side wall thickness
Wall_Stinka = 3.0; // [0.8 : 0.2 : 8.0]
// Товщина дна бази / Base bottom thickness
Bottom_Dno = 2.0; // [0.8 : 0.2 : 8.0]
// Товщина даху кришки / Lid top thickness
Top_Dakh = 2.0; // [0.8 : 0.2 : 8.0]
// Радіус заокруглення зовнішніх кутів / Outer corner rounding radius
Radius_Kutiv = 4.0; // [0.0 : 0.5 : 40.0]
// Розмір фаски на дні / Bottom chamfer size
Chamfer_Faska = 0.4; // [0.0 : 0.1 : 3.0]

/* [04. Профіль Стику та Герметизація (Mating Joint & Sealing)] */
// Тип стику між половинами / Joint type between halves
Joint_Styk = "Губа (Lip)"; // ["Плоский (Flat)", "Губа (Lip)", "Сходинка (Ledge)"]
// Висота виступу стику / Joint lip height
Lip_Height_Vysota = 2.5; // [1.0 : 0.5 : 10.0]
// Товщина виступу стику / Joint lip thickness
Lip_Thick_Tovshchyna = 1.6; // [0.4 : 0.2 : 4.0]
// Зазор між половинами стику / Clearance between joint halves
Clearance_Zazor = 0.15; // [0.05 : 0.01 : 0.60]
// Увімкнути вологозахисний паз / Enable waterproof gasket groove
Gasket_Groove_Enable = false;
// Ширина пазу під ущільнювач / Gasket groove width
Gasket_Groove_Width = 2.0; // [1.0 : 0.1 : 5.0]
// Глибина пазу під ущільнювач / Gasket groove depth
Gasket_Groove_Depth = 1.5; // [0.5 : 0.1 : 4.0]

/* [05. Кріплення Кришки (Fastening Settings)] */
// Тип кріплення корпусу / Enclosure fastening type
Fastening_Kriplennya = "Гайки (Nuts)"; // ["Магніти (Magnets)", "Защіпки (Snaps)", "Термозакладки (Heatset)", "Гайки (Nuts)", "Саморізи (Self-tap)"]
// Розмір гвинта / Screw size
Screw_Gvynt = "M3"; // ["M2", "M2.5", "M3", "M4", "M5"]
// Тип головки гвинта / Screw head type
Head_Golovka = "Потайна (CSK)"; // ["Циліндрична (Socket)", "Напівкругла (Button)", "Потайна (CSK)"]
// Відстань від кута корпусу до осі кріплення / Fastener axis distance from corner
// 2-4мм = бобишка злита з кутом, 6-10мм = плаваюча бобишка з розпорками
// 2-4mm = corner-integrated boss, 6-10mm = floating boss with gussets
Offset_Vidstup = 8.0; // [2.0 : 0.5 : 30.0]
// Діаметр магніту / Magnet diameter
Magnet_Dia_Diametr = 4.2; // [1.0 : 0.1 : 20.0]
// Товщина магніту / Magnet thickness
Magnet_Thick_Tovshchyna = 1.8; // [0.5 : 0.1 : 10.0]
// Посадка магніту: -0.10...-0.20 = запресовка (рекомендовано), 0 = по номіналу, +0.10 = вільно
// [PRO] Magnet fit: negative = tighter press-fit (recommended -0.10), 0 = nominal, positive = loose
Magnet_Press_Fit = -0.10; // [-0.30 : 0.02 : 0.10]

/* [06. Параметри Защіпок (Snap-Fit Settings)] */
// Форма профілю защіпки / Snap-fit profile style
Snap_Style_Styl = "Трапеція (Trapezoid)"; // ["Трапеція (Trapezoid)", "Напівкруг (Rounded)", "Трикутник (Triangle)"]
// Кількість защіпок по осі X / Number of snaps along X axis
Snap_X_Kilkist = 2; // [0 : 1 : 5]
// Кількість защіпок по осі Y / Number of snaps along Y axis
Snap_Y_Kilkist = 1; // [0 : 1 : 5]
// Ширина защіпки / Snap width
Snap_Width_Shyryna = 15.0; // [2.0 : 0.5 : 30.0]
// Глибина виступу защіпки / Snap bump depth
Snap_Depth_Glybyna = 0.8; // [0.3 : 0.1 : 3.0]
// Висота виступу защіпки (0 = авто) / Snap bump height (0 = auto from lip height)
Snap_Height_Vysota = 0.0; // [0.0 : 0.1 : 8.0]
// Зазор механізму защіпки / Snap mechanism clearance
Snap_Clearance = 0.15; // [0.05 : 0.01 : 0.50]
// Увімкнути розрізи кантилевера для гнучкості / Enable cantilever tongue cuts
Snap_Tongue_Enable = true; // [false, true]
// Ширина розрізу кантилевера (0 = авто: 10% від ширини защіпки, мін 1мм) / Tongue slot width (0 = auto)
Snap_Tongue_Slot_W = 0.0; // [0.0 : 0.1 : 3.0]

/* [07. Знімні Бічні Панелі (Removable Side Panels)] */
// Увімкнути знімні бічні панелі / Enable removable side panels
Panel_Enable = false;
// Які стінки знімні / Which walls are removable
Panel_Walls = "Перед+Зад (Front+Back)"; // ["Перед+Зад (Front+Back)", "Ліво+Право (Left+Right)", "Всі 4 (All 4)"]
// Глибина кутового гнізда / Corner mortise depth into floor/ceiling (mm)
// Рекомендовано >= 3 мм для надійного утримання / Recommended >= 3 mm for secure hold
Panel_Groove_D = 3.0; // [1.5 : 0.1 : 6.0]
// Ширина кутового шипа / Corner tenon rail width (mm)
// Розмір кожного з двох кутових шипів уздовж стінки / Size of each corner tenon along the wall
Panel_Rail_W = 4.0; // [2.0 : 0.5 : 12.0]
// Зазор ковзання / Panel sliding clearance
Panel_Cl = 0.2; // [0.1 : 0.05 : 0.5]

/* [08. Внутрішні Перегородки (Internal Dividers)] */
// Тип внутрішньої перегородки / Internal divider type
Divider_Type = "Немає (None)"; // ["Немає (None)", "Подовжня (X-Axis)", "Поперечна (Y-Axis)"]
// Зміщення перегородки від центру / Divider offset from center
Divider_Pos_Offset = 0.0; // [-150.0 : 1.0 : 150.0]
// Товщина перегородки / Divider thickness
Divider_Thickness = 1.6; // [0.8 : 0.2 : 5.0]
// Висота перегородки / Divider height
Divider_Height = 15.0; // [2.0 : 1.0 : 150.0]
// Отвір для прокладання дротів / Wire routing hole in divider
Divider_Wire_Hole = false;
// Діаметр отвору для дротів / Wire routing hole diameter
Divider_Wire_Hole_Dia = 8.0; // [4.0 : 0.5 : 30.0]

/* [09. Стійки під Плату (PCB Standoffs)] */
// Увімкнути стійки для плати / Enable PCB standoffs
PCB_Enable_Stiyky = false;
// Об'єднати стійки з базою / Fuse standoffs with base (Set False to print standoffs separately)
PCB_Fused_To_Base = true; // [true, false]
// Кількість стійок / Number of standoffs
PCB_Count_Kilkist = 4; // [2, 3, 4, 6]
// Зміщення стійок по осі X / Standoffs X offset
PCB_X_Vidstup = 10.0; // [2.0 : 0.5 : 100.0]
// Зміщення стійок по осі Y / Standoffs Y offset
PCB_Y_Vidstup = 10.0; // [2.0 : 0.5 : 100.0]
// Висота стійок / Standoffs height
PCB_Height_Vysota = 5.0; // [2.0 : 0.5 : 60.0]
// Розмір гвинта для плати / PCB screw size
PCB_Screw_Gvynt = "M3"; // ["M2", "M2.5", "M3"]
// Режим розташування стійок / Standoff placement mode
PCB_Layout_Mode = "Кути (Corners)"; // ["Кути (Corners)", "Сітка (Grid)"]
// Кількість стійок по осі X (для режиму Grid) / Standoff columns (Grid mode)
PCB_Grid_Cols = 2; // [2 : 1 : 6]
// Кількість стійок по осі Y (для режиму Grid) / Standoff rows (Grid mode)
PCB_Grid_Rows = 2; // [2 : 1 : 6]

/* [10. Вирізи під Дроти та Сальники (Wire Cutouts & Cable Glands)] */
// Грань для вирізу під дроти / Face for wire cutout
Wire_Face_Gran = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Форма вирізу або сальника / Cutout or cable gland shape
Wire_Shape_Forma = "Слот (Slot)"; // ["Круг (Circle)", "Слот (Slot)", "M12 Gland (Clearance)", "M16 Gland (Clearance)", "M20 Gland (Clearance)", "M12 Gland (Threaded)", "M16 Gland (Threaded)", "M20 Gland (Threaded)"]
// Розмір 1 (Діаметр або Ширина) / Size 1 (Diameter or Width)
Wire_Size1_Rozmir = 12.0; // [2.0 : 0.5 : 50.0]
// Розмір 2 (Висота для слота) / Size 2 (Height for slot)
Wire_Size2_Rozmir = 6.0; // [2.0 : 0.5 : 50.0]
// Зміщення вирізу по осі X / Cutout X offset
Wire_X_Zmishennya = 0.0; // [-100.0 : 1.0 : 100.0]
// Висота вирізу по осі Z / Cutout Z height
Wire_Z_Vysota = 5.0; // [0.0 : 1.0 : 100.0]

// Примітка: для розвантаження кабелю використовуйте різьбовий сальник у Групі 10
// (Wire_Shape_Forma = "M12/M16/M20 Gland (Threaded)") — це промисловий стандарт.
// Note: for cable strain relief use a threaded cable gland in Group 10
// (Wire_Shape_Forma = "M12/M16/M20 Gland (Threaded)") — the industry standard.

/* [11. Стандартні Інтерфейсні Порти (Standard Interface Ports)] */
// --- Типи роз'ємів / Available connector types ---
// USB:        USB-A  USB-A Dual Stack  USB-B  USB-C  Micro-USB  Mini-USB
// Video/Data: HDMI  Mini-HDMI  RJ45 Ethernet
// D-Sub:      DE-9 (DB9)  DA-15 (DB15)  DB-25
// Audio:      XLR 3-pin  XLR 5-pin  Speakon NL4  Jack 3.5mm  Jack 6.35mm  MIDI DIN-5
// Power:      DC Jack M8  DC Jack M11  XT30  XT60  IEC AC 220V  IEC C8 Fig-8
// Circular:   GX16 Aviation  GX20 Aviation
// ---
// Кількість активних слотів (1-8) / Number of active port slots
Port_Count = 4; // [1 : 1 : 8]
// Додатковий зазор для портів / Additional clearance for ports
Port_Clearance = 0.2; // [0.0 : 0.05 : 1.0]
// Тип порту 1 / Port 1 type
Port_1_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 1 / Face for port 1
Port_1_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 1 (горизонтальне) / Port 1 horizontal offset
Port_1_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
// Зміщення порту 1 (вертикальне) / Port 1 vertical offset
Port_1_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту порту 1 / Port 1 rotation angle
Port_1_Rot_Kut = 0; // [0 : 1 : 359]
// Тип порту 2 / Port 2 type
Port_2_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 2 / Face for port 2
Port_2_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 2 (горизонтальне) / Port 2 horizontal offset
Port_2_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
// Зміщення порту 2 (вертикальне) / Port 2 vertical offset
Port_2_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту порту 2 / Port 2 rotation angle
Port_2_Rot_Kut = 0; // [0 : 1 : 359]
// Тип порту 3 / Port 3 type
Port_3_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 3 / Face for port 3
Port_3_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 3 (горизонтальне) / Port 3 horizontal offset
Port_3_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
// Зміщення порту 3 (вертикальне) / Port 3 vertical offset
Port_3_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту порту 3 / Port 3 rotation angle
Port_3_Rot_Kut = 0; // [0 : 1 : 359]
// Тип порту 4 / Port 4 type
Port_4_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 4 / Face for port 4
Port_4_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 4 (горизонтальне) / Port 4 horizontal offset
Port_4_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
// Зміщення порту 4 (вертикальне) / Port 4 vertical offset
Port_4_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту порту 4 / Port 4 rotation angle
Port_4_Rot_Kut = 0; // [0 : 1 : 359]
// Тип порту 5 / Port 5 type
Port_5_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 5 / Face for port 5
Port_5_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 5 / Port 5 offsets
Port_5_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
Port_5_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
Port_5_Rot_Kut = 0; // [0 : 1 : 359]
// Тип порту 6 / Port 6 type
Port_6_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 6 / Face for port 6
Port_6_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 6 / Port 6 offsets
Port_6_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
Port_6_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
Port_6_Rot_Kut = 0; // [0 : 1 : 359]
// Тип порту 7 / Port 7 type
Port_7_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 7 / Face for port 7
Port_7_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 7 / Port 7 offsets
Port_7_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
Port_7_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
Port_7_Rot_Kut = 0; // [0 : 1 : 359]
// Тип порту 8 / Port 8 type
Port_8_Type = "Немає (None)"; // ["Немає (None)", "USB-A", "USB-A Dual Stack", "USB-B", "USB-C", "Micro-USB", "Mini-USB", "HDMI", "Mini-HDMI", "RJ45 Ethernet", "DE-9 (DB9)", "DA-15 (DB15)", "DB-25", "XLR 3-pin", "XLR 5-pin", "Speakon NL4", "Jack 3.5mm", "Jack 6.35mm", "MIDI DIN-5", "DC Jack M8", "DC Jack M11", "XT30", "XT60", "IEC AC 220V", "IEC C8 Fig-8", "GX16 Aviation", "GX20 Aviation"]
// Грань для порту 8 / Face for port 8
Port_8_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Зміщення порту 8 / Port 8 offsets
Port_8_Offset_1 = 0.0; // [-150.0 : 0.5 : 150.0]
Port_8_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
Port_8_Rot_Kut = 0; // [0 : 1 : 359]

/* [12. Світловоди для LED (Light Pipes)] */
// Увімкнути світловоди / Enable light pipes
LightPipe_Enable = false;
// Грань для світловодів / Face for light pipes
LightPipe_Face = "Спереду (Front)"; // ["Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Кількість світловодів / Number of light pipes
LightPipe_Count = 2; // [1 : 1 : 8]
// Відстань між світловодами / Spacing between light pipes
LightPipe_Spacing = 10.0; // [4.0 : 0.5 : 30.0]
// Зовнішній діаметр (вхідна лінза) / Outer diameter (lens side)
LightPipe_Outer_Dia = 5.0; // [2.0 : 0.5 : 12.0]
// Внутрішній діаметр (канал) / Inner channel diameter
LightPipe_Inner_Dia = 3.0; // [1.0 : 0.5 : 8.0]
// Глибина гнізда для LED / LED socket depth
LightPipe_Socket_Depth = 4.0; // [2.0 : 0.5 : 10.0]
// Горизонтальне зміщення масиву / Array horizontal offset
LightPipe_Offset_X = 0.0; // [-100.0 : 1.0 : 100.0]
// Висота від дна бази / Height from base bottom
LightPipe_Z = 8.0; // [2.0 : 0.5 : 100.0]

/* [13. Вентиляція та Охолодження (Ventilation & Cooling)] */
// Вентиляційні отвори на даху / Top ventilation holes
Vent_Top_Dakh = "Немає (None)"; // ["Немає (None)", "Слоти (Slots)", "Отвори (Holes)", "Соти (Honeycomb)"]
// Вентиляційні отвори на дні / Bottom ventilation holes
Vent_Bottom_Dno = "Немає (None)"; // ["Немає (None)", "Слоти (Slots)", "Отвори (Holes)", "Соти (Honeycomb)"]
// Розмір вентиляційного отвору / Ventilation hole size
Vent_Size_Rozmir = 3.0; // [1.0 : 0.5 : 15.0]
// Крок між вентиляційними отворами / Spacing between ventilation holes
Vent_Spacing_Krok = 2.0; // [0.5 : 0.5 : 10.0]

// Грань для бічної вентиляції / Face for side ventilation
Vent_Side_Face = "Немає (None)"; // ["Немає (None)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)", "Зліва та Справа (Left & Right)", "Спереду та Ззаду (Front & Back)"]
// Стиль бічної вентиляції / Side ventilation style
Vent_Side_Style = "Немає (None)"; // ["Немає (None)", "Слоти (Slots)", "Отвори (Holes)", "Соти (Honeycomb)"]
// Ширина зони бічної вентиляції / Side ventilation area width
Vent_Side_Width = 40.0; // [10.0 : 1.0 : 300.0]
// Висота зони бічної вентиляції / Side ventilation area height
Vent_Side_Height = 15.0; // [5.0 : 1.0 : 150.0]
// Горизонтальне зміщення бічної вентиляції / Side ventilation horizontal offset
Vent_Side_Offset_X = 0.0; // [-150.0 : 1.0 : 150.0]
// Вертикальне зміщення бічної вентиляції (Z) / Side ventilation vertical offset (Z)
Vent_Side_Offset_Z = 0.0; // [-100.0 : 1.0 : 100.0]

// Грань для встановлення вентилятора / Face for cooling fan
Fan_Face_Gran = "Немає (None)"; // ["Немає (None)", "Дах (Top)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Розмір кулера / Cooling fan size
Fan_Size_Rozmir = "80x80"; // ["30x30", "40x40", "60x60", "80x80", "120x120"]
// Стиль захисної решітки / Fan grill style
Fan_Grill_Style = "Кільця (Rings)"; // ["Відкритий (Open)", "Отвори (Holes)", "Слоти (Slots)", "Соти (Honeycomb)", "Кільця (Rings)"]
// Зміщення вентилятора 1 / Fan offset 1
Fan_Offset_1 = 0.0; // [-100.0 : 1.0 : 100.0]
// Зміщення вентилятора 2 / Fan offset 2
Fan_Offset_2 = 16.0; // [-100.0 : 1.0 : 100.0]
// Товщина ліній решітки / Grill lines thickness
Fan_Grill_Thickness = 1.6; // [0.6 : 0.2 : 5.0]
// Зазор між лініями решітки / Gap between grill lines
Fan_Grill_Gap = 3.0; // [1.0 : 0.5 : 10.0]
// Відступ вентиляційної маски від краю кришки / Vent mask inset from lid/base edge
Vent_Lid_Inset = 15.0; // [5.0 : 1.0 : 40.0]

/* [14. Зовнішнє Кріплення та Ніжки (Mounting Ears & Feet)] */
// Зовнішні вушка для монтажу / External mounting ears
Ears_Type = "Немає (None)"; // ["Немає (None)", "Зліва та Справа (Left & Right)", "Спереду та Ззаду (Front & Back)"]
// Кількість монтажних вушок / Number of mounting ears
Ears_Count = 4; // [2, 4]
// Ширина монтажного вушка / Mounting ear width
Ears_Width = 15.0; // [8.0 : 1.0 : 50.0]
// Довжина монтажного вушка / Mounting ear length
Ears_Length = 15.0; // [5.0 : 1.0 : 40.0]
// Діаметр отвору у вушці / Mounting ear hole diameter
Ears_Hole_Dia = 4.2; // [1.0 : 0.1 : 10.0]
// Зміщення отвору від краю вушка / Hole offset from ear edge
Ears_Hole_Offset = 8.0; // [3.0 : 0.5 : 30.0]
// Радіус заокруглення вушка / Ear rounding radius
Ears_Rounding = 4.0; // [0.0 : 0.5 : 20.0]
// Замкові щілини для настінного монтажу / Keyhole slots for wall mounting
Keyholes_Bottom_Enable = false;
// Кількість замкових щілин / Number of keyholes
Keyholes_Bottom_Count = 2; // [1, 2, 3, 4]
// Розмір гвинта для монтажу / Mounting screw size
Keyholes_Screw_Size = "M4"; // ["M3", "M4", "M5", "M6"]
// Тип розміщення / Positioning mode
Keyholes_Bottom_Position_Type = "По зміщенню (By Offset)"; // ["По зміщенню (By Offset)", "Стандартний крок (Std Spacing)", "Біля бобишок (Near Bosses)"]
// Напрямок пазу (куди ковзає корпус при монтажі) / Slot direction (slide direction)
Keyholes_Slot_Dir = "До центру (Inward)"; // ["До центру (Inward)", "-Y (Down)", "+Y (Up)", "+X", "-X"]
// Зміщення щілин по осі X / Keyholes X offset
Keyholes_Bottom_Offset_X = 30.0; // [5.0 : 0.5 : 200.0]
// Зміщення щілин по осі Y / Keyholes Y offset
Keyholes_Bottom_Offset_Y = 30.0; // [5.0 : 0.5 : 200.0]
// Стандартний міжосьовий крок (DIN/VESA/EU) / Standard centre-to-centre spacing (mm)
Keyholes_Std_Spacing = 100.0; // [64.0, 85.0, 100.0, 120.0, 150.0, 200.0]
// Довжина паза (мін = діаметр головки * 1.2) / Slot length (min = head_dia * 1.2)
Keyholes_Slot_Length = 12.0; // [5.0 : 0.5 : 40.0]
// Ніжки на дні корпусу / Feet on the bottom of enclosure
Feet_Type = "Немає (None)"; // ["Немає (None)", "Виступаючі ніжки (Pads)", "Пази під гумові ніжки (Recesses)"]
// Діаметр ніжок / Feet diameter
Feet_Diameter = 10.0; // [4.0 : 0.5 : 30.0]
// Висота виступу або глибина пазу / Feet pad height or recess depth
Feet_Height_Depth = 1.2; // [0.4 : 0.1 : 5.0]
// Зміщення ніжок від кутів / Feet offset from corners
Feet_Offset = 8.0; // [2.0 : 0.5 : 30.0]

/* [14b. PRO: DIN-Rail / VESA] */
// Кріплення на DIN-рейку TS-35 / DIN-Rail TS-35 clip mount
DIN_Rail_Enable = false;
// VESA монтажний стандарт / VESA mount pattern
VESA_Mount_Enable = false;
// Розмір VESA (мм) / VESA pattern size (mm)
VESA_Size = "75x75"; // ["75x75", "100x100"]
// Діаметр отвору VESA / VESA hole diameter (M4 clearance)
VESA_Hole_Dia = 4.5; // [3.0 : 0.1 : 6.0]

/* [15. Текст та Маркування (Text Inlays)] */
// Текст 1 / Text 1
Text_1_Custom_Tekst = "DEVICE v1.0"; 
// Грань для тексту 1 / Face for text 1
Text_1_Face_Gran = "Немає (None)"; // ["Немає (None)", "Дах (Top)", "Дно (Bottom)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Шрифт тексту 1 / Font for text 1
Text_1_Font_Shryft = "Arial:style=Bold"; // ["Arial:style=Bold", "Courier New:style=Bold", "Impact", "Consolas", "Liberation Sans:style=Bold", "Liberation Serif:style=Bold", "Liberation Mono:style=Bold", "Trebuchet MS:style=Bold", "Times New Roman:style=Bold", "Georgia:style=Bold", "Verdana:style=Bold", "Tahoma:style=Bold"]
// Розмір тексту 1 / Size of text 1
Text_1_Size_Rozmir = 8.0; // [2.0 : 0.5 : 50.0]
// Глибина тексту 1 (від'ємна для гравіювання) / Depth of text 1 (negative for deboss)
Text_1_Depth_Glybyna = -1.0; // [-5.0 : 0.1 : 5.0]
// Зміщення тексту 1 (горизонтальне) / Text 1 horizontal offset
Text_1_Offset_1 = 0.0; // [-100.0 : 0.5 : 100.0]
// Зміщення тексту 1 (вертикальне) / Text 1 vertical offset
Text_1_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту тексту 1 / Text 1 rotation angle
Text_1_Rot_Kut = 0; // [0 : 1 : 359]

// Текст 2 / Text 2
Text_2_Custom_Tekst = ""; 
// Грань для тексту 2 / Face for text 2
Text_2_Face_Gran = "Немає (None)"; // ["Немає (None)", "Дах (Top)", "Дно (Bottom)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Шрифт тексту 2 / Font for text 2
Text_2_Font_Shryft = "Arial:style=Bold"; // ["Arial:style=Bold", "Courier New:style=Bold", "Impact", "Consolas", "Liberation Sans:style=Bold", "Liberation Serif:style=Bold", "Liberation Mono:style=Bold", "Trebuchet MS:style=Bold", "Times New Roman:style=Bold", "Georgia:style=Bold", "Verdana:style=Bold", "Tahoma:style=Bold"]
// Розмір тексту 2 / Size of text 2
Text_2_Size_Rozmir = 8.0; // [2.0 : 0.5 : 50.0]
// Глибина тексту 2 / Depth of text 2
Text_2_Depth_Glybyna = -1.0; // [-5.0 : 0.1 : 5.0]
// Зміщення тексту 2 (горизонтальне) / Text 2 horizontal offset
Text_2_Offset_1 = 0.0; // [-100.0 : 0.5 : 100.0]
// Зміщення тексту 2 (вертикальне) / Text 2 vertical offset
Text_2_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту тексту 2 / Text 2 rotation angle
Text_2_Rot_Kut = 0; // [0 : 1 : 359]

// Текст 3 / Text 3
Text_3_Custom_Tekst = ""; 
// Грань для тексту 3 / Face for text 3
Text_3_Face_Gran = "Немає (None)"; // ["Немає (None)", "Дах (Top)", "Дно (Bottom)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Шрифт тексту 3 / Font for text 3
Text_3_Font_Shryft = "Arial:style=Bold"; // ["Arial:style=Bold", "Courier New:style=Bold", "Impact", "Consolas", "Liberation Sans:style=Bold", "Liberation Serif:style=Bold", "Liberation Mono:style=Bold", "Trebuchet MS:style=Bold", "Times New Roman:style=Bold", "Georgia:style=Bold", "Verdana:style=Bold", "Tahoma:style=Bold"]
// Розмір тексту 3 / Size of text 3
Text_3_Size_Rozmir = 8.0; // [2.0 : 0.5 : 50.0]
// Глибина тексту 3 / Depth of text 3
Text_3_Depth_Glybyna = -1.0; // [-5.0 : 0.1 : 5.0]
// Зміщення тексту 3 (горизонтальне) / Text 3 horizontal offset
Text_3_Offset_1 = 0.0; // [-100.0 : 0.5 : 100.0]
// Зміщення тексту 3 (вертикальне) / Text 3 vertical offset
Text_3_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту тексту 3 / Text 3 rotation angle
Text_3_Rot_Kut = 0; // [0 : 1 : 359]

// Текст 4 / Text 4
Text_4_Custom_Tekst = ""; 
// Грань для тексту 4 / Face for text 4
Text_4_Face_Gran = "Немає (None)"; // ["Немає (None)", "Дах (Top)", "Дно (Bottom)", "Спереду (Front)", "Ззаду (Back)", "Зліва (Left)", "Справа (Right)"]
// Шрифт тексту 4 / Font for text 4
Text_4_Font_Shryft = "Arial:style=Bold"; // ["Arial:style=Bold", "Courier New:style=Bold", "Impact", "Consolas", "Liberation Sans:style=Bold", "Liberation Serif:style=Bold", "Liberation Mono:style=Bold", "Trebuchet MS:style=Bold", "Times New Roman:style=Bold", "Georgia:style=Bold", "Verdana:style=Bold", "Tahoma:style=Bold"]
// Розмір тексту 4 / Size of text 4
Text_4_Size_Rozmir = 8.0; // [2.0 : 0.5 : 50.0]
// Глибина тексту 4 / Depth of text 4
Text_4_Depth_Glybyna = -1.0; // [-5.0 : 0.1 : 5.0]
// Зміщення тексту 4 (горизонтальне) / Text 4 horizontal offset
Text_4_Offset_1 = 0.0; // [-100.0 : 0.5 : 100.0]
// Зміщення тексту 4 (вертикальне) / Text 4 vertical offset
Text_4_Offset_2 = 0.0; // [-100.0 : 0.5 : 100.0]
// Кут повороту тексту 4 / Text 4 rotation angle
Text_4_Rot_Kut = 0; // [0 : 1 : 359]

/* [16. Матеріал та Усадка (Material & Shrinkage)] */
// Тип пластику для друку / 3D printing material type
Material_Type = "PLA"; // ["Custom", "PLA", "PETG", "ABS", "ASA"]
// Власне значення усадки (%) / Custom shrinkage value (%)
Custom_Shrinkage = 0.0; // [0.0 : 0.05 : 3.0]

/* [17. Системні Налаштування (System & Colors)] */
// Модель принтера Bambu Lab / Bambu Lab printer model
Printer_Model = "P2S"; // ["A1 mini", "A1", "P1S", "P2S", "X1 Carbon (X1C)", "X2D", "X1 Enterprise (X1E)", "H2S", "H2C", "H2D"]
// Колір бази / Base color
C_BASE = "#1F618D";
// Колір кришки / Lid color
C_LID = "#E67E22";
// Колір бобишок та стійок / Bosses and standoffs color
C_BOSS = "#27AE60";
// Колір защіпок / Snaps color
C_SNAP = "#E74C3C";
// Колір тексту / Text color
C_TEXT = "#F1C40F";
// Авто-розрахунок мінімальних значень / Auto-calculate minimal values
Auto_Optimization = true; // [true, false]

/* [18. Розширені Допуски (Advanced Tolerances — Expert Only)] */
// CAUTION: change only if you know what you are doing
// Зазор для прохідного отвору гвинта (множник до діаметра) / Screw clearance hole multiplier
Coeff_Clearance_Hole = 1.10; // [1.05 : 0.01 : 1.20]
// Множник діаметра стійки PCB / PCB standoff OD multiplier
Coeff_PCB_OD = 2.50; // [2.0 : 0.1 : 3.5]
// Множник для отвору під саморіз / Self-tap hole multiplier
Coeff_Selftap_Hole = 0.85; // [0.75 : 0.01 : 0.95]
// Множник діаметра отвору під термозакладку / Heatset hole diameter multiplier
Coeff_Heatset_Dia = 1.35; // [1.20 : 0.01 : 1.50]
// Множник глибини отвору під термозакладку / Heatset hole depth multiplier
Coeff_Heatset_Depth = 1.50; // [1.20 : 0.05 : 2.00]

include <modules/constants.scad>
include <modules/connectors.scad>
include <modules/ventilation.scad>
include <modules/fasteners.scad>
include <modules/snaps.scad>
include <modules/text.scad>
include <modules/features.scad>
include <modules/panels.scad>
include <modules/pcb.scad>
include <modules/base_lid.scad>
include <modules/bom.scad>
include <modules/assembly.scad>