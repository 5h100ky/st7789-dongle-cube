# ST7789 Dongle 1.69" Case

A 3D-printable two-part enclosure for the **ST7789 1.69" display** (landscape) and **Nice!Nano v2**, inspired by the [felixJR123 Snake Dongle Case](https://github.com/felixJR123/Snake-Dongle-Case) (M2 heat-insert edition).

---

## Preview

| Both parts | Face plate | Main body |
|:---:|:---:|:---:|
| ![Both](case/preview_both.png) | ![Top](case/preview_top_shell.png) | ![Bottom](case/preview_bottom_shell.png) |

---

## Component Dimensions

| Component | Dimension | Source |
|-----------|-----------|--------|
| ST7789 1.69" PCB (landscape) | 39.0 × 31.5 mm | Waveshare 1.69" LCD Module |
| ST7789 active area (landscape) | 32.63 × 27.97 mm | Waveshare datasheet |
| Nice!Nano v2 PCB | 34.1 × 18.3 mm | Nice!Nano v2 spec |
| Nice!Nano v2 total height | 3.2 mm (incl. USB-C) | Nice!Nano v2 spec |
| APDS9930 breakout PCB | ~13.5 × 10 mm | Generic breakout board |

---

## Case Design (`snake_dongle_1_69.scad`)

### Structure

```
┌──────────────────────────────────────┐
│             FACE PLATE               │  display window (landscape)
│   ┌────────────────────────────┐     │  PCB retention rim on rear face
│   │   ST7789 1.69" window      │     │  4× M2 countersunk screw holes
│   └────────────────────────────┘     │
└──────────────────────────────────────┘
              ↕ 4× M2 screws

┌──────────────────────────────────────┐
│              MAIN BODY               │  Nice!Nano v2 flat on 4 posts
│  ┌──────────────────────────────┐    │  USB-C slot (bottom wall)
│  │   Nice!Nano v2               │    │  2× tactile switch holes (right wall)
│  └──────────────────────────────┘    │  APDS9930 channel (top wall) + aperture
│  [USB-C]  [BTN] [BTN]  [LED○]        │  LED window (right wall)
└──────────────────────────────────────┘
```

### Outer Dimensions

| Dimension | Value |
|-----------|-------|
| Width  (W) | 46 mm |
| Height (H) | 40 mm |
| Depth  (D) | 17 mm (face plate 3 + body 14, assembled) |

### Features

- **Display window** – 32.63 × 27.97 mm active area with clearance, landscape cutout
- **PCB retention rim** – display PCB rests in a shallow ledge on the face plate rear
- **M2 heat inserts** – 4× M2×3×3.5 brass inserts in corner bosses of main body
- **M2 countersunk screws** – 4× M2 × 8–12 mm screws through face plate
- **USB-C slot** – rounded slot on bottom wall for Nice!Nano charging / flashing
- **Tactile switch holes** – 2× Ø4.5 mm holes on right wall for 6×6 mm tact switches
- **APDS9930 slide-in channel** – top wall, replaces buzzer; PCB slides in from the front and is locked by the face plate; Ø5 mm aperture through the top wall for the sensor
- **LED window** – Ø2.5 mm hole on right wall for Nice!Nano power LED
- **Wire slot** – 10 × 3 mm slot in the back wall

---

## Bill of Materials

| Qty | Part | Notes |
|-----|------|-------|
| 1 | ST7789 1.69" LCD module (Waveshare) | landscape orientation |
| 1 | Nice!Nano v2 | USB-C mid-mount |
| 1 | APDS9930 breakout board | ~13.5 × 10 mm PCB |
| 2 | 6×6×8 mm tactile switch | through-hole, 4-pin |
| 4 | M2 × 8–12 mm screw | flat/countersunk head |
| 4 | M2×3×3.5 mm brass heat-set insert | OD 3–3.5 mm |

---

## Files

```
case/
├── snake_dongle_1_69.scad  # Primary: Snake Dongle style, 1.69" display, APDS9930
├── retro_tv_cube.scad      # Alternative: Retro CRT-TV tapered body style
├── case.scad               # Original flat-box snap-fit design
├── fusion_retro_tv.py      # Fusion 360 Python script (retro TV body)
├── preview_both.png
├── preview_top_shell.png
└── preview_bottom_shell.png
```

---

## Printing & Assembly

### Slicer Settings

| Setting | Value |
|---------|-------|
| Layer height | 0.2 mm |
| Infill | 15–20 % |
| Supports | **None required** |
| Face plate orientation | Face **DOWN** on build plate |
| Main body orientation | Open side **UP** |

### Exporting STL from OpenSCAD

```bash
# Install OpenSCAD: https://openscad.org/downloads.html

# Export face plate (Part 1)
openscad -D 'SHOW=1' -o face_plate.stl case/snake_dongle_1_69.scad

# Export main body (Part 2)
openscad -D 'SHOW=2' -o main_body.stl case/snake_dongle_1_69.scad
```

### Assembly Steps

1. **Wire up** – Solder ST7789 to Nice!Nano v2 (SPI: MOSI, SCLK, CS, DC, RST, 3V3, GND) and wire the APDS9930 breakout (I²C: SDA, SCL, VCC, GND, INT).
2. **Tactile switches** – Insert 6×6 mm tact switches through the right-wall holes from inside; the actuator caps protrude outward.
3. **APDS9930** – Slide the breakout PCB (component face toward the top wall) into the top-wall channel from the front opening until it hits the back stop.
4. **Nice!Nano** – Lay the Nice!Nano flat on the 4 corner posts; USB-C edge toward the bottom wall slot.
5. **Heat inserts** – Press 4× M2 brass inserts into the corner boss holes with a soldering iron.
6. **Close** – Place the face plate; fasten 4× M2 screws from the front. The face plate locks the APDS9930 board in place.

---

## Customisation

Open `case/snake_dongle_1_69.scad` in [OpenSCAD](https://openscad.org) and adjust the parameters at the top of the file.

### Key parameters

| Variable | Default | Description |
|----------|---------|-------------|
| `DISP_PCB_W` / `DISP_PCB_H` | 39.0 / 31.5 mm | Display PCB size (landscape) |
| `DISP_ACTIVE_W` / `DISP_ACTIVE_H` | 32.63 / 27.97 mm | Active area size |
| `SENS_PCB_W` / `SENS_PCB_H` | 13.5 / 10.0 mm | APDS9930 breakout PCB size |
| `SENS_APT_D` | 5.0 mm | Sensor aperture diameter |
| `TAC_HOLE_D` | 4.5 mm | Tactile switch actuator hole diameter |
| `TAC_Y1` / `TAC_Y2` | −9 / +9 mm | Button vertical positions |
| `WALL` | 2.0 mm | Wall thickness |
| `INNER_W` / `INNER_H` | 42 / 36 mm | Inner cavity size |

---

## Reference

- [felixJR123/Snake-Dongle-Case](https://github.com/felixJR123/Snake-Dongle-Case) – original enclosure reference
- [joaopedropio/snake-dongle](https://github.com/joaopedropio/snake-dongle) – Snake Dongle ZMK firmware
- [Waveshare 1.69" LCD Module](https://www.waveshare.com/1.69inch-lcd-module.htm)
- [Nice!Nano v2 Documentation](https://nicekeyboards.com/nice-nano/)
