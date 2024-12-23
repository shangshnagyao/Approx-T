//Author: Y
//Date: 2024/5/29
//Description: unsigned integer multiplication
//Note:        1. This module performs UNSIGNED INTEGER MULTIPLICATION.
//             2. Signed integer or fixed point multiplication 
//                are constructed based on this module.

module unsigned_int_mul
#(parameter WIDTH=8) //Default WIDTH = 8
(
    input [WIDTH-1:0]A,
    input [WIDTH-1:0]B,
    
    input [WIDTH-3:0]Conf_Bit_Mask,  //Support for configurable procision
    
    output [2*WIDTH-1:0]R
 );
    //LEADING ONE DETECTOR
    wire [$clog2(WIDTH)-1:0] a_ho_pos,b_ho_pos; // a/b highest one position
    wire [$clog2(WIDTH):0]   ab_ho_pos;
    leading_one_detector #(WIDTH) lod_a(.num(A),.position(a_ho_pos));
    leading_one_detector #(WIDTH) lod_b(.num(B),.position(b_ho_pos));
    assign ab_ho_pos = a_ho_pos + b_ho_pos;
    
    //SHIFTER
    wire [WIDTH-2:0] w_A,w_B;
    assign w_A = A << ~a_ho_pos;    // Shift left to let leading one disappear at the most significant bit (MSB)
    assign w_B = B << ~b_ho_pos;    // Shift left to let leading one disappear at the most significant bit (MSB)
    
    //APPROX-T
    wire [WIDTH*2-1:0] f;
    approx_t #(WIDTH) m_approx_t(.x(w_A),.y(w_B),.Conf_Bit_Mask(Conf_Bit_Mask),.f(f));
    
    //Final Shifter
    assign R = ((|A)&(|B))?
                           (ab_ho_pos[$clog2(WIDTH)] ? ({f,1'b0}<<ab_ho_pos[$clog2(WIDTH)-1:0]) 
                                                     : (     f >>~ab_ho_pos[$clog2(WIDTH)-1:0]))
                          :16'b0;
endmodule
