// =============================================================================
// КОНСТАНТИ ТА ЗАХИСТ ВІД ПОМИЛОК (SAFETY COMPILATION BLOCK)
// =============================================================================

_eps = 0.01;

$fa = (Render_Quality == "Fine") ? 1 : (Render_Quality == "Draft") ? 6 : 2;
$fs = (Render_Quality == "Fine") ? 0.2 : (Render_Quality == "Draft") ? 1.0 : 0.4;

effective_custom_shrinkage = is_undef(Custom_Shrinkage) ? 0.0 : Custom_Shrinkage;

shrinkage_rate = 
    (Material_Type == "PLA") ? 0.3 :
    (Material_Type == "PETG") ? 0.5 :
    (Material_Type == "ABS") ? 0.8 :
    (Material_Type == "ASA") ? 0.6 :
    effective_custom_shrinkage;

// Ruthex brass heat-set inserts (M2–M5) — паспортні розміри
// Джерело: Ruthex datasheet rev.2024
function ruthex_hole_dia(screw) =
    (screw == "M2")   ? 3.0 :
    (screw == "M2.5") ? 3.5 :
    (screw == "M3")   ? 4.0 :
    (screw == "M4")   ? 5.0 :
    (screw == "M5")   ? 6.0 :
    undef;

function ruthex_insert_len(screw) =
    (screw == "M2")   ? 3.6 :
    (screw == "M2.5") ? 4.5 :
    (screw == "M3")   ? 4.0 :
    (screw == "M4")   ? 5.8 :
    (screw == "M5")   ? 7.0 :
    undef;

// =============================================================================
// PRESET DATABASE (10 curated DIY enclosures)
// Returns [L, W, H, radius_hint] for each preset name.
// =============================================================================
function _pd(p) =
    (p == "1 Micro-Dongle 50x35x22")   ? [ 50,  35,  22, 2.0] :
    (p == "2 Pocket 64x41x20")         ? [ 64,  41,  20, 2.0] :
    (p == "3 KeyFob 80x45x16")         ? [ 80,  45,  16, 2.0] :
    (p == "4 Mini-Gauge 100x60x25")    ? [100,  60,  25, 3.0] :
    (p == "5 Sensor 85x50x21")         ? [ 85,  50,  21, 2.5] :
    (p == "6 Handheld 115x70x35")      ? [115,  70,  35, 3.5] :
    (p == "7 Project 115x75x40")       ? [115,  75,  40, 4.0] :
    (p == "8 Gadget 120x80x40")        ? [120,  80,  40, 4.0] :
    (p == "9 Desktop-S 130x70x45")     ? [130,  70,  45, 4.0] :
    (p == "10 Router 140x90x35")       ? [140,  90,  35, 4.5] :
    (p == "11 Mainframe 150x100x50")   ? [150, 100,  50, 5.0] :
    (p == "12 PSU-Box 160x110x60")     ? [160, 110,  60, 5.0] :
    (p == "13 Automation 200x120x55")  ? [200, 120,  55, 6.0] :
    (p == "14 Console 200x150x75")     ? [200, 150,  75, 6.0] :
    (p == "15 Maxi 250x180x100")       ? [250, 180, 100, 7.0] :
    [Length_Dovzhyna, Width_Shyryna, Height_Vysota, 3.0];

// Effective volume for auto-optimization (cm³)
function _calc_vol() = Length_Dovzhyna * Width_Shyryna * Height_Vysota / 1000;

_use_preset = (Enclosure_Preset != "Custom");
_pdata      = _pd(Enclosure_Preset);
_pL = _pdata[0]; _pW = _pdata[1]; _pH = _pdata[2];
_p_radius_hint = _pdata[3];

// Габарити: пресет перевизначає Length/Width/Height коли активний
L = (_use_preset ? _pL : Length_Dovzhyna) * (1 + shrinkage_rate / 100);
W = (_use_preset ? _pW : Width_Shyryna)  * (1 + shrinkage_rate / 100);
_H_total = _use_preset ? _pH : Height_Vysota;
H_base = _H_total * Split_Proportsiya / 100;
H_lid  = _H_total - H_base;

// 1. Безпечні товщини та радіуси
// Effective enclosure volume for auto-optimization (cm³)
effective_volume = (_use_preset ? (_pL * _pW * _pH) : (Length_Dovzhyna * Width_Shyryna * Height_Vysota)) / 1000;

// Auto-optimization floors: minimum safe thickness by volume (cm³)
// When Auto_Optimization=true or preset active, these enforce a MINIMUM.
// User can set thicker values freely; auto only prevents too-thin walls.
_auto_wall_floor = (Auto_Optimization || _use_preset) ? (
    effective_volume < 50   ? 1.2 :
    effective_volume < 150  ? 1.6 :
    effective_volume < 500  ? 2.0 :
    effective_volume < 2000 ? 2.5 : 3.0
) : 0;

_auto_dno_floor  = (Auto_Optimization || _use_preset) ? (
    effective_volume < 50   ? 1.0 :
    effective_volume < 150  ? 1.2 :
    effective_volume < 500  ? 1.6 :
    effective_volume < 2000 ? 2.0 : 2.5
) : 0;

_auto_top_floor  = (Auto_Optimization || _use_preset) ? _auto_dno_floor : 0;

// User value or auto floor (whichever is larger), then geometric safety cap
Wall_Stinka_safe = min(max(Wall_Stinka, _auto_wall_floor), min(L, W) * 0.4);
T = Wall_Stinka_safe;

Bottom_Dno_safe = min(max(Bottom_Dno, _auto_dno_floor), Height_Vysota * 0.4);

Top_Dakh_safe = min(max(Top_Dakh, _auto_top_floor), Height_Vysota * 0.4);

Radius_Kutiv_safe = min(_use_preset ? _p_radius_hint : Radius_Kutiv, min(L, W) / 2 - 0.1);
Chamfer_Faska_safe = max(0.0, min(Chamfer_Faska, min(Bottom_Dno_safe, Radius_Kutiv_safe) - 0.01));

Lip_Height_Vysota_safe = min(Lip_Height_Vysota, min(H_base, H_lid) * 0.8);
// Snap bump: lower-edge aligned for max cantilever; lead-in above for smooth entry
_snap_lead = max(1.5, Lip_Height_Vysota_safe * 0.4); // guide zone above bump
_snap_h_auto = max(1.0, Lip_Height_Vysota_safe - _snap_lead); // auto bump height
_snap_h = (Snap_Height_Vysota > 0)
    ? max(0.5, min(Snap_Height_Vysota, Lip_Height_Vysota_safe - 0.5))
    : _snap_h_auto; // bump height: manual or auto

L_in = L - 2*T;
W_in = W - 2*T;
t_lip = min(Lip_Thick_Tovshchyna, T - 0.4);
// Safe snap depth: must be after t_lip (t_lip used in formula)
_snap_d_max  = max(0.2, T - t_lip - Clearance_Zazor - 0.1); // geometric limit
_snap_d_safe = min(Snap_Depth_Glybyna, _snap_d_max);         // clamped

// Removable panel derived variables
_panel_en_x = Panel_Enable && (Panel_Walls != "Ліво+Право (Left+Right)");
_panel_en_y = Panel_Enable && (Panel_Walls != "Перед+Зад (Front+Back)");
// Floor groove depth — clamped so ≥0.8mm floor remains after groove cut
_gd_s_base = max(0.5, min(Panel_Groove_D, Bottom_Dno_safe - 0.8));
// Ceiling groove depth — same but for lid ceiling thickness
_gd_s_lid  = max(0.5, min(Panel_Groove_D, Top_Dakh_safe - 0.8));
_rail_w = max(3.0, min(Panel_Rail_W, min(W_in, L_in) / 4));

_raw_ledge = (Joint_Styk == "Сходинка" || Joint_Styk == "Сходинка (Ledge)");
_raw_lip   = (Joint_Styk == "Губа" || Joint_Styk == "Губа (Lip)");
_raw_flat  = (Joint_Styk == "Плоский" || Joint_Styk == "Плоский (Flat)");

// Edition clamping: Free edition uses only Flat joint
is_flat = false ? _raw_flat : true;
is_lip  = false ? _raw_lip : false;
is_ledge = false ? _raw_ledge : false;
if (!false && !_raw_flat) echo(str("(PRO) Lip/Ledge joints are a Pro feature. Using Flat instead."));
// Нормалізовані ключі для уникнення дублювання рядкових порівнянь
_joint = is_ledge ? "ledge" : (is_lip ? "lip" : "flat");
_raw_fast = (Fastening_Kriplennya == "Магніти (Magnets)" || Fastening_Kriplennya == "Магніти") ? "magnets" :
         (Fastening_Kriplennya == "Защіпки (Snaps)"   || Fastening_Kriplennya == "Защіпки")  ? "snaps"   :
         (Fastening_Kriplennya == "Термозакладки (Heatset)" || Fastening_Kriplennya == "Термозакладки") ? "heatset" :
         (Fastening_Kriplennya == "Гайки (Nuts)"       || Fastening_Kriplennya == "Гайки")    ? "nuts"    : "selftap";
_fast = (!false && _raw_fast != "selftap") ? "selftap" : _raw_fast;
__fast_warn = (!false && _raw_fast != "selftap") ? echo(str("(PRO) ", _raw_fast, " fastening is a Pro feature. Using Self-tap instead.")) : 0;



// Edition clamping: Free edition uses only M3 screws
_effective_screw = (!false && Screw_Gvynt != "M3") ? "M3" : Screw_Gvynt;
__screw_warn = (!false && Screw_Gvynt != "M3") ? echo(str("(PRO) Screw size ", Screw_Gvynt, " is a Pro feature. Using M3 instead.")) : 0;

function boss_dia() =
    let(
        sc_info = screw_info(_effective_screw),
        nt_info = nut_info(_effective_screw),
        sc_dia  = struct_val(sc_info, "diameter"),
        n_af    = struct_val(nt_info, "width")  // nut across-flats (AF)
    )
    (_fast == "magnets") ? Magnet_Dia_Diametr + 3.0 :
    // heatset: boss OD = insert_OD + 2×wall; insert OD ≈ sc_dia×1.45+0.3 (Ruthex spec),
    // wall ≥ 1.5 mm each side → boss ≈ sc_dia×1.45 + 3.3; min 8 mm for printability
    (_fast == "heatset") ? max(8.0, sc_dia * 2.7) :
    // nuts: boss circumscribes hex nut, AF + 2×wall ≥ 1.5 mm
    (_fast == "nuts")    ? max(8.0, (is_undef(n_af) ? sc_dia * 2.4 : n_af) * 1.25) :
    (_fast == "selftap") ? sc_dia * 2.5 : 0;

// 2. Безпечні зміщення кріплень
min_offset_safe = boss_dia()/2 + T + 0.5;
max_offset_safe = min(L, W)/2 - Radius_Kutiv_safe - 0.1;
Offset_Vidstup_safe = max(min_offset_safe, min(Offset_Vidstup, max_offset_safe));

off_x = L/2 - Offset_Vidstup_safe;
off_y = W/2 - Offset_Vidstup_safe;
pos_fasten = [[off_x, off_y], [-off_x, off_y], [-off_x, -off_y], [off_x, -off_y]];

// 3. Безпечні зміщення стійок PCB
pcb_sc_info = screw_info(PCB_Screw_Gvynt);
pcb_sc_dia  = struct_val(pcb_sc_info, "diameter");
pcb_d       = pcb_sc_dia * Coeff_PCB_OD;

max_pcb_x = max(0, L_in/2 - pcb_d/2 - 0.5);
max_pcb_y = max(0, W_in/2 - pcb_d/2 - 0.5);
PCB_X_Vidstup_safe = min(PCB_X_Vidstup, max_pcb_x);
PCB_Y_Vidstup_safe = min(PCB_Y_Vidstup, max_pcb_y);

px_off = L/2 - T - PCB_X_Vidstup_safe;
py_off = W/2 - T - PCB_Y_Vidstup_safe;
pos_pcb =
    (PCB_Layout_Mode == "Сітка (Grid)") ?
        // Рівномірна сітка по внутрішньому простору
        let(
            cols = max(2, PCB_Grid_Cols),
            rows = max(2, PCB_Grid_Rows),
            step_x = (2 * PCB_X_Vidstup_safe) / max(1, cols - 1),
            step_y = (2 * PCB_Y_Vidstup_safe) / max(1, rows - 1),
            pts = [for (r = [0 : rows-1]) for (c = [0 : cols-1])
                       [-PCB_X_Vidstup_safe + c * step_x,
                        -PCB_Y_Vidstup_safe + r * step_y]]
        ) pts :
    // Режим кутів (оригінальна логіка)
    (PCB_Count_Kilkist == 2) ? [[px_off, py_off], [-px_off, -py_off]] :
    (PCB_Count_Kilkist == 3) ? [[px_off, py_off], [-px_off, -py_off], [-px_off, py_off]] :
    (PCB_Count_Kilkist == 6) ? [[px_off, py_off], [-px_off, py_off], [-px_off, -py_off], [px_off, -py_off], [0, py_off], [0, -py_off]] :
    [[px_off, py_off], [-px_off, py_off], [-px_off, -py_off], [px_off, -py_off]];

// 4. Безпечне зміщення вирізу під дроти
max_wire_x = max(0, L_in/2 - Wire_Size1_Rozmir/2 - 0.5);
Wire_X_Zmishennya_safe = max(-max_wire_x, min(Wire_X_Zmishennya, max_wire_x));

// 5. Безпечні габарити бічної вентиляції (враховує як одиничні, так і симетричні режими)
is_side_x_face = (Vent_Side_Face == "Зліва (Left)" || Vent_Side_Face == "Зліва" || 
                  Vent_Side_Face == "Справа (Right)" || Vent_Side_Face == "Справа" ||
                  Vent_Side_Face == "Зліва та Справа (Left & Right)" || Vent_Side_Face == "Зліва та Справа" || Vent_Side_Face == "Left & Right");
max_side_w = is_side_x_face ? (W_in - 10) : (L_in - 10);
Vent_Side_Width_safe = max(5.0, min(Vent_Side_Width, max_side_w));

max_side_h = Height_Vysota - Bottom_Dno_safe - Top_Dakh_safe - 4.0;
Vent_Side_Height_safe = max(2.0, min(Vent_Side_Height, max_side_h));

max_side_off_x = max(0, (is_side_x_face ? W_in : L_in)/2 - Vent_Side_Width_safe/2 - 2.0);
Vent_Side_Offset_X_safe = max(-max_side_off_x, min(Vent_Side_Offset_X, max_side_off_x));

max_side_off_z = max(0, Height_Vysota/2 - Bottom_Dno_safe - Vent_Side_Height_safe/2 - 2.0);
Vent_Side_Offset_Z_safe = max(-max_side_off_z, min(Vent_Side_Offset_Z, max_side_off_z));

// 6. Додаткові системні функції та масиви
pos_feet = [
    [L/2 - Feet_Offset, W/2 - Feet_Offset],
    [-L/2 + Feet_Offset, W/2 - Feet_Offset],
    [-L/2 + Feet_Offset, -W/2 + Feet_Offset],
    [L/2 - Feet_Offset, -W/2 + Feet_Offset]
];

function face_vector(face) =
    (face == "Спереду (Front)" || face == "Спереду" || face == "Front") ? FWD :
    (face == "Ззаду (Back)" || face == "Ззаду" || face == "Back") ? BACK :
    (face == "Зліва (Left)" || face == "Зліва" || face == "Left") ? LEFT :
    (face == "Справа (Right)" || face == "Справа" || face == "Right") ? RIGHT :
    (face == "Дах (Top)" || face == "Дах" || face == "Top") ? UP :
    (face == "Дно (Bottom)" || face == "Дно" || face == "Bottom") ? DOWN : [0,0,0];

function get_ears_positions() = 
    let(
        max_y_offset = W/2 - Radius_Kutiv_safe - Ears_Width/2,
        max_x_offset = L/2 - Radius_Kutiv_safe - Ears_Width/2,
        oy = (Ears_Count == 2) ? 0 : min(max_y_offset, W/2 - Offset_Vidstup_safe),
        ox = (Ears_Count == 2) ? 0 : min(max_x_offset, L/2 - Offset_Vidstup_safe)
    )
    (Ears_Type == "Зліва та Справа" || Ears_Type == "Зліва та Справа (Left & Right)") ? 
        ((Ears_Count == 2) ? [[-L/2, 0], [L/2, 0]] : [[-L/2, oy], [-L/2, -oy], [L/2, oy], [L/2, -oy]]) :
    (Ears_Type == "Спереду та Ззаду" || Ears_Type == "Спереду та Ззаду (Front & Back)") ? 
        ((Ears_Count == 2) ? [[0, -W/2], [0, W/2]] : [[ox, -W/2], [-ox, -W/2], [ox, W/2], [-ox, W/2]]) : 
    [];

// ── Keyhole helper functions (ISO screw standards) ───────────────────────
// Розміри гвинтів: [зазор стержня, зазор головки, глибина зенківки]
// Based on ISO 4762 socket-cap: M3(5.5mm) M4(7.0mm) M5(8.5mm) M6(10.0mm)
function kh_screw_data(sz) =
    (sz == "M3") ? [3.5,  6.5, 2.0] :
    (sz == "M4") ? [4.5,  8.0, 2.5] :
    (sz == "M5") ? [5.5,  9.5, 3.0] :
    (sz == "M6") ? [6.5, 11.0, 3.5] : [4.5, 8.0, 2.5];

function kh_shank()  = kh_screw_data(Keyholes_Screw_Size)[0]; // діаметр отв. під стержень
function kh_head()   = kh_screw_data(Keyholes_Screw_Size)[1]; // діаметр отв. під головку
function kh_recess() = kh_screw_data(Keyholes_Screw_Size)[2]; // глибина зенківки під головку
function kh_slot()   = max(kh_head() * 1.2, Keyholes_Slot_Length); // довжина паза

// Вектор напряму паза: куди ковзає корпус при надіванні на гвинти
function kh_dir(p) =
    (Keyholes_Slot_Dir == "+Y") ? [ 0,  1, 0] :
    (Keyholes_Slot_Dir == "-Y") ? [ 0, -1, 0] :
    (Keyholes_Slot_Dir == "+X") ? [ 1,  0, 0] :
    (Keyholes_Slot_Dir == "-X") ? [-1,  0, 0] :
    // "До центру (Inward)" — паз дивиться до центру корпусу
    (abs(p[1]) >= abs(p[0])) ? [0, (p[1] > 0 ? -1 : 1), 0] :
                               [(p[0] > 0 ? -1 : 1), 0, 0];

function get_keyholes_positions() =
    let(
        kh  = kh_head(),
        ks  = kh_slot(),
        pr  = kh/2 + 2.0,                       // відступ від стінки
        // By-offset: clamped to interior
        max_kh_x = max(0, L_in/2 - pr),
        max_kh_y = max(0, W_in/2 - pr - ks),
        ox = min(max_kh_x, Keyholes_Bottom_Offset_X),
        oy = min(max_kh_y, Keyholes_Bottom_Offset_Y),
        // Standard spacing: half-pitch clamped
        sp  = Keyholes_Std_Spacing / 2,
        spx = min(max_kh_x, sp),
        spy = min(max_kh_y, sp),
        // Near bosses: offset from boss edge inward
        bd  = boss_dia(),
        nbx = max(0, off_x - bd/2 - pr - 1.0),
        nby = max(0, off_y - bd/2 - pr - ks - 1.0),
        // Position arrays per count
        by_offset =
            (Keyholes_Bottom_Count == 1) ? [[ 0,  oy]] :
            (Keyholes_Bottom_Count == 2) ? [[ 0, -oy], [0, oy]] :
            (Keyholes_Bottom_Count == 3) ? [[ ox, oy], [-ox, oy], [0, -oy]] :
            [[ ox,  oy], [-ox,  oy], [-ox, -oy], [ ox, -oy]],
        by_std =
            (Keyholes_Bottom_Count == 1) ? [[ 0,    0]] :
            (Keyholes_Bottom_Count == 2) ? [[-spx,  0], [spx, 0]] :
            (Keyholes_Bottom_Count == 3) ? [[-spx,-spy], [spx,-spy], [0, spy]] :
            [[-spx,-spy], [spx,-spy], [spx, spy], [-spx, spy]],
        by_boss =
            (Keyholes_Bottom_Count == 2) ? [[0, -nby], [0, nby]] :
            [[-nbx, nby], [nbx, nby], [nbx, -nby], [-nbx, -nby]],
        pts =
            (Keyholes_Bottom_Position_Type == "Стандартний крок (Std Spacing)") ? by_std :
            (Keyholes_Bottom_Position_Type == "Біля бобишок (Near Bosses)")     ? by_boss :
            by_offset
    )
    !Keyholes_Bottom_Enable ? [] : pts;

// ── Port lookup arrays (dynamic port count 1-8) ─────────────────────────
// Clamp Port_Count to valid range for safety
_port_count = false ? max(1, min(8, Port_Count)) : max(1, min(2, Port_Count));

_port_types    = [Port_1_Type, Port_2_Type, Port_3_Type, Port_4_Type, Port_5_Type, Port_6_Type, Port_7_Type, Port_8_Type];
_port_faces    = [Port_1_Face, Port_2_Face, Port_3_Face, Port_4_Face, Port_5_Face, Port_6_Face, Port_7_Face, Port_8_Face];
_port_offsets1 = [Port_1_Offset_1, Port_2_Offset_1, Port_3_Offset_1, Port_4_Offset_1, Port_5_Offset_1, Port_6_Offset_1, Port_7_Offset_1, Port_8_Offset_1];
_port_offsets2 = [Port_1_Offset_2, Port_2_Offset_2, Port_3_Offset_2, Port_4_Offset_2, Port_5_Offset_2, Port_6_Offset_2, Port_7_Offset_2, Port_8_Offset_2];
_port_rots     = [Port_1_Rot_Kut, Port_2_Rot_Kut, Port_3_Rot_Kut, Port_4_Rot_Kut, Port_5_Rot_Kut, Port_6_Rot_Kut, Port_7_Rot_Kut, Port_8_Rot_Kut];