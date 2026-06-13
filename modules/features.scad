// =============================================================================
// КОНСТРУКТИВНІ ЕЛЕМЕНТИ (WIRE CUTOUTS, DIVIDERS, FEET, EARS, KEYHOLES, DIN, VESA, GASKET, LIGHT PIPES)
// =============================================================================

module wire_cutout() {
    // Cable glands are PRO; circle/slot are FREE
    if (!false) {
        if (Wire_Shape_Forma == "M12 Gland (Clearance)" || Wire_Shape_Forma == "M16 Gland (Clearance)" ||
            Wire_Shape_Forma == "M20 Gland (Clearance)" || Wire_Shape_Forma == "M12 Gland (Threaded)" ||
            Wire_Shape_Forma == "M16 Gland (Threaded)" || Wire_Shape_Forma == "M20 Gland (Threaded)") {
            echo("(PRO) Cable glands are a Pro feature. Using Circle (Wire_Size1_Rozmir dia) instead.");
        }
    }
    if (Wire_Face_Gran != "Немає (None)") {
        depth = T + 2*_eps;
        // Зміщення на T/2 усередину для повного наскрізного прорізання (центр кубоїда посеред стінки)
        pos_y = (Wire_Face_Gran == "Спереду (Front)") ? (-W/2 + T/2) : 
                (Wire_Face_Gran == "Ззаду (Back)") ? (W/2 - T/2) : 0;
        pos_x = (Wire_Face_Gran == "Зліва (Left)") ? (-L/2 + T/2) : 
                (Wire_Face_Gran == "Справа (Right)") ? (L/2 - T/2) : Wire_X_Zmishennya_safe;
        rot = (Wire_Face_Gran == "Спереду (Front)" || Wire_Face_Gran == "Ззаду (Back)") ? [90,0,0] : [0,90,0];
        
        translate([pos_x, pos_y, Wire_Z_Vysota]) rotate(rot) {
            if (Wire_Shape_Forma == "Круг (Circle)") {
                cyl(h=depth, d=Wire_Size1_Rozmir, anchor=CENTER);
            } else if (Wire_Shape_Forma == "Слот (Slot)") {
                safe_rounding = min(Wire_Size1_Rozmir, Wire_Size2_Rozmir) / 2.01;
                cuboid([Wire_Size1_Rozmir, Wire_Size2_Rozmir, depth], rounding=safe_rounding, edges="Z", anchor=CENTER);
            } else if (Wire_Shape_Forma == "M12 Gland (Clearance)") {
                cyl(h=depth, d=12.2, anchor=CENTER);
            } else if (Wire_Shape_Forma == "M16 Gland (Clearance)") {
                cyl(h=depth, d=16.2, anchor=CENTER);
            } else if (Wire_Shape_Forma == "M20 Gland (Clearance)") {
                cyl(h=depth, d=20.2, anchor=CENTER);
            } else if (Wire_Shape_Forma == "M12 Gland (Threaded)") {
                screw_hole("M12", thread=true, pitch=1.5, length=depth, anchor=CENTER);
            } else if (Wire_Shape_Forma == "M16 Gland (Threaded)") {
                screw_hole("M16", thread=true, pitch=1.5, length=depth, anchor=CENTER);
            } else if (Wire_Shape_Forma == "M20 Gland (Threaded)") {
                screw_hole("M20", thread=true, pitch=1.5, length=depth, anchor=CENTER);
            }
        }
    }
}

module gasket_groove_subtraction() {
    // Gasket groove is PRO; guarded at call site
    if (Gasket_Groove_Enable) {
        shoulder_width = is_ledge ? t_lip : (T - t_lip);
        g_w = min(Gasket_Groove_Width, T - 0.4);
        g_d = Gasket_Groove_Depth;
        
        if (g_w > 0.1) {
            L_g = is_ledge ? (L_in + t_lip) : (L_in + T + t_lip);
            W_g = is_ledge ? (W_in + t_lip) : (W_in + T + t_lip);
            
            r_center = is_ledge ? (Radius_Kutiv_safe - T + t_lip/2) : (Radius_Kutiv_safe - (T - t_lip)/2);
            z_pos = is_ledge ? (H_base - Lip_Height_Vysota_safe) : H_base;
            
            safe_r = max(0.1, r_center);
            
            translate([0, 0, z_pos - g_d]) {
                linear_extrude(g_d + _eps) {
                    difference() {
                        rect([L_g + g_w, W_g + g_w], rounding=safe_r + g_w/2);
                        rect([L_g - g_w, W_g - g_w], rounding=max(0.1, safe_r - g_w/2));
                    }
                }
            }
        }
    }
}

module mounting_ears_solid() {
    // PRO feature; guarded at call site
    if (Ears_Type != "Немає (None)") {
        color(C_BOSS) {
            ears_positions = get_ears_positions();
            for (p = ears_positions) {
                e_thick = Bottom_Dno_safe;
                
                if (Ears_Type == "Зліва та Справа (Left & Right)") {
                    if (p[0] > 0) {
                        translate([L/2 - 1.0, p[1], 0])
                            cuboid([Ears_Length + 1.0, Ears_Width, e_thick], 
                                   rounding=Ears_Rounding, edges=[RIGHT+FRONT, RIGHT+BACK], 
                                   anchor=LEFT+BOTTOM);
                    } else {
                        translate([-L/2 + 1.0, p[1], 0])
                            cuboid([Ears_Length + 1.0, Ears_Width, e_thick], 
                                   rounding=Ears_Rounding, edges=[LEFT+FRONT, LEFT+BACK], 
                                   anchor=RIGHT+BOTTOM);
                    }
                } else if (Ears_Type == "Спереду та Ззаду (Front & Back)") {
                    if (p[1] > 0) {
                        translate([p[0], W/2 - 1.0, 0])
                            cuboid([Ears_Width, Ears_Length + 1.0, e_thick], 
                                   rounding=Ears_Rounding, edges=[BACK+LEFT, BACK+RIGHT], 
                                   anchor=FRONT+BOTTOM);
                    } else {
                        translate([p[0], -W/2 + 1.0, 0])
                            cuboid([Ears_Width, Ears_Length + 1.0, e_thick], 
                                   rounding=Ears_Rounding, edges=[FRONT+LEFT, FRONT+RIGHT], 
                                   anchor=BACK+BOTTOM);
                    }
                }
            }
        }
    }
}

module mounting_ears_holes() {
    // PRO feature; guarded at call site
    if (Ears_Type != "Немає (None)") {
        ears_positions = get_ears_positions();
        e_thick = Bottom_Dno_safe;
        
        for (p = ears_positions) {
            h_x = (Ears_Type == "Зліва та Справа (Left & Right)") ? 
                  (p[0] + sign(p[0]) * Ears_Hole_Offset) : p[0];
            h_y = (Ears_Type == "Спереду та Ззаду (Front & Back)") ? 
                  (p[1] + sign(p[1]) * Ears_Hole_Offset) : p[1];
            
            translate([h_x, h_y, -_eps]) {
                cyl(h=e_thick + 2*_eps, d=Ears_Hole_Dia, anchor=BOTTOM);
                up(e_thick - 1.0)
                    cyl(h=1.0 + 2*_eps, d1=Ears_Hole_Dia, d2=Ears_Hole_Dia * 1.8, anchor=BOTTOM);
            }
        }
    }
}

module keyhole_pocket_solid(p) {
    // PRO feature; guarded at call site
    kh  = kh_head();
    ks  = kh_slot();
    sv  = kh_dir(p);
    // Бобишка виступає над дном бази для жорсткості зони щілини
    pocket_h = Bottom_Dno_safe + kh * 0.4 + 1.5;
    translate([p[0], p[1], 0])
        color(C_BOSS)
            hull() {
                linear_extrude(pocket_h) circle(d=kh + 3.0);
                translate([sv[0]*ks, sv[1]*ks, 0])
                    linear_extrude(pocket_h) circle(d=kh + 3.0);
            }
}

module keyhole_pocket_cutout(p) {
    // PRO feature; guarded at call site
    kh  = kh_head();    // зазор під головку гвинта (вхідний отвір)
    ksh = kh_shank();   // зазор під стержень (вузький паз)
    kr  = kh_recess();  // глибина зенківки на зовнішній поверхні
    ks  = kh_slot();    // довжина паза
    sv  = kh_dir(p);    // вектор напряму паза
    
    translate([p[0], p[1], 0]) {
        // 1. Вхідний отвір — великий, наскрізний (для проходу головки)
        translate([0, 0, -_eps])
            cyl(h=Bottom_Dno_safe + 2*_eps, d=kh, anchor=BOTTOM);
        
        // 2. Вузький паз — для стержня гвинта, наскрізний, вздовж sv
        translate([0, 0, -_eps])
            hull() {
                cyl(h=Bottom_Dno_safe + 2*_eps, d=ksh, anchor=BOTTOM);
                translate([sv[0]*ks, sv[1]*ks, 0])
                    cyl(h=Bottom_Dno_safe + 2*_eps, d=ksh, anchor=BOTTOM);
            }
        
        // 3. Зенківка під головку — на ЗОВНІШНІЙ поверхні (стінка→стіна)
        //    Глибина kr: головка потопає, корпус лежить рівно на стіні
        //    Ширина kh+0.4: вільне ковзання головки вздовж паза
        translate([0, 0, -_eps])
            hull() {
                cyl(h=kr + _eps, d=kh + 0.4, anchor=BOTTOM);
                translate([sv[0]*ks, sv[1]*ks, 0])
                    cyl(h=kr + _eps, d=kh + 0.4, anchor=BOTTOM);
            }
    }
}

module feet_solid() {
    // PRO feature; guarded at call site
    if (Feet_Type == "Виступаючі ніжки (Pads)") {
        color(C_BOSS) {
            for (p = pos_feet) {
                translate([p[0], p[1], 0])
                    down(Feet_Height_Depth)
                        cyl(h=Feet_Height_Depth, d=Feet_Diameter, anchor=BOTTOM);
            }
        }
    }
}

module feet_holes() {
    // PRO feature; guarded at call site
    if (Feet_Type == "Пази під гумові ніжки (Recesses)") {
        for (p = pos_feet) {
            translate([p[0], p[1], -_eps])
                cyl(h=Feet_Height_Depth + _eps, d=Feet_Diameter, anchor=BOTTOM);
        }
    }
}

module din_rail_clip() {
    // PRO feature; guarded at call site
    // TS-35 DIN rail: 35mm wide (Y), 7.5mm deep, mounts on enclosure bottom
    // Крючки — інтегральна частина стінок (два вирізи з цільного блоку)
    // Hooks are integral wall extensions -- carved from one solid via two differences
    _rail_w   = 35.0;          // TS-35 hat width
    _rail_h   = 7.5;           // TS-35 hat depth
    _clip_t   = 3.0;           // top plate / wall thickness
    _hook_h   = 2.5;           // hook zone height
    _hook_in  = 3.5;           // hook inward reach under rail flange
    _tol      = 0.4;           // rail fit clearance
    _body_len = min(L * 0.6, 60.0);
    _total_h  = _clip_t + _rail_h + _hook_h;  // full clip height

    color(C_BOSS)
    difference() {
        // 1. Цільний блок від Z=0 вниз (Z=0 — знизу корпусу)
        cuboid([_body_len, _rail_w + 2*_clip_t, _total_h],
               rounding=1.5, edges="Z", anchor=TOP);

        // 2. Паз під рейку: від Z=-_clip_t до глибини рейки
        // Rail slot: removes inner channel, leaves top plate + side walls + hook zone
        translate([0, 0, -_clip_t])
            cuboid([_body_len + 2*_eps, _rail_w + _tol, _rail_h + _tol + _eps],
                   anchor=TOP);

        // 3. Розвантаження пазу зони крючків: вирізає центральну частину під крючками
        // Hook relief: removes center of hook zone, leaving integral hooks on each side
        translate([0, 0, -(_clip_t + _rail_h)])
            cuboid([_body_len + 2*_eps,
                    _rail_w + _tol - 2*_hook_in,
                    _hook_h + 2*_eps],
                   anchor=TOP);
    }
}

module vesa_holes() {
    // PRO feature; guarded at call site
    _pitch = ((VESA_Size == "75x75") ? 75.0 : 100.0) * (1 + shrinkage_rate / 100);
    _d = VESA_Hole_Dia;
    _depth = Bottom_Dno_safe + _eps;
    for (dx = [-_pitch/2, _pitch/2])
        for (dy = [-_pitch/2, _pitch/2])
            translate([dx, dy, -_eps])
                cyl(h=_depth, d=_d, anchor=BOTTOM);
}

module apply_light_pipes() {
    // PRO feature; guarded at call site
    if (LightPipe_Enable && LightPipe_Count > 0) {
        face_vec = face_vector(LightPipe_Face);
        if (face_vec != [0,0,0]) {
            is_x_face = (face_vec[0] != 0);
            face_dist = is_x_face ? L/2 : W/2;
            tangent_vec = is_x_face ? BACK : RIGHT;
            total_span = (LightPipe_Count - 1) * LightPipe_Spacing;
            for (i = [0 : LightPipe_Count - 1]) {
                offset = -total_span/2 + i * LightPipe_Spacing + LightPipe_Offset_X;
                pos = face_vec * (face_dist - T/2) + tangent_vec * offset + UP * LightPipe_Z;
                translate(pos) rot(from=UP, to=face_vec) {
                    cyl(h=T + 2*_eps, d1=LightPipe_Inner_Dia, d2=LightPipe_Outer_Dia, center=true);
                    down(T/2) cyl(h=LightPipe_Socket_Depth, d=LightPipe_Inner_Dia * 1.6, anchor=TOP);
                }
            }
        }
    }
}
