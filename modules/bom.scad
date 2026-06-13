// =============================================================================
// ПЕРЕВІРКА КОНФІГУРАЦІЇ ТА BOM (CONFIGURATION WARNINGS & BILL OF MATERIALS)
// =============================================================================

module check_configuration_warnings() {
    if (!false) { echo("Community Edition - upgrade to Pro for BOM, printer hints, and advanced features (gumroad link)"); }
    if (false) {
    // Рекомендована довжина гвинта
    if (_fast != "snaps" && _fast != "magnets") {
        sc_info_chk = screw_info(Screw_Gvynt);
        sc_d_chk    = struct_val(sc_info_chk, "diameter");
        recommended_len = H_lid + H_base + 2.0;
        echo(str("INFO: Recommended screw length = ", recommended_len, " mm (", Screw_Gvynt, ")"));
    }

    // Snap-fit strain warning
    if (_fast == "snaps") {
        if (Snap_Depth_Glybyna > _snap_d_max) {
            echo(str("<B><FONT COLOR='orange'>SNAP DEPTH CLAMPED: Snap_Depth_Glybyna=",
                     Snap_Depth_Glybyna, " mm exceeds safe limit ", round(_snap_d_max*100)/100,
                     " mm (T=", T, " t_lip=", t_lip, " Clearance=", Clearance_Zazor,
                     "). Actual bump depth = ", round(_snap_d_safe*100)/100, " mm.</FONT></B>"));
        }
        snap_strain_pct = 1.5 * _snap_d_safe * t_lip / pow(max(1.0, Lip_Height_Vysota_safe), 2) * 100;
        max_strain = (Material_Type == "PLA") ? 1.0 :
                     (Material_Type == "PETG") ? 1.8 :
                     (Material_Type == "ABS")  ? 2.5 :
                     (Material_Type == "ASA")  ? 2.5 : 2.0;
        if (snap_strain_pct > max_strain) {
            echo(str("<B><FONT COLOR='red'>WARNING: Snap-fit strain ~", round(snap_strain_pct*10)/10,
                     "% exceeds limit ", max_strain, "% for ", Material_Type,
                     ". Reduce Snap_Depth_Glybyna or increase Lip_Height_Vysota.</FONT></B>"));
        } else {
            echo(str("INFO: Snap-fit strain ~", round(snap_strain_pct*10)/10, "% — OK for ", Material_Type));
        }
    }

    // Hint для шрифтів
    echo("INFO: If text renders incorrectly, try font='Liberation Sans:style=Bold' (available on all platforms)");

    // Preset info
    if (_use_preset) {
        echo(str("PRESET: ", Enclosure_Preset,
                  "  |  ", _pL, "x", _pW, "x", _pH, " mm",
                  "  |  Vol: ~", effective_volume, " cm3",
                  "  |  Suggested corner radius: ", _p_radius_hint, " mm",
                  "  |  Wall: ", Wall_Stinka_safe, "mm / Bottom: ", Bottom_Dno_safe, "mm / Top: ", Top_Dakh_safe, "mm"));
        if (_auto_wall_floor > 0 && Wall_Stinka_safe == _auto_wall_floor) {
            echo(str("       (auto-floor active: wall ≥", _auto_wall_floor, "mm, bottom ≥", _auto_dno_floor, "mm)"));
        }
    }

    }
}
check_configuration_warnings();

module generate_bom() {
    if (false) {
    sc_info_b = screw_info(Screw_Gvynt);
    sc_dia_b  = struct_val(sc_info_b, "diameter");
    screw_len = round((H_lid + H_base + 2.0) / 1.0) * 1.0;

    echo("=== BILL OF MATERIALS ===");
    echo(str("Enclosure: ", Length_Dovzhyna, " x ", Width_Shyryna, " x ", Height_Vysota, " mm"));
    echo(str("Material: ", Material_Type, " (shrinkage compensation: ", shrinkage_rate, "%)"));

    if (_fast != "snaps" && _fast != "magnets") {
        echo(str("FASTENERS: ", Screw_Gvynt, " x ", screw_len, "mm -- qty: ", len(pos_fasten), " pcs"));
    }
    if (_fast == "heatset") {
        r_len_b = ruthex_insert_len(Screw_Gvynt);
        ins_len = is_undef(r_len_b) ? round(sc_dia_b * Coeff_Heatset_Depth) : r_len_b;
        echo(str("HEAT-SET INSERTS: Ruthex ", Screw_Gvynt, " (L=", ins_len, "mm) -- qty: ", len(pos_fasten), " pcs"));
    }
    if (_fast == "nuts") {
        nt_info_b = nut_info(Screw_Gvynt);
        n_w_b = struct_val(nt_info_b, "width");
        echo(str("NUTS: DIN 934 ", Screw_Gvynt, " (AF=", n_w_b, "mm) -- qty: ", len(pos_fasten), " pcs"));
    }
    if (_fast == "magnets") {
        echo(str("MAGNETS: D", Magnet_Dia_Diametr, " x ", Magnet_Thick_Tovshchyna, "mm -- qty: ", len(pos_fasten) * 2, " pcs (base + lid)"));
    }
    if (PCB_Enable_Stiyky) {
        pcb_info_b = screw_info(PCB_Screw_Gvynt);
        pcb_d_b    = struct_val(pcb_info_b, "diameter");
        pcb_len_b  = round((PCB_Height_Vysota + pcb_d_b * 1.0) / 1.0);
        echo(str("PCB SCREWS: ", PCB_Screw_Gvynt, " x ", pcb_len_b, "mm -- qty: ", len(pos_pcb), " pcs"));
    }
    if (Gasket_Groove_Enable) {
        perim = 2 * (Length_Dovzhyna + Width_Shyryna);
        echo(str("GASKET: O-ring/foam strip ", Gasket_Groove_Width, "x", Gasket_Groove_Depth, "mm -- length: ~", perim, "mm"));
    }

    echo("=========================");

    // Bambu Studio companion data (copy from console to .json)
    echo("--- BAMBU STUDIO HINTS ---");
    echo(str("{ \"printer\": \"Bambu Lab ", Printer_Model, "\","));
    echo(str("  \"filament\": \"", Material_Type, "\","));
    echo(str("  \"layer_height\": 0.2,"));
    echo(str("  \"wall_loops\": ", max(3, ceil(T / 0.4)), ","));
    echo(str("  \"top_shell_layers\": ", max(4, ceil(Top_Dakh_safe / 0.2)), ","));
    echo(str("  \"bottom_shell_layers\": ", max(4, ceil(Bottom_Dno_safe / 0.2)), ","));
    echo(str("  \"support_needed\": false,"));
    echo(str("  \"print_orientation\": \"as_generated\","));
    echo(str("  \"note\": \"Screw: ", Screw_Gvynt, ", Boss_OD: ", round(boss_dia()*10)/10, "mm\" }"));
    echo("--------------------------");

    }
}
generate_bom();
