`timescale 1ns / 1ps

module mp_CMP #(
    parameter OPERAND_WIDTH = 512,  
    parameter CMP_WIDTH = 32,      
    parameter N_ITERATIONS = (OPERAND_WIDTH + CMP_WIDTH - 1) / CMP_WIDTH
)
(
    input  wire iClk,
    input  wire iRst,
    input  wire iStart,
    input  wire [OPERAND_WIDTH-1:0] iOpA,
    input  wire [OPERAND_WIDTH-1:0] iOpB,
    output wire oResult,   // Comparison result: 1 if equal, 0 otherwise
    output wire oDone
);

    // FSM state encoding
    localparam s_IDLE      = 3'b000,
               s_STORE_OPS = 3'b001,
               s_COMPARE   = 3'b010,
               s_DONE      = 3'b011;

    reg [2:0] rFSM_current, wFSM_next;

    // Registers for operand A and B
    wire [OPERAND_WIDTH-1:0] regA_D;
    reg [OPERAND_WIDTH-1:0] regA_Q;

    wire [OPERAND_WIDTH-1:0] regB_D;
    reg [OPERAND_WIDTH-1:0] regB_Q;

    // Operand latch logic
    assign regA_D = (rFSM_current == s_STORE_OPS) ? iOpA : regA_Q;
    assign regB_D = (rFSM_current == s_STORE_OPS) ? iOpB : regB_Q;

    always @(posedge iClk)
    begin
        if(iRst)
            regA_Q <= {OPERAND_WIDTH{1'b0}};
        else
            regA_Q <= regA_D;
    end

    always @(posedge iClk)
    begin
        if(iRst)
            regB_Q <= {OPERAND_WIDTH{1'b0}};
        else
            regB_Q <= regB_D;
    end

    // Instantiate 32-bit comparators for each chunk
    wire [N_ITERATIONS-1:0] cmp_results;
    wire [N_ITERATIONS-1:0] cmp_done;

    genvar i;
    generate
        for (i = 0; i < N_ITERATIONS; i = i + 1) 
        begin
            cmp_32bit cmp_i (
                .iOpA(regA_Q[(i+1)*CMP_WIDTH-1:i*CMP_WIDTH]),
                .iOpB(regB_Q[(i+1)*CMP_WIDTH-1:i*CMP_WIDTH]),
                .oEqual(cmp_results[i]),
                .oDone(cmp_done[i])
            );
        end
    endgenerate

    // Combine all comparison results and done signals
    wire wAllEqual = &cmp_results;
    wire wAllDone  = &cmp_done;

    

    // FSM control
    reg [$clog2(N_ITERATIONS):0] rCnt_Current, wCnt_next;

    always @(posedge iClk)
    begin
        if(iRst)
            rFSM_current <= s_IDLE;
        else
            rFSM_current <= wFSM_next;
    end

    always @(posedge iClk)
    begin
        if(iRst)
            rCnt_Current <= 0;
        else
            rCnt_Current <= wCnt_next;
    end

    always @(*)
    begin
        case (rFSM_current)
            s_IDLE:
            begin
                wFSM_next = (iStart == 1) ? s_STORE_OPS : s_IDLE;
                wCnt_next = 0;
            end

            s_STORE_OPS:
            begin
                wFSM_next = s_COMPARE;
                wCnt_next = rCnt_Current + 1;
            end

            s_COMPARE:
            begin
                if (!wAllEqual)
                    wFSM_next = s_DONE;
                else if (rCnt_Current < (N_ITERATIONS - 1))
                    wFSM_next = s_STORE_OPS;
                else
                    wFSM_next = s_DONE;
                wCnt_next = rCnt_Current + 1;
            end

            s_DONE:
            begin
                wFSM_next = s_IDLE;
                wCnt_next = 0;
            end

            default:
            begin
                wFSM_next = s_IDLE;
                wCnt_next = 0;
            end
        endcase
    end

    // Done signal generation
    reg regDone;
    always @(posedge iClk)
    begin
        if (iRst)
            regDone <= 1'b0;
        else
            regDone <= (rFSM_current == s_DONE);
    end
    assign oResult = wAllEqual;
    assign oDone   = regDone;

endmodule