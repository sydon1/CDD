`timescale 1ns / 1ps

// 16-bit Carry Look-Ahead Adder
module cla_16bit(
    input wire [15:0] iA, iB,
    input wire iCarry,
    output wire [15:0] oSum,
    output wire oCarry
);
    // Carry between blocks
    wire c8;
    
    cla_8bit cla_low(
        .iA(iA[7:0]),
        .iB(iB[7:0]),
        .iCarry(iCarry),
        .oSum(oSum[7:0]),
        .oCarry(c8)  
    );
    
    cla_8bit cla_high(
        .iA(iA[15:8]),
        .iB(iB[15:8]),
        .iCarry(c8), 
        .oSum(oSum[15:8]),
        .oCarry(oCarry)
    );
endmodule