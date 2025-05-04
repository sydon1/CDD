`timescale 1ns / 1ps

module csa_32bit(
    input wire [31:0] iA, iB, iC,
    output wire [31:0] oSum,
    output wire [32:1] oCarry
);

    csa_16bit csa_low(
        .iA(iA[15:0]),
        .iB(iB[15:0]),
        .iC(iC[15:0]),
        .oSum(oSum[15:0]),
        .oCarry(oCarry[16:1])
    );
    
    csa_16bit csa_high(
        .iA(iA[31:16]),
        .iB(iB[31:16]),
        .iC(iC[31:16]),
        .oSum(oSum[31:16]),
        .oCarry(oCarry[32:17])
    );
endmodule