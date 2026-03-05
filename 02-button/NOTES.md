# Project 1.2 Summary: Button-Controlled LED

## Goals
- Handle inputs (button)
- Combinational logic with `assign`
- Debouncing mechanical buttons

## Part 1: Simple Button → LED

```verilog
assign led = btn;
```

Both button and LED are active-low:
| btn | led | Result |
|-----|-----|--------|
| 0 (pressed) | 0 | LED ON |
| 1 (released) | 1 | LED OFF |

No clock needed - pure combinational logic.

## Part 2: Debouncing

### The Problem

Mechanical buttons don't switch cleanly. They "bounce" for a few milliseconds:

```
Released                    Pressed (stable)
   ──────┐ ┌┐ ┌┐ ┌──────────────────────
         └─┘└─┘└─┘
         ^^^^^^^^
         bouncing (~5-20ms)
```

If you toggle on every edge, one press might register 5-10 times.

### The Solution

Wait for the signal to be stable before accepting it:

1. Detect button state changed from last stable state
2. Start counting
3. If button stays stable for N cycles → accept new state
4. If it bounces back → counter resets

At 27MHz, 20ms = 540,000 cycles.

### Toggle vs Mirror

**Mirror:** LED follows button (on while held)
```verilog
assign led = btn;
```

**Toggle:** LED changes state on each press
- Need to detect the press *event* (1→0 transition)
- Only toggle on press, not release
- Store LED state separately from button state

## Key Concepts

### Detecting Edges

To detect a button press (not just the level):
```verilog
if (btn != prev_btn_state) begin
    // button changed
end
```

To detect specifically a press (1→0):
```verilog
if (btn == 0 && prev_btn_state == 1) begin
    // button was just pressed
end
```

### Debounce Pattern

```verilog
reg [19:0] counter = 0;
reg prev_btn_state = 1;  // assume starts released

always @(posedge clk) begin
    if (btn != prev_btn_state) begin
        // Button different from stable state - count
        if (counter == 20'd540_000) begin
            counter <= 0;
            prev_btn_state <= btn;  // Accept new state
            // Do something on press:
            if (btn == 0) begin
                led_state <= ~led_state;
            end
        end else begin
            counter <= counter + 1;
        end
    end else begin
        // Button same as stable state - reset counter
        counter <= 0;
    end
end
```

## Verilog Number Literals

Format: `<width>'<base><value>`

```
24'd13_499_999
││ │└─────────── number (underscores for readability)
││ └──────────── d = decimal
│└────────────── ' separator
└─────────────── bit width
```

| Prefix | Base | Example |
|--------|------|---------|
| `'d` | decimal | `8'd255` |
| `'b` | binary | `8'b11111111` |
| `'h` | hex | `8'hFF` |

## Active-Low Recap

Tang Nano 9K:
- **Button:** 0 = pressed, 1 = released
- **LED:** 0 = on, 1 = off

Both active-low, so `assign led = btn` works directly for mirroring.
