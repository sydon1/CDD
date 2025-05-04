`timescale 1ns / 1ps

module uart_top #(
    parameter   OPERAND_WIDTH = 512,
    parameter   ADDER_WIDTH   = 16,
    parameter   NBYTES        = OPERAND_WIDTH / 8,     
    parameter   CMP_WIDTH     = 32,    
    // values for the UART (in case we want to change them)
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200
  )  
  (
    input   wire   iClk, iRst,
    input   wire   iRx,
    output  wire   oTx
  );
  
  // Buffer to exchange data between Pynq-Z2 and laptop
  reg [NBYTES*8-1:0] rBuffer;
  
  // State definition 
  localparam s_IDLE         = 3'b000; 
  localparam s_WAIT_RX_MODE = 3'b001;  
  localparam s_WAIT_RX_A    = 3'b010;  
  localparam s_WAIT_RX_B    = 3'b011;   
  localparam s_ADD_COMPARE  = 3'b100;  
  localparam s_TX           = 3'b101;  
  localparam s_WAIT_TX      = 3'b110;  
  localparam s_DONE         = 3'b111;  
    
   
  // Declare all variables needed for the finite state machine 
  // -> the FSM state
  reg [2:0]   rFSM;  
  
  // Connection to UART TX (inputs = registers, outputs = wires)
  reg         rTxStart;
  reg [7:0]   rTxByte;
  
  reg rOperationMode;  // 0 for comparator, 1 for adder

  
  wire        wTxBusy;
  wire        wTxDone;
      
  uart_tx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_TX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iTxStart(rTxStart),
     .iTxByte(rTxByte),
     .oTxSerial(oTx),
     .oTxBusy(wTxBusy),
     .oTxDone(wTxDone)
     );
  
  // Connection to UART RX (outputs = wires)
  wire        wRxDone;
  wire [7:0]  wRxByte;

   uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE))
   UART_RX_INST
     (.iClk(iClk),
      .iRst(iRst),
      .iRxSerial(iRx),
      .oRxByte(wRxByte),
      .oRxDone(wRxDone)
   
    );
    
    //we use nbytes+1 due to formatting of possible carry. See lab text
    reg rStart;
    reg [OPERAND_WIDTH-1:0] rA, rB;
    wire [OPERAND_WIDTH:0] wRes_adder;
    wire wDone_adder;
    wire wRes_comparator; 
    wire wDone_comparator;
    reg [(NBYTES+1)*8-1:0] rResult;
        
    mp_adder #(.OPERAND_WIDTH(OPERAND_WIDTH), .ADDER_WIDTH(ADDER_WIDTH), .N_ITERATIONS((OPERAND_WIDTH + ADDER_WIDTH - 1) / ADDER_WIDTH))
        MP_ADDER_INST
        (.iClk(iClk),
         .iRst(iRst),
         .iStart(rStart),
         .iOpA(rA),
         .iOpB(rB),
         .oRes(wRes_adder),
         .oDone(wDone_adder)
     );
    
    //comparator added here
    mp_CMP #( .OPERAND_WIDTH(OPERAND_WIDTH), .CMP_WIDTH(CMP_WIDTH), .N_ITERATIONS(OPERAND_WIDTH / CMP_WIDTH))
    MP_CMP_INST (
        .iClk(iClk),
        .iRst(iRst),
        .iStart(rStart),
        .iOpA(rA),
        .iOpB(rB),
        .oResult(wRes_comparator),  // 1-bit result, to indicate if its equal or not
        .oDone(wDone_comparator)
    );
        
     //ditto
    reg [$clog2(NBYTES)+1:0] rCnt;
  
  
  always @(posedge iClk)
  begin
  
  // reset all registers upon reset
    
if (iRst == 1 ) 
begin
    rFSM <= s_IDLE;
    rTxStart <= 0;
    rCnt <= 0;
    rTxByte <= 0;
    rBuffer <= 0;
    rA <= 0;
    rB <= 0;
    rStart <= 0;
    rResult <= 0;
    rOperationMode <= 0;
    end 
    else 
    begin
    //note = always define every possible scenario when possible, to avoid latches.
    case (rFSM)
    s_IDLE :
        begin
            rFSM <= s_WAIT_RX_MODE;
            rCnt <= 0;
            rA <= 0;
            rB <= 0;
            rStart <= 0;
        end
        
    //here we have the waiting mode, simply, before we do the actual operation we await 512 bits to determine which operation we want to do
    //depending on the response, we change the reg operation mode, and use this later in s_ADD_COMPARE to determine the operation we wish to do    
    s_WAIT_RX_MODE :
        begin
        if (wRxDone)
            begin
                //all 0xFF for adder, all 0x00 for comparator
                if (wRxByte == 8'hFF)
                    rOperationMode <= 1;  // Adder mode
                else if (wRxByte == 8'h00)
                    rOperationMode <= 0;  // Comparator mode
                else
                    rOperationMode <= 1;  // Default
                
                rCnt <= rCnt + 1;
                
                if (rCnt == NBYTES-1) 
                begin
                    rFSM <= s_WAIT_RX_A;
                    rCnt <= 0;
                end
            end
        end                


      //Because we have two mux'es, we have can seperate these two into two seperate states
      //Both states wait for the rx, of their corresponding A/B, and then write this into the register
      //After A is done, we go to B.    
      s_WAIT_RX_A :
            begin
            if (wRxDone)
                begin 
                    rA <= {rA[OPERAND_WIDTH-9:0], wRxByte};
                    rCnt <= rCnt + 1;
                    if (rCnt == NBYTES-1) 
                    begin
                        rFSM <= s_WAIT_RX_B;
                        rCnt <= 0; // Reset counter for transmission            
                    end
                end
        end
              
        s_WAIT_RX_B :
            begin
            if (wRxDone)
                begin 
                    rB <= {rB[OPERAND_WIDTH-9:0], wRxByte};
                    rCnt <= rCnt + 1;
                    if (rCnt == NBYTES-1)
                    begin
                        rFSM <= s_ADD_COMPARE;
                        rCnt <= 0; // Reset counter for transmission            
                    end
                end
          end
       //After having done both A and B, we trigger rStart of the MP adder (or comparator)
       //We wait until it is done, but to make the sizes all equal we do the 
       //zero padding of the final result   
       s_ADD_COMPARE :
       begin
       if (rStart == 0 && (rOperationMode ? wDone_adder : wDone_comparator) == 0)
            rStart <= 1;
            else
            rStart <= 0;
      
            if (rOperationMode ? wDone_adder : wDone_comparator) 
            begin
                // Select result based on operation mode
                if (rOperationMode)  // Adder mode
                    rResult <= {7'b0000000, wRes_adder};
                else                 // Comparator mode
                    rResult <= {{(NBYTES+1)*8-1{1'b0}}, wRes_comparator};
                rFSM <= s_TX;
            end
        end
             
        s_TX :
          begin
            if ( (rCnt <= NBYTES) && (wTxBusy ==0) ) 
              begin
                rFSM <= s_WAIT_TX;
                rTxStart <= 1; 
                rTxByte <= rResult[(NBYTES+1)*8-1:(NBYTES+1)*8-8];        //we take the result per 8 bits, and then we send the MSB 
                rResult <= {rResult[(NBYTES+1)*8-9:0], 8'b0000_0000};    //After getting the MSB out, we add 0's on the right, to push the old MSB out, and get the new one
                rCnt <= rCnt + 1;                                        //we increment the counter,this goes upto Nbytes+1
              end 
            else 
              begin
                rFSM <= s_IDLE;
                rTxStart <= 0;
                rTxByte <= 0;
                rCnt <= 0;
              end
            end 
            
            s_WAIT_TX :
              begin
                if (wTxDone) begin
                  rFSM <= s_TX;
                end else begin
                  rFSM <= s_WAIT_TX;
                  rTxStart <= 0;                   
                end
              end 
              
            s_DONE :
              begin
                rFSM <= s_IDLE;
              end 

            default :
              rFSM <= s_IDLE;
             
          endcase
      end
    end       
    
endmodule
