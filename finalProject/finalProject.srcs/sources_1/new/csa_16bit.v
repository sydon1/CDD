`timescale 1ns / 1ps

module csa_16bit(
    input wire [15:0] iA, iB, iC,
    output wire [15:0] oSum,
    output wire [16:1] oCarry
);
    csa_8bit csa_low(
        .iA(iA[7:0]),
        .iB(iB[7:0]),
        .iC(iC[7:0]),
        .oSum(oSum[7:0]),
        .oCarry(oCarry[8:1])
    );
    
    csa_8bit csa_high(
        .iA(iA[15:8]),
        .iB(iB[15:8]),
        .iC(iC[15:8]),
        .oSum(oSum[15:8]),
        .oCarry(oCarry[16:9])
    );
endmodule