// =============================================================================
// БОБИШКИ КРІПЛЕННЯ (FASTENER BOSSES & RIBS)
// =============================================================================

// Hull-based corner gussets: smooth tangent transition from boss cylinder to wall faces.
// Geometry adapts automatically:
//   - Boss near wall  → gusset shrinks gracefully; boss merges with wall via intersection()
//   - Boss in corner  → no separate gussets; intersection() trims boss into wedge shape
//   - Boss floating   → full triangular hull fills the corner triangle (boss→X-wall→Y-wall)
// All gusset geometry is clipped by the outer intersection() in base_part / lid_part,
// so over-extension into walls is harmless and creates the strongest possible bond.
module boss_ribs(p, h) {
    bd    = boss_dia();
    r     = bd / 2;
    dir_x = sign(p[0]);
    dir_y = sign(p[1]);

    // Signed distance from boss centre to each inner wall face (in local boss coords)
    lx = L/2 - T - abs(p[0]);   // to inner X-wall; positive = wall is away from boss
    ly = W/2 - T - abs(p[1]);   // to inner Y-wall

    // Rib plate thickness: min 4 perimeters (1.6mm) for shear strength under fastener load
    rib_t = max(1.6, T * 0.45);

    // Gusset foot width at each wall: wider base = lower stress concentration
    // Capped at 1.8×boss_dia to stay visually clean; floor = rib_t to stay printable
    foot_x = max(rib_t, min(bd * 1.8, bd));   // width of plate pressed against X-wall
    foot_y = max(rib_t, min(bd * 1.8, bd));   // width of plate pressed against Y-wall

    // A gusset exists only when the wall is meaningfully far from the boss edge
    has_x = (lx > rib_t * 0.5);
    has_y = (ly > rib_t * 0.5);

    if (has_x && has_y) {
        // Unified corner gusset: convex hull of boss cylinder + X-wall plate + Y-wall plate.
        // Result: a smooth solid that blends the boss into both walls with no sharp steps.
        // The corner triangle (between X-plate, Y-plate and boss) is fully filled.
        hull() {
            cyl(h=h, d=bd, anchor=BOTTOM);
            // Thin plate flush against inner X-wall face, centred on boss Y axis
            translate([dir_x * lx, 0, 0])
                cuboid([rib_t, foot_x, h], anchor=BOTTOM);
            // Thin plate flush against inner Y-wall face, centred on boss X axis
            translate([0, dir_y * ly, 0])
                cuboid([foot_y, rib_t, h], anchor=BOTTOM);
        }
    } else if (has_x) {
        // Boss is merged with Y-wall; only X-direction gusset needed
        hull() {
            cyl(h=h, d=bd, anchor=BOTTOM);
            translate([dir_x * lx, 0, 0])
                cuboid([rib_t, bd, h], anchor=BOTTOM);
        }
    } else if (has_y) {
        // Boss is merged with X-wall; only Y-direction gusset needed
        hull() {
            cyl(h=h, d=bd, anchor=BOTTOM);
            translate([0, dir_y * ly, 0])
                cuboid([bd, rib_t, h], anchor=BOTTOM);
        }
    }
    // Both gaps ≤ threshold: boss is corner-integrated — no separate gussets needed.
    // The intersection() in base_part clips the cylinder to a quarter-round wedge
    // that bonds to both walls along their full inner faces.
}
