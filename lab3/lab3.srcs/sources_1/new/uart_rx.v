`timescale 1ns / 1ps

module uart_rx #(
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200,
    // Example: 125 MHz Clock / 115200 baud UART -> CLKS_PER_BIT = 1085 
    parameter   CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE
    )
    (
    input wire        iClk, iRst,
    input wire        iRxSerial,
    output wire [7:0] oRxByte, 
    output wire       oRxDone
);

    // State definition
    localparam sIDLE         = 3'b000;
    localparam sRX_START     = 3'b001;
    localparam sRX_DATA      = 3'b010;
    localparam sRX_STOP      = 3'b011;
    localparam sDONE         = 3'b100;
   
    // Register variables required to drive the FSM
    //---------------------------------------------
    // Remember:  -> 'current' is the register output
    //            -> 'next' is the register input
    // -> FSM state
    reg [2:0] rFSM_Current, wFSM_Next; 
    
    // -> counter to keep track of the clock cycles
    reg [$clog2(CLKS_PER_BIT):0]   rCnt_Current, wCnt_Next;
    
    // -> counter to keep track of received bits
    // (between 0 and 7)
    reg [2:0] rBit_Current, wBit_Next;
    
    // -> the byte we are receiving
    reg [7:0] rRxData_Current, wRxData_Next;

    //for metastability    
    reg rRx1, rRx2;

    
    always @(posedge iClk)
    begin
      if (iRst==1)
      begin
        rFSM_Current <= sIDLE;
        rCnt_Current <= 0;
        rBit_Current <= 0;
        rRxData_Current <= 0;        
        rRx1 <= 1'b1;
        rRx2 <= 1'b1; 
      end
      else begin
        rFSM_Current <= wFSM_Next;
        rCnt_Current <= wCnt_Next;
        rBit_Current <= wBit_Next;
        rRxData_Current <= wRxData_Next;
        rRx1 <= iRxSerial;
        rRx2 <= rRx1;
      end
    end

    always @(*)
        begin
        
          case (rFSM_Current)
          // Idle = We wait on the start bit, which is when it is low. 
          // We take Rx2, as to make sure we have no metastability errors.
            sIDLE :
            begin
                wCnt_Next = 0;
                wBit_Next = 0;
                wRxData_Next = rRxData_Current;
                
                if (rRx2 == 0) begin
                    wFSM_Next = sRX_START;
                end else
                begin    
                    wFSM_Next = sIDLE;
                end
            end 
               
            // RX_START STATE:
            // the FSM waits CLKS_PER_BIT cycles until the start bit is completed.
            sRX_START :
            begin
                wBit_Next = 0;
                wRxData_Next = rRxData_Current;

                if (rCnt_Current < (CLKS_PER_BIT - 1)) 
                    begin
                      wFSM_Next = sRX_START;
                      wCnt_Next = rCnt_Current + 1;
                    end
                else
                    begin
                      wFSM_Next = sRX_DATA;
                      wCnt_Next = 0; 
                    end
                end

            // RX_DATA STATE:
            // we stay here for the duration of receiving the byte,
            // which takes 8 * CLKS_PER_BIT clock cycles     
            // we use rCnt_Current to keep track of clock cycles 
            // we use rBit_Current to keep track of number of bits
            // SAMPLE IN THE MIDDLE!!!!!
            sRX_DATA :
            begin
            if (rCnt_Current == (CLKS_PER_BIT - 1)/2)
                begin
                      wFSM_Next = sRX_DATA;
                      wCnt_Next = rCnt_Current + 1;
                      wBit_Next = rBit_Current;
                      wRxData_Next = {rRx2, rRxData_Current[7:1]};
                end
            else if (rCnt_Current < (CLKS_PER_BIT - 1))
                begin
                    //if we arent in the midle, we aren't doing anything special to the data array
                      wFSM_Next = sRX_DATA;
                      wCnt_Next = rCnt_Current + 1;
                      wBit_Next = rBit_Current;
                      wRxData_Next = rRxData_Current;
                end
            else 
                begin
                // End of bit period - reset counter and check bit count
                wCnt_Next = 0;
                wRxData_Next = rRxData_Current;
                if (rBit_Current < 7) begin
                      wFSM_Next = sRX_DATA;
                      wBit_Next = rBit_Current + 1;
                end     
            else 
                begin
                  // All 8 bits received, move to stop bit
                  wFSM_Next = sRX_STOP;
                  wBit_Next = 0;
                end
            end
            end  

              // RX_STOP STATE:
              // takes CLKS_PER_BIT clock cycles, stop bit is 1  
              sRX_STOP :
              begin
                  wRxData_Next = rRxData_Current;
                  wBit_Next = 0; 
                  if (rCnt_Current < (CLKS_PER_BIT - 1))
                  begin
                      wFSM_Next = sRX_STOP;
                      wCnt_Next = rCnt_Current + 1;
                  end
                  else
                  begin
                          wFSM_Next = sDONE;
                          wCnt_Next = 0;
                  end
                end 
               
               
              // DONE STATE:
              // -> we stay here 1 clock cycle to assert the oRxDone signal
              sDONE :
                begin
                  wRxData_Next = rRxData_Current;
                  wBit_Next = 0;
                  wCnt_Next = 0;
                  wFSM_Next = sIDLE; // Go back to idle for next byte
                end
                         
              default :
                begin
                  wFSM_Next = sIDLE;
                  wCnt_Next = 0;
                  wBit_Next = 0;
                  wRxData_Next = 0;
                end 
            endcase
        end
 
  // Output logic
  //------------------------------------------ 
  // Define the outputs based on the current state of registers
  
  // Output oRxByte: Directly connect to the data shift register
  assign oRxByte = rRxData_Current;
  
  // Output oRxDone: Indicates a byte has been successfully received
  // It is asserted for one clock cycle when in the DONE state
  assign oRxDone = (rFSM_Current == sDONE) ? 1 : 0;
endmodule
