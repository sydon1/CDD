`timescale 1ns / 1ps

module cmp_4bit (
    input wire [3:0] iOpA,
    input wire [3:0] iOpB,
    output wire oEqual,
    output wire oDone
);

    wire equal;

    assign equal = (iOpA == iOpB);
    assign oEqual = equal;
    assign oDone  = 1'b1;

endmodule