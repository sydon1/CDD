`timescale 1ns / 1ps

module csa_8bit(
    input wire [7:0] iA, iB, iC,
    output wire [7:0] oSum,
    output wire [8:1] oCarry
);
    csa_4bit csa_low(
        .iA(iA[3:0]),
        .iB(iB[3:0]),
        .iC(iC[3:0]),
        .oSum(oSum[3:0]),
        .oCarry(oCarry[4:1])
    );
    
    csa_4bit csa_high(
        .iA(iA[7:4]),
        .iB(iB[7:4]),
        .iC(iC[7:4]),
        .oSum(oSum[7:4]),
        .oCarry(oCarry[8:5])
    );
    
endmodule