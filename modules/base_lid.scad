// =============================================================================
// БАЗА ТА КРИШКА (BASE & LID GEOMETRY)
// =============================================================================

module base_shell(l, w, h, r, chamf) {
    if (chamf > 0) {
        intersection() {
            cuboid([l, w, h], chamfer=chamf, edges=BOTTOM, anchor=BOTTOM);
            cuboid([l, w, h], rounding=r, edges="Z", anchor=BOTTOM);
        }
    } else {
        cuboid([l, w, h], rounding=r, edges="Z", anchor=BOTTOM);
    }
}

module base_part() {
    difference() {
        union() {
            color(C_BASE) difference() {
                base_shell(L, W, H_base, Radius_Kutiv_safe, Chamfer_Faska_safe);
                up(Bottom_Dno_safe) cuboid([L_in, W_in, H_base + _eps], rounding=max(0.1, Radius_Kutiv_safe - T), edges="Z", anchor=BOTTOM);
            }
            
            if (is_lip) {
                color(C_BASE) up(H_base - _eps) difference() {
                    cuboid([L_in + 2*t_lip, W_in + 2*t_lip, Lip_Height_Vysota_safe], rounding=max(0.1, Radius_Kutiv_safe - T + t_lip), edges="Z", anchor=BOTTOM);
                    down(_eps) cuboid([L_in, W_in, Lip_Height_Vysota_safe + 2*_eps], rounding=max(0.1, Radius_Kutiv_safe - T), edges="Z", anchor=BOTTOM);
                }
            }
            
            mounting_ears_solid();
            feet_solid();
            if (DIN_Rail_Enable) din_rail_clip();
            if (Keyholes_Bottom_Enable) {
                kh_positions = get_keyholes_positions();
                for (p = kh_positions) {
                    keyhole_pocket_solid(p);
                }
            }
            
            if (Divider_Type != "Немає (None)") {
                color(C_BASE) {
                    div_h = min(Divider_Height, H_base - Bottom_Dno_safe - 0.4);
                    if (Divider_Type == "Подовжня (X-Axis)") {
                        difference() {
                            _mox = W_in/2 - Divider_Thickness/2 - 1.0; _ox = min(max(Divider_Pos_Offset, -_mox), _mox); translate([0, _ox, Bottom_Dno_safe])
                                cuboid([L_in, Divider_Thickness, div_h], anchor=BOTTOM);
                            if (Divider_Wire_Hole) {
                                translate([0, _ox, Bottom_Dno_safe + div_h/2])
                                    xrot(90) cyl(h=Divider_Thickness + 2*_eps, d=Divider_Wire_Hole_Dia, anchor=CENTER);
                            }
                        }
                    } else if (Divider_Type == "Поперечна (Y-Axis)") {
                        difference() {
                            _moy = L_in/2 - Divider_Thickness/2 - 1.0; _oy = min(max(Divider_Pos_Offset, -_moy), _moy); translate([_oy, 0, Bottom_Dno_safe])
                                cuboid([Divider_Thickness, W_in, div_h], anchor=BOTTOM);
                            if (Divider_Wire_Hole) {
                                translate([_oy, 0, Bottom_Dno_safe + div_h/2])
                                    yrot(90) cyl(h=Divider_Thickness + 2*_eps, d=Divider_Wire_Hole_Dia, anchor=CENTER);
                            }
                        }
                    }
                }
            }

            
            intersection() {
                cuboid([L, W, H_base * 2], rounding=Radius_Kutiv_safe, edges="Z", anchor=BOTTOM);
                union() {
                    if (_fast != "snaps") {
                        color(C_BOSS) for (p = pos_fasten) {
                            translate([p[0], p[1], Bottom_Dno_safe]) {
                                cyl(h=H_base - Bottom_Dno_safe, d=boss_dia(), anchor=BOTTOM);
                                boss_ribs(p, H_base - Bottom_Dno_safe);
                            }
                        }
                    }
                    if (false && PCB_Enable_Stiyky && PCB_Fused_To_Base) {
                        pcb_sc_info = screw_info(PCB_Screw_Gvynt);
                        pcb_sc_dia  = struct_val(pcb_sc_info, "diameter");
                        pcb_d       = pcb_sc_dia * Coeff_PCB_OD;
                        color(C_BOSS) for (p = pos_pcb) {
                            translate([p[0], p[1], Bottom_Dno_safe]) {
                                cyl(h=PCB_Height_Vysota, d=pcb_d, anchor=BOTTOM);
                                pcb_ribs(PCB_Height_Vysota, pcb_d);
                            }
                        }
                    }
                }
            }
            
            if (_fast == "snaps" && is_lip) {
                up(H_base + Lip_Height_Vysota_safe - _snap_h) snap_array(is_male=true, cl=0);
            }
            
            apply_text(is_cutout=false, is_lid=false);
        }
        
        mounting_ears_holes();
        feet_holes();
        if (VESA_Mount_Enable) vesa_holes();
        apply_light_pipes();
        
        if (Keyholes_Bottom_Enable) {
            kh_positions = get_keyholes_positions();
            for (p = kh_positions) {
                keyhole_pocket_cutout(p);
            }
        }
        
        if (is_ledge) {
            up(H_base - Lip_Height_Vysota_safe) difference() {
                cuboid([L_in + 2*t_lip + 2*Clearance_Zazor, W_in + 2*t_lip + 2*Clearance_Zazor, Lip_Height_Vysota_safe + _eps], rounding=max(0.1, Radius_Kutiv_safe - T + t_lip + Clearance_Zazor), edges="Z", anchor=BOTTOM);
                down(_eps) cuboid([L_in, W_in, Lip_Height_Vysota_safe + 2*_eps], rounding=max(0.1, Radius_Kutiv_safe - T), edges="Z", anchor=BOTTOM);
            }
        }
        
        if (_fast == "snaps" && is_ledge) {
            up(H_base - Lip_Height_Vysota_safe) snap_array(is_male=false, cl=Snap_Clearance);
        }
        // Cantilever relief for is_lip male on base lip
        if (_fast == "snaps" && is_lip) {
            up(H_base) snap_tongue_cuts(arm_h=Lip_Height_Vysota_safe);
        }
        
        if (Vent_Bottom_Dno != "Немає (None)") {
            _vw2 = max(10.0, L - 2*Vent_Lid_Inset);
            _vh2 = max(10.0, W - 2*Vent_Lid_Inset);
            down(_eps) linear_extrude(Bottom_Dno_safe + 2*_eps) vent_mask(_vw2, _vh2, Vent_Bottom_Dno);
        }
        
        if (_fast != "snaps") {
            for (p = pos_fasten) {
                translate([p[0], p[1], H_base + _eps]) {
                    if (_fast == "magnets") {
                        // Interference fit: Magnet_Press_Fit < 0 — запресування
                        down(Magnet_Thick_Tovshchyna) cyl(h=Magnet_Thick_Tovshchyna + _eps, d=Magnet_Dia_Diametr + Magnet_Press_Fit, anchor=BOTTOM);
                    } else {
                        sc_info = screw_info(Screw_Gvynt);
                        sc_dia  = struct_val(sc_info, "diameter");

                        down(H_base + _eps) cyl(h=H_base + _eps, d=sc_dia * Coeff_Clearance_Hole, anchor=BOTTOM);

                        if (_fast == "nuts") {
                            nt_info = nut_info(Screw_Gvynt);
                            n_h = struct_val(nt_info, "thickness");
                            z_pos = H_base - n_h - 3.0;
                            down(H_base - z_pos) {
                                angle_to_center = atan2(-p[1], -p[0]);
                                zrot(angle_to_center)
                                    nut_trap_side(trap_width=20, spec=Screw_Gvynt, anchor=BOTTOM);
                            }
                        } else if (_fast == "heatset") {
                            r_dia = ruthex_hole_dia(Screw_Gvynt);
                            r_len = ruthex_insert_len(Screw_Gvynt);
                            insert_dia = is_undef(r_dia) ? sc_dia * Coeff_Heatset_Dia : r_dia;
                            insert_len = is_undef(r_len) ? sc_dia * Coeff_Heatset_Depth : r_len;
                            down(insert_len) cyl(h=insert_len + _eps, d=insert_dia, anchor=BOTTOM);
                        } else if (_fast == "selftap") {
                            down(H_base + _eps) cyl(h=H_base + _eps, d=sc_dia * Coeff_Selftap_Hole, anchor=BOTTOM);
                        }
                    }
                }
            }
        }
        
        if (false && PCB_Enable_Stiyky && PCB_Fused_To_Base) {
            for (p = pos_pcb) {
                translate([p[0], p[1], Bottom_Dno_safe + PCB_Height_Vysota + _eps]) {
                    pcb_sc_info = screw_info(PCB_Screw_Gvynt);
                    pcb_sc_dia  = struct_val(pcb_sc_info, "diameter");
                    pcb_hole_len = max(pcb_sc_dia * 1.5, PCB_Height_Vysota - 0.8);

                    down(pcb_hole_len) cyl(h=pcb_hole_len + _eps, d=pcb_sc_dia * Coeff_Selftap_Hole, anchor=BOTTOM);
                }
            }
        }
        
        wire_cutout();
        apply_text(is_cutout=true, is_lid=false);
        apply_fan_cutout("Base");
        apply_side_ventilation("Base");
        if (false) gasket_groove_subtraction();
        apply_all_ports();
        // Пазові різи для знімних панелей / Removable panel groove cuts
        // Висота різу охоплює губу/уступ щоб не лишалось плаваючого ободу
        if (Panel_Enable) {
            _ph_base = H_base - Bottom_Dno_safe
                     + (is_lip  ? Lip_Height_Vysota_safe + 2*_eps : 0)
                     + (is_ledge ? Clearance_Zazor + 2*_eps : 0);
            panel_groove_cuts(_ph_base, Bottom_Dno_safe, true);
        }
    }
}

module lid_part() {
    difference() {
        union() {
            color(C_LID) difference() {
                cuboid([L, W, H_lid], rounding=Radius_Kutiv_safe, edges="Z", anchor=BOTTOM);
                up(Top_Dakh_safe) cuboid([L_in, W_in, H_lid + _eps], rounding=max(0.1, Radius_Kutiv_safe - T), edges="Z", anchor=BOTTOM);
            }
            
            if (is_ledge) {
                color(C_LID) up(H_lid - _eps) difference() {
                    cuboid([L_in + 2*t_lip, W_in + 2*t_lip, Lip_Height_Vysota_safe], rounding=max(0.1, Radius_Kutiv_safe - T + t_lip), edges="Z", anchor=BOTTOM);
                    down(_eps) cuboid([L_in, W_in, Lip_Height_Vysota_safe + 2*_eps], rounding=max(0.1, Radius_Kutiv_safe - T), edges="Z", anchor=BOTTOM);
                }
            }
            
            intersection() {
                cuboid([L, W, H_lid * 2], rounding=Radius_Kutiv_safe, edges="Z", anchor=BOTTOM);
                union() {
                    if (_fast != "snaps") {
                        color(C_BOSS) for (p = pos_fasten) {
                            translate([p[0], p[1], Top_Dakh_safe]) {
                                cyl(h=H_lid - Top_Dakh_safe, d=boss_dia(), anchor=BOTTOM);
                                boss_ribs(p, H_lid - Top_Dakh_safe);
                            }
                        }
                    }
                }
            }

            if (_fast == "snaps" && is_ledge) {
                up(H_lid + Lip_Height_Vysota_safe - _snap_h) snap_array(is_male=true, cl=0);
            }
            
            apply_text(is_cutout=false, is_lid=true);
        }
        
        if (is_lip) {
            up(H_lid - Lip_Height_Vysota_safe) difference() {
                cuboid([L_in + 2*t_lip + 2*Clearance_Zazor, W_in + 2*t_lip + 2*Clearance_Zazor, Lip_Height_Vysota_safe + _eps], rounding=max(0.1, Radius_Kutiv_safe - T + t_lip + Clearance_Zazor), edges="Z", anchor=BOTTOM);
                down(_eps) cuboid([L_in, W_in, Lip_Height_Vysota_safe + 2*_eps], rounding=max(0.1, Radius_Kutiv_safe - T), edges="Z", anchor=BOTTOM);
            }
        }
        
        if (_fast == "snaps" && is_lip) {
            up(H_lid - Lip_Height_Vysota_safe) snap_array(is_male=false, cl=Snap_Clearance);
        }
        // Cantilever relief for is_ledge male on lid ledge ring
        if (_fast == "snaps" && is_ledge) {
            up(H_lid) snap_tongue_cuts(arm_h=Lip_Height_Vysota_safe);
        }
        
        if (Vent_Top_Dakh != "Немає (None)") {
            _vw = max(10.0, L - 2*Vent_Lid_Inset);
            _vh = max(10.0, W - 2*Vent_Lid_Inset);
            down(_eps) linear_extrude(Top_Dakh_safe + 2*_eps) vent_mask(_vw, _vh, Vent_Top_Dakh);
        }
        
        if (_fast != "snaps") {
            for (p = pos_fasten) {
                translate([p[0], p[1], 0]) {
                    if (_fast == "magnets") {
                        // Interference fit: Magnet_Press_Fit < 0 — запресування
                        up(H_lid - Magnet_Thick_Tovshchyna) cyl(h=Magnet_Thick_Tovshchyna + _eps, d=Magnet_Dia_Diametr + Magnet_Press_Fit, anchor=BOTTOM);
                    } else {
                        screw_head_style = (Head_Golovka == "Циліндрична (Socket)") ? "socket" :
                                           (Head_Golovka == "Напівкругла (Button)") ? "button" : "flat";
                        
                        screw_hole(Screw_Gvynt, head=screw_head_style, length=H_lid + 2*_eps, anchor=TOP, orient=DOWN);
                    }
                }
            }
        }
        
        apply_text(is_cutout=true, is_lid=true);
        if (false) apply_fan_cutout("Lid");
        if (false) apply_side_ventilation("Lid");
        // Пазові різи для знімних панелей / Removable panel groove cuts
        if (Panel_Enable) {
            _ph_lid = H_lid - Top_Dakh_safe
                    + (is_ledge ? Lip_Height_Vysota_safe + 2*_eps : 0)
                    + (is_lip   ? Clearance_Zazor + 2*_eps : 0);
            panel_groove_cuts(_ph_lid, Top_Dakh_safe, false);
        }
    }
}