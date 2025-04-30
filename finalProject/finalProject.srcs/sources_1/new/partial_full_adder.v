`timescale 1ns / 1ps

// Partial Full Adder (PFA)
// - Sum term 
// - Generate term (G = A AND B) - indicates when a carry is generated regardless of input carry
// - Propagate term (P = A XOR B) - indicates when a carry is propagated if there is an input carry

module partial_full_adder(
    input wire iA, iB, iCarry,
    output wire oSum, oG, oP
);
    assign oP = iA ^ iB;
    assign oG = iA & iB;
    assign oSum = oP ^ iCarry;
    
endmodule