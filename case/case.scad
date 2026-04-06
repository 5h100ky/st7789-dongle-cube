// ============================================================
// ST7789 1.69" (Landscape) + Nice!Nano v2  –  Dongle Cube Case
// ============================================================
//
// 설명: ST7789 1.69인치 디스플레이(가로 방향)와 나이스나노 v2를 위한
//       2파트 스냅핏 3D 프린트 케이스.
//
// Description: Two-part snap-fit 3D-printable enclosure for the
//   ST7789 1.69" display (landscape / horizontal) and Nice!Nano v2.
//
// Print settings / 출력 설정:
//   • Top shell  → print face-DOWN (display side on build plate)
//   • Bottom shell → print as-is (open side up)
//   • Layer height : 0.2 mm
//   • Infill       : 15 %
//   • Supports     : none required
//
// Assembly / 조립 순서:
//   1. Wire the ST7789 to the Nice!Nano v2 (SPI).
//   2. Press the display PCB into the top-shell window from inside.
//   3. Tuck the Nice!Nano v2 into the bottom-shell PCB seat.
//   4. Route the wires and press the two shells together.
//
// Units: mm
// ============================================================

/* [What to render / 렌더링 선택] */
// 0 = both parts side-by-side  |  1 = top shell only  |  2 = bottom shell only
SHOW = 0; // [0:Both, 1:Top shell, 2:Bottom shell]

/* ── Component dimensions / 컴포넌트 치수 ────────────────────── */

// ST7789 1.69" module  (landscape = PCB rotated 90°)
// PCB  portrait: 31.5 mm tall × 39.0 mm wide  →  landscape: W × H
DISP_PCB_W      = 39.0;   // display PCB width  (landscape long side)  [mm]
DISP_PCB_H      = 31.5;   // display PCB height (landscape short side) [mm]
DISP_PCB_T      = 1.2;    // PCB + glass stack thickness                [mm]
DISP_ACTIVE_W   = 32.63;  // active / viewing area width (landscape)   [mm]
DISP_ACTIVE_H   = 27.97;  // active / viewing area height (landscape)  [mm]
DISP_CONN_H     = 3.0;    // FPC connector height protruding below PCB [mm]

// Nice!Nano v2
NN_W            = 34.1;   // PCB width  [mm]
NN_H            = 18.3;   // PCB height [mm]
NN_PCB_T        = 1.6;    // PCB thickness [mm]
NN_TOTAL_T      = 3.2;    // incl. mid-mount USB-C connector on top     [mm]
NN_USBC_W       = 9.5;    // USB-C receptacle opening width             [mm]
NN_USBC_H       = 3.5;    // USB-C receptacle opening height            [mm]
// USB-C sits on the top long edge of the Nice!Nano; centred along width.

/* ── Case parameters / 케이스 파라미터 ──────────────────────── */
WALL            = 2.0;    // shell wall thickness  [mm]
FLOOR           = 2.0;    // bottom floor thickness [mm]
TOLERANCE       = 0.25;   // print-fit clearance on each side [mm]
CORNER_R        = 2.5;    // outer corner radius  [mm]

// Internal clearances around components
DISP_CLR        = 0.3;    // clearance around display PCB edges [mm]
NN_CLR          = 0.4;    // clearance around Nice!Nano PCB     [mm]

// Snap-fit tongue parameters
SNAP_W          = 6.0;    // snap tab width   [mm]
SNAP_T          = 0.9;    // snap tab thickness (flexes) [mm]
SNAP_CATCH      = 0.7;    // undercut depth   [mm]
SNAP_H          = 4.0;    // snap tab height  [mm]
NUM_SNAPS       = 2;      // snaps on each long side

/* ── Derived dimensions / 파생 치수 ─────────────────────────── */
// Cavity is sized for the display PCB (widest component in W direction)
INNER_W = max(DISP_PCB_W, NN_W) + 2 * (TOLERANCE + 0.5); // ~42 mm
INNER_H = DISP_PCB_H             + 2 * (TOLERANCE + 0.5); // ~34 mm

// Depth breakdown (inside the closed case):
//   top-shell ledge (display PCB) + air gap + Nice!Nano stack
LEDGE_D  = DISP_PCB_T + 0.4;                // pocket in top shell for display PCB
WIRE_GAP = 5.0;                              // wiring / air gap between PCBs
INNER_D  = LEDGE_D + WIRE_GAP + NN_TOTAL_T; // total inner depth ~10 mm

// Top-shell dimensions
TOP_H    = LEDGE_D + WALL;   // thin: just enough for display PCB pocket
// Bottom-shell dimensions
BOT_H    = INNER_D - LEDGE_D + FLOOR;       // rest of the depth + floor

OUTER_W  = INNER_W + 2 * WALL;
OUTER_H  = INNER_H + 2 * WALL;

// Nice!Nano seat position inside bottom shell (centred W, centred H)
NN_SEAT_X = (INNER_W - NN_W) / 2;
NN_SEAT_Y = (INNER_H - NN_H) / 2;

// USB-C cutout position on the BOTTOM edge of the bottom shell
// The Nice!Nano USB-C faces the BOTTOM edge of the case (short side)
USBC_OFFSET_Z = FLOOR + NN_TOTAL_T / 2; // height of USB-C centre from floor

/* ── Helper modules / 헬퍼 모듈 ─────────────────────────────── */

// Rounded rectangular prism (centred at XY origin, Z starts at 0)
module rbox(w, h, d, r = CORNER_R) {
    r_clamped = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull()
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (w / 2 - r_clamped), sy * (h / 2 - r_clamped), 0])
                cylinder(r = r_clamped, h = d, $fn = 32);
}

// Rounded rectangle 2-D (used with linear_extrude)
module rrect(w, h, r = CORNER_R) {
    r_clamped = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull()
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (w / 2 - r_clamped), sy * (h / 2 - r_clamped)])
                circle(r = r_clamped, $fn = 32);
}

// Snap tongue protruding inward (along -X, centred at origin)
// Used on top-shell inner skirt; bottom-shell has matching groove.
module snap_tongue(protruding_side = "left") {
    // tongue points INWARD (+X) – caller rotates/mirrors as needed
    linear_extrude(SNAP_W)
        polygon([
            [0,          0],
            [SNAP_T,     0],
            [SNAP_T,     SNAP_H - SNAP_CATCH],
            [SNAP_T + SNAP_CATCH, SNAP_H],
            [SNAP_T,     SNAP_H + SNAP_CATCH * 0.8],
            [0,          SNAP_H + SNAP_CATCH * 0.8]
        ]);
}

/* ── Top shell / 상단 쉘 (display side) ─────────────────────── */
module top_shell() {
    difference() {
        union() {
            // ── Outer face plate ────────────────────────────────
            rbox(OUTER_W, OUTER_H, WALL, r = CORNER_R);

            // ── Display PCB ledge rim (pocket walls, from inside face) ──
            // Creates a shallow rim the display PCB rests on.
            translate([0, 0, WALL])
                difference() {
                    rbox(DISP_PCB_W + 2 * DISP_CLR + 2 * 1.0,
                         DISP_PCB_H + 2 * DISP_CLR + 2 * 1.0,
                         LEDGE_D, r = 1.5);
                    translate([0, 0, -0.1])
                        rbox(DISP_PCB_W + 2 * DISP_CLR,
                             DISP_PCB_H + 2 * DISP_CLR,
                             LEDGE_D + 0.2, r = 0.8);
                }

            // ── Inner skirt (slides over bottom-shell walls) ────
            translate([0, 0, WALL + LEDGE_D])
                difference() {
                    rbox(OUTER_W, OUTER_H, SNAP_H + SNAP_CATCH + 1.0, r = CORNER_R);
                    translate([0, 0, -0.1])
                        rbox(INNER_W - 2 * TOLERANCE,
                             INNER_H - 2 * TOLERANCE,
                             SNAP_H + SNAP_CATCH + 1.2, r = CORNER_R - WALL);
                }

            // ── Snap tongues on long sides ───────────────────────
            snap_z = WALL + LEDGE_D + 1.0;
            for (side = [-1, 1])
                for (i = [0 : NUM_SNAPS - 1]) {
                    x_pos = (i - (NUM_SNAPS - 1) / 2) * (INNER_W / (NUM_SNAPS));
                    translate([x_pos - SNAP_W / 2,
                               side * (INNER_H / 2 - TOLERANCE),
                               snap_z])
                        rotate([side > 0 ? 0 : 180, 0, 90])
                            snap_tongue();
                }
        }

        // ── Display viewing window ──────────────────────────────
        translate([0, 0, -0.1])
            rbox(DISP_ACTIVE_W + 2 * TOLERANCE,
                 DISP_ACTIVE_H + 2 * TOLERANCE,
                 WALL + 0.2, r = 1.0);
    }
}

/* ── Bottom shell / 하단 쉘 (electronics side) ─────────────── */
module bottom_shell() {
    difference() {
        union() {
            // ── Main outer body ─────────────────────────────────
            rbox(OUTER_W, OUTER_H, BOT_H, r = CORNER_R);

            // ── Nice!Nano PCB seat risers ────────────────────────
            // Four corner posts that raise the Nice!Nano PCB off the floor
            // so the USB-C connector side faces the opening edge cleanly.
            translate([-INNER_W / 2 + NN_SEAT_X,
                       -INNER_H / 2 + NN_SEAT_Y,
                        FLOOR]) {
                for (cx = [1, NN_W - 1])
                    for (cy = [1, NN_H - 1])
                        translate([cx, cy, 0])
                            cylinder(d = 2.4, h = 1.5, $fn = 16);
            }
        }

        // ── Inner cavity ────────────────────────────────────────
        translate([0, 0, FLOOR])
            rbox(INNER_W, INNER_H, BOT_H, r = CORNER_R - WALL);

        // ── Snap-fit grooves on long-side walls ─────────────────
        // Matching recesses for top-shell tongues
        snap_z = BOT_H - SNAP_H - SNAP_CATCH - 0.5;
        for (side = [-1, 1])
            for (i = [0 : NUM_SNAPS - 1]) {
                x_pos = (i - (NUM_SNAPS - 1) / 2) * (INNER_W / (NUM_SNAPS));
                translate([x_pos - SNAP_W / 2 - 0.1,
                           side * (OUTER_H / 2 - WALL - TOLERANCE),
                           snap_z])
                    cube([SNAP_W + 0.2,
                          SNAP_T + SNAP_CATCH + 0.3,
                          SNAP_H + SNAP_CATCH + 0.8]);
            }

        // ── USB-C port cutout ────────────────────────────────────
        // On the FRONT short wall of the case (−Y side), centred.
        // The Nice!Nano USB-C faces this direction.
        translate([0,
                   -(OUTER_H / 2) - 0.1,
                   USBC_OFFSET_Z])
            rotate([-90, 0, 0])
                hull()
                    for (dx = [-1, 1])
                        translate([dx * (NN_USBC_W / 2 - NN_USBC_H / 2), 0, 0])
                            cylinder(d = NN_USBC_H + 2 * TOLERANCE,
                                     h = WALL + 0.2, $fn = 16);

        // ── Status LED window (optional tiny window on side wall) ──
        // Cut a 2.5 mm circle on the right short wall for the power LED.
        translate([OUTER_W / 2 - 0.1,
                   0,
                   FLOOR + NN_TOTAL_T / 2 + 1])
            rotate([0, 90, 0])
                cylinder(d = 2.5, h = WALL + 0.2, $fn = 16);

        // ── Ventilation / cable pass-through slot on back wall ──
        // 12 × 3 mm slot at the top of the back (+ Y) wall.
        translate([0,
                   OUTER_H / 2 - 0.1,
                   FLOOR + NN_TOTAL_T + WIRE_GAP / 2])
            rotate([90, 0, 0])
                rbox(12, 3, WALL + 0.2, r = 1.0);
    }
}

/* ── Render / 렌더링 ─────────────────────────────────────────── */
if (SHOW == 0) {
    // Both parts side-by-side for a layout view
    translate([-(OUTER_W / 2 + 3), 0, 0]) top_shell();
    translate([  OUTER_W / 2 + 3,  0, 0]) bottom_shell();
} else if (SHOW == 1) {
    top_shell();
} else {
    bottom_shell();
}
