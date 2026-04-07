// ================================================================
// Snake Dongle 1.69" Enclosure  (snake_dongle_1_69.scad)
// ================================================================
//
// Two-part M2 screw-closed rectangular box enclosure for:
//   • ST7789 1.69" LCD module  (landscape, 39 × 31.5 mm PCB)
//   • Nice!Nano v2             (34.1 × 18.3 mm, USB-C mid-mount)
//   • 2× 6×6 mm tactile switches  (right side wall)
//   • APDS9930 breakout board     (top-wall slide-in channel,
//                                  replaces buzzer, 5 mm aperture)
//
// Inspired by felixJR123/Snake-Dongle-Case
//   (M2 heat-set insert edition, adapted for ST7789 1.69" display)
//
// Assembly order:
//   1. Solder Nice!Nano, tactile switches and APDS9930 with wires.
//   2. Slide APDS9930 PCB into top-wall channel from the front.
//   3. Lay Nice!Nano flat on the 4 corner posts.
//   4. Press face plate on; fasten 4× M2 × 8 mm screws from front.
//
// Print orientation:
//   Face plate → face-DOWN (display opening on build plate)
//   Main body  → open side UP
//
// Units: mm
// ================================================================

/* [Render] */
// 0 = both side-by-side  |  1 = face plate only  |  2 = main body only
SHOW = 0; // [0:Both, 1:Face plate, 2:Main body]

/* ── Display – ST7789 1.69" (Waveshare) ───────────────────── */
DISP_PCB_W    = 39.0;   // PCB width  (landscape) [mm]
DISP_PCB_H    = 31.5;   // PCB height (landscape) [mm]
DISP_PCB_T    =  1.2;   // PCB + glass stack thickness [mm]
DISP_ACTIVE_W = 32.63;  // active area width  [mm]
DISP_ACTIVE_H = 27.97;  // active area height [mm]

/* ── MCU – Nice!Nano v2 ────────────────────────────────────── */
NN_W       = 34.1;  // PCB width  [mm]
NN_H       = 18.3;  // PCB height [mm]
NN_PCB_T   =  1.6;  // PCB thickness [mm]
NN_TOTAL_T =  3.2;  // total height incl. USB-C connector [mm]
NN_USBC_W  =  9.5;  // USB-C receptacle width  [mm]
NN_USBC_H  =  3.5;  // USB-C receptacle height [mm]

/* ── APDS9930 Breakout Board ───────────────────────────────── */
// Generic APDS9930 breakout: ~13.5 × 10 mm PCB
// Component (sensor) face slides toward the top wall; chip protrudes
// through the 5 mm aperture. Face plate locks the board in place.
SENS_PCB_W  = 13.5;  // PCB width  (X in channel) [mm]
SENS_PCB_H  = 10.0;  // PCB length (Z in channel) [mm]
SENS_PCB_T  =  1.6;  // PCB thickness [mm]
SENS_COMP_H =  1.5;  // sensor chip height above PCB [mm]
SENS_APT_D  =  5.0;  // aperture hole diameter through top wall [mm]
SENS_Z      =  7.0;  // channel centre Z from body front opening [mm]

/* ── Tactile Switches – 6×6 mm tact, ≤8 mm height ─────────── */
TAC_HOLE_D  =  4.5;  // actuator through-hole diameter [mm]
TAC_Y1      = -9.0;  // lower button Y position [mm]
TAC_Y2      =  9.0;  // upper button Y position [mm]
TAC_Z_POS   =  7.0;  // button Z position from body front [mm]

/* ── Case parameters ───────────────────────────────────────── */
WALL       = 2.0;   // side-wall thickness [mm]
FLOOR      = 2.0;   // body back-wall thickness [mm]
FACE_T     = 3.0;   // face-plate thickness [mm]
CORNER_R   = 3.0;   // outer corner radius [mm]
TOLERANCE  = 0.3;   // fit clearance per side [mm]
DISP_CLR   = 0.3;   // clearance around display PCB edges [mm]
SCREEN_CLR = 0.4;   // extra clearance around active area [mm]

/* ── Derived dimensions ────────────────────────────────────── */
INNER_W = 42.0;               // fits 39 mm PCB + margins [mm]
INNER_H = 36.0;               // fits 31.5 mm PCB + margins [mm]
INNER_D = 12.0;               // Nice!Nano 3.2 + wiring 8.8 [mm]
BODY_D  = INNER_D + FLOOR;   // 14.0 mm body depth
OUTER_W = INNER_W + 2*WALL;  // 46.0 mm
OUTER_H = INNER_H + 2*WALL;  // 40.0 mm

/* ── M2 heat-insert & screw parameters ─────────────────────── */
HI_OD    = 3.5;  // heat-insert outer diameter [mm]
HI_DEPTH = 4.0;  // heat-insert hole depth [mm]
BOSS_D   = 6.0;  // boss outer diameter [mm]
BOSS_H   = 5.5;  // boss height [mm]
SCREW_D  = 2.4;  // M2 clearance hole diameter [mm]
CS_D     = 4.5;  // countersink top diameter [mm]
BOSS_CX  = OUTER_W / 2 - 2.0;  // = 21.0 mm
BOSS_CY  = OUTER_H / 2 - 2.0;  // = 18.0 mm

/* ── Helper modules ────────────────────────────────────────── */
$fn_def = 32;

module rrect(w, h, r) {
    rc = min(r, w/2 - 0.01, h/2 - 0.01);
    hull()
        for (sx = [-1,1], sy = [-1,1])
            translate([sx*(w/2 - rc), sy*(h/2 - rc)])
                circle(r = rc, $fn = $fn_def);
}

module rbox(w, h, d, r) {
    rc = min(r, w/2 - 0.01, h/2 - 0.01);
    hull()
        for (sx = [-1,1], sy = [-1,1])
            translate([sx*(w/2 - rc), sy*(h/2 - rc), 0])
                cylinder(r = rc, h = d, $fn = $fn_def);
}

/* ══════════════════════════════════════════════════════════════
   Part 1 – Face Plate
   ══════════════════════════════════════════════════════════════
   Attaches to the main body front with 4× M2 countersunk screws.
   Display PCB rests in a shallow ledge on the rear face.
   Print: face-DOWN (display opening on build plate).             */
module face_plate() {
    rim_ow = DISP_PCB_W + 2*DISP_CLR + 3.0;
    rim_oh = DISP_PCB_H + 2*DISP_CLR + 3.0;
    rim_iw = DISP_PCB_W + 2*DISP_CLR;
    rim_ih = DISP_PCB_H + 2*DISP_CLR;
    rim_d  = DISP_PCB_T + 0.4;

    difference() {
        union() {
            // Outer bezel panel
            rbox(OUTER_W, OUTER_H, FACE_T, CORNER_R);

            // Display PCB retention rim on rear face
            translate([0, 0, FACE_T])
                difference() {
                    rbox(rim_ow, rim_oh, rim_d, max(0.5, CORNER_R - 2.5));
                    translate([0, 0, -0.1])
                        rbox(rim_iw, rim_ih, rim_d + 0.2,
                             max(0.3, CORNER_R - 4));
                }
        }

        // Display active-area window (full thickness)
        translate([0, 0, -0.1])
            linear_extrude(FACE_T + 0.2)
                rrect(DISP_ACTIVE_W + 2*SCREEN_CLR,
                      DISP_ACTIVE_H + 2*SCREEN_CLR, 1.5);

        // Inward chamfer on window rear (bezel feel)
        translate([0, 0, FACE_T])
            hull() {
                translate([0, 0, 0])
                    linear_extrude(0.001)
                        rrect(DISP_ACTIVE_W + 2*SCREEN_CLR,
                              DISP_ACTIVE_H + 2*SCREEN_CLR, 1.5);
                translate([0, 0, 2.5])
                    linear_extrude(0.001)
                        rrect(DISP_ACTIVE_W + 2*SCREEN_CLR + 5.0,
                              DISP_ACTIVE_H + 2*SCREEN_CLR + 5.0, 3.0);
            }

        // 4× M2 countersunk clearance holes at corners
        for (sx = [-1,1], sy = [-1,1])
            translate([sx*BOSS_CX, sy*BOSS_CY, -0.1]) {
                cylinder(d = SCREW_D, h = FACE_T + 0.2, $fn = 20);
                cylinder(d1 = CS_D, d2 = SCREW_D,
                         h = (CS_D - SCREW_D)/2 + 0.1, $fn = 20);
            }
    }
}

/* ══════════════════════════════════════════════════════════════
   Part 2 – Main Body
   ══════════════════════════════════════════════════════════════
   Z = 0      : front opening (face plate attaches here)
   Z = BODY_D : back wall (FLOOR thick)
   Print: open-side UP.

   Nice!Nano lays flat on 4 corner posts near the back wall.
   USB-C edge faces –Y (bottom wall), which carries the slot.
   APDS9930 PCB slides into the top-wall channel from the front;
   the face plate retains it once screwed down.                  */
module main_body() {
    // ── APDS9930 channel geometry ────────────────────────────
    ch_clr   = 0.2;                         // clearance per side
    ch_xhalf = SENS_PCB_W/2 + ch_clr;      // half channel width  = 6.95 mm
    ch_gap   = SENS_COMP_H + SENS_PCB_T + 0.6; // rail depth from top inner wall = 3.7 mm
    ch_rw    = 1.5;                         // rail wall thickness in X
    ch_y0    = INNER_H/2 - ch_gap;         // rail bottom Y = 14.3 mm
    ch_z0    = SENS_Z - SENS_PCB_H/2;      // channel front Z = 2.0 mm
    ch_z1    = SENS_Z + SENS_PCB_H/2;      // channel back  Z = 12.0 mm

    difference() {
        union() {
            // Outer rectangular shell
            rbox(OUTER_W, OUTER_H, BODY_D, CORNER_R);

            // 4× M2 heat-insert bosses (corner pillars at front face)
            for (sx = [-1,1], sy = [-1,1])
                translate([sx*BOSS_CX, sy*BOSS_CY, 0])
                    cylinder(d = BOSS_D, h = BOSS_H, $fn = 20);

            // Nice!Nano corner mount posts (raise PCB 2 mm off back wall)
            translate([-NN_W/2, -NN_H/2, FLOOR])
                for (cx = [0.8, NN_W - 0.8])
                    for (cy = [0.8, NN_H - 0.8])
                        translate([cx, cy, 0])
                            cylinder(d = 2.0, h = 2.0, $fn = 16);
        }

        // Inner cavity (full depth minus back wall floor)
        translate([0, 0, -0.1])
            linear_extrude(BODY_D - FLOOR + 0.1)
                rrect(INNER_W, INNER_H, max(0.5, CORNER_R - WALL));

        // 4× M2 heat-insert holes (from front face)
        for (sx = [-1,1], sy = [-1,1])
            translate([sx*BOSS_CX, sy*BOSS_CY, -0.1])
                cylinder(d = HI_OD, h = HI_DEPTH + 0.1, $fn = 20);

        // USB-C slot (bottom wall –Y, centred X)
        usbc_z = FLOOR + NN_TOTAL_T/2;
        translate([0, -(OUTER_H/2) - 0.1, usbc_z])
            rotate([-90, 0, 0])
                hull()
                    for (dx = [-1,1])
                        translate([dx*(NN_USBC_W/2 - NN_USBC_H/2), 0, 0])
                            cylinder(d = NN_USBC_H + 2*TOLERANCE,
                                     h = WALL + 0.2, $fn = 16);

        // 2× tactile switch actuator holes (right wall +X)
        for (ty = [TAC_Y1, TAC_Y2])
            translate([OUTER_W/2 + 1, ty, TAC_Z_POS])
                rotate([0, -90, 0])
                    cylinder(d = TAC_HOLE_D, h = WALL + 3, $fn = 20);

        // APDS9930 aperture through top wall (+Y), sensor looks outward
        translate([0, OUTER_H/2 + 1, SENS_Z])
            rotate([-90, 0, 0])
                cylinder(d = SENS_APT_D, h = WALL + 3, $fn = 20);

        // LED window (right wall +X, power indicator)
        translate([OUTER_W/2 - 0.1, 0, FLOOR + NN_TOTAL_T/2 + 2])
            rotate([0, 90, 0])
                cylinder(d = 2.5, h = WALL + 0.2, $fn = 16);

        // Wire pass-through slot (back wall, centred)
        translate([0, 0, BODY_D - WALL - 0.1])
            rbox(10, 3, WALL + 0.2, 1.0);
    }

    // ── APDS9930 slide-in channel rails ──────────────────────
    // Added outside the difference() so the cavity does not erase them.
    // The PCB slides in from the front (Z = 0) and stops at the back rail.
    // The face plate locks the PCB in place when screwed down.

    // Left rail
    translate([-ch_xhalf - ch_rw, ch_y0, ch_z0])
        cube([ch_rw, ch_gap, SENS_PCB_H]);

    // Right rail
    translate([ch_xhalf, ch_y0, ch_z0])
        cube([ch_rw, ch_gap, SENS_PCB_H]);

    // Back stop (prevents over-insertion)
    translate([-ch_xhalf - ch_rw, ch_y0, ch_z1])
        cube([SENS_PCB_W + 2*ch_rw + 2*ch_clr, ch_gap, ch_rw]);
}

/* ── Render ──────────────────────────────────────────────────── */
if (SHOW == 0) {
    translate([-(OUTER_W/2 + 5), 0, 0]) face_plate();
    translate([  OUTER_W/2 + 5,  0, 0]) main_body();
} else if (SHOW == 1) {
    face_plate();
} else {
    main_body();
}
