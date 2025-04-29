`timescale 1ns / 1ps

module pf_adder(
    input wire iA, iB, iCarry,
    output wire oSum, oP, oG
    );
    
    // Generate term: indicates when this bit position will generate a carry
    assign oG = iA & iB;
    
    // Propagate term: indicates when this bit position will propagate an incoming carry
    // CORRECTED: This should be XOR (^), not OR (|)
    assign oP = iA ^ iB;
    
    // Sum calculation
    assign oSum = (iA ^ iB) ^ iCarry;
     
endmodule