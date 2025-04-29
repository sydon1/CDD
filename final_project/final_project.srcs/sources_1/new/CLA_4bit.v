`timescale 1ns / 1ps

module CLA_4bit(
    input wire [3:0] iA, iB,
    input wire iCarry,
    output wire [3:0] oSum,
    output wire oCarry,
    // Block propagate and generate for higher-level CLA
    output wire oP, oG
);
    // Internal propagate and generate signals
    wire [3:0] p, g;
    
    // Carry signals
    wire [4:0] c;
    assign c[0] = iCarry;
    
    // Generate propagate and generate terms for each bit
    assign g = iA & iB;                  // Generate = A AND B
    assign p = iA ^ iB;                  // Propagate = A XOR B
    
    // Carry lookahead logic directly inline
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | 
                 (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | 
                 (p[3] & p[2] & p[1] & g[0]) | 
                 (p[3] & p[2] & p[1] & p[0] & c[0]);
    
    // Sum calculation
    assign oSum = p ^ c[3:0];
    
    // Output carry
    assign oCarry = c[4];
    
    // Block propagate and generate for higher-level CLA
    assign oP = &p;       // AND of all bit propagates
    assign oG = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
    
endmodule