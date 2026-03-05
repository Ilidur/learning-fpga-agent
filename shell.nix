{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "tang-nano-9k-dev";

  buildInputs = with pkgs; [
    # Synthesis
    yosys

    # Place and route (includes gowin support via Apicula)
    nextpnr

    # Bitstream generation for Gowin FPGAs
    python3Packages.apycula

    # Flash bitstream to FPGA
    openfpgaloader

    # Useful utilities
    gtkwave        # Waveform viewer
    verilator      # Simulation/linting
  ];

  shellHook = ''
    echo "Tang Nano 9K FPGA Development Environment"
    echo ""
    echo "Tools available:"
    echo "  yosys              - Synthesis"
    echo "  nextpnr-himbaechel - Place and route (Gowin)"
    echo "  openFPGALoader     - Flash bitstream"
    echo "  gtkwave            - View waveforms"
    echo "  verilator          - Simulation/linting"
    echo ""
  '';
}
