// =============================================================================
// КОНЕКТОРИ ТА ПОРТИ (CONNECTOR DATABASE & PORTS)
// =============================================================================
function port_bound_r(type) =
    let(
        cl = Port_Clearance,
        w = (type == "USB-A")            ? (34.0  + 2*cl) :
            (type == "USB-A Dual Stack") ? (34.0  + 2*cl) :
            (type == "USB-B")            ? (24.2  + 2*cl) :
            (type == "USB-C")            ? (16.0  + 2*cl) :
            (type == "Micro-USB")        ? (10.0  + 2*cl) :
            (type == "Mini-USB")         ? ( 9.0  + 2*cl) :
            (type == "HDMI")             ? (17.5  + 2*cl) :
            (type == "Mini-HDMI")        ? (12.0  + 2*cl) :
            (type == "RJ45 Ethernet")    ? (16.0  + 2*cl) :
            (type == "DE-9 (DB9)")       ? (28.2  + 2*cl) :
            (type == "DA-15 (DB15)")     ? (36.2  + 2*cl) :
            (type == "DB-25")            ? (50.2  + 2*cl) :
            (type == "XLR 3-pin")        ? (24.0  + 2*cl) :
            (type == "XLR 5-pin")        ? (24.0  + 2*cl) :
            (type == "Speakon NL4")      ? (24.0  + 2*cl) :
            (type == "Jack 3.5mm")       ? ( 7.0  + 2*cl) :
            (type == "Jack 6.35mm")      ? ( 9.5  + 2*cl) :
            (type == "MIDI DIN-5")       ? (16.5  + 2*cl) :
            (type == "DC Jack M8")       ? (10.0  + 2*cl) :
            (type == "DC Jack M11")      ? (13.0  + 2*cl) :
            (type == "XT30")             ? (18.9  + 2*cl) :
            (type == "XT60")             ? (22.7  + 2*cl) :
            (type == "IEC AC 220V")      ? (44.4  + 2*cl) :
            (type == "IEC C8 Fig-8")     ? (24.0  + 2*cl) :
            (type == "GX16 Aviation")    ? (16.0  + 2*cl) :
            (type == "GX20 Aviation")    ? (20.0  + 2*cl) : 0,
        h = (type == "USB-A")            ? ( 7.0  + 2*cl) :
            (type == "USB-A Dual Stack") ? (16.5  + 2*cl) :
            (type == "USB-B")            ? (11.0  + 2*cl) :
            (type == "USB-C")            ? ( 3.5  + 2*cl) :
            (type == "Micro-USB")        ? ( 3.0  + 2*cl) :
            (type == "Mini-USB")         ? ( 3.8  + 2*cl) :
            (type == "HDMI")             ? ( 6.5  + 2*cl) :
            (type == "Mini-HDMI")        ? ( 4.4  + 2*cl) :
            (type == "RJ45 Ethernet")    ? (13.5  + 2*cl) :
            (type == "DE-9 (DB9)")       ? (10.5  + 2*cl) :
            (type == "DA-15 (DB15)")     ? (10.5  + 2*cl) :
            (type == "DB-25")            ? (10.5  + 2*cl) :
            (type == "XLR 3-pin")        ? (24.0  + 2*cl) :
            (type == "XLR 5-pin")        ? (24.0  + 2*cl) :
            (type == "Speakon NL4")      ? (24.0  + 2*cl) :
            (type == "Jack 3.5mm")       ? ( 7.0  + 2*cl) :
            (type == "Jack 6.35mm")      ? ( 9.5  + 2*cl) :
            (type == "MIDI DIN-5")       ? (16.5  + 2*cl) :
            (type == "DC Jack M8")       ? (10.0  + 2*cl) :
            (type == "DC Jack M11")      ? (13.0  + 2*cl) :
            (type == "XT30")             ? ( 7.5  + 2*cl) :
            (type == "XT60")             ? (11.2  + 2*cl) :
            (type == "IEC AC 220V")      ? (22.8  + 2*cl) :
            (type == "IEC C8 Fig-8")     ? (13.0  + 2*cl) :
            (type == "GX16 Aviation")    ? (16.0  + 2*cl) :
            (type == "GX20 Aviation")    ? (20.0  + 2*cl) : 0
    )
    max(w, h) / 2;

// =============================================================================
// ДОПОМІЖНІ МОДУЛІ
// =============================================================================

module _port_dsub(body_w, body_h, mount_d, depth, cl) {
    w=body_w+2*cl; h=body_h+2*cl; ch=2.5;
    linear_extrude(depth, center=true)
        polygon([[-w/2+ch,h/2],[w/2-ch,h/2],[w/2,h/2-ch],[w/2,-h/2],[-w/2,-h/2],[-w/2,h/2-ch]]);
    if (mount_d > 0)
        grid_copies(spacing=mount_d, size=[mount_d,1])
            cyl(h=depth+_eps, d=3.2+cl, center=true);
}

module port_cutout_3d(type, depth) {
    cl = Port_Clearance;
    if (type == "USB-A") {
        linear_extrude(depth, center=true) rect([14.5+2*cl, 7.0+2*cl]);
        grid_copies(spacing=28.0, size=[28.0,1]) cyl(h=depth+_eps, d=3.2+cl, center=true);
    } else if (type == "USB-A Dual Stack") {
        linear_extrude(depth, center=true) rect([14.5+2*cl, 16.5+2*cl]);
        grid_copies(spacing=28.0, size=[28.0,1]) cyl(h=depth+_eps, d=3.2+cl, center=true);
    } else if (type == "USB-B") {
        w_b=12.2+2*cl; h_b=11.0+2*cl; ch_b=2.5;
        linear_extrude(depth, center=true)
            polygon([[-w_b/2+ch_b,h_b/2],[w_b/2-ch_b,h_b/2],[w_b/2,h_b/2-ch_b],
                     [w_b/2,-h_b/2],[-w_b/2,-h_b/2],[-w_b/2,h_b/2-ch_b]]);
        grid_copies(spacing=20.5, size=[20.5,1]) cyl(h=depth+_eps, d=3.2+cl, center=true);
    } else if (type == "USB-C") {
        linear_extrude(depth, center=true) rect([9.0+2*cl, 3.5+2*cl], rounding=1.75+cl);
        grid_copies(spacing=12.0, size=[12.0,1]) cyl(h=depth+_eps, d=2.2+cl, center=true);
    } else if (type == "Micro-USB") {
        linear_extrude(depth, center=true) rect([8.0+2*cl, 3.0+2*cl], rounding=1.0+cl);
    } else if (type == "Mini-USB") {
        linear_extrude(depth, center=true) rect([7.4+2*cl, 3.8+2*cl], rounding=0.8+cl);
    } else if (type == "HDMI") {
        linear_extrude(depth, center=true) rect([15.0+2*cl, 5.5+2*cl], rounding=0.5);
        grid_copies(spacing=24.0, size=[24.0,1]) cyl(h=depth+_eps, d=2.5+cl, center=true);
    } else if (type == "Mini-HDMI") {
        linear_extrude(depth, center=true) rect([10.42+2*cl, 3.84+2*cl], rounding=0.5);
    } else if (type == "RJ45 Ethernet") {
        linear_extrude(depth, center=true) rect([14.0+2*cl, 12.5+2*cl], rounding=0.5);
        grid_copies(spacing=24.0, size=[24.0,1]) cyl(h=depth+_eps, d=3.2+cl, center=true);
    } else if (type == "DE-9 (DB9)")   { _port_dsub(25.1,  10.5, 25.00, depth, cl);
    } else if (type == "DA-15 (DB15)") { _port_dsub(33.3,  10.5, 33.00, depth, cl);
    } else if (type == "DB-25")        { _port_dsub(47.0,  10.5, 47.04, depth, cl);
    } else if (type == "XLR 3-pin") {
        cyl(h=depth, d=23.5+2*cl, center=true);
        cyl(h=depth+_eps, d=28.0+2*cl, center=true, $fn=3);
    } else if (type == "XLR 5-pin") {
        cyl(h=depth, d=23.5+2*cl, center=true);
        cyl(h=depth+_eps, d=28.0+2*cl, center=true, $fn=3);
    } else if (type == "Speakon NL4") {
        cyl(h=depth, d=23.5+2*cl, center=true);
        cyl(h=depth+_eps, d=28.0+2*cl, center=true, $fn=4);
    } else if (type == "Jack 3.5mm") {
        cyl(h=depth, d=6.4+2*cl, center=true);
    } else if (type == "Jack 6.35mm") {
        cyl(h=depth, d=9.4+2*cl, center=true);
    } else if (type == "MIDI DIN-5") {
        cyl(h=depth, d=15.4+2*cl, center=true);
        grid_copies(spacing=14.0, size=[14.0,1]) cyl(h=depth+_eps, d=3.2+cl, center=true);
    } else if (type == "DC Jack M8") { cyl(h=depth, d=8.2+cl, center=true);
    } else if (type == "DC Jack M11") { cyl(h=depth, d=11.2+cl, center=true);
    } else if (type == "XT30") {
        linear_extrude(depth, center=true) rect([10.5+2*cl, 5.5+2*cl], rounding=2.75+cl);
        grid_copies(spacing=14.5, size=[14.5,1]) cyl(h=depth+_eps, d=2.2+cl, center=true);
    } else if (type == "XT60") {
        linear_extrude(depth, center=true) rect([16.0+2*cl, 11.2+2*cl], rounding=4.25+cl);
        grid_copies(spacing=20.0, size=[20.0,1]) cyl(h=depth+_eps, d=2.7+cl, center=true);
    } else if (type == "IEC AC 220V") {
        linear_extrude(depth, center=true) rect([28.2+2*cl, 22.8+2*cl], rounding=3.0+cl);
        grid_copies(spacing=40.0, size=[40.0,1]) cyl(h=depth+_eps, d=3.2+cl, center=true);
    } else if (type == "IEC C8 Fig-8") {
        hull() {
            translate([-7.5,0,0]) cyl(h=depth, d=9.5+2*cl, center=true);
            translate([ 7.5,0,0]) cyl(h=depth, d=9.5+2*cl, center=true);
        }
    } else if (type == "GX16 Aviation") { cyl(h=depth, d=16.0+2*cl, center=true);
    } else if (type == "GX20 Aviation") { cyl(h=depth, d=20.0+2*cl, center=true);
    }
}

module apply_port(type, face, offset_1, offset_2, rot_angle) {
    face_vec = face_vector(face);
    if (face_vec != [0,0,0] && type != "Немає (None)") {
        depth = T + 2*_eps;
        pr = port_bound_r(type);
        
        is_x_face = (face_vec[0] != 0); // LEFT або RIGHT
        max_limit_hor = is_x_face ? max(0, W_in/2 - pr) : max(0, L_in/2 - pr);
        clamped_offset_1 = min(max_limit_hor, max(-max_limit_hor, offset_1));
        
        z_center = H_base/2;
        min_z = Bottom_Dno_safe + pr;
        max_z = H_base - Lip_Height_Vysota_safe - pr;
        clamped_z = (min_z > max_z) ? z_center : min(max_z, max(min_z, z_center + offset_2));
        
        tangent_vec = is_x_face ? BACK : RIGHT;
        face_dist = is_x_face ? L/2 : W/2;
        
        // Зсув на T/2 усередину для скрізного різу (модулі портів використовують center=true)
        translate(face_vec * (face_dist - T/2) + tangent_vec * clamped_offset_1 + UP * clamped_z)
            rot(from=UP, to=face_vec)
                zrot(rot_angle)
                    port_cutout_3d(type, depth);
    }
}

function is_free_connector(type) =
    type == "USB-C" || type == "USB-A" || type == "DC Jack M8" ||
    type == "Jack 3.5mm" || type == "RJ45 Ethernet" || type == "HDMI";
module apply_all_ports() {
    apply_port(Port_1_Type, Port_1_Face, Port_1_Offset_1, Port_1_Offset_2, Port_1_Rot_Kut);
    apply_port(Port_2_Type, Port_2_Face, Port_2_Offset_1, Port_2_Offset_2, Port_2_Rot_Kut);
    apply_port(Port_3_Type, Port_3_Face, Port_3_Offset_1, Port_3_Offset_2, Port_3_Rot_Kut);
    apply_port(Port_4_Type, Port_4_Face, Port_4_Offset_1, Port_4_Offset_2, Port_4_Rot_Kut);
}

