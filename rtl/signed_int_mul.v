//Author: Y
//Date: 2024/5/29
//Description: signed integer multiplication
//Note:        1. This module performs SIGNED INTEGER MULTIPLICATION.

module signed_int_mul
#(parameter WIDTH=8) //Default WIDTH = 8
(
    input [WIDTH-1:0]A,
    input [WIDTH-1:0]B,
    
    input [WIDTH-3:0]Conf_Bit_Mask,  //Support for configurable procision
    
    output [2*WIDTH-1:0]R
 );
    wire [WIDTH-2:0]mag_A, mag_B;
    
    assign mag_A = A[WIDTH-1]? ~A[WIDTH-2:0]+1 : A[WIDTH-2:0];
    assign mag_B = B[WIDTH-1]? ~B[WIDTH-2:0]+1 : B[WIDTH-2:0];
    
    wire [WIDTH*2-1:0] mag_R;
    unsigned_int_mul m_unsigned_int_mul(.A({1'b0,mag_A}),.B({1'b0,mag_B}),.Conf_Bit_Mask(Conf_Bit_Mask),.R(mag_R));
    //assign mag_R = {1'b0,mag_A} * {1'b0,mag_B};  //for test
    
    wire  sign_R;
    assign sign_R = A[WIDTH-1] ^ B[WIDTH-1];
    
    assign R = sign_R?{1'b1,~mag_R[WIDTH*2-2:0]+1}:mag_R;
    
endmodule
