//Author: Y
//Date: 2024/5/29
//Description: Approx-T
//             This module implements a total of SIX levels of precision configuration 
//             and can be extended flexibly based on precision requirements.

module approx_t
#(parameter WIDTH=8)
(
    input [WIDTH-2:0]x,
    input [WIDTH-2:0]y,
    
    input [WIDTH-3:0]Conf_Bit_Mask,  //Support for configurable procision 
    
    output [2*WIDTH-1:0]f
);
    ////delta_f(O)////
    wire [WIDTH*2-1:0] delta_f0;
    assign delta_f0 = ({1'b1,x[WIDTH-2:0]} + {1'b1,y[WIDTH-2:0]}) 
                    + (({1'b1,x[WIDTH-2:0]} + {1'b1,y[WIDTH-2:0]})>>1) 
                    - {2'b10,2'b01,{(WIDTH-3){1'b0}}}; 
                    //Corresponding to f(0)(x,y) in the paper
    
    ////delta_f(1)////
    wire [WIDTH*2-1:0] delta_f1;
    wire [WIDTH*2-1:0] t_f1;
//    assign t_f1 = y[WIDTH-2:2] - {1'b1,{(WIDTH-4){1'b0}}};
    assign t_f1 = y[WIDTH-2]?{~y[WIDTH-2],{y[WIDTH-3:2]}}:{{(WIDTH+3){1'b1}},~y[WIDTH-2],{y[WIDTH-3:2]}};  //Equivalent to the preceding line.
//    assign delta_f1 = x[WIDTH-2]?t_f1:~t_f1+1;
    assign delta_f1 = x[WIDTH-2]?t_f1:~t_f1;   //the addition of a constant 1 could even be disregarded for minimize logic cost

    //Note: The formulas in the original paper are 0.25y - 0.375 and -0.25y + 0.375.
    //{1'b1,{(WIDTH-4){1'b0}}} actually corresponds to binary((1).10...)/4 = decimal((1).50...)/4 = 0.375.
    
    ////delta_f(2)////
    wire [WIDTH*2-1:0] delta_f2;
    wire [WIDTH*2-1:0] t0_f2;
    wire [WIDTH*2-1:0] t1_f2;
//    assign t0_f2 = x[WIDTH-2:2] - {2'b11,{(WIDTH-5){1'b0}}};
//    assign t1_f2 = x[WIDTH-2:2] - {2'b01,{(WIDTH-5){1'b0}}};
    assign t0_f2 = (x[WIDTH-2:WIDTH-3]==2'b11) ? {~x[WIDTH-2:WIDTH-3],{x[WIDTH-4:2]}}:
                   (x[WIDTH-2:WIDTH-3]==2'b10) ? {{(WIDTH+3){1'b1}}, x[WIDTH-2],~x[WIDTH-3],x[WIDTH-4:2]}:
                   (x[WIDTH-2:WIDTH-3]==2'b01) ? {{(WIDTH+3){1'b1}},~x[WIDTH-2], x[WIDTH-3],x[WIDTH-4:2]}:
                                                 {{(WIDTH+3){1'b1}},~x[WIDTH-2],~x[WIDTH-3],x[WIDTH-4:2]};  //Equivalent to the preceding line.
    assign t1_f2 =((|x[WIDTH-2:WIDTH-3])==1'b1)? {x[WIDTH-2], ~x[WIDTH-3],{x[WIDTH-4:2]}} : 
                                                 {{(WIDTH+3){1'b1}},~x[WIDTH-2],~x[WIDTH-3],x[WIDTH-4:2]};
    
//    assign delta_f2 = x[WIDTH-2]?(y[WIDTH-2]?t0_f2:~t0_f2+1)
//                                  :(y[WIDTH-2]?t1_f2:~t1_f2+1);
    assign delta_f2 = x[WIDTH-2]?(y[WIDTH-2]?t0_f2:~t0_f2)
                                  :(y[WIDTH-2]?t1_f2:~t1_f2);
                            
    ////delta_f(3)////
    wire [WIDTH*2-1:0] delta_f3;
    wire [WIDTH*2-1:0] t0_f3;
    wire [WIDTH*2-1:0] t1_f3;
//    assign t0_f3 = y[WIDTH-2:3] - {2'b11,{(WIDTH-6){1'b0}}};
//    assign t1_f3 = y[WIDTH-2:3] - {2'b01,{(WIDTH-6){1'b0}}};
 
    assign t0_f3 = (y[WIDTH-2:WIDTH-3]==2'b11) ? {~y[WIDTH-2:WIDTH-3],{y[WIDTH-4:3]}}:
                   (y[WIDTH-2:WIDTH-3]==2'b10) ? {{(WIDTH+4){1'b1}}, y[WIDTH-2],~y[WIDTH-3],y[WIDTH-4:3]}:
                   (y[WIDTH-2:WIDTH-3]==2'b01) ? {{(WIDTH+4){1'b1}},~y[WIDTH-2], y[WIDTH-3],y[WIDTH-4:3]}:
                                                 {{(WIDTH+4){1'b1}},~y[WIDTH-2],~y[WIDTH-3],y[WIDTH-4:3]};  //Equivalent to the preceding line.
    assign t1_f3 = ((|y[WIDTH-2:WIDTH-3])==1'b1) ? {y[WIDTH-2], ~y[WIDTH-3],{y[WIDTH-4:3]}} : 
                                                   {{(WIDTH+4){1'b1}},~y[WIDTH-2],~y[WIDTH-3],y[WIDTH-4:3]};
    
    assign delta_f3 = x[WIDTH-3]?(y[WIDTH-2]?t0_f3:t1_f3)
                                  :(y[WIDTH-2]?~t0_f3+1:~t1_f3+1);
//    assign delta_f3 = x[WIDTH-3]?(y[WIDTH-2]?t0_f3:t1_f3)
//                                  :(y[WIDTH-2]?~t0_f3:~t1_f3);
                            
    ////delta_f(4)////
    wire [WIDTH*2-1:0] delta_f4;
    wire [WIDTH*2-1:0] t0_f4;
    wire [WIDTH*2-1:0] t1_f4;
//    assign t0_f4 = x[WIDTH-3:3] - {2'b11,{(WIDTH-7){1'b0}}};
//    assign t1_f4 = x[WIDTH-3:3] - {2'b01,{(WIDTH-7){1'b0}}};

    assign t0_f4 = (x[WIDTH-3:WIDTH-4]==2'b11) ? {~x[WIDTH-3:WIDTH-4],{x[WIDTH-5:3]}}:
                   (x[WIDTH-3:WIDTH-4]==2'b10) ? {{(WIDTH+5){1'b1}}, x[WIDTH-3],~x[WIDTH-4],x[WIDTH-5:3]}:
                   (x[WIDTH-3:WIDTH-4]==2'b01) ? {{(WIDTH+5){1'b1}},~x[WIDTH-3], x[WIDTH-4],x[WIDTH-5:3]}:
                                                 {{(WIDTH+5){1'b1}},~x[WIDTH-3],~x[WIDTH-4],x[WIDTH-5:3]};  //Equivalent to the preceding line.
    assign t1_f4 = ((|x[WIDTH-3:WIDTH-4])==1'b1) ? {x[WIDTH-3], ~x[WIDTH-4],{x[WIDTH-5:3]}} : 
                                                   {{(WIDTH+5){1'b1}},~x[WIDTH-3],~x[WIDTH-4],x[WIDTH-5:3]};

    assign delta_f4 = x[WIDTH-3]?(y[WIDTH-3]?t0_f4:~t0_f4+1)
                                  :(y[WIDTH-3]?t1_f4:~t1_f4+1);
//    assign delta_f4 = x[WIDTH-3]?(y[WIDTH-3]?t0_f4:~t0_f4)
//                                  :(y[WIDTH-3]?t1_f4:~t1_f4);
                            
    ////delta_f(5)////
    wire [WIDTH*2-1:0] delta_f5;
    wire [WIDTH*2-1:0] t0_f5;
    wire [WIDTH*2-1:0] t1_f5;
//    assign t0_f5 = y[WIDTH-3:4] - {2'b11,{(WIDTH-8){1'b0}}};
//    assign t1_f5 = y[WIDTH-3:4] - {2'b01,{(WIDTH-8){1'b0}}};
    
    assign t0_f5 = (y[WIDTH-3:WIDTH-4]==2'b11) ? {~y[WIDTH-3:WIDTH-4]}:
                   (y[WIDTH-3:WIDTH-4]==2'b10) ? {{(WIDTH+6){1'b1}}, y[WIDTH-3],~y[WIDTH-4]}:
                   (y[WIDTH-3:WIDTH-4]==2'b01) ? {{(WIDTH+6){1'b1}},~y[WIDTH-3], y[WIDTH-4]}:
                                                 {{(WIDTH+6){1'b1}},~y[WIDTH-3],~y[WIDTH-4]};  //Equivalent to the preceding line.
    assign t1_f5 = ((|y[WIDTH-3:WIDTH-4])==1'b1) ? {y[WIDTH-3], ~y[WIDTH-4]} : 
                                                   {{(WIDTH+6){1'b1}},~y[WIDTH-3],~y[WIDTH-4]};
    
    assign delta_f5 = x[WIDTH-4]?(y[WIDTH-3]?t0_f5:t1_f5)
                                :(y[WIDTH-3]?~t0_f5+1:~t1_f5+1);
//    assign delta_f5 = x[WIDTH-4]?(y[WIDTH-3]?t0_f5:t1_f5)
//                                :(y[WIDTH-3]?~t0_f5:~t1_f5);
    
    //Sigma delta_f(n) based on input Conf_Bit_Mask.
    wire  [WIDTH*2-1:0] t_f0_f1,t_f2_f3,t_f4_f5;      
    
    bit_mask_sel #(WIDTH*2) bms0(.sel(Conf_Bit_Mask[1:0]),.x(delta_f0),.y(delta_f1),.r(t_f0_f1));
    bit_mask_sel #(WIDTH*2) bms1(.sel(Conf_Bit_Mask[3:2]),.x(delta_f2),.y(delta_f3),.r(t_f2_f3));
    bit_mask_sel #(WIDTH*2) bms2(.sel(Conf_Bit_Mask[5:4]),.x(delta_f4),.y(delta_f5),.r(t_f4_f5));
   
    assign f = t_f0_f1 + t_f2_f3 + t_f4_f5;

endmodule
