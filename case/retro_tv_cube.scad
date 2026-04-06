// ============================================================
// ST7789 Dongle – Retro CRT-TV Cube Case  (retro_tv_cube.scad)
// ============================================================
//
// 레트로 브라운관 TV 스타일 2파트 스냅핏 케이스
// Retro CRT-TV styled two-part snap-fit enclosure for:
//   • ST7789 1.69" display (landscape, 39 × 31.5 mm PCB)
//   • Nice!Nano v2 (34.1 × 18.3 mm, USB-C on top edge)
//
// 형태 특징 / Shape features:
//   • 전면 페이스플레이트가 메인 바디보다 큼 (CRT 베젤 오버행)
//   • 메인 바디가 전면(넓음) → 후면(좁음)으로 테이퍼됨 (브라운관 실루엣)
//   • 두꺼운 전면 베젤 + 화면 내측 챔퍼 (브라운관 느낌)
//   • 후면 중앙에 USB-C 포트 슬롯
//   • 하단 좌우에 레트로 TV 스타일 발
//   • 측면에 LED 창
//
// 파트 구성 / Parts:
//   Part 1 – Face plate   : 화면 베젤 + 윈도우 + 내부 스커트(스냅핏)
//   Part 2 – Main body    : 전자부품 수납 + 테이퍼드 케이스 + 후면 USB-C
//
// 출력 방향 / Print orientation:
//   Face plate → 전면(화면)을 빌드 플레이트 쪽으로 (face-down)
//   Main body  → 개구부(앞면)가 위를 향하게 (open-side up)
//
// Units: mm
// ============================================================

/* [렌더링 / Render] */
// 0 = 전체 배치  1 = 페이스플레이트만  2 = 메인 바디만
SHOW = 0; // [0:Both, 1:Face plate, 2:Main body]

/* ── 컴포넌트 치수 / Component dimensions ──────────────── */
DISP_PCB_W    = 39.0;   // 디스플레이 PCB 폭  [mm]
DISP_PCB_H    = 31.5;   // 디스플레이 PCB 높이 [mm]
DISP_PCB_T    = 1.2;    // PCB + 유리 두께    [mm]
DISP_ACTIVE_W = 32.63;  // 화면 활성 영역 폭  [mm]
DISP_ACTIVE_H = 27.97;  // 화면 활성 영역 높이 [mm]

NN_W          = 34.1;   // 나이스나노 PCB 폭  [mm]
NN_H          = 18.3;   // 나이스나노 PCB 높이 [mm]
NN_TOTAL_T    = 3.2;    // 나이스나노 총 높이 (USB-C 포함) [mm]
NN_USBC_W     = 9.5;    // USB-C 리셉터클 폭  [mm]
NN_USBC_H     = 3.5;    // USB-C 리셉터클 높이 [mm]

/* ── 케이스 디자인 파라미터 / Case design parameters ─────── */

// ▸ 페이스플레이트 (전면 판)
FACE_W        = 52.0;   // 페이스플레이트 폭    [mm]
FACE_H        = 48.0;   // 페이스플레이트 높이   [mm]
FACE_T        = 3.0;    // 페이스플레이트 두께   [mm]
CORNER_R_FACE = 6.0;    // 페이스플레이트 코너 반지름

// ▸ 메인 바디 개구부 (페이스플레이트 뒤에 삽입되는 직선 벽 구간)
//   페이스플레이트가 3mm씩 오버행 → 오버행만큼 작음
BODY_OPEN_W   = 46.0;   // 개구부 폭  (FACE_W - 2 × 3 mm 오버행)  [mm]
BODY_OPEN_H   = 42.0;   // 개구부 높이 (FACE_H - 2 × 3 mm 오버행)  [mm]
CORNER_R_OPEN = 4.0;    // 개구부 코너 반지름

// ▸ 후면 + 테이퍼
BACK_W        = 40.0;   // 후면 폭  [mm]
BACK_H        = 36.0;   // 후면 높이 [mm]
BODY_DEPTH    = 36.0;   // 메인 바디 깊이 (개구부 → 후면 벽) [mm]
CORNER_R_BACK =  2.5;   // 후면 코너 반지름

// ▸ 벽 두께
WALL          =  2.5;   // 측면 벽 두께      [mm]
BACK_WALL     =  2.5;   // 후면 벽 두께      [mm]
TOLERANCE     =  0.25;  // 스냅핏 클리어런스  [mm]
SCREEN_CLR    =  0.4;   // 화면 윈도우 클리어런스 [mm]

/* ── 스냅핏 파라미터 / Snap-fit parameters ───────────────── */
SNAP_INSET    =  8.0;   // 직선 벽 구간 깊이 (스냅핏 존) [mm]
SNAP_W        =  6.0;   // 스냅 탭 폭        [mm]
SNAP_T        =  0.9;   // 스냅 탭 두께 (굴곡) [mm]
SNAP_CATCH    =  0.7;   // 언더컷 깊이        [mm]
SNAP_H        =  4.0;   // 스냅 탭 높이       [mm]
NUM_SNAPS     =  2;     // 장변 당 스냅 수

/* ── 내부 치수 (파생) / Derived internal dimensions ────────── */
INNER_W  = BODY_OPEN_W - 2 * WALL;         // ~41 mm
INNER_H  = BODY_OPEN_H - 2 * WALL;         // ~37 mm
INNER_D  = BODY_DEPTH  - BACK_WALL;        // usable depth

// 나이스나노 시트 오프셋
NN_SEAT_X = (INNER_W - NN_W) / 2;
NN_SEAT_Y = (INNER_H - NN_H) / 2;

// 나이스나노 마운팅 포스트 Z (디스플레이 아래 5 mm 간격)
NN_POST_Z = SNAP_INSET + DISP_PCB_T + 0.4 + 5.0;

// USB-C 구멍 중심 Z (내부 후면 벽 앞, 나이스나노 높이 중앙)
USBC_Z = BODY_DEPTH - BACK_WALL / 2;

/* ── 헬퍼 모듈 / Helper modules ─────────────────────────── */
$fn_def = 32;

// 2D 둥근 직사각형
module rrect(w, h, r) {
    rc = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull()
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (w / 2 - rc), sy * (h / 2 - rc)])
                circle(r = rc, $fn = $fn_def);
}

// 3D 둥근 직육면체 (Z=0 기준)
module rbox(w, h, d, r) {
    rc = min(r, w / 2 - 0.01, h / 2 - 0.01);
    hull()
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (w / 2 - rc), sy * (h / 2 - rc), 0])
                cylinder(r = rc, h = d, $fn = $fn_def);
}

// 테이퍼드 솔리드: Z=0에서 (w_f × h_f), Z=d에서 (w_b × h_b)
module tapered_box(w_f, h_f, w_b, h_b, d, r_f, r_b) {
    hull() {
        translate([0, 0, 0])
            linear_extrude(height = 0.001)
                rrect(w_f, h_f, r_f);
        translate([0, 0, d - 0.001])
            linear_extrude(height = 0.001)
                rrect(w_b, h_b, r_b);
    }
}

// 스냅 혀 (+X 방향으로 돌출, SNAP_W 만큼 Z 방향 압출)
module snap_tongue() {
    linear_extrude(SNAP_W)
        polygon([
            [0,                         0              ],
            [SNAP_T,                    0              ],
            [SNAP_T,                    SNAP_H - SNAP_CATCH],
            [SNAP_T + SNAP_CATCH,       SNAP_H         ],
            [SNAP_T,                    SNAP_H + SNAP_CATCH * 0.8],
            [0,                         SNAP_H + SNAP_CATCH * 0.8]
        ]);
}

/* ══════════════════════════════════════════════════════════
   파트 1: 페이스플레이트 / Part 1: Face plate
   ══════════════════════════════════════════════════════════
   조립시 메인 바디 개구부 위에 올려지고,
   내부 스커트가 개구부 안으로 삽입되어 스냅핏으로 고정됨.
   출력: 화면(전면)을 빌드 플레이트 방향으로 (face-down).    */
module face_plate() {
    // 스커트 외부 크기 (TOLERANCE만큼 작게 → 개구부에 헐렁 없이 끼워짐)
    skirt_ow = BODY_OPEN_W - 2 * TOLERANCE;
    skirt_oh = BODY_OPEN_H - 2 * TOLERANCE;
    // 스커트 내부 크기
    skirt_iw = BODY_OPEN_W - 2 * WALL - 2 * TOLERANCE;
    skirt_ih = BODY_OPEN_H - 2 * WALL - 2 * TOLERANCE;

    // 스냅 혀 Z 위치 (스커트 시작부터 측정, 주 바디 개구부 기준 1.5 mm)
    tongue_z = 1.5;

    difference() {
        union() {
            // ① 전면 판 (큰 베젤 포함, FACE_W × FACE_H × FACE_T)
            rbox(FACE_W, FACE_H, FACE_T, CORNER_R_FACE);

            // ② 내부 스커트 (개구부 안으로 삽입)
            translate([0, 0, FACE_T]) {
                difference() {
                    // 스커트 외벽
                    linear_extrude(SNAP_INSET + SNAP_H + SNAP_CATCH + 1.5)
                        rrect(skirt_ow, skirt_oh, CORNER_R_OPEN);
                    // 스커트 내부 오목
                    translate([0, 0, -0.1])
                        linear_extrude(SNAP_INSET + SNAP_H + SNAP_CATCH + 1.7)
                            rrect(skirt_iw, skirt_ih, CORNER_R_OPEN - WALL);
                }

                // ③ 스냅 혀 (장변 ±Y 면, X 방향으로 배치)
                for (side = [-1, 1])
                    for (i = [0 : NUM_SNAPS - 1]) {
                        xp = (i - (NUM_SNAPS - 1) / 2) * (skirt_iw / NUM_SNAPS);
                        translate([xp - SNAP_W / 2,
                                   side * (skirt_ih / 2 + WALL - TOLERANCE),
                                   tongue_z])
                            rotate([side > 0 ? 0 : 180, 0, 90])
                                snap_tongue();
                    }
            }
        }

        // ④ 화면 윈도우 (전면 판 관통)
        translate([0, 0, -0.1])
            linear_extrude(FACE_T + 0.2)
                rrect(DISP_ACTIVE_W + 2 * SCREEN_CLR,
                      DISP_ACTIVE_H + 2 * SCREEN_CLR,
                      2.5);

        // ⑤ 화면 내측 챔퍼 (브라운관 TV의 화면 오목 느낌)
        //    전면 판 뒤면에서 안쪽으로 경사를 넣어 깊이감을 줌
        translate([0, 0, FACE_T])
            hull() {
                translate([0, 0, 0])
                    linear_extrude(0.001)
                        rrect(DISP_ACTIVE_W + 2 * SCREEN_CLR,
                              DISP_ACTIVE_H + 2 * SCREEN_CLR, 2.5);
                translate([0, 0, 3.0])
                    linear_extrude(0.001)
                        rrect(DISP_ACTIVE_W + 2 * SCREEN_CLR + 6.0,
                              DISP_ACTIVE_H + 2 * SCREEN_CLR + 6.0, 4.0);
            }
    }
}

/* ══════════════════════════════════════════════════════════
   파트 2: 메인 바디 / Part 2: Main body
   ══════════════════════════════════════════════════════════
   전자부품 수납 + 테이퍼드 CRT TV 바디.
   Z=0: 개구부(페이스플레이트가 부착되는 면)
   Z=BODY_DEPTH: 후면(USB-C 포트가 있는 면)
   출력: 개구부가 위를 향하게 (open-side up).           */
module main_body() {
    difference() {
        union() {
            // ① 직선 벽 구간 (개구부 ~ SNAP_INSET, 스냅핏 존)
            linear_extrude(SNAP_INSET)
                rrect(BODY_OPEN_W, BODY_OPEN_H, CORNER_R_OPEN);

            // ② 테이퍼 바디 (SNAP_INSET ~ BODY_DEPTH)
            //    개구부 크기에서 후면 크기로 점점 좁아짐
            translate([0, 0, SNAP_INSET])
                tapered_box(BODY_OPEN_W, BODY_OPEN_H,
                            BACK_W,      BACK_H,
                            BODY_DEPTH - SNAP_INSET,
                            CORNER_R_OPEN, CORNER_R_BACK);

            // ③ 레트로 TV 발 (하단 좌우, 후면 쪽에 위치)
            //    조립 완료 후 케이스가 세워졌을 때 -Y 방향이 바닥
            for (dx = [-1, 1])
                translate([dx * (BACK_W / 2 - 7),
                           -(BACK_H / 2 + 0.001),
                           BODY_DEPTH - 4])
                    rotate([-90, 0, 0])
                        cylinder(d = 10, h = 4, $fn = 32);
        }

        // ── 내부 캐비티 ──────────────────────────────────────

        // 직선 구간 캐비티
        translate([0, 0, -0.1])
            linear_extrude(SNAP_INSET + 0.2)
                rrect(INNER_W, INNER_H, CORNER_R_OPEN - WALL);

        // 테이퍼 구간 캐비티 (벽 두께 WALL 유지, 후면 벽 BACK_WALL 유지)
        translate([0, 0, SNAP_INSET])
            tapered_box(INNER_W, INNER_H,
                        BACK_W - 2 * WALL, BACK_H - 2 * WALL,
                        BODY_DEPTH - SNAP_INSET - BACK_WALL + 0.001,
                        CORNER_R_OPEN - WALL,
                        max(0.5, CORNER_R_BACK - WALL));

        // ── 스냅 그루브 (장변 ±Y 벽, 페이스플레이트 스냅 혀에 맞는 홈) ──
        //    개구부에서 tongue_z=1.5mm 위치에 홈 형성
        snap_groove_z = 1.5;
        for (side = [-1, 1])
            for (i = [0 : NUM_SNAPS - 1]) {
                xp = (i - (NUM_SNAPS - 1) / 2) * (INNER_W / NUM_SNAPS);
                translate([xp - SNAP_W / 2 - 0.1,
                           side * (BODY_OPEN_H / 2 - WALL - TOLERANCE),
                           snap_groove_z])
                    cube([SNAP_W + 0.2,
                          SNAP_T + SNAP_CATCH + 0.3,
                          SNAP_H + SNAP_CATCH + 0.8]);
            }

        // ── USB-C 포트 구멍 (후면 벽 중앙) ──────────────────────
        //    나이스나노 USB-C가 이 구멍을 통해 접근 가능
        translate([0, 0, USBC_Z - 0.1])
            hull()
                for (dx = [-1, 1])
                    translate([dx * (NN_USBC_W / 2 - NN_USBC_H / 2), 0, 0])
                        cylinder(d = NN_USBC_H + 2 * TOLERANCE,
                                 h = BACK_WALL + 0.2, $fn = 20);

        // ── LED 창 (우측 측면 벽) ─────────────────────────────
        translate([BODY_OPEN_W / 2 - 0.1,
                   0,
                   SNAP_INSET + NN_TOTAL_T / 2 + 6])
            rotate([0, 90, 0])
                cylinder(d = 2.5, h = WALL + 0.2, $fn = 16);
    }

    // ── 디스플레이 PCB 코너 포스트 ──────────────────────────────
    //    디스플레이 PCB(39 × 31.5 mm)가 개구부 바로 아래 안착
    disp_x0 = -INNER_W / 2 + (INNER_W - DISP_PCB_W) / 2;
    disp_y0 = -INNER_H / 2 + (INNER_H - DISP_PCB_H) / 2;
    translate([disp_x0, disp_y0, SNAP_INSET])
        for (cx = [0.5, DISP_PCB_W - 0.5])
            for (cy = [0.5, DISP_PCB_H - 0.5])
                translate([cx, cy, 0])
                    cylinder(d = 2.0, h = 1.5, $fn = 16);

    // ── 나이스나노 마운팅 포스트 ────────────────────────────────
    translate([-INNER_W / 2 + NN_SEAT_X,
               -INNER_H / 2 + NN_SEAT_Y,
               NN_POST_Z])
        for (cx = [1, NN_W - 1])
            for (cy = [1, NN_H - 1])
                translate([cx, cy, 0])
                    cylinder(d = 2.4, h = 1.5, $fn = 16);
}

/* ── 렌더링 / Render ─────────────────────────────────────── */
if (SHOW == 0) {
    // 나란히 배치 (레이아웃 확인용)
    translate([-(FACE_W / 2 + 8), 0, 0])
        face_plate();
    translate([BODY_OPEN_W / 2 + 8, 0, 0])
        main_body();
} else if (SHOW == 1) {
    face_plate();
} else {
    main_body();
}
