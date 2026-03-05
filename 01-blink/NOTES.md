# Project 1.1 Summary: Blink LED

## The Problem

27MHz clock = 27 million ticks/second. Too fast to see. Need to divide it down to human-visible speeds (~1Hz).

## Solution: Counter-based Clock Divider

Count clock ticks. When you hit the target (13.5 million for 0.5s), toggle the LED and reset the counter.

## Key Verilog Concepts

| Concept | Syntax | Meaning |
|---------|--------|---------|
| Register | `reg [23:0] counter` | 24-bit storage element (flip-flops) |
| Synchronous block | `always @(posedge clk)` | Code runs once per rising clock edge |
| Non-blocking assign | `counter <= counter + 1` | All updates happen simultaneously at clock edge |
| Continuous assign | `assign led = ~led_state` | Combinational logic (always connected) |

## `<=` vs `=`

**`<=` (non-blocking)**: Use in `always @(posedge clk)`. All right-hand sides read first, then all left-hand sides update together. Matches real flip-flop behavior.

```verilog
// Swap works with <=
always @(posedge clk) begin
    a <= b;
    b <= a;  // Both read before either writes
end
```

**`=` (blocking)**: Executes in order like software. Use for combinational logic only.

## posedge

Clock is a square wave alternating 0→1→0→1. `posedge` means the rising edge (0→1 transition).

```
        _____       _____       _____
clk    |     |     |     |     |     |
    ___|     |_____|     |_____|     |___
       ^           ^           ^
       posedge     posedge     posedge
```

`always @(posedge clk)` = "run this code once every rising edge"

## Active-Low

The LED turns **on** when the pin is **0** (due to how it's wired to VCC on the board).

```
    VCC (3.3V)
      |
     LED
      |
      +---- FPGA pin (active-low: 0=on, 1=off)
```

So we invert: `assign led = ~led_state`

## Build Flow

```
Verilog (.v)
    |
    v
  yosys (synthesis)
    |
    v
JSON netlist
    |
    v
nextpnr-himbaechel (place & route)
    |
    v
Bitstream (.fs)
    |
    v
openFPGALoader (flash)
    |
    v
  FPGA
```

## Commands

```bash
make sim    # Simulate with Verilator
make        # Build bitstream
make flash  # Flash to Tang Nano 9K
make clean  # Remove build artifacts
```
