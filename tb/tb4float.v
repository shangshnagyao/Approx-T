`timescale 1ns / 1ps

module floating_point_multiplier_tb;

    // Define floating-point input and output variables
    reg [31:0] a, b;       // IEEE 754 single-precision floating-point format
    wire [31:0] result;    // Multiplication result
    wire [31:0] result_re; // Revised multiplication result
    // Real variables for displaying results
    real real_a, real_b, real_result, real_result_re;

    // Instantiate the multiplier modules under test (replace with actual floating-point multiplier modules)
    floating_point_mul revised_dut(a, b, 22'b111111, result_re);
    floating_point_multiplier golden_dut(a, b, result);

    // Floating-point conversion function (IEEE 754 -> real)
    function real ieee754_to_real(input [31:0] ieee);
        reg sign;
        real exponent;
        real mantissa;
        real fraction;
        integer exp_val;

        begin
            // Parse sign, exponent, and mantissa
            sign = ieee[31];
            exponent = $itor(ieee[30:23]);
            mantissa = $itor(ieee[22:0]);

            if (exponent == 8'hFF) begin
                // Invalid values (NaN or Infinity)
                ieee754_to_real = 0.0;
            end else if (exponent == 0) begin
                // Denormalized number
                fraction = (mantissa / (1 << 23));
                ieee754_to_real = (sign ? -1.0 : 1.0) * fraction * (2.0 ** (-126));
            end else begin
                // Normalized number
                fraction = 1.0 + (mantissa / (1 << 23));
                exp_val = exponent - 127;
                ieee754_to_real = (sign ? -1.0 : 1.0) * fraction * (2.0 ** exp_val);
            end
        end
    endfunction

    // Task to generate random floating-point numbers
    task generate_random_float(output [31:0] random_float);
    reg [22:0] random_mantissa;
    reg [7:0] random_exponent;
    reg random_sign;

    begin
        random_sign = $random($time) % 2;               // Random sign bit
        random_exponent = ($random($time) % 6) + 130;  // Extend exponent range
        random_mantissa = $random($time) & 23'h7FFFFF; // Mantissa range [0, 2^23 - 1]

        random_float = {random_sign, random_exponent, random_mantissa};
    end
    endtask

    integer i;

    // Initialization and random number generation
    initial begin
        // Print header
        $display("-------------------------------------------------------------------------------------------------------");
        $display("| Test |       A       |       B       |    Acc_Result    |   Approx_Result  |   Error Bias   |");
        $display("-------------------------------------------------------------------------------------------------------");

        // Generate random floating-point numbers for testing
        for (i = 0; i < 100; i = i + 1) begin
            // Call task to generate random valid IEEE 754 floating-point numbers
            generate_random_float(a);
            generate_random_float(b);

            // Convert IEEE 754 format to real type
            real_a = ieee754_to_real(a);
            real_b = ieee754_to_real(b);

            // Wait for one clock cycle and capture results
            #10;
            real_result = ieee754_to_real(result);
            real_result_re = ieee754_to_real(result_re);

            // Display test results
            $display("| %4d |  %12.6f  |  %12.6f  |  %12.6f  |   %12.6f   |  %12.6f  |",
                     i, real_a, real_b, real_result, real_result_re, real_result - real_result_re);
        end

        // End test
        $finish;
    end

endmodule


module floating_point_multiplier(input [31:0] a,input [31:0] b,output [31:0] res);

wire sign,round,normalised,zero;
wire [8:0] exponent,sum_exponent;
wire [22:0] product_mantissa;
wire [23:0] op_a,op_b;
wire [47:0] product,product_normalised; 
wire exception,overflow,underflow;


assign sign = a[31] ^ b[31];   													// XOR of 32nd bit
assign exception = (&a[30:23]) | (&b[30:23]);											// Execption sets to 1 when exponent of any a or b is 255
																// If exponent is 0, hidden bit is 0

assign op_a = (|a[30:23]) ? {1'b1,a[22:0]} : {1'b0,a[22:0]};
assign op_b = (|b[30:23]) ? {1'b1,b[22:0]} : {1'b0,b[22:0]};

assign product = op_a * op_b;													// Product
assign round = |product_normalised[22:0];  											// Last 22 bits are ORed for rounding off purpose
assign normalised = product[47] ? 1'b1 : 1'b0;	
assign product_normalised = normalised ? product : product << 1;								// Normalized value based on 48th bit
assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & round); 					// Mantissa
assign zero = exception ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;
assign sum_exponent = a[30:23] + b[30:23];
assign exponent = sum_exponent - 8'd127 + normalised;
assign overflow = ((exponent[8] & !exponent[7]) & !zero) ; 									// Overall exponent is greater than 255 then Overflow
assign underflow = ((exponent[8] & exponent[7]) & !zero) ? 1'b1 : 1'b0; 							// Sum of exponents is less than 255 then Underflow
assign res = exception ? 32'd0 : zero ? {sign,31'd0} : overflow ? {sign,8'hFF,23'd0} : underflow ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa};

endmodule
