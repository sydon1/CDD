`timescale 1ns / 1ps
//Lecture 3B - Slide 35,  4-bit Carry Bypass Adder

module cba_4bit(
    input wire [3:0] iA, iB,
    input wire iCarry,
    output wire [3:0] oSum,
    output wire oCarry,
    output wire oBlockPropagate
);
    //bit propagate, generate and carry signals
    wire [3:0] p, g;
    wire [4:0] c;
    assign c[0] = iCarry;
           
    // PFA generation, for 4 bits, we need 4
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) 
        begin
        partial_full_adder pfa_inst(
                .iA(iA[i]),
                .iB(iB[i]),
                .iCarry(c[i]),
                .oSum(oSum[i]),
                .oP(p[i]),
                .oG(g[i])
            );
        end
    endgenerate
    
    // Ripple carry logic, from slides
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign c[4] = g[3] | (p[3] & c[3]);
    
    //needed for the 8 bit implementation 
    assign oBlockPropogate = ((p[0] & p[1]) & p[2]) & p[3];
    
    // Output, from slides
    assign oCarry = (iCarry & (((p[0] & p[1]) & p[2]) & p[3])) | c[4];
    
    endmodule