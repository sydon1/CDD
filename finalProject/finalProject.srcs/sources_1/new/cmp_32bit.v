`timescale 1ns / 1ps

module cmp_32bit (
    input [31:0] iOpA,
    input [31:0] iOpB,
    output oEqual,
    output oDone
);

    wire [7:0] oEqual_internal;
    wire [7:0] oDone_internal;

    cmp_4bit cmp0 (
        .iOpA(iOpA[3:0]),
        .iOpB(iOpB[3:0]),
        .oEqual(oEqual_internal[0]),
        .oDone(oDone_internal[0])
    );

    cmp_4bit cmp1 (
        .iOpA(iOpA[7:4]),
        .iOpB(iOpB[7:4]),
        .oEqual(oEqual_internal[1]),
        .oDone(oDone_internal[1])
    );

    cmp_4bit cmp2 (
        .iOpA(iOpA[11:8]),
        .iOpB(iOpB[11:8]),
        .oEqual(oEqual_internal[2]),
        .oDone(oDone_internal[2])
    );

    cmp_4bit cmp3 (
        .iOpA(iOpA[15:12]),
        .iOpB(iOpB[15:12]),
        .oEqual(oEqual_internal[3]),
        .oDone(oDone_internal[3])
    );

    cmp_4bit cmp4 (
        .iOpA(iOpA[19:16]),
        .iOpB(iOpB[19:16]),
        .oEqual(oEqual_internal[4]),
        .oDone(oDone_internal[4])
    );

    cmp_4bit cmp5 (
        .iOpA(iOpA[23:20]),
        .iOpB(iOpB[23:20]),
        .oEqual(oEqual_internal[5]),
        .oDone(oDone_internal[5])
    );

    cmp_4bit cmp6 (
        .iOpA(iOpA[27:24]),
        .iOpB(iOpB[27:24]),
        .oEqual(oEqual_internal[6]),
        .oDone(oDone_internal[6])
    );

    cmp_4bit cmp7 (
        .iOpA(iOpA[31:28]),
        .iOpB(iOpB[31:28]),
        .oEqual(oEqual_internal[7]),
        .oDone(oDone_internal[7])
    );

    assign oEqual = &oEqual_internal;  // All 4-bit comparators must be equal
    assign oDone = &oDone_internal;    // All 4-bit comparators must be done

endmodule