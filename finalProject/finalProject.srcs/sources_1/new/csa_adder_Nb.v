`timescale 1ns / 1ps

module csa_adder_Nb #(
    parameter ADDER_WIDTH = 256
)
(
    input wire [ADDER_WIDTH-1:0] iA, iB,
    input wire iCarry,
    output wire [ADDER_WIDTH-1:0] oSum,
    output wire oCarry
);
    
    wire [ADDER_WIDTH-1:0] csa_sum;
    wire [ADDER_WIDTH-1:0] csa_carry;
    
    genvar i;
    generate
        for (i = 0; i < ADDER_WIDTH; i = i + 1) 
        begin : gen_csa
            if (i == 0) begin
                // First bit uses input carry
                csa csa_inst(
                    .iA(iA[i]),
                    .iB(iB[i]),
                    .iC(iCarry),
                    .oSum(csa_sum[i]),
                    .oCarry(csa_carry[i])
                );
            end else begin
                // Other bits have no carry input
                csa csa_inst(
                    .iA(iA[i]),
                    .iB(iB[i]),
                    .iC(1'b0),
                    .oSum(csa_sum[i]),
                    .oCarry(csa_carry[i])
                );
            end
        end
    endgenerate
    
    //Shift carries left by 1 and extend with 0
    wire [ADDER_WIDTH:0] shifted_carries = {csa_carry, 1'b0};
    
    // Add sum and shifted carries
    wire [ADDER_WIDTH:0] final_result = {1'b0, csa_sum} + shifted_carries;
    
    assign oSum = final_result[ADDER_WIDTH-1:0];
    assign oCarry = final_result[ADDER_WIDTH];
    
endmodule