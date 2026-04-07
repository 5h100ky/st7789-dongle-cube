// ============================================================
// ST7789 Dongle – Retro CRT-TV Cube Case  (retro_tv_cube.scad)
// ============================================================
//
// 레트로 브라운관 TV 스타일 2파트 나사 체결 케이스
// Retro CRT-TV styled two-part screw-fastened enclosure for:
//   • ST7789 1.69" display (landscape, 39 × 31.5 mm PCB)
//   • Nice!Nano v2 (34.1 × 18.3 mm, USB-C on bottom edge)
//
// 형태 특징 / Shape features:
//   • 전면 페이스플레이트가 메인 바디보다 큼 (CRT 베젤 오버행)
//   • 메인 바디가 전면(넓음) → 후면(좁음)으로 테이퍼됨 (브라운관 실루엣)
//   • 두꺼운 전면 베젤 + 화면 내측 챔퍼 (브라운관 느낌)
//   • 하단 벽에 USB-C 포트 슬롯 (MCU 수직 장착)
//   • 하단 좌우에 레트로 TV 스타일 발
//   • 측면에 LED 창
//   • 메인 바디 4 코너에 M2 히트인서트 → 페이스플레이트 나사 체결
//
// 파트 구성 / Parts:
//   Part 1 – Face plate   : 화면 베젤 + 윈도우 + 내부 스커트 + M2 카운터싱크
//   Part 2 – Main body    : 전자부품 수납 + 테이퍼드 케이스 + 하단 USB-C
//                           + M2 히트인서트 보스 + MCU ㄷ가이드
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
NN_PCB_T      = 1.6;    // 나이스나노 PCB 두께 [mm]
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

/* ── MCU 가이드 파라미터 / MCU guide parameters ─────────────── */
MCU_GUIDE_WALL =  1.0;  // 가이드 레일 벽 두께 [mm]
MCU_GUIDE_H    =  4.0;  // 가이드 레일 높이    [mm]
MCU_Z_POS      = 11.0;  // MCU 수직 장착 Z 위치 (개구부로부터) [mm]

/* ── 히트인서트 & 나사 파라미터 / Heat-insert & screw parameters ─
       M2 히트인서트, OD 3.5 mm                                   */
HI_OD     =  3.5;   // 히트인서트 외경 [mm]
HI_DEPTH  =  4.0;   // 히트인서트 홀 깊이 [mm]
BOSS_D    =  6.0;   // 보스 외경 [mm]
BOSS_H    =  6.5;   // 보스 높이 [mm]
SCREW_D   =  2.4;   // M2 클리어런스 홀 직경 [mm]
CS_D      =  4.5;   // 카운터싱크 상단 직경 [mm]

/* ── 스냅핏 파라미터 / Snap-fit parameters ───────────────── */
SNAP_INSET    =  8.0;   // 직선 벽 구간 깊이 (스냅핏 존) [mm]
SNAP_W        =  6.0;   // 스냅 탭 폭        [mm]
SNAP_T        =  0.9;   // 스냅 탭 두께 (굴곡) [mm]
SNAP_CATCH    =  0.7;   // 언더컷 깊이        [mm]
SNAP_H        =  4.0;   // 스냅 탭 높이       [mm]
NUM_SNAPS     =  2;     // 장변 당 스냅 수

/* ── 전술 스위치 파라미터 / Tactile switch parameters ───── */
// Standard 6 × 6 mm tact switch; 4 mm actuator hole fits actuator cap.
TAC_HOLE_D    =  4.0;   // actuator hole diameter [mm]
TAC_Z         = 15.0;   // button Z position from front opening [mm]
TAC_Y_OFFSET  =  7.0;   // vertical offset ±Y from center [mm]

/* ── APDS9930 센서 홀 / APDS9930 sensor aperture ─────────── */
SENSOR_D      =  5.0;   // sensor aperture hole diameter [mm]
SENSOR_X      =  0.0;   // sensor X position (centred) [mm]
SENSOR_Z      = 18.0;   // sensor hole Z position from front opening [mm]

/* ── 내부 치수 (파생) / Derived internal dimensions ────────── */
INNER_W  = BODY_OPEN_W - 2 * WALL;         // ~41 mm
INNER_H  = BODY_OPEN_H - 2 * WALL;         // ~37 mm
INNER_D  = BODY_DEPTH  - BACK_WALL;        // usable depth

// 보스 코너 위치: 메인 바디 개구부 외벽 중심 (±X, ±Y)
// 이 위치는 내부 캐비티 경계(±INNER_W/2, ±INNER_H/2) 바깥 외벽에 속함
BOSS_CX = BODY_OPEN_W / 2 - 2.0;   // = 21.0 mm
BOSS_CY = BODY_OPEN_H / 2 - 2.0;   // = 19.0 mm

// MCU 가이드 Z 깊이 (PCB 두께 + 클리어런스 + 후면 벽)
MCU_GUIDE_ZDEPTH = NN_PCB_T + TOLERANCE + MCU_GUIDE_WALL;

// 경사진 내부 바닥 Y 위치 함수 (테이퍼 구간)
// Z=SNAP_INSET → -(INNER_H/2),  Z=BODY_DEPTH-BACK_WALL → -(BACK_H-2*WALL)/2
function inner_floor_y(z) =
    (z <= SNAP_INSET)
        ? -(INNER_H / 2)
        : -(INNER_H / 2) + (INNER_H / 2 - (BACK_H - 2 * WALL) / 2) *
          (z - SNAP_INSET) / (BODY_DEPTH - BACK_WALL - SNAP_INSET);

// MCU 가이드 기준 Y (경사 보정 후 수평 기준면 = 가이드 후단 바닥 높이)
MCU_FLOOR_Y_F    = inner_floor_y(MCU_Z_POS);
MCU_FLOOR_Y_B    = inner_floor_y(MCU_Z_POS + MCU_GUIDE_ZDEPTH);
MCU_PAD_H        = MCU_FLOOR_Y_B - MCU_FLOOR_Y_F;   // 수평 패드 높이 차 (쐐기)
MCU_GUIDE_BASE_Y = MCU_FLOOR_Y_B;                   // 가이드 바닥 Y (수평)

// USB-C 구멍 Z 중심 (MCU PCB 두께 중앙)
MCU_USBC_Z = MCU_Z_POS + NN_PCB_T / 2;

/* ── 헬퍼 모듈 / Helper modules ─────────────────────────── */
$fn_def = 32;
EPSILON = 0.001;  // hull() 무한소 슬라이스용 두께 [mm]

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

    // 디스플레이 PCB 코너 포스트 위치 (내면 기준)
    disp_x0_fp = -INNER_W / 2 + (INNER_W - DISP_PCB_W) / 2;
    disp_y0_fp = -INNER_H / 2 + (INNER_H - DISP_PCB_H) / 2;

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

            // ④ 디스플레이 PCB 코너 포스트 (페이스플레이트 내면, 화면 고정)
            //    전면 판 안쪽에 작은 기둥 4개 → PCB 코너를 잡아줌
            translate([disp_x0_fp, disp_y0_fp, FACE_T])
                for (cx = [0.5, DISP_PCB_W - 0.5])
                    for (cy = [0.5, DISP_PCB_H - 0.5])
                        translate([cx, cy, 0])
                            cylinder(d = 2.0, h = 1.5, $fn = 16);
        }

        // ⑤ 화면 윈도우 (전면 판 관통)
        translate([0, 0, -0.1])
            linear_extrude(FACE_T + 0.2)
                rrect(DISP_ACTIVE_W + 2 * SCREEN_CLR,
                      DISP_ACTIVE_H + 2 * SCREEN_CLR,
                      2.5);

        // ⑥ 화면 내측 챔퍼 (브라운관 TV의 화면 오목 느낌)
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

        // ⑦ M2 나사 카운터싱크 홀 (4 코너, 히트인서트 체결용)
        //    메인 바디 히트인서트 보스 위치와 동일 (±BOSS_CX, ±BOSS_CY)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * BOSS_CX, sy * BOSS_CY, -0.1]) {
                // M2 클리어런스 관통 홀
                cylinder(d = SCREW_D, h = FACE_T + 0.2, $fn = 20);
                // 카운터싱크 (전면에서 깔대기 형)
                cylinder(d1 = CS_D, d2 = SCREW_D,
                         h = (CS_D - SCREW_D) / 2 + 0.1, $fn = 20);
            }
    }
}

/* ══════════════════════════════════════════════════════════
   파트 2: 메인 바디 / Part 2: Main body
   ══════════════════════════════════════════════════════════
   전자부품 수납 + 테이퍼드 CRT TV 바디.
   Z=0: 개구부(페이스플레이트가 부착되는 면)
   Z=BODY_DEPTH: 후면
   출력: 개구부가 위를 향하게 (open-side up).
   나이스나노 장착 방향:
     • PCB 수직 기립 (XY 평면, Z=MCU_Z_POS)
     • USB-C 에지가 하단(-Y 벽) 쪽을 향함 → 하단 벽에 USB-C 구멍
     • ㄷ 가이드가 바닥에서 PCB 3면(좌·우·뒤)을 감쌈 (앞 개구부 방향 열림) */
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

            // ④ 히트인서트 보스 (4 코너 외벽, M2 OD 3.5 mm)
            //    개구부 면(Z=0)에서 내부로 BOSS_H 만큼 돌출
            //    위치: 외벽 중앙 (BOSS_CX, BOSS_CY) – 내부 캐비티 바깥
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx * BOSS_CX, sy * BOSS_CY, 0])
                    cylinder(d = BOSS_D, h = BOSS_H, $fn = 20);
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
        //    스냅핏: 조립 위치 정렬 및 1차 고정 역할
        //    최종 체결은 4코너 M2 나사(히트인서트)로 보강
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

        // ── USB-C 포트 구멍 (하단 벽 중앙, 바닥으로 이동) ────────────
        //    나이스나노가 수직 기립하여 USB-C 에지가 하단(-Y 벽)을 향함.
        //    구멍은 -Y 외벽을 +Y 방향으로 관통.
        //    MCU_USBC_Z: PCB 두께 중앙 Z 위치
        translate([0, -(BODY_OPEN_H / 2) - 0.5, MCU_USBC_Z])
            rotate([-90, 0, 0])
                hull()
                    for (dx = [-1, 1])
                        translate([dx * (NN_USBC_W / 2 - NN_USBC_H / 2), 0, 0])
                            cylinder(d = NN_USBC_H + 2 * TOLERANCE,
                                     h = WALL + 2.0, $fn = 16);

        // ── LED 창 (우측 측면 벽) ─────────────────────────────
        translate([BODY_OPEN_W / 2 - 0.1,
                   0,
                   SNAP_INSET + NN_TOTAL_T / 2 + 6])
            rotate([0, 90, 0])
                cylinder(d = 2.5, h = WALL + 0.2, $fn = 16);

        // ── 히트인서트 홀 (보스 중심, Z=0에서 HI_DEPTH 깊이) ─────────
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * BOSS_CX, sy * BOSS_CY, -0.1])
                cylinder(d = HI_OD, h = HI_DEPTH + 0.1, $fn = 20);
    }

    // ── MCU 수평 패드 + ㄷ 가이드 ───────────────────────────────────
    //
    // 메인 바디가 테이퍼로 인해 내부 바닥(-Y 면)이 앞→뒤로 경사짐.
    // 수평 패드(쐐기형)가 이 경사를 보정하여 가이드 기준면을 수평으로 만듦.
    //
    // 나이스나노 장착 방향:
    //   • PCB 폭(NN_W=34.1mm) → X 축 중앙
    //   • PCB 높이(NN_H=18.3mm) → +Y 방향 (기립)
    //   • PCB 두께(NN_PCB_T=1.6mm) → Z 방향 (MCU_Z_POS 위치)
    //   • USB-C 에지: 하단(-Y), MCU_GUIDE_BASE_Y 수준
    //
    // ㄷ 가이드 형상 (개구부(-Z) 방향으로 열린 U채널):
    //   좌측 레일 | 후면 벽 | 우측 레일
    //   PCB를 위에서 아래로 삽입 후 개구부에서 지지

    // 수평 패드 (쐐기형, 전단이 높고 후단에서 0이 됨)
    if (MCU_PAD_H > 0.01)
        hull() {
            translate([-(NN_W / 2) - MCU_GUIDE_WALL,
                       MCU_FLOOR_Y_F,
                       MCU_Z_POS])
                cube([NN_W + 2 * MCU_GUIDE_WALL, MCU_PAD_H, EPSILON]);
            translate([-(NN_W / 2) - MCU_GUIDE_WALL,
                       MCU_GUIDE_BASE_Y - EPSILON,
                       MCU_Z_POS + MCU_GUIDE_ZDEPTH])
                cube([NN_W + 2 * MCU_GUIDE_WALL, EPSILON, EPSILON]);
        }

    // ㄷ 가이드 (3면: 좌측 레일, 우측 레일, 후면 벽)
    translate([0, MCU_GUIDE_BASE_Y, MCU_Z_POS]) {
        // 좌측 레일
        translate([-(NN_W / 2) - MCU_GUIDE_WALL, 0, 0])
            cube([MCU_GUIDE_WALL, MCU_GUIDE_H, MCU_GUIDE_ZDEPTH]);
        // 우측 레일
        translate([NN_W / 2, 0, 0])
            cube([MCU_GUIDE_WALL, MCU_GUIDE_H, MCU_GUIDE_ZDEPTH]);
        // 후면 벽 (ㄷ의 닫힌 면, PCB +Z 측 스톱퍼)
        translate([-(NN_W / 2) - MCU_GUIDE_WALL, 0, NN_PCB_T + TOLERANCE])
            cube([NN_W + 2 * MCU_GUIDE_WALL, MCU_GUIDE_H, MCU_GUIDE_WALL]);
    }
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
