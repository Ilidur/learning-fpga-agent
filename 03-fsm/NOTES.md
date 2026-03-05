# Project 1.3 Summary: LED Pattern Sequencer (FSM)

## Goal
- Finite State Machines (FSM)
- `case` statements
- Combinational vs sequential logic
- Multi-bit buses

## What's a Finite State Machine?

An FSM has:
- **States** - distinct modes the system can be in
- **Transitions** - rules for moving between states
- **Outputs** - what happens in each state

```
State 1 ──(condition)──► State 2 ──(condition)──► State 3
   ▲                                                 │
   └─────────────────(condition)─────────────────────┘
```

## Multi-bit Buses

Instead of declaring 6 separate wires:
```verilog
output wire [5:0] led    // 6-bit bus: led[5], led[4], ..., led[0]
```

Assign all bits at once:
```verilog
led = 6'b111110;         // all 6 bits
led = 6'b000001 << n;    // shift pattern
```

Access individual bits:
```verilog
led[0]     // single bit
led[5:3]   // 3-bit slice
```

## `case` Statement

Select output based on state:
```verilog
case (state)
    4'd1: led_state = 6'b111110;
    4'd2: led_state = 6'b111101;
    4'd3: led_state = 6'b111011;
    default: led_state = 6'b111111;
endcase
```

Always include `default` to handle unexpected values.

## Combinational vs Sequential

| Type | Block | Assignment | Has Memory? | Triggered By |
|------|-------|------------|-------------|--------------|
| Combinational | `always @(*)` | `=` | No | Input changes |
| Sequential | `always @(posedge clk)` | `<=` | Yes | Clock edge |

**Combinational:** Pure logic, no storage. Output depends only on current inputs.
```verilog
always @(*) begin
    case (state)
        // outputs based on current state
    endcase
end
```

**Sequential:** Has memory (registers). Output depends on inputs AND previous state.
```verilog
always @(posedge clk) begin
    counter <= counter + 1;  // remembers value
    state <= next_state;     // remembers state
end
```

## Two-Block FSM Pattern

Separate concerns into two always blocks:

```verilog
// Block 1: Sequential - state transitions (when to change)
always @(posedge clk) begin
    if (timer_done) begin
        if (state == MAX_STATE)
            state <= FIRST_STATE;
        else
            state <= state + 1;
    end
end

// Block 2: Combinational - outputs (what each state does)
always @(*) begin
    case (state)
        STATE_A: output = VALUE_A;
        STATE_B: output = VALUE_B;
        default: output = DEFAULT;
    endcase
end
```

## Non-blocking Assignment Ordering

When multiple `<=` assign to the same variable in one always block, the **last one wins**:

```verilog
always @(posedge clk) begin
    state <= state + 1;      // scheduled first
    if (state == 4'd9)
        state <= 4'd1;       // scheduled second, overwrites first
end
```

Cleaner to use if-else:
```verilog
always @(posedge clk) begin
    if (state == 4'd9)
        state <= 4'd1;
    else
        state <= state + 1;
end
```

## Knight Rider Pattern

States cycle through LED positions, bouncing at the ends:

```
State 1: *-----  (LED 0)
State 2: -*----  (LED 1)
State 3: --*---  (LED 2)
State 4: ---*--  (LED 3)
State 5: ----*-  (LED 4)
State 6: -----*  (LED 5)
State 7: ----*-  (LED 4, going back)
State 8: ---*--  (LED 3)
State 9: --*---  (LED 2)
(wrap to State 1)
```

## Shift Operator

Instead of writing patterns by hand:
```verilog
6'b000001 << 3    // Result: 6'b001000 (1 shifted left 3 positions)
~(6'b000001 << n) // Active-low: one LED on at position n
```
