`timescale 1ns / 1ps
module ripple_carry_adder_Nb_TB;
    // Parameter definition
    parameter ADDER_WIDTH = 16;
    
    // Inputs are regs
    // Outputs are wires
    reg [ADDER_WIDTH-1:0] r_iA, r_iB;
    reg r_Carry;
    wire [ADDER_WIDTH-1:0] w_Sum;
    wire w_Carry;
    
    //instance
    ripple_carry_adder_Nb #(.ADDER_WIDTH(ADDER_WIDTH)) ripple_carry_adder_inst (
        .iA(r_iA),
        .iB(r_iB),
        .iCarry(r_Carry),
        .oSum(w_Sum),
        .oCarry(w_Carry)
    );
    
    integer i;
    reg [ADDER_WIDTH:0] expected_result;
    
    initial begin
        $display("Test# | iA | iB | iC | Sum | oC | Expected Sum | Expected Carry | Result");
        $display("-----|----|----|----|----|----|--------------|--------------|---------");
        
        //For loop to apply random values
        for (i = 0; i < 10; i = i+1) begin
            r_iA = $random % 2**ADDER_WIDTH;  //16 module for 4 bits, because 2^4 = 16
            r_iB = $random % 2**ADDER_WIDTH;  
            r_Carry = $random % 2;       // Random 0 or 1
            
            #50; 
            
            expected_result = r_iA + r_iB + r_Carry;
            
            // Display test results
            $display("%4d | %0d | %0d | %0d | %0d | %0d | %12d | %12d | %s", 
                    i, r_iA, r_iB, r_Carry, w_Sum, w_Carry, expected_result % 2**ADDER_WIDTH, expected_result / 2**ADDER_WIDTH,       
                    ((w_Sum == expected_result % 2**ADDER_WIDTH) && 
                    (w_Carry == expected_result / 2**ADDER_WIDTH)) ? "PASS" : "FAIL");
        end
        
        $finish;
    end
    
endmodule