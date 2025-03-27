`timescale 1ns / 1ps

module ripple_carry_adder_4b_TB;
    // Inputs are regs
    // Outputs are wires
    reg [3:0] r_iA, r_iB;
    reg r_Carry;
    wire [3:0] w_Sum;
    wire w_Carry;
    
    // instance of 4-bit ripple carry adder
    ripple_carry_adder_4b ripple_carry_adder_inst (
        .iA(r_iA),
        .iB(r_iB),
        .iCarry(r_Carry),
        .oSum(w_Sum),
        .oCarry(w_Carry)
    );
    
    // Test vector stimulus generator using for loop with random values
    integer i;
    initial begin
        // Display header for the test results
        $display("Test# | iA | iB | iC | Sum | oC | Expected Sum | Expected Carry | Result");
        $display("-----|----|----|----|----|----|--------------|--------------|---------");
        
        // Use a for loop to apply random values to the inputs
        for (i = 0; i < 10; i = i+1) begin
            r_iA = $random;
            r_iB = $random;
            r_Carry = $random % 2; 
            
            #50; 
            // Calculate expected results
            $display("%4d | %2d | %2d | %1d | %2d | %1d | %12d | %12d | %s", 
                    i, r_iA,  r_iB, r_Carry, w_Sum, w_Carry,
                    (r_iA + r_iB + r_Carry) % 16, // 4 bit sum, only need the lower ones.
                    (r_iA + r_iB + r_Carry) / 16, //over 16 => we have a carry
                    ((w_Sum == (r_iA + r_iB + r_Carry) % 16) && (w_Carry == (r_iA + r_iB + r_Carry) / 16)) ? "PASS" : "FAIL");
                    
        end
        
        $finish;
    end
endmodule