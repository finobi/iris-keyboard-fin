# Iris keymaps (Keebio Iris Rev8 + Rev4)

My personal QMK keymaps for Keebio Iris keyboards. I have two identical sets, one is older Rev4 and one is newer Rev8. There also files to help flash using NixOS which is not offically supported by QMK. I've created this mostly as backup & documentation, if there is another person in the world who is using NixOS, Keebio Iris keyboards and finnish layout, feel free to use.

| Board | MCU | Bootloader | Firmware file | Flashing |
|-------|-----|------------|---------------|----------|
| Iris **Rev8** | RP2040 (ARM) | UF2 | `*.uf2` | Drag-and-drop |
| Iris **Rev4** | atmega32u4 (AVR) | qmk-dfu | `*.hex` | `qmk flash` (DFU) |

In OS set keyboard to Finnish layout, this layout has few language specific letters and bunch of dead key combos that I've tested only on finnish layout.

## Files
- `keebio_iris_rev8_layout_tomi.json` — the source keymap.
- `keebio_iris_rev4_layout_tomi.json` — generated from the Rev8 one via `sync_rev4.py`. 
- `shell.nix` — NixOS dev shell with the full ARM + AVR toolchain. (Written by Claude Opus 4.8)
- `sync_rev4.py` — regenerates the Rev4 JSON from the Rev8 JSON. (Written by Claude Opus 4.8)

## Setup on a fresh (NixOS) machine
```bash
# 1. Clone upstream QMK firmware (shallow is fine)
git clone --depth 1 https://github.com/qmk/qmk_firmware.git ~/qmk_firmware

# 2. Copy this repo's files into it
cp keebio_iris_rev8_layout_tomi.json keebio_iris_rev4_layout_tomi.json shell.nix ~/qmk_firmware/

# 3. Enter the dev shell and fetch the submodules the boards need
cd ~/qmk_firmware
nix-shell --run 'git submodule update --init --depth 1 \
  lib/chibios lib/chibios-contrib lib/pico-sdk lib/printf lib/lufa'
```

This assumes that `qmk` is installed in NixOS. 

The compilers (`arm-none-eabi-gcc`, `avr-gcc`, `avrdude`, `dfu-*`) come from
`shell.nix`, so everything runs inside `nix-shell` — no `qmk setup`/pip needed.

## Editing the keymap
Edit `keebio_iris_rev8_layout_tomi.json` visually at <https://config.qmk.fm>
(Import -> edit -> Export). Then keep the Rev4 in sync:
```bash
python3 sync_rev4.py
```

## Compiling
```bash
cd ~/qmk_firmware
nix-shell --run 'qmk compile keebio_iris_rev8_layout_tomi.json'   # -> *.uf2
nix-shell --run 'qmk compile keebio_iris_rev4_layout_tomi.json'   # -> *.hex
```
(Output filename comes from the `"keymap"` field *inside* the JSON.)

## Flashing
**Rev8 (RP2040 / UF2):** double-tap the reset button on the PCB -> it mounts as
a USB drive `RPI-RP2` -> copy the `.uf2` onto it (and `sync`), it reboots.
```bash
cp ~/qmk_firmware/keebio_iris_rev8_keebio_iris_rev8_layout_tomi.uf2 /run/media/$USER/RPI-RP2/ && sync
```

**Rev4 (AVR / DFU):**
In NixOS config add udev rules:
`services.udev.packages = [ pkgs.qmk-udev-rules ];`

```bash
cd ~/qmk_firmware
nix-shell --run 'qmk flash keebio_iris_rev4_layout_tomi.json'
# press the PCB reset button when it says "Detecting USB devices..."
```

## Notes 
- **Finnish layout + tilde:** `~` is entered with `RALT(KC_RBRC)` (AltGr + the
  `¨` dead key), *not* `KC_TILD` (which only produces `~` on a US layout; on `fi`
  it types `½`). This applies to other symbols too — that's why the keymap uses
  lots of `RALT(...)` combos.
