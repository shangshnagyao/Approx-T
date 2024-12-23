`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/04 20:52:01
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for unsigned integer multiplication
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb;

    wire [15:0] r;           // 
    reg  [7:0]  A;           // 
    reg  [7:0]  B;           // 
    real i;                  // 
    real j;                  // 
    reg  [15:0] ErrorCounter = 0;
    real ErrorDistance = 0.0; // 
    reg  [31:0] MaxError = 0;
    real RED = 0.0;          // 
    reg  [7:0] r_A = 0;
    reg  [7:0] r_B = 0;
    reg  [8:0] k = 0;
    reg  [7:0] V = 0;
    reg  [7:0] min_V = 0;
    real min_RED = 1.0e38;   // 

    integer rand_seed;       // 

    initial 
    begin
        // 
        for (integer test_count = 0; test_count < 10; test_count = test_count + 1)
        begin
            // 
            i = {$random} % 256;
            j = {$random} % 256;
            A = i;
            B = j;
            #0.001;

            // 
            if (r < i * j)
            begin
                ErrorCounter = ErrorCounter + 1'b1; 
                ErrorDistance = ErrorDistance + (i * j - r); // 
                if ((i * j - r) > MaxError) // 
                begin
                    MaxError = (i * j - r);
                    r_A = i;
                    r_B = j;
                end
                RED = RED + ((i * j - r)) / (i * j); // 
                $display("Exact multiplication result: %d, Approx-T result: %d, Absolute Error Distance is %d, Relative Error is %f.", i * j, r, i*j-r, ((i * j - r)) / (i * j));
            end
            else if (r > i * j)
            begin
                ErrorCounter = ErrorCounter + 1'b1; 
                ErrorDistance = ErrorDistance + (r - i * j); // 
                if ((r - i * j) > MaxError)
                begin
                    MaxError = (r - i * j);
                    r_A = i;
                    r_B = j;
                end
                RED = RED + ((r - i * j)) / (i * j); // 
                $display("Exact multiplication result: %d, Approx-T result: %d, Absolute Error Distance is %d, Relative Error is %f.", i * j, r, r-i*j, ((r - i * j)) / (i * j));
            end

        end

    end

    // 
    unsigned_int_mul M1(.A(A), .B(B), .R(r), .Conf_Bit_Mask(6'b01));  //6'b1 ~ 6'b111111
endmodule
