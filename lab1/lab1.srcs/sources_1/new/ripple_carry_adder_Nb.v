`timescale 1ns / 1ps

module ripple_carry_adder_Nb #(
    parameter   ADDER_WIDTH = 16
    )
    (
    input   wire [ADDER_WIDTH-1:0]  iA, iB, 
    input   wire                    iCarry,
    output  wire [ADDER_WIDTH-1:0]  oSum, 
    output  wire                    oCarry
);
    wire [ADDER_WIDTH:0] c ;
    
    //dont need c-1 here, because we need to assign the initial iCarry as well. 
    
    assign c[0] = iCarry;
    assign oCarry = c[ADDER_WIDTH];
    
    //variable to control loop
    genvar i;
    generate 
        for(i=0; i < ADDER_WIDTH; i=i+1) begin
        full_adder full_adder_inst(
            .iA(iA[i]),
            .iB(iB[i]),
            .iCarry(c[i]),        
            .oSum(oSum[i]),
            .oCarry(c[i+1])        
        );
        end
    endgenerate
endmodule  