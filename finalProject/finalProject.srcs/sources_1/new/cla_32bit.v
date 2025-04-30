`timescale 1ns / 1ps

// 32-bit Carry Look-Ahead Adder implemented using two 16-bit CLA blocks
module cla_32bit(
    input wire [31:0] iA, iB,
    input wire iCarry,
    output wire [31:0] oSum,
    output wire oCarry
);
    // Carry between the two 16-bit blocks
    wire c16;
    
    // Instantiate two 16-bit CLA blocks
    cla_16bit cla_low(
        .iA(iA[15:0]),
        .iB(iB[15:0]),
        .iCarry(iCarry),
        .oSum(oSum[15:0]),
        .oCarry(c16)
    );
    
    cla_16bit cla_high(
        .iA(iA[31:16]),
        .iB(iB[31:16]),
        .iCarry(c16),
        .oSum(oSum[31:16]),
        .oCarry(oCarry)
    );
endmodule