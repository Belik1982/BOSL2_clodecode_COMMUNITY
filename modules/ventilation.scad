// =============================================================================
// ВЕНТИЛЯЦІЯ ТА ОХОЛОДЖЕННЯ (VENTILATION & COOLING)
// =============================================================================

function fan_pitch(sz) = (sz=="30x30")?24.0 : (sz=="40x40")?32.0 : (sz=="60x60")?50.0 : (sz=="80x80")?71.5 : 105.0;
function fan_rotor_dia(sz) = (sz=="30x30")?28.0 : (sz=="40x40")?38.0 : (sz=="60x60")?56.0 : (sz=="80x80")?76.0 : 115.0;
function fan_screw_dia(sz) = (sz=="30x30")?3.2 : (sz=="40x40")?3.2 : (sz=="60x60")?4.5 : (sz=="80x80")?4.5 : 4.5;
module vent_mask(aw, ah, pattern) {
    if (pattern != "Немає (None)") {
        spacing = Vent_Size_Rozmir + Vent_Spacing_Krok;
        nx = max(1, floor(aw / spacing)); ny = max(1, floor(ah / spacing));
        if (pattern == "Отвори (Holes)") {
            xcopies(spacing, n=nx) ycopies(spacing, n=ny) circle(d=Vent_Size_Rozmir);
        } else if (pattern == "Слоти (Slots)") {
            nx_slots = max(1, floor(aw / (spacing*2)));
            xcopies(spacing*2, n=nx_slots) ycopies(spacing, n=ny) 
                rect([spacing*1.5, Vent_Size_Rozmir], rounding=Vent_Size_Rozmir/2 - 0.01);
        } else if (pattern == "Соти (Honeycomb)") {
            sy = spacing * sqrt(3)/2; ny_hc = max(1, floor(ah / sy));
            for (r = [0 : ny_hc-1]) {
                y = -ah/2 + r*sy + sy/2; offset_x = (r % 2 == 1) ? spacing/2 : 0;
                translate([offset_x, y, 0]) xcopies(spacing, n=nx) circle(d=Vent_Size_Rozmir, $fn=6);
            }
        }
    }
}

module fan_cutout(size, style) {
    pitch = fan_pitch(size);
    rotor = fan_rotor_dia(size);
    scr_d = fan_screw_dia(size);
    
    grid_copies(spacing=pitch, size=[pitch, pitch])
        circle(d=scr_d);
    
    if (style == "Відкритий (Open)") {
        circle(d=rotor);
    } else if (style == "Отвори (Holes)") {
        spacing = Fan_Grill_Gap + Fan_Grill_Thickness;
        intersection() {
            circle(d=rotor);
            grid_copies(spacing=spacing, size=[rotor, rotor])
                circle(d=Fan_Grill_Gap);
        }
    } else if (style == "Слоти (Slots)") {
        spacing_x = (Fan_Grill_Gap + Fan_Grill_Thickness) * 2;
        spacing_y = Fan_Grill_Gap + Fan_Grill_Thickness;
        intersection() {
            circle(d=rotor);
            grid_copies(spacing=[spacing_x, spacing_y], size=[rotor, rotor])
                rect([spacing_x - Fan_Grill_Thickness, Fan_Grill_Gap], rounding=Fan_Grill_Gap/2-0.01);
        }
    } else if (style == "Соти (Honeycomb)") {
        spacing = Fan_Grill_Gap + Fan_Grill_Thickness;
        sy = spacing * sqrt(3)/2;
        intersection() {
            circle(d=rotor);
            grid_copies(spacing=[spacing, sy], size=[rotor, rotor], stagger=true)
                circle(d=Fan_Grill_Gap, $fn=6);
        }
    } else if (style == "Кільця (Rings)") {
        step = Fan_Grill_Gap + Fan_Grill_Thickness;
        difference() {
            circle(d=rotor);
            union() {
                for (r = [Fan_Grill_Gap : step : rotor/2]) {
                    if (r > Fan_Grill_Gap) {
                        difference() {
                            circle(r=r);
                            circle(r=r - Fan_Grill_Gap);
                        }
                    }
                }
            }
            rect([rotor + _eps, Fan_Grill_Thickness]);
            rect([Fan_Grill_Thickness, rotor + _eps]);
            zrot(45) rect([rotor + _eps, Fan_Grill_Thickness]);
            zrot(-45) rect([rotor + _eps, Fan_Grill_Thickness]);
        }
    }
}

module apply_fan_cutout(current_part) {
    if (Fan_Face_Gran != "Немає (None)") {
        ext_h = T + 2*_eps;
        is_lid_face = (Fan_Face_Gran == "Дах (Top)");
        
        z_center = (current_part == "Base") ?
                   (_H_total/2 + Fan_Offset_2) :
                   (_H_total/2 - Fan_Offset_2);

        if (current_part == "Lid" && is_lid_face) {
            translate([Fan_Offset_1, Fan_Offset_2, -_eps])
                linear_extrude(ext_h)
                    fan_cutout(Fan_Size_Rozmir, Fan_Grill_Style);
        } else if (!is_lid_face) {
            if (Fan_Face_Gran == "Спереду (Front)") {
                translate([Fan_Offset_1, -W/2 - _eps, z_center])
                    xrot(-90) linear_extrude(ext_h)
                        fan_cutout(Fan_Size_Rozmir, Fan_Grill_Style);
            } else if (Fan_Face_Gran == "Ззаду (Back)") {
                translate([Fan_Offset_1, W/2 + _eps, z_center])
                    xrot(90) linear_extrude(ext_h)
                        fan_cutout(Fan_Size_Rozmir, Fan_Grill_Style);
            } else if (Fan_Face_Gran == "Зліва (Left)") {
                translate([-L/2 - _eps, Fan_Offset_1, z_center])
                    yrot(90) linear_extrude(ext_h)
                        fan_cutout(Fan_Size_Rozmir, Fan_Grill_Style);
            } else if (Fan_Face_Gran == "Справа (Right)") {
                translate([L/2 + _eps, Fan_Offset_1, z_center])
                    yrot(-90) linear_extrude(ext_h)
                        fan_cutout(Fan_Size_Rozmir, Fan_Grill_Style);
            }
        }
    }
}

module apply_side_ventilation(current_part) {
    if (Vent_Side_Face != "Немає (None)" && Vent_Side_Style != "Немає (None)") {
        // Перевірка колізії з бобышками кріплення (тільки warning в консолі)
        if (_fast != "snaps" && _fast != "magnets") {
            bdia = boss_dia();
            vent_z_min = Height_Vysota/2 + Vent_Side_Offset_Z_safe - Vent_Side_Height_safe/2;
            vent_z_max = Height_Vysota/2 + Vent_Side_Offset_Z_safe + Vent_Side_Height_safe/2;
            boss_z_min = Bottom_Dno_safe;
            boss_z_max = H_base;
            z_overlap = (vent_z_min < boss_z_max) && (vent_z_max > boss_z_min);
            vent_half = Vent_Side_Width_safe / 2;
            boss_half = Offset_Vidstup_safe + bdia/2;
            x_overlap = vent_half > (boss_half - Vent_Side_Offset_X_safe - bdia/2);
            if (z_overlap && x_overlap) {
                echo("<B><FONT COLOR='orange'>WARNING: Side ventilation may overlap fastener bosses. Check render carefully or adjust Vent_Side_Offset_X / Vent_Side_Width.</FONT></B>");
            }
        }

        ext_h = T + 2*_eps;
        
        // Визначення глобального Z центру решітки
        z_global = Height_Vysota/2 + Vent_Side_Offset_Z_safe;
        
        // Трансляція у локальні Z-координати поточної деталі
        z_local = (current_part == "Base") ? z_global : (Height_Vysota - z_global);
        
        // Визначення переліку граней для обробки (включає як одиночні, так і симетричні пари)
        faces_to_process = 
            (Vent_Side_Face == "Зліва та Справа (Left & Right)" || Vent_Side_Face == "Зліва та Справа" || Vent_Side_Face == "Left & Right") ? ["Зліва (Left)", "Справа (Right)"] :
            (Vent_Side_Face == "Спереду та Ззаду (Front & Back)" || Vent_Side_Face == "Спереду та Ззаду" || Vent_Side_Face == "Front & Back") ? ["Спереду (Front)", "Ззаду (Back)"] :
            [Vent_Side_Face];
        
        for (f = faces_to_process) {
            face_vec = face_vector(f);
            if (face_vec != [0,0,0]) {
                is_x_face = (face_vec[0] != 0); // LEFT або RIGHT
                face_dist = is_x_face ? L/2 : W/2;
                
                // Зсув на T/2 усередину для скрізного прорізу
                translate(face_vec * (face_dist - T/2) + (is_x_face ? BACK : RIGHT) * Vent_Side_Offset_X_safe + UP * z_local)
                    rot(from=UP, to=face_vec)
                        linear_extrude(ext_h, center=true)
                            vent_mask(Vent_Side_Width_safe, Vent_Side_Height_safe, Vent_Side_Style);
            }
        }
    }
}