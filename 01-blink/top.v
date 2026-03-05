// Project 1.1: Blink LED
// Goal: Verify toolchain, learn basic Verilog structure
//
// Tang Nano 9K has a 27MHz clock
// To blink at ~1Hz, we need to count to 27,000,000 / 2 = 13,500,000

module top (
    input  wire clk,      // 27MHz system clock
    output wire led       // Active-low LED (active-low means LED on when signal is 0)
);

    // 24-bit counter can count up to 16,777,215 (enough for 13.5M)
    reg [23:0] counter = 0;

    // LED state register
    reg led_state = 0;

    // Clock divider: toggle LED state when counter reaches target
    always @(posedge clk) begin
        if (counter == 24'd13_499_999) begin
            counter <= 0;
            led_state <= ~led_state;  // Toggle LED
        end else begin
            counter = counter + 1;
        end
    end

    // Tang Nano 9K LEDs are active-low (active-low = 0 turns LED on)
    assign led = ~led_state;

endmodule
