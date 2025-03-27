`timescale 1ns / 1ps

module uart_top #(
    parameter   OPERAND_WIDTH = 512,
    parameter   ADDER_WIDTH   = 16,
    parameter   NBYTES        = OPERAND_WIDTH / 8,     
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
  localparam s_WAIT_RX_A    = 3'b001;
  localparam s_WAIT_RX_B    = 3'b010;
  localparam s_ADD          = 3'b011;
  localparam s_TX           = 3'b100;
  localparam s_WAIT_TX      = 3'b101;
  localparam s_DONE         = 3'b110;
   
  // Declare all variables needed for the finite state machine 
  // -> the FSM state
  reg [2:0]   rFSM;  
  
  // Connection to UART TX (inputs = registers, outputs = wires)
  reg         rTxStart;
  reg [7:0]   rTxByte;
  
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
    reg rStart;
    reg [OPERAND_WIDTH-1:0] rA, rB;
    wire [OPERAND_WIDTH:0] wRes;
    wire wDone;
    reg [OPERAND_WIDTH:0]   rResult;
    
    mp_adder #(.OPERAND_WIDTH(OPERAND_WIDTH), .ADDER_WIDTH(ADDER_WIDTH))
    MP_ADDER_INST
        (.iClk(iClk),
         .iRst(iRst),
         .iStart(rStart),
         .iOpA(rA),
         .iOpB(rB),
         .oRes(wRes),
         .oDone(wDone)
     );
         
        
     
  reg [$clog2(NBYTES):0] rCnt;
  
  
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
    end 
  else 
    begin
      case (rFSM)
   
        s_IDLE :
          begin
              rFSM <= s_WAIT_RX_A;
              rCnt <= 0;
              rA <= 0;
              rB <= 0;
              rStart <= 0;
          end
          
        s_WAIT_RX_A :
          begin
            if (wRxDone)
              begin 
              rBuffer <= {rBuffer[NBYTES*8-9:0], wRxByte};
              rCnt <= rCnt + 1;
              if (rCnt == NBYTES-1) begin
                rFSM <= s_TX;
                rCnt <= 0; // Reset counter for transmission            
                end
                end
          end
          
         s_WAIT_RX_B :
          begin
            if (wRxDone)
              begin 
              rBuffer <= {rBuffer[NBYTES*8-9:0], wRxByte};
              rCnt <= rCnt + 1;
              if (rCnt == NBYTES-1) begin
                rFSM <= s_TX;
                rCnt <= 0; // Reset counter for transmission            
                end
                end
          end
          
       s_ADD :
          begin
            if (wRxDone)
              begin 
              rBuffer <= {rBuffer[NBYTES*8-9:0], wRxByte};
              rCnt <= rCnt + 1;
              if (rCnt == NBYTES-1) begin
                rFSM <= s_TX;
                rCnt <= 0; // Reset counter for transmission            
                end
                end
          end
             
        s_TX :
          begin
            if ( (rCnt < NBYTES) && (wTxBusy ==0) ) 
              begin
                rFSM <= s_WAIT_TX;
                rTxStart <= 1; 
                rTxByte <= rBuffer[NBYTES*8-1:NBYTES*8-8];            // we send the uppermost byte
                rBuffer <= {rBuffer[NBYTES*8-9:0] , 8'b0000_0000};    // we shift from right to left
                rCnt <= rCnt + 1;
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
