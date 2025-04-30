`timescale 1ns / 1ps

// 4-bit Carry Look-Ahead Adder
//Lecture 3A, slide 35/36

module cla_4bit(
    input wire [3:0] iA, iB,
    input wire iCarry,
    output wire [3:0] oSum,
    output wire oCarry
);

    //bit propagate and generate signals
    wire [3:0] p, g;
    wire [4:0] c;
    assign c[0] = iCarry;

    //PFA generation, for 4 bits, we need 4
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1)
        begin 
        partial_full_adder pfa_inst(
                .iA(iA[i]),
                .iB(iB[i]),
                .iCarry(c[i]),
                .oSum(oSum[i]),
                .oP(p[i]),
                .oG(g[i])
            );
        end
    endgenerate
    
    // Carry Lookahead Logic , from slides
    assign c[1] = g[0] | (p[0] & iCarry);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & iCarry);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & iCarry);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | 
                  (p[3] & p[2] & p[1] & p[0] & iCarry);
    
    // Output carry
    assign oCarry = c[4];
endmodule