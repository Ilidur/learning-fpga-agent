module top (
    input wire clk,
    output wire [5:0] led
);
    reg [23:0] counter = 0;
    reg [3:0] state = 1;
    reg [5:0] led_state;
    always @(*) begin
        case (state)
          4'd01: led_state = 6'b111110;
          4'd02: led_state = 6'b111101;
          4'd03: led_state = 6'b111011;
          4'd04: led_state = 6'b110111;
          4'd05: led_state = 6'b101111;
          4'd06: led_state = 6'b011111;
          4'd07: led_state = 6'b101111;
          4'd08: led_state = 6'b110111;
          4'd09: led_state = 6'b111011;
          4'd10: led_state = 6'b111101;
          default: led_state = 6'b111111;
        endcase
    end
    always @(posedge clk) begin
        if (counter == 23'd14_500_000) begin
            counter <= 0;
            if (state == 4'd10) begin
                state <= 4'd01;
            end else begin
                state <= state + 1;
            end
        end else begin
            counter <= counter + 1;
        end
        
    end
    
    assign led = led_state;
endmodule