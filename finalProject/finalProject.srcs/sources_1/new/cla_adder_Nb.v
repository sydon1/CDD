`timescale 1ns / 1ps

// Parameterized Carry Look-Ahead Adder, with 4/8/16/32 blocks and combinations
module cla_adder_Nb #(
    parameter ADDER_WIDTH = 44
    )
    (
    input wire [ADDER_WIDTH-1:0] iA, iB,
    input wire iCarry,
    output wire [ADDER_WIDTH-1:0] oSum,
    output wire oCarry
);
    generate
        if (ADDER_WIDTH == 4) begin
            cla_4bit cla_inst(
                .iA(iA),
                .iB(iB),
                .iCarry(iCarry),
                .oSum(oSum),
                .oCarry(oCarry)
            );
        end
        else if (ADDER_WIDTH == 8) begin
            cla_8bit cla_inst(
                .iA(iA),
                .iB(iB),
                .iCarry(iCarry),
                .oSum(oSum),
                .oCarry(oCarry)
            );
        end
        else if (ADDER_WIDTH == 16) begin
            cla_16bit cla_inst(
                .iA(iA),
                .iB(iB),
                .iCarry(iCarry),
                .oSum(oSum),
                .oCarry(oCarry)
            );
        end
        else if (ADDER_WIDTH == 32) begin
            cla_32bit cla_inst(
                .iA(iA),
                .iB(iB),
                .iCarry(iCarry),
                .oSum(oSum),
                .oCarry(oCarry)
            );
        end
        
        else if (ADDER_WIDTH % 32 == 0) begin
            wire [ADDER_WIDTH/32:0] carries;
            assign carries[0] = iCarry;
            assign oCarry = carries[ADDER_WIDTH/32];
            
            genvar i;
            for (i = 0; i < ADDER_WIDTH/32; i = i + 1) 
            begin
            cla_32bit cla_inst(
                    .iA(iA[(i+1)*32-1:i*32]),
                    .iB(iB[(i+1)*32-1:i*32]),
                    .iCarry(carries[i]),
                    .oSum(oSum[(i+1)*32-1:i*32]),
                    .oCarry(carries[i+1])
                );
            end
        end
        
        else if (ADDER_WIDTH % 16 == 0) begin
            wire [ADDER_WIDTH/16:0] carries;
            assign carries[0] = iCarry;
            assign oCarry = carries[ADDER_WIDTH/16];
            
            genvar i;
            for (i = 0; i < ADDER_WIDTH/16; i = i + 1) 
            begin
            cla_16bit cla_inst(
                    .iA(iA[(i+1)*16-1:i*16]),
                    .iB(iB[(i+1)*16-1:i*16]),
                    .iCarry(carries[i]),
                    .oSum(oSum[(i+1)*16-1:i*16]),
                    .oCarry(carries[i+1])
                );
            end
        end
        
        else if (ADDER_WIDTH % 8 == 0) begin
            wire [ADDER_WIDTH/8:0] carries;
            assign carries[0] = iCarry;
            assign oCarry = carries[ADDER_WIDTH/8];
            
            genvar i;
            for (i = 0; i < ADDER_WIDTH/8; i = i + 1) begin : cla8_blocks
                cla_8bit cla_inst(
                    .iA(iA[(i+1)*8-1:i*8]),
                    .iB(iB[(i+1)*8-1:i*8]),
                    .iCarry(carries[i]),
                    .oSum(oSum[(i+1)*8-1:i*8]),
                    .oCarry(carries[i+1])
                );
            end
        end
        //mixed 32 16
        else if ((ADDER_WIDTH % 32 != 0) && (ADDER_WIDTH % 16 == 0)) begin
            localparam NUM_32BIT = ADDER_WIDTH / 32;
            localparam REMAINING = ADDER_WIDTH - (NUM_32BIT * 32);
            localparam NUM_16BIT = REMAINING / 16;
            
            wire [NUM_32BIT+NUM_16BIT:0] carries;
            assign carries[0] = iCarry;
            assign oCarry = carries[NUM_32BIT+NUM_16BIT];
            
            genvar i;
            for (i = 0; i < NUM_32BIT; i = i + 1) 
            begin
                cla_32bit cla_inst(
                    .iA(iA[(i+1)*32-1:i*32]),
                    .iB(iB[(i+1)*32-1:i*32]),
                    .iCarry(carries[i]),
                    .oSum(oSum[(i+1)*32-1:i*32]),
                    .oCarry(carries[i+1])
                );
            end
            
            for (i = 0; i < NUM_16BIT; i = i + 1) 
            begin
                cla_16bit cla_inst(
                    .iA(iA[NUM_32BIT*32 + (i+1)*16-1:NUM_32BIT*32 + i*16]),
                    .iB(iB[NUM_32BIT*32 + (i+1)*16-1:NUM_32BIT*32 + i*16]),
                    .iCarry(carries[NUM_32BIT+i]),
                    .oSum(oSum[NUM_32BIT*32 + (i+1)*16-1:NUM_32BIT*32 + i*16]),
                    .oCarry(carries[NUM_32BIT+i+1])
                );
            end
        end
        // Mixed 16-bit and 8-bit blocks
        else if ((ADDER_WIDTH % 16 != 0) && (ADDER_WIDTH % 8 == 0)) 
        begin
            localparam NUM_16BIT = ADDER_WIDTH / 16;
            localparam REMAINING = ADDER_WIDTH - (NUM_16BIT * 16);
            localparam NUM_8BIT = REMAINING / 8;
            
            wire [NUM_16BIT+NUM_8BIT:0] carries;
            assign carries[0] = iCarry;
            assign oCarry = carries[NUM_16BIT+NUM_8BIT];
            
            // Instantiate 16-bit blocks
            genvar i;
            for (i = 0; i < NUM_16BIT; i = i + 1) 
            begin
                cla_16bit cla_inst(
                    .iA(iA[(i+1)*16-1:i*16]),
                    .iB(iB[(i+1)*16-1:i*16]),
                    .iCarry(carries[i]),
                    .oSum(oSum[(i+1)*16-1:i*16]),
                    .oCarry(carries[i+1])
                );
            end
            
            // Instantiate remaining 8-bit blocks
            for (i = 0; i < NUM_8BIT; i = i + 1) 
            begin 
                cla_8bit cla_inst(
                    .iA(iA[NUM_16BIT*16 + (i+1)*8-1:NUM_16BIT*16 + i*8]),
                    .iB(iB[NUM_16BIT*16 + (i+1)*8-1:NUM_16BIT*16 + i*8]),
                    .iCarry(carries[NUM_16BIT+i]),
                    .oSum(oSum[NUM_16BIT*16 + (i+1)*8-1:NUM_16BIT*16 + i*8]),
                    .oCarry(carries[NUM_16BIT+i+1])
                );
            end
        end
        
        // Mixed blocks for any width that's a multiple of 4,  largest blocks possible (32 → 16 → 8 → 4)
        else if (ADDER_WIDTH % 4 == 0) begin
            localparam NUM_32BIT = ADDER_WIDTH / 32;
            localparam REMAINING_AFTER_32 = ADDER_WIDTH - (NUM_32BIT * 32);
            localparam NUM_16BIT = REMAINING_AFTER_32 / 16;
            localparam REMAINING_AFTER_16 = REMAINING_AFTER_32 - (NUM_16BIT * 16);
            localparam NUM_8BIT = REMAINING_AFTER_16 / 8;
            localparam REMAINING_AFTER_8 = REMAINING_AFTER_16 - (NUM_8BIT * 8);
            localparam NUM_4BIT = REMAINING_AFTER_8 / 4;
            
            wire [NUM_32BIT+NUM_16BIT+NUM_8BIT+NUM_4BIT:0] carries;
            assign carries[0] = iCarry;
            assign oCarry = carries[NUM_32BIT+NUM_16BIT+NUM_8BIT+NUM_4BIT];
            
            genvar i;
            
            // Instantiate 32-bit blocks
            for (i = 0; i < NUM_32BIT; i = i + 1) 
            begin 
            cla_32bit cla_inst(
                    .iA(iA[(i+1)*32-1:i*32]),
                    .iB(iB[(i+1)*32-1:i*32]),
                    .iCarry(carries[i]),
                    .oSum(oSum[(i+1)*32-1:i*32]),
                    .oCarry(carries[i+1])
                );
            end
            
            // Instantiate 16-bit blocks
            for (i = 0; i < NUM_16BIT; i = i + 1) 
            begin 
            cla_16bit cla_inst(
                    .iA(iA[NUM_32BIT*32 + (i+1)*16-1:NUM_32BIT*32 + i*16]),
                    .iB(iB[NUM_32BIT*32 + (i+1)*16-1:NUM_32BIT*32 + i*16]),
                    .iCarry(carries[NUM_32BIT+i]),
                    .oSum(oSum[NUM_32BIT*32 + (i+1)*16-1:NUM_32BIT*32 + i*16]),
                    .oCarry(carries[NUM_32BIT+i+1])
                );
            end
            
            // Instantiate 8-bit blocks
            for (i = 0; i < NUM_8BIT; i = i + 1) 
            begin
            cla_8bit cla_inst(
                    .iA(iA[NUM_32BIT*32 + NUM_16BIT*16 + (i+1)*8-1:NUM_32BIT*32 + NUM_16BIT*16 + i*8]),
                    .iB(iB[NUM_32BIT*32 + NUM_16BIT*16 + (i+1)*8-1:NUM_32BIT*32 + NUM_16BIT*16 + i*8]),
                    .iCarry(carries[NUM_32BIT+NUM_16BIT+i]),
                    .oSum(oSum[NUM_32BIT*32 + NUM_16BIT*16 + (i+1)*8-1:NUM_32BIT*32 + NUM_16BIT*16 + i*8]),
                    .oCarry(carries[NUM_32BIT+NUM_16BIT+i+1])
                );
            end
            
            // Instantiate 4-bit blocks
            for (i = 0; i < NUM_4BIT; i = i + 1) 
            begin
            cla_4bit cla_inst(
                    .iA(iA[NUM_32BIT*32 + NUM_16BIT*16 + NUM_8BIT*8 + (i+1)*4-1:NUM_32BIT*32 + NUM_16BIT*16 + NUM_8BIT*8 + i*4]),
                    .iB(iB[NUM_32BIT*32 + NUM_16BIT*16 + NUM_8BIT*8 + (i+1)*4-1:NUM_32BIT*32 + NUM_16BIT*16 + NUM_8BIT*8 + i*4]),
                    .iCarry(carries[NUM_32BIT+NUM_16BIT+NUM_8BIT+i]),
                    .oSum(oSum[NUM_32BIT*32 + NUM_16BIT*16 + NUM_8BIT*8 + (i+1)*4-1:NUM_32BIT*32 + NUM_16BIT*16 + NUM_8BIT*8 + i*4]),
                    .oCarry(carries[NUM_32BIT+NUM_16BIT+NUM_8BIT+i+1])
                );
            end
        end
    endgenerate
endmodule