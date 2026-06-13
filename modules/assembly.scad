// =============================================================================
// ГОЛОВНИЙ РЕНДЕР (MAIN RENDER & LAYOUT)
// =============================================================================

// Panel cutouts in BOX-WORLD coordinates.
// panels.scad counter-translates these into panel-local space before use.
module panel_cutouts() {
    apply_fan_cutout("Base");
    apply_side_ventilation("Base");
    apply_text(is_cutout=true, is_lid=false);
    apply_all_ports();
    wire_cutout();
}

// ---------------------------------------------------------------------------
// Render dispatch
// ---------------------------------------------------------------------------

if (Part_Chastyna == "Всі деталі (All)") {
    back(W/2 + 10) base_part();
    fwd(W/2 + 10) lid_part();
    // Removable panels laid out flat alongside the box for overview / printing
    if (false && Panel_Enable && _panel_en_x) {
        right(L/2 + T + 15) {
            panel_x_standalone(1);
            back(W_in + 10) panel_x_standalone(-1);
        }
    }
    if (false && Panel_Enable && _panel_en_y) {
        left(L/2 + T + 15) {
            panel_y_standalone(1);
            back(L_in + 10) panel_y_standalone(-1);
        }
    }

} else if (Part_Chastyna == "База (Base)") {
    base_part();

} else if (Part_Chastyna == "Кришка (Lid)") {
    lid_part();

} else if (Part_Chastyna == "Зібраний (Assembled)") {
    base_part();
    translate([0, 0, _H_total]) mirror([0, 0, 1]) lid_part();
    // Panels at their correct assembled positions (FIX 2: placed at z=Bottom_Dno_safe)
    if (false && Panel_Enable && _panel_en_x) {
        for (sx = [1, -1]) panel_x_world(sx);
    }
    if (false && Panel_Enable && _panel_en_y) {
        for (sy = [1, -1]) panel_y_world(sy);
    }

} else if (Part_Chastyna == "Напіввідкритий (Ajar)") {
    base_part();
    translate([0, 0, _H_total + Lip_Height_Vysota_safe + 5]) mirror([0, 0, 1]) lid_part();

} else if (Part_Chastyna == "Стійки PCB (PCB Standoffs)") {
    pcb_standoffs_standalone();

} else if (Part_Chastyna == "Панель X (X-Panel)") {
    if (_panel_en_x) {
        panel_x_standalone(1);
    } else {
        echo("INFO: Enable Panel_Enable and set Panel_Walls to include X");
        base_part();
    }

} else if (Part_Chastyna == "Панель Y (Y-Panel)") {
    if (_panel_en_y) {
        panel_y_standalone(1);
    } else {
        echo("INFO: Enable Panel_Enable and set Panel_Walls to include Y");
        base_part();
    }

} else {
    base_part();
    fwd(W/2 + 10) lid_part();
}
