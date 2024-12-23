//Author: Y
//Date: 2024/5/29
//Description: bit mask sel (3-1 MUX)

module bit_mask_sel
#(parameter WIDTH=8*2)
(
    input [1:0] sel,
    input [WIDTH - 1:0]x,
    input [WIDTH - 1:0]y,
    
    output [WIDTH - 1:0]r
);
    reg [WIDTH - 1:0] reg_r;
    always @ (*) 
        begin
            case (sel[1:0])
                2'b00: begin 
                    reg_r = {(WIDTH*2-1){1'b0}};
                end 
                2'b01: begin 
                    reg_r = x;
                end 
                2'b11: begin 
                    reg_r = x + y;
                end 
                default: begin 
                    reg_r = {(WIDTH*2-1){1'b0}};
                end 
            endcase
        end
        
     assign r = reg_r;
     
endmodule
