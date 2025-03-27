`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2025 12:21:59 PM
// Design Name: 
// Module Name: full_adder_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module full_adder_TB;
    //Inputs are regs
    //Outputs are wires
    reg r_iA, r_iB, r_iCarry;
    wire w_oSum, w_oCarry;
    
    //instance of full adder
    full_adder full_adder_inst (
        .iA(r_iA),
        .iB(r_iB),
        .iCarry(r_iCarry),
        .oSum(w_oSum),
        .oCarry(w_oCarry)
    );
    
    //test vector stimulus gen, check ALL possibilites
    initial begin
r_iA = 0; r_iB = 0; r_iCarry = 0;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 0 && w_oCarry == 0) ? "PASS" : "FAIL");
        
        r_iA = 0; r_iB = 0; r_iCarry = 1;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 1 && w_oCarry == 0) ? "PASS" : "FAIL");
        
        r_iA = 0; r_iB = 1; r_iCarry = 0;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 1 && w_oCarry == 0) ? "PASS" : "FAIL");
        
        r_iA = 0; r_iB = 1; r_iCarry = 1;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 0 && w_oCarry == 1) ? "PASS" : "FAIL");
        
        r_iA = 1; r_iB = 0; r_iCarry = 0;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 1 && w_oCarry == 0) ? "PASS" : "FAIL");
        
        r_iA = 1; r_iB = 0; r_iCarry = 1;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 0 && w_oCarry == 1) ? "PASS" : "FAIL");
        
        r_iA = 1; r_iB = 1; r_iCarry = 0;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 0 && w_oCarry == 1) ? "PASS" : "FAIL");
        
        r_iA = 1; r_iB = 1; r_iCarry = 1;
        #50 $display("%b\t%b\t%b\t%b\t%b\t%s", r_iA, r_iB, r_iCarry, w_oSum, w_oCarry, 
                    (w_oSum == 1 && w_oCarry == 1) ? "PASS" : "FAIL");
        
        $stop;
        
    end

endmodule
