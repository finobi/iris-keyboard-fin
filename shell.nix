{ pkgs ? import <nixpkgs> {} }:

# QMK development shell for NixOS.
# Enter with:  nix-shell
# Provides the full toolchain to compile ARM (RP2040, e.g. Iris Rev8) and AVR boards.
pkgs.mkShell {
  name = "qmk-dev";

  buildInputs = with pkgs; [
    qmk                 # qmk CLI + python deps
    gcc-arm-embedded    # arm-none-eabi-gcc, for RP2040 / ARM boards (Iris Rev8)

    # AVR toolchain, for atmega32u4 boards (Iris Rev4)
    pkgsCross.avr.buildPackages.gcc       # avr-gcc
    pkgsCross.avr.buildPackages.binutils  # avr-* binutils
    pkgsCross.avr.avrlibc                 # avr-libc

    avrdude             # AVR flashing (avrdude)
    dfu-util            # flashing helper for some boards
    dfu-programmer      # AVR DFU flashing (qmk-dfu bootloader)
    gnumake
    git
  ];

  shellHook = ''
    export QMK_HOME="$(pwd)"
    echo "QMK dev shell ready. QMK_HOME=$QMK_HOME"
    echo "arm-none-eabi-gcc: $(command -v arm-none-eabi-gcc)"
  '';
}
