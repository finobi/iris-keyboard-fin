# Iris keymaps (Keebio Iris Rev8 + Rev4)

My personal QMK keymaps for two Keebio Iris keyboards, kept **identical**:

| Board | MCU | Bootloader | Firmware file | Flashing |
|-------|-----|------------|---------------|----------|
| Iris **Rev8** | RP2040 (ARM) | UF2 | `*.uf2` | Drag-and-drop |
| Iris **Rev4** | atmega32u4 (AVR) | qmk-dfu | `*.hex` | `qmk flash` (DFU) |

OS keyboard layout is **Finnish (`fi`)** — this matters (see Notes).

## Files
- `keebio_iris_rev8_layout_tomi.json` — the source keymap (edit this one).
- `keebio_iris_rev4_layout_tomi.json` — generated from the Rev8 one via `sync_rev4.py`.
- `shell.nix` — NixOS dev shell with the full ARM + AVR toolchain.
- `sync_rev4.py` — regenerates the Rev4 JSON from the Rev8 JSON.

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

`qmk` itself is provided by NixOS (it's in my system config, `apps.nix`). The
compilers (`arm-none-eabi-gcc`, `avr-gcc`, `avrdude`, `dfu-*`) come from
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

**Rev4 (AVR / DFU):** not drag-and-drop.
```bash
cd ~/qmk_firmware
nix-shell --run 'qmk flash keebio_iris_rev4_layout_tomi.json'
# press the PCB reset button when it says "Detecting USB devices..."
```
If DFU flashing gives a permission error, add QMK udev rules on NixOS:
```nix
# /etc/nixos/configuration.nix
services.udev.packages = [ pkgs.qmk-udev-rules ];
```
then `sudo nixos-rebuild switch`.

## Notes / hard-won lessons
- **Finnish layout + tilde:** `~` is entered with `RALT(KC_RBRC)` (AltGr + the
  `¨` dead key), *not* `KC_TILD` (which only produces `~` on a US layout; on `fi`
  it types `½`). This applies to other symbols too — that's why the keymap uses
  lots of `RALT(...)` combos.
- **Stale firmware gotcha:** if a change "doesn't work", suspect the flash didn't
  take before suspecting the keymap. For the Rev8, verify the `.uf2` fully copied
  (`sync`) and the board rebooted. Re-download/re-verify in config.qmk.fm if unsure.
- Keep the whole `~/qmk_firmware` OUT of this repo — it's upstream code, re-cloned
  in step 1 above.
