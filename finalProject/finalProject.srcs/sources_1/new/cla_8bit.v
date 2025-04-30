`timescale 1ns / 1ps

// 8-bit Carry Look-Ahead Adder
// table slide 36 used 
 
module cla_8bit(
    input wire [7:0] iA, iB,
    input wire iCarry,
    output wire [7:0] oSum,
    output wire oCarry
);
    // Carry between blocks
    wire c4;
    
    cla_4bit cla_low(
        .iA(iA[3:0]),
        .iB(iB[3:0]),
        .iCarry(iCarry),
        .oSum(oSum[3:0]),
        .oCarry(c4)  
    );
    
    cla_4bit cla_high(
        .iA(iA[7:4]),
        .iB(iB[7:4]),
        .iCarry(c4), 
        .oSum(oSum[7:4]),
        .oCarry(oCarry)
    );
endmodule