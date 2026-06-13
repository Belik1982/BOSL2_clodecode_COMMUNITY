// =============================================================================
// ТЕКСТ ТА МАРКУВАННЯ (TEXT & LABELING)
// =============================================================================

module render_text_block(txt, face, font, sz, depth, offset_1, offset_2, rot_angle, is_cutout, is_lid) {
    if (face != "Немає (None)" && txt != "") {
        is_deboss = depth < 0;
        is_emboss = depth > 0;
        d = abs(depth);
        ext_d = is_cutout ? d + _eps : d;

        if ((is_cutout && is_deboss) || (!is_cutout && is_emboss)) {
            _font = (!false && font != "Arial:style=Bold" && font != "Courier New:style=Bold" && font != "Times New Roman:style=Bold") ? "Arial:style=Bold" : font;
            if (font != _font) echo(str("(PRO) Font ", font, " is a Pro feature. Using Arial instead."));
            color(C_TEXT) {
                is_lid_face = (face == "Дах (Top)" || face == "Top");
                is_base_face = !is_lid_face;
                
                if ((is_lid && is_lid_face) || (!is_lid && is_base_face)) {
                    shift = is_cutout ? -ext_d + _eps : 0;
                    face_vec = face_vector(face);
                    
                    if (face_vec == UP || face_vec == DOWN) {
                        is_lid_top = (is_lid && face_vec == UP);
                        translate([offset_1, offset_2, -shift]) {
                            if (is_lid_top) {
                                // Дзеркальне відображення по Y для компенсації глобального mirror([0,0,1]) у збірці
                                scale([1, -1, 1])
                                    xrot(180) 
                                        linear_extrude(ext_d) 
                                            zrot(rot_angle)
                                                text(txt, font=_font, size=sz, halign="center", valign="center");
                            } else {
                                xrot(180) 
                                    linear_extrude(ext_d) 
                                        zrot(rot_angle)
                                            text(txt, font=_font, size=sz, halign="center", valign="center");
                            }
                        }
                    } else if (face_vec != [0,0,0]) {
                        is_x_face = (face_vec[0] != 0);
                        tangent_vec = is_x_face ? BACK : RIGHT;
                        face_dist = is_x_face ? L/2 : W/2;
                        z_center = is_lid ? (H_lid/2) : (H_base/2);
                        z_world = is_lid ? (H_base + z_center) : z_center;

                        translate(face_vec * (face_dist + shift) + tangent_vec * offset_1 + UP * (z_world + offset_2))
                            rot(from=UP, to=face_vec)
                                linear_extrude(ext_d) 
                                    zrot(rot_angle)
                                        text(txt, font=_font, size=sz, halign="center", valign="center");
                    }
                }
            }
        }
    }
}

module apply_text(is_cutout, is_lid) {
    render_text_block(Text_1_Custom_Tekst, Text_1_Face_Gran, Text_1_Font_Shryft, Text_1_Size_Rozmir, Text_1_Depth_Glybyna, Text_1_Offset_1, Text_1_Offset_2, Text_1_Rot_Kut, is_cutout, is_lid);
    render_text_block(Text_2_Custom_Tekst, Text_2_Face_Gran, Text_2_Font_Shryft, Text_2_Size_Rozmir, Text_2_Depth_Glybyna, Text_2_Offset_1, Text_2_Offset_2, Text_2_Rot_Kut, is_cutout, is_lid);
    if (false) {
        render_text_block(Text_3_Custom_Tekst, Text_3_Face_Gran, Text_3_Font_Shryft, Text_3_Size_Rozmir, Text_3_Depth_Glybyna, Text_3_Offset_1, Text_3_Offset_2, Text_3_Rot_Kut, is_cutout, is_lid);
        render_text_block(Text_4_Custom_Tekst, Text_4_Face_Gran, Text_4_Font_Shryft, Text_4_Size_Rozmir, Text_4_Depth_Glybyna, Text_4_Offset_1, Text_4_Offset_2, Text_4_Rot_Kut, is_cutout, is_lid);
    }
}