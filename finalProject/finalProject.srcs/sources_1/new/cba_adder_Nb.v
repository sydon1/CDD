`timescale 1ns / 1ps

// Parameterized Carry Bypass Adder
module cba_adder_Nb #(
    parameter ADDER_WIDTH = 32
    )
    (
    input wire [ADDER_WIDTH-1:0] iA, iB,
    input wire iCarry,
    output wire [ADDER_WIDTH-1:0] oSum,
    output wire oCarry
);
    generate
        if (ADDER_WIDTH == 4) begin
            // Use basic 4-bit CBA for width=4
            cba_4bit cba_inst(
                .iA(iA),
                .iB(iB),
                .iCarry(iCarry),
                .oSum(oSum),
                .oCarry(oCarry),
                .oBlockPropagate() // Not connected at top level
            );
        end
        else if (ADDER_WIDTH == 8) begin
            // Use basic 8-bit CBA for width=8
            cba_8bit cba_inst(
                .iA(iA),
                .iB(iB),
                .iCarry(iCarry),
                .oSum(oSum),
                .oCarry(oCarry),
                .oBlockPropagate() // Not connected at top level
            );
        end
        else if (ADDER_WIDTH % 8 == 0) begin
            // For widths that are multiples of 8 (including 32-bit)
            localparam NUM_BLOCKS = ADDER_WIDTH / 8;
            
            wire [NUM_BLOCKS-1:0] block_propagate;
            wire [NUM_BLOCKS:0] block_carry;
            assign block_carry[0] = iCarry;
            
            // Instantiate the 8-bit blocks
            genvar i;
            for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : gen_blocks
                cba_8bit block(
                    .iA(iA[(i+1)*8-1:i*8]),
                    .iB(iB[(i+1)*8-1:i*8]),
                    .iCarry(block_carry[i]),
                    .oSum(oSum[(i+1)*8-1:i*8]),
                    .oCarry(block_carry[i+1]),
                    .oBlockPropagate(block_propagate[i])
                );
            end
            
            // Implement inter-block bypassing with direct assignments
            // Use a synthesizable approach for combining all block propagate signals
            
            // For 32-bit (NUM_BLOCKS=4), we'd have:
            wire all_blocks_propagate;
            
            if (NUM_BLOCKS == 1) begin
                assign all_blocks_propagate = block_propagate[0];
            end
            else if (NUM_BLOCKS == 2) begin
                assign all_blocks_propagate = block_propagate[0] & block_propagate[1];
            end
            else if (NUM_BLOCKS == 3) begin
                assign all_blocks_propagate = block_propagate[0] & block_propagate[1] & block_propagate[2];
            end
            else if (NUM_BLOCKS == 4) begin
                assign all_blocks_propagate = block_propagate[0] & block_propagate[1] & 
                                             block_propagate[2] & block_propagate[3];
            end
            else if (NUM_BLOCKS == 8) begin
                assign all_blocks_propagate = block_propagate[0] & block_propagate[1] & 
                                             block_propagate[2] & block_propagate[3] &
                                             block_propagate[4] & block_propagate[5] &
                                             block_propagate[6] & block_propagate[7];
            end
            
            // Final output carry with bypass
            assign oCarry = (iCarry & all_blocks_propagate) | block_carry[NUM_BLOCKS];
        end
        else if ((ADDER_WIDTH % 4 == 0) && (ADDER_WIDTH % 8 != 0)) begin
            // For widths that are multiples of 4 but not 8
            localparam NUM_8BIT = ADDER_WIDTH / 8;
            localparam REMAINING = ADDER_WIDTH - (NUM_8BIT * 8); // Will be 4
            
            // Block-level propagate signals
            wire [NUM_8BIT:0] block_propagate; // +1 for the final 4-bit block
            
            // Carries between blocks
            wire [NUM_8BIT+1:0] block_carry;
            assign block_carry[0] = iCarry;
            
            // Instantiate 8-bit blocks
            genvar i;
            for (i = 0; i < NUM_8BIT; i = i + 1) begin : gen_8bit
                cba_8bit block(
                    .iA(iA[(i+1)*8-1:i*8]),
                    .iB(iB[(i+1)*8-1:i*8]),
                    .iCarry(block_carry[i]),
                    .oSum(oSum[(i+1)*8-1:i*8]),
                    .oCarry(block_carry[i+1]),
                    .oBlockPropagate(block_propagate[i])
                );
            end
            
            // Final 4-bit block
            cba_4bit final_block(
                .iA(iA[ADDER_WIDTH-1:NUM_8BIT*8]),
                .iB(iB[ADDER_WIDTH-1:NUM_8BIT*8]),
                .iCarry(block_carry[NUM_8BIT]),
                .oSum(oSum[ADDER_WIDTH-1:NUM_8BIT*8]),
                .oCarry(block_carry[NUM_8BIT+1]),
                .oBlockPropagate(block_propagate[NUM_8BIT])
            );
            
            // Implement inter-block bypassing with direct assignments
            wire all_blocks_propagate;
            
            if (NUM_8BIT == 0) begin
                assign all_blocks_propagate = block_propagate[0];
            end
            else if (NUM_8BIT == 1) begin
                assign all_blocks_propagate = block_propagate[0] & block_propagate[1];
            end
            else if (NUM_8BIT == 2) begin
                assign all_blocks_propagate = block_propagate[0] & block_propagate[1] & block_propagate[2];
            end
            else if (NUM_8BIT == 3) begin
                assign all_blocks_propagate = block_propagate[0] & block_propagate[1] & 
                                             block_propagate[2] & block_propagate[3];
            end
            assign oCarry = (iCarry & all_blocks_propagate) | block_carry[NUM_8BIT+1];
        end
    endgenerate
endmodule