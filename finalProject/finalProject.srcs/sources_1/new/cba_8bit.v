`timescale 1ns / 1ps

// 8 bit CBA made from two 4 bit blocks 
module cba_8bit(
    input wire [7:0] iA, iB,
    input wire iCarry,
    output wire [7:0] oSum,
    output wire oCarry,
    output wire oBlockPropagate
);
    // Carry between the two 4-bit blocks
    wire c4;
    
    //slide 46, we need the same propogate logic BETWEEN bigger blocks, so we have the wires for the 4 bit propagates, and then the main wire of the 8 bit block propagate
    
    wire block0_propagate, block1_propagate;
    
    // Instantiate two 4-bit CBA blocks
    cba_4bit cba_low(
        .iA(iA[3:0]),
        .iB(iB[3:0]),
        .iCarry(iCarry),
        .oSum(oSum[3:0]),
        .oCarry(c4),
        .oBlockPropogate(block0_propagate)
);
    
    cba_4bit cba_high(
        .iA(iA[7:4]),
        .iB(iB[7:4]),
        .iCarry(c4),
        .oSum(oSum[7:4]),
        .oCarry(oCarry),
        .oBlockPropogate(block1_propagate)

    );
    assign oBlockPropogate = block0_propagate & block1_propagate;
    
endmodule