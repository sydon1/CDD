`timescale 1ns / 1ps

module carry_lookahead_adder_Nb #(
    parameter ADDER_WIDTH = 32
    )
    (
    input wire [ADDER_WIDTH-1:0] iA, iB,
    input wire iCarry,                   
    output wire [ADDER_WIDTH-1:0] oSum,  
    output wire oCarry                     
    );
    
    // Calculate the number of 4-bit blocks needed (ceiling division)
    localparam NUM_BLOCKS = (ADDER_WIDTH + 3) / 4;
    
    // Block propagate and generate signals
    wire [NUM_BLOCKS-1:0] block_p, block_g;
    
    // Inter-block carries
    wire [NUM_BLOCKS:0] c;
    assign c[0] = iCarry;
    
    // We need some internal wires for handling non-4-bit-aligned widths
    wire [NUM_BLOCKS*4-1:0] extended_a, extended_b, extended_sum;
    
    // Zero-extend inputs if needed
    generate
        if (NUM_BLOCKS*4 > ADDER_WIDTH) begin
            assign extended_a = {{(NUM_BLOCKS*4-ADDER_WIDTH){1'b0}}, iA};
            assign extended_b = {{(NUM_BLOCKS*4-ADDER_WIDTH){1'b0}}, iB};
        end else begin
            assign extended_a = iA;
            assign extended_b = iB;
        end
    endgenerate
    
    // Generate instances of the 4-bit CLA combined module
    genvar i;
    generate
        for (i = 0; i < NUM_BLOCKS; i = i + 1) begin: cla_blocks
            CLA_4bit CLA_4bit_inst (
                .iA(extended_a[i*4+3:i*4]),
                .iB(extended_b[i*4+3:i*4]),
                .iCarry(c[i]),
                .oSum(extended_sum[i*4+3:i*4]),
                .oCarry(),  // Not connected internally
                .oP(block_p[i]),
                .oG(block_g[i])
            );
        end
    endgenerate
    
    // Simplified carry propagation logic - we'll hard-code for up to 8 blocks (32 bits)
    // This could be extended for larger bit widths if needed
    
    // First block carry is simple
    assign c[1] = block_g[0] | (block_p[0] & c[0]);
    
    // For other blocks, we need to expand the carry equations
    generate
        if (NUM_BLOCKS > 1) begin
            assign c[2] = block_g[1] | (block_p[1] & block_g[0]) | (block_p[1] & block_p[0] & c[0]);
        end
        
        if (NUM_BLOCKS > 2) begin
            assign c[3] = block_g[2] | 
                         (block_p[2] & block_g[1]) | 
                         (block_p[2] & block_p[1] & block_g[0]) | 
                         (block_p[2] & block_p[1] & block_p[0] & c[0]);
        end
        
        if (NUM_BLOCKS > 3) begin
            assign c[4] = block_g[3] | 
                         (block_p[3] & block_g[2]) | 
                         (block_p[3] & block_p[2] & block_g[1]) | 
                         (block_p[3] & block_p[2] & block_p[1] & block_g[0]) | 
                         (block_p[3] & block_p[2] & block_p[1] & block_p[0] & c[0]);
        end
        
        if (NUM_BLOCKS > 4) begin
            assign c[5] = block_g[4] | 
                         (block_p[4] & block_g[3]) | 
                         (block_p[4] & block_p[3] & block_g[2]) | 
                         (block_p[4] & block_p[3] & block_p[2] & block_g[1]) | 
                         (block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_g[0]) | 
                         (block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_p[0] & c[0]);
        end
        
        if (NUM_BLOCKS > 5) begin
            assign c[6] = block_g[5] | 
                         (block_p[5] & block_g[4]) | 
                         (block_p[5] & block_p[4] & block_g[3]) | 
                         (block_p[5] & block_p[4] & block_p[3] & block_g[2]) | 
                         (block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_g[1]) | 
                         (block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_g[0]) | 
                         (block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_p[0] & c[0]);
        end
        
        if (NUM_BLOCKS > 6) begin
            assign c[7] = block_g[6] | 
                         (block_p[6] & block_g[5]) | 
                         (block_p[6] & block_p[5] & block_g[4]) | 
                         (block_p[6] & block_p[5] & block_p[4] & block_g[3]) | 
                         (block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_g[2]) | 
                         (block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_g[1]) | 
                         (block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_g[0]) | 
                         (block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_p[0] & c[0]);
        end
        
        if (NUM_BLOCKS > 7) begin
            assign c[8] = block_g[7] | 
                         (block_p[7] & block_g[6]) | 
                         (block_p[7] & block_p[6] & block_g[5]) | 
                         (block_p[7] & block_p[6] & block_p[5] & block_g[4]) | 
                         (block_p[7] & block_p[6] & block_p[5] & block_p[4] & block_g[3]) | 
                         (block_p[7] & block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_g[2]) | 
                         (block_p[7] & block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_g[1]) | 
                         (block_p[7] & block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_g[0]) | 
                         (block_p[7] & block_p[6] & block_p[5] & block_p[4] & block_p[3] & block_p[2] & block_p[1] & block_p[0] & c[0]);
        end
        
        // For larger bit widths, additional carry equations would be needed
        // This implementation supports up to 32 bits (8 blocks)
    endgenerate
    
    // Output sum (truncate back to original width if needed)
    assign oSum = extended_sum[ADDER_WIDTH-1:0];
    
    // Output carry
    assign oCarry = c[NUM_BLOCKS];
    
endmodule