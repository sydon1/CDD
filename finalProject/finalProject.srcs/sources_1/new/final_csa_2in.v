`timescale 1ns / 1ps

module final_csa_2in(
    input wire iA, iB, iCarry,
    output wire oSum, oCarry
);

    csa csa_inst(
        .iA(iA),
        .iB(iB),
        .iC(iCarry),      // carry = 3de
        .oSum(oSum),
        .oCarry(oCarry)
    );
endmodule
