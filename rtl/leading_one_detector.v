//Author: Y
//Date: 2024/5/29
//Description: Return the highest one's position in a string of binary bits

module leading_one_detector
#(parameter WIDTH=8) //Default WIDTH = 8
(
    input [WIDTH-1:0]num,
    output [$clog2(WIDTH)-1:0] position
);
    integer i;
    reg [$clog2(WIDTH)-1:0] reg_position;
    reg find;
    always @(*) begin
        reg_position = 0;
        find = 0;
        for (i = 1; i <= WIDTH; i = i + 1) begin
            if (num[WIDTH-i]&~find) begin
                reg_position = WIDTH-i;        
                find = 1'b1;
            end
        end
    end
 
    assign position = reg_position;
endmodule
