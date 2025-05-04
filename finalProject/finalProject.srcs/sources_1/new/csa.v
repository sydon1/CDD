`timescale 1ns / 1ps

module csa(
    input wire iA, iB, iC,
    output wire oSum, oCarry
);
    // Sum is XOR of all three inputs  
    assign oSum = iA ^ iB ^ iC;
    
    // Carry is majority function of three inputs
    assign oCarry = (iA & iB) | (iB & iC) | (iA & iC);
    
endmodule