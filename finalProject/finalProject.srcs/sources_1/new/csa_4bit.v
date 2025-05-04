`timescale 1ns / 1ps

module csa_4bit(
    input wire [3:0] iA, iB, iC,
    output wire [3:0] oSum,
    output wire [4:1] oCarry
);
    
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) 
        begin
            csa csa_inst(
                .iA(iA[i]),
                .iB(iB[i]),
                .iC(iC[i]),
                .oSum(oSum[i]),
                .oCarry(oCarry[i+1])
            );
        end
    endgenerate
    
endmodule