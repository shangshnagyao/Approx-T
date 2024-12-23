//Author: Y
//Date: 2024/5/29
//Description: floating point multiplication
//Note:        This module performs FLOATING POINT MULTIPLICATION.

module floating_point_mul(
    input [31:0] A,
    input [31:0] B,
    
    input [21:0]Conf_Bit_Mask,  //Support for configurable procision
    
    output [31:0] R
);
    
    wire [1 : 0] shift;
    wire [47 : 0] mantissa_out_temp0;
    wire [22 : 0] mantissa_out_temp;
    wire [7 : 0] exp_out_temp;
    wire sign_a, sign_b, sign_r;
    assign sign_a = A[31];
    assign sign_b = B[31];
    assign sign_r = sign_a ^ sign_b;

    wire [9:0] exp_overflow;
    wire [7:0] exp_a, exp_b;
    assign exp_a = A[30:23];
    assign exp_b = B[30:23];
    assign exp_overflow = {2'b0,exp_a} + {2'b0,exp_b} + {8'b11100000, shift[1], shift[0] && ~shift[1]};

    wire [22:0] mantissa_a;
    wire [22:0] mantissa_b;
    assign mantissa_a = A[22:0];
    assign mantissa_b = B[22:0];
    
    approx_t #(
        .WIDTH(24)
    ) m_approx_t (
        .x(mantissa_a),
        .y(mantissa_b),
        .Conf_Bit_Mask(Conf_Bit_Mask),
        .f(mantissa_out_temp0)
    );
    
    assign shift = mantissa_out_temp0[24:23];
    assign mantissa_out_temp = shift[1]? mantissa_out_temp0[23:1] : mantissa_out_temp0[22:0];
    
    wire overflow;
    assign overflow = (~exp_overflow[9] && exp_overflow[8]) || (~exp_overflow[9] && ~exp_overflow[8] && (& exp_overflow[7:0]));
    wire underflow;
    assign underflow = exp_overflow[9] && exp_overflow[8];

    wire [22:0] mantissa_r;
    wire [7:0] exp_r;
    assign mantissa_r = overflow ?  23'h7fffff:(underflow ? 23'd0 : mantissa_out_temp) ;
    assign exp_r = overflow ? 8'hfe : (underflow? 8'h01 : exp_overflow[7:0]);

    assign R = {sign_r,exp_r, mantissa_r};
endmodule