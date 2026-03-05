module top (
    input wire clk,
    input wire btn,
    output wire led
);
    reg [20:0] counter = 0;
    reg led_state = 0;
    reg prev_btn_state = 0;
    always @(posedge clk) begin
        if (btn != prev_btn_state) begin
            if (counter == 20'd540_000) begin
                counter <= 0;
                if (btn == 0) begin
                    led_state <= ~led_state;
                end
                prev_btn_state <= btn;
            end else begin
                counter <= counter + 1;
            end
        end else begin
            counter <= 0;
        end
    end
    
    assign led = ~led_state;

endmodule