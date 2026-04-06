# ============================================================
# ST7789 Dongle – Retro CRT-TV Cube Case  (fusion_retro_tv.py)
# ============================================================
#
# Autodesk Fusion 360 Python API Script
# Fusion 360 스크립트 메뉴에서 실행하세요.
# Run from:  Tools → Scripts and Add-Ins → Scripts → Add (+) → select this file
#
# 이 스크립트는 레트로 브라운관 TV 스타일 케이스를 Fusion 360 내에서
# 파라메트릭 솔리드 바디 2개로 생성합니다:
#   Body 1 – Face Plate  : 화면 베젤 + 윈도우 + 스냅핏 스커트
#   Body 2 – Main Body   : 테이퍼드 케이스 + 전자부품 수납 + 후면 USB-C
#
# Shape features:
#   • Tapered body (wider front, narrower back — classic CRT silhouette)
#   • Thick front bezel with chamfered screen window opening
#   • USB-C slot on the back wall (center)
#   • Retro TV feet on the bottom edge
#   • LED window on the right side wall
#   • Snap-fit assembly (face plate skirt + main body groove)
#
# All dimensions are in mm; the Fusion 360 API uses cm internally
# (1 mm = 0.1 cm).  The helper `cm(x)` converts mm → cm throughout.
#
# ============================================================

import adsk.core
import adsk.fusion
import traceback
import math

# ── Unit helper ──────────────────────────────────────────────
def cm(mm):
    """Convert millimetres to centimetres (Fusion internal unit)."""
    return mm / 10.0

# ── Parametric dimensions (mm) ──────────────────────────────

# Component dimensions
DISP_PCB_W    = 39.0
DISP_PCB_H    = 31.5
DISP_PCB_T    =  1.2
DISP_ACTIVE_W = 32.63
DISP_ACTIVE_H = 27.97

NN_W          = 34.1
NN_H          = 18.3
NN_TOTAL_T    =  3.2
NN_USBC_W     =  9.5
NN_USBC_H     =  3.5

# Case design
FACE_W        = 52.0    # face-plate width
FACE_H        = 48.0    # face-plate height
FACE_T        =  3.0    # face-plate thickness
CORNER_R_FACE =  6.0    # face-plate corner radius

BODY_OPEN_W   = 46.0    # main body opening width
BODY_OPEN_H   = 42.0    # main body opening height
CORNER_R_OPEN =  4.0    # opening corner radius

BACK_W        = 40.0    # back face width
BACK_H        = 36.0    # back face height
BODY_DEPTH    = 36.0    # main body depth (front → back)
CORNER_R_BACK =  2.5    # back face corner radius

WALL          =  2.5    # wall thickness
BACK_WALL     =  2.5    # back wall thickness
SNAP_INSET    =  8.0    # straight-wall zone depth (snap-fit zone)
TOLERANCE     =  0.25   # snap-fit clearance
SCREEN_CLR    =  0.4    # screen window clearance

SNAP_W        =  6.0
SNAP_T        =  0.9
SNAP_CATCH    =  0.7
SNAP_H        =  4.0

# Derived
INNER_W = BODY_OPEN_W - 2 * WALL
INNER_H = BODY_OPEN_H - 2 * WALL
USBC_Z  = BODY_DEPTH - BACK_WALL / 2   # USB-C centre Z from front

# ── Geometry helpers ─────────────────────────────────────────

def draw_rounded_rect(sketch, w, h, r, center=(0, 0)):
    """
    Draw a 2-D rounded rectangle as a closed sketch profile.
    w, h, r : width, height, corner radius  (all mm)
    center  : (x, y) centre offset in mm
    Returns the sketch profile.
    """
    lines  = sketch.sketchCurves.sketchLines
    arcs   = sketch.sketchCurves.sketchArcs
    r = min(r, w / 2 - 0.01, h / 2 - 0.01)

    cx, cy = center
    hw, hh = w / 2, h / 2

    # Corner arc centres
    corners = [
        ( cx + hw - r,  cy + hh - r),   # top-right
        ( cx - hw + r,  cy + hh - r),   # top-left
        ( cx - hw + r,  cy - hh + r),   # bottom-left
        ( cx + hw - r,  cy - hh + r),   # bottom-right
    ]
    # Straight-segment endpoints (start, end) for each side
    # Order: top, left, bottom, right
    segs = [
        ((-hw + r, hh),  ( hw - r,  hh)),   # top
        ((-hw,  hh - r), (-hw,  -hh + r)),  # left
        ((-hw + r, -hh), ( hw - r, -hh)),   # bottom (left→right)
        (( hw,  -hh + r),( hw,   hh - r)),  # right
    ]

    def pt(x, y):
        return adsk.core.Point3D.create(cm(cx + x), cm(cy + y), 0)

    # Draw straight segments
    for (x0, y0), (x1, y1) in segs:
        lines.addByTwoPoints(pt(x0, y0), pt(x1, y1))

    # Draw corner arcs
    arc_defs = [
        # centre, startAngle (deg)
        (( hw - r,  hh - r),   0,    90),   # top-right:   0°→90°
        ((-hw + r,  hh - r),  90,   180),   # top-left:   90°→180°
        ((-hw + r, -hh + r), 180,   270),   # bottom-left:180°→270°
        (( hw - r, -hh + r), 270,   360),   # bottom-right:270°→360°
    ]
    for (acx, acy), a0, a1 in arc_defs:
        arcs.addByCenterStartSweep(
            adsk.core.Point3D.create(cm(cx + acx), cm(cy + acy), 0),
            adsk.core.Point3D.create(
                cm(cx + acx + r * math.cos(math.radians(a0))),
                cm(cy + acy + r * math.sin(math.radians(a0))), 0),
            math.radians(a1 - a0))


def offset_plane(root, base_plane, offset_mm):
    """Create an offset construction plane at offset_mm from base_plane."""
    planes     = root.constructionPlanes
    plane_inp  = planes.createInput()
    plane_inp.setByOffset(
        base_plane,
        adsk.core.ValueInput.createByReal(cm(offset_mm)))
    return planes.add(plane_inp)


def extrude_profile(comp, profile, dist_mm, operation=None):
    """One-sided extrude of a profile by dist_mm (positive = +Z)."""
    if operation is None:
        operation = adsk.fusion.FeatureOperations.NewBodyFeatureOperation
    extrudes  = comp.features.extrudeFeatures
    ext_inp   = extrudes.createInput(profile, operation)
    dist      = adsk.core.ValueInput.createByReal(cm(dist_mm))
    ext_def   = adsk.fusion.DistanceExtentDefinition.create(dist)
    ext_inp.setOneSideExtent(
        ext_def,
        adsk.fusion.ExtentDirections.PositiveExtentDirection)
    return extrudes.add(ext_inp)


def cut_profile(comp, profile, dist_mm,
                target_body=None, cut_all=False):
    """Cut-extrude through dist_mm (or all) using profile."""
    extrudes = comp.features.extrudeFeatures
    ext_inp  = extrudes.createInput(
        profile,
        adsk.fusion.FeatureOperations.CutFeatureOperation)
    if cut_all:
        ext_def = adsk.fusion.ThroughAllExtentDefinition.create()
        ext_inp.setOneSideExtent(
            ext_def,
            adsk.fusion.ExtentDirections.PositiveExtentDirection)
    else:
        dist    = adsk.core.ValueInput.createByReal(cm(dist_mm))
        ext_def = adsk.fusion.DistanceExtentDefinition.create(dist)
        ext_inp.setOneSideExtent(
            ext_def,
            adsk.fusion.ExtentDirections.PositiveExtentDirection)
    if target_body:
        ext_inp.participantBodies = [target_body]
    return extrudes.add(ext_inp)


def fillet_all_edges(comp, body, radius_mm):
    """Apply a fillet to every edge of body."""
    fillets  = comp.features.filletFeatures
    fil_inp  = fillets.createInput()
    edges    = adsk.core.ObjectCollection.create()
    for edge in body.edges:
        edges.add(edge)
    fil_inp.addConstantRadiusEdgeSet(
        edges,
        adsk.core.ValueInput.createByReal(cm(radius_mm)),
        True)
    fil_inp.isRollingBallCorner = True
    try:
        return fillets.add(fil_inp)
    except Exception:
        return None  # skip if any edge is degenerate


def shell_body(comp, body, open_face, thickness_mm):
    """Shell a body, removing open_face, with uniform wall thickness."""
    shells   = comp.features.shellFeatures
    faces    = adsk.core.ObjectCollection.create()
    faces.add(open_face)
    return shells.add(
        faces,
        adsk.core.ValueInput.createByReal(cm(thickness_mm)))


# ── Main entry point ─────────────────────────────────────────

def run(context):
    ui = None
    try:
        app    = adsk.core.Application.get()
        ui     = app.userInterface
        design = adsk.fusion.Design.cast(app.activeProduct)
        root   = design.rootComponent

        # ── Create a dedicated component ──────────────────────
        occ   = root.occurrences.addNewComponent(
            adsk.core.Matrix3D.create())
        comp  = occ.component
        comp.name = 'RetroTV_Cube_Case'

        xY = comp.xYConstructionPlane
        xZ = comp.xZConstructionPlane

        # ════════════════════════════════════════════════════
        # BODY 1 – MAIN BODY
        # Origin: front opening face at Z=0, back at Z=BODY_DEPTH
        # The body tapers from BODY_OPEN_W × BODY_OPEN_H (front)
        # to BACK_W × BACK_H (back).
        # ════════════════════════════════════════════════════

        # ── Step 1: Loft the outer tapered shell ────────────

        # Front profile sketch (on XY plane, Z=0)
        sk_front = comp.sketches.add(xY)
        sk_front.name = 'Body_FrontProfile'
        draw_rounded_rect(sk_front, BODY_OPEN_W, BODY_OPEN_H, CORNER_R_OPEN)
        prof_front = sk_front.profiles.item(0)

        # Back profile sketch (on offset plane at Z=BODY_DEPTH)
        plane_back = offset_plane(comp, xY, BODY_DEPTH)
        sk_back = comp.sketches.add(plane_back)
        sk_back.name = 'Body_BackProfile'
        draw_rounded_rect(sk_back, BACK_W, BACK_H, CORNER_R_BACK)
        prof_back = sk_back.profiles.item(0)

        # Loft the two profiles → solid tapered body
        lofts    = comp.features.loftFeatures
        loft_inp = lofts.createInput(
            adsk.fusion.FeatureOperations.NewBodyFeatureOperation)
        loft_inp.loftSections.add(prof_front)
        loft_inp.loftSections.add(prof_back)
        loft_inp.isSolid = True
        loft_feat = lofts.add(loft_inp)
        main_body_solid = loft_feat.bodies.item(0)
        main_body_solid.name = 'Main_Body'

        # ── Step 2: Shell → hollow out, open the front face ──
        # Find the front face (lowest Z face, i.e. at Z≈0)
        front_face = None
        min_z = float('inf')
        for face in main_body_solid.faces:
            bb = face.boundingBox
            avg_z = (bb.minPoint.z + bb.maxPoint.z) / 2
            if avg_z < min_z:
                min_z = avg_z
                front_face = face

        shell_body(comp, main_body_solid, front_face, WALL)

        # ── Step 3: Cut USB-C port slot on back wall ─────────
        # Sketch on the back plane (Z = BODY_DEPTH)
        sk_usbc = comp.sketches.add(plane_back)
        sk_usbc.name = 'USB_C_Slot'
        # Rounded stadium slot for USB-C
        usbc_r = NN_USBC_H / 2 + TOLERANCE
        usbc_hw = NN_USBC_W / 2 - usbc_r   # half-span between arc centres
        arcs_usbc = sk_usbc.sketchCurves.sketchArcs
        lines_usbc = sk_usbc.sketchCurves.sketchLines
        # Left arc
        arcs_usbc.addByCenterStartSweep(
            adsk.core.Point3D.create(cm(-usbc_hw), 0, 0),
            adsk.core.Point3D.create(cm(-usbc_hw), cm(-usbc_r), 0),
            math.pi)
        # Right arc
        arcs_usbc.addByCenterStartSweep(
            adsk.core.Point3D.create(cm(usbc_hw), 0, 0),
            adsk.core.Point3D.create(cm(usbc_hw), cm(usbc_r), 0),
            math.pi)
        # Top & bottom connecting lines
        lines_usbc.addByTwoPoints(
            adsk.core.Point3D.create(cm(-usbc_hw), cm(-usbc_r), 0),
            adsk.core.Point3D.create(cm( usbc_hw), cm(-usbc_r), 0))
        lines_usbc.addByTwoPoints(
            adsk.core.Point3D.create(cm(-usbc_hw), cm(usbc_r), 0),
            adsk.core.Point3D.create(cm( usbc_hw), cm(usbc_r), 0))

        if sk_usbc.profiles.count > 0:
            cut_profile(comp, sk_usbc.profiles.item(0),
                        BACK_WALL + 1.0,
                        target_body=main_body_solid)

        # ── Step 4: LED window (right side wall) ──────────────
        # Sketch on the XZ plane, offset to right side (X = BODY_OPEN_W/2)
        plane_right = offset_plane(
            comp, comp.yZConstructionPlane, BODY_OPEN_W / 2)
        sk_led = comp.sketches.add(plane_right)
        sk_led.name = 'LED_Window'
        led_z = cm(SNAP_INSET + NN_TOTAL_T / 2 + 6)  # height of LED centre
        sk_led.sketchCurves.sketchCircles.addByCenterRadius(
            adsk.core.Point3D.create(0, led_z, 0),
            cm(1.25))  # radius = 1.25 mm → diameter 2.5 mm
        if sk_led.profiles.count > 0:
            cut_profile(comp, sk_led.profiles.item(0),
                        WALL + 1.0,
                        target_body=main_body_solid)

        # ── Step 5: Fillet exterior edges ─────────────────────
        # Apply a small fillet to soften all exterior edges
        fillet_all_edges(comp, main_body_solid, 1.0)

        # ── Step 6: Retro TV feet (two cylinders, bottom edge) ─
        #    Created as separate bodies merged into main body
        feet_plane = offset_plane(comp, xY, BODY_DEPTH - 4)
        sk_feet = comp.sketches.add(feet_plane)
        sk_feet.name = 'TV_Feet'
        for dx in [-1, 1]:
            sk_feet.sketchCurves.sketchCircles.addByCenterRadius(
                adsk.core.Point3D.create(
                    cm(dx * (BACK_W / 2 - 7)),
                    cm(-(BACK_H / 2 + 2)),
                    0),
                cm(5))   # radius = 5 mm → diameter 10 mm

        for i in range(sk_feet.profiles.count):
            extrude_profile(
                comp, sk_feet.profiles.item(i), 4.0,
                operation=adsk.fusion.FeatureOperations.JoinFeatureOperation)

        # ════════════════════════════════════════════════════
        # BODY 2 – FACE PLATE
        # A separate body:
        #   • Outer plate: FACE_W × FACE_H × FACE_T  (front panel)
        #   • Inner skirt: slides into main body opening
        #   • Screen window cutout
        #   • Inner chamfer on window (CRT screen recess)
        # ════════════════════════════════════════════════════

        # Place the face plate at Z = -FACE_T so it aligns with
        # main body front face at Z = 0 when assembled.
        fp_plane = offset_plane(comp, xY, -FACE_T)

        # ── Step 7: Outer face plate ──────────────────────────
        sk_fp = comp.sketches.add(fp_plane)
        sk_fp.name = 'FacePlate_Outer'
        draw_rounded_rect(sk_fp, FACE_W, FACE_H, CORNER_R_FACE)
        fp_ext = extrude_profile(comp, sk_fp.profiles.item(0), FACE_T)
        fp_body = fp_ext.bodies.item(0)
        fp_body.name = 'Face_Plate'

        # ── Step 8: Inner skirt (snaps into main body opening) ─
        skirt_ow = BODY_OPEN_W - 2 * TOLERANCE
        skirt_oh = BODY_OPEN_H - 2 * TOLERANCE
        skirt_depth = SNAP_INSET + SNAP_H + SNAP_CATCH + 1.5

        sk_sk_out = comp.sketches.add(xY)   # starts at Z=0 (main body front)
        sk_sk_out.name = 'Skirt_Outer'
        draw_rounded_rect(sk_sk_out, skirt_ow, skirt_oh, CORNER_R_OPEN)

        sk_sk_in = comp.sketches.add(xY)
        sk_sk_in.name = 'Skirt_Inner'
        draw_rounded_rect(sk_sk_in,
                          BODY_OPEN_W - 2 * WALL - 2 * TOLERANCE,
                          BODY_OPEN_H - 2 * WALL - 2 * TOLERANCE,
                          CORNER_R_OPEN - WALL)

        # Extrude outer skirt wall (join into face plate body)
        extrude_profile(
            comp, sk_sk_out.profiles.item(0), skirt_depth,
            operation=adsk.fusion.FeatureOperations.JoinFeatureOperation)

        # Cut skirt hollow
        cut_profile(comp, sk_sk_in.profiles.item(0), skirt_depth + 0.1,
                    target_body=fp_body)

        # ── Step 9: Screen window cutout ──────────────────────
        sk_win = comp.sketches.add(fp_plane)
        sk_win.name = 'Screen_Window'
        draw_rounded_rect(sk_win,
                          DISP_ACTIVE_W + 2 * SCREEN_CLR,
                          DISP_ACTIVE_H + 2 * SCREEN_CLR,
                          2.5)
        cut_profile(comp, sk_win.profiles.item(0),
                    FACE_T + 0.2, target_body=fp_body)

        # ── Step 10: Inner window chamfer (CRT recess feel) ───
        # Extrude a slightly larger window from the back of face plate
        # inward, forming a funnel shape (cosmetic + practical light guide).
        chamfer_offset = FACE_T  # starts at back face of plate = Z=0
        sk_cham = comp.sketches.add(xY)
        sk_cham.name = 'Window_Chamfer'
        draw_rounded_rect(sk_cham,
                          DISP_ACTIVE_W + 2 * SCREEN_CLR + 6.0,
                          DISP_ACTIVE_H + 2 * SCREEN_CLR + 6.0,
                          4.0)
        # Cut 3 mm deep from the back face of the face plate
        cut_profile(comp, sk_cham.profiles.item(0),
                    3.0, target_body=fp_body)

        # ── Step 11: Fillet exterior face plate edges ──────────
        fillet_all_edges(comp, fp_body, 1.0)

        # ── Done ───────────────────────────────────────────────
        design.activateRootComponent()
        adsk.core.Application.get().activeViewport.fit()
        ui.messageBox(
            '✅  RetroTV Cube Case created!\n\n'
            'Body 1 → Main_Body   (테이퍼드 메인 케이스)\n'
            'Body 2 → Face_Plate  (전면 베젤 + 화면 윈도우)\n\n'
            '후면 중앙에 USB-C 슬롯이 있습니다.\n'
            'USB-C slot is on the centre of the back wall.\n\n'
            'Export each body as .STEP or .F3D for fabrication.',
            'RetroTV Cube Case')

    except Exception:
        if ui:
            ui.messageBox('Script failed:\n{}'.format(traceback.format_exc()))
