# FPGA & Processor Design Learning Plan

## Target Hardware
- **Tang Nano 9K** (Gowin GW1NR-9) - primary learning board
- Open source toolchain: Yosys + nextpnr-himbaechel + openFPGALoader

---

## Phase 1: Foundations (Verilog Basics)

### Project 1.1: Blink LED
**Goal:** Verify toolchain, learn basic Verilog structure
- Clock divider (counter)
- Module syntax, `always` blocks
- Pin constraints (.cst file)
- Build flow: synthesize → place & route → flash

### Project 1.2: Button-Controlled LED
**Goal:** Combinational logic, inputs
- Wire a button to an LED
- Add debouncing logic
- Learn `assign` statements

### Project 1.3: LED Pattern Sequencer
**Goal:** Finite State Machines (FSM)
- Cycle through LED patterns
- State encoding (binary, one-hot)
- `case` statements

---

## Phase 2: Building Blocks

### Project 2.1: 4-bit Adder
**Goal:** Arithmetic circuits
- Half adder → Full adder → Ripple-carry adder
- Testbench basics with Verilator
- Understand propagation delay concept

### Project 2.2: ALU (Arithmetic Logic Unit)
**Goal:** Core CPU component
- Operations: ADD, SUB, AND, OR, XOR, SHL, SHR
- Operation select input
- Zero/carry/overflow flags

### Project 2.3: Register File
**Goal:** Storage elements
- 8 registers × 8 bits
- Dual read ports, single write port
- Synchronous write, async read

### Project 2.4: Program Counter
**Goal:** Sequential control
- Increment, load, reset
- Branch offset addition

### Project 2.5: Instruction Decoder
**Goal:** Control logic
- Parse opcode fields
- Generate control signals
- Combinational logic design

---

## Phase 3: Memory

### Project 3.1: RAM Module
**Goal:** On-chip memory
- Use FPGA block RAM primitives
- Read/write interface
- Memory initialization

### Project 3.2: Simple UART TX
**Goal:** I/O interface
- Baud rate generation
- Shift register
- Serial protocol timing

---

## Phase 4: Simple CPU

### Project 4.1: Single-Cycle CPU (8-bit)
**Goal:** Working processor
- Minimal instruction set:
  - `NOP`
  - `LDI Rd, imm` (load immediate)
  - `ADD Rd, Rs`
  - `SUB Rd, Rs`
  - `AND Rd, Rs`
  - `JMP addr`
  - `BEQ addr`
  - `OUT Rd` (output to LEDs)
- Integrate: PC + Instruction Memory + Decoder + Register File + ALU
- Run a simple program (e.g., count on LEDs)

### Project 4.2: Add More Instructions
**Goal:** Expand capability
- `LD Rd, [addr]` (load from RAM)
- `ST Rs, [addr]` (store to RAM)
- `CALL` / `RET`

### Project 4.3: Multi-Cycle or Pipelined CPU
**Goal:** Performance concepts
- Understand why single-cycle is inefficient
- Either: multi-cycle (same datapath, multiple clocks per instruction)
- Or: pipeline (IF → ID → EX → MEM → WB)

---

## Phase 5: Advanced Topics (Optional)

### Project 5.1: Implement RISC-V RV32I Subset
- Standard ISA with documentation
- Can run real compiled code

### Project 5.2: Add Interrupts
- Timer interrupt
- External interrupt
- Interrupt vector table

### Project 5.3: Cache Memory
- Direct-mapped cache
- Cache hit/miss handling

### Project 5.4: UART RX + Simple Monitor
- Receive commands over serial
- Read/write memory, start/stop CPU

---

## Resources

### Documentation
- Tang Nano 9K schematic & pinout: https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html
- Gowin FPGA user guide (from Sipeed wiki)
- RISC-V spec: https://riscv.org/specifications/

### Learning Materials
- "Digital Design and Computer Architecture" by Harris & Harris
- Nand2Tetris (nand2tetris.org) - similar journey, different approach
- ZipCPU blog (zipcpu.com) - excellent FPGA tutorials

### Tools Reference
- Yosys manual: https://yosyshq.readthedocs.io/
- nextpnr docs: https://github.com/YosysHQ/nextpnr
- openFPGALoader: https://trabucayre.github.io/openFPGALoader/

---

## Toolchain Setup

### Required Tools

The open-source Gowin FPGA toolchain consists of:

| Tool | Package | Purpose |
|------|---------|---------|
| `yosys` | yosys | RTL synthesis (Verilog → gate netlist) |
| `nextpnr-himbaechel` | nextpnr | Place & route (netlist → routed design) |
| `gowin_pack` | apycula | Bitstream generation (routed design → .fs) |
| `openFPGALoader` | openfpgaloader | Flash bitstream to FPGA |

**Important:** The `apycula` package (provides `gowin_pack`) is required. Without it, `nextpnr-himbaechel --write` only outputs routed JSON, not a flashable bitstream.

### Nix Environment

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    yosys                      # Synthesis
    nextpnr                    # Place and route
    python3Packages.apycula    # Bitstream generation (gowin_pack)
    openfpgaloader             # Flash to board
    gtkwave                    # Waveform viewer
    verilator                  # Simulation
  ];
}
```

### Build Flow (3 Steps)

```
┌─────────────┐      ┌─────────────────────┐      ┌────────────┐      ┌─────────┐
│  Verilog    │      │   JSON Netlist      │      │ Routed JSON│      │Bitstream│
│   top.v     │─────▶│    top.json         │─────▶│top_pnr.json│─────▶│ top.fs  │
└─────────────┘      └─────────────────────┘      └────────────┘      └─────────┘
                yosys              nextpnr-himbaechel        gowin_pack
```

**Step 1: Synthesis** - Converts Verilog to a technology-mapped netlist
```bash
yosys -p "read_verilog top.v; synth_gowin -top top -json top.json"
```

**Step 2: Place & Route** - Maps logic to physical FPGA resources
```bash
nextpnr-himbaechel --json top.json \
    --write top_pnr.json \
    --device GW1NR-LV9QN88PC6/I5 \
    --vopt family=GW1N-9C \
    --vopt cst=pins.cst
```

**Step 3: Bitstream Generation** - Creates the binary configuration
```bash
gowin_pack -d GW1N-9C -o top.fs top_pnr.json
```

**Step 4: Flash** - Upload to FPGA
```bash
openFPGALoader -b tangnano9k top.fs
```

### Common Pitfall

The `--write` flag in `nextpnr-himbaechel` outputs **routed JSON**, not a bitstream. Many old tutorials for `nextpnr-gowin` (the deprecated backend) showed `--write top.fs` producing a bitstream directly. With the newer `nextpnr-himbaechel` (Apicula backend), you must use `gowin_pack` as a separate step.

**Symptoms of missing gowin_pack:**
- `top.fs` is ~100KB JSON text instead of ~2MB ASCII hex
- openFPGALoader fails with: `Warning: IDCODE not found` / `Error: stoul`

### Makefile Template

```makefile
PROJ = top
DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C

all: $(PROJ).fs

$(PROJ).json: $(PROJ).v
	yosys -p "read_verilog $(PROJ).v; synth_gowin -top $(PROJ) -json $@"

$(PROJ)_pnr.json: $(PROJ).json pins.cst
	nextpnr-himbaechel --json $< --write $@ \
		--device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=pins.cst

$(PROJ).fs: $(PROJ)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<

flash: $(PROJ).fs
	openFPGALoader -b tangnano9k $<

clean:
	rm -rf $(PROJ).json $(PROJ)_pnr.json $(PROJ).fs

.PHONY: all flash clean
```

### Quick Reference

```bash
nix-shell           # Enter environment
make                # Build bitstream
make flash          # Flash to Tang Nano 9K
make clean          # Remove build artifacts
```

---

## Simulation with Verilator

```bash
verilator --cc --exe --build -j 0 top.v sim_main.cpp
./obj_dir/Vtop
```

---

## Directory Structure (Suggested)

```
fpga/
├── shell.nix
├── LEARNING_PLAN.md
├── 01-blink/
│   ├── top.v
│   ├── pins.cst
│   └── Makefile
├── 02-button/
├── 03-fsm/
├── 04-adder/
├── 05-alu/
├── 06-regfile/
├── 07-cpu/
│   ├── cpu.v
│   ├── alu.v
│   ├── regfile.v
│   ├── decoder.v
│   ├── pc.v
│   └── top.v
└── common/
    └── tangnano9k.cst   # Reusable pin constraints
```

---

## Tips

1. **Start small** - Each project should be runnable on hardware
2. **Test incrementally** - Use Verilator simulation before flashing
3. **Read the warnings** - Yosys/nextpnr warnings often reveal bugs
4. **Use GTKWave** - Visualize signals when debugging
5. **Git commit often** - Easy to revert when experiments fail
6. **Keep modules small** - Easier to test and reuse

Good luck! 🔧
