//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
//Date        : Thu Mar 27 11:25:30 2025
//Host        : sodir-HP-Laptop running 64-bit Ubuntu 24.04.2 LTS
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (iClk,
    iRst,
    iRx,
    oTx);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ICLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ICLK, CLK_DOMAIN design_1_iClk, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input iClk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.IRST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.IRST, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input iRst;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.IRX DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.IRX, LAYERED_METADATA undef" *) input iRx;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.OTX DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.OTX, LAYERED_METADATA undef" *) output oTx;

  wire Debounce_Switch_0_o_Switch;
  wire iClk_1;
  wire iRst_1;
  wire iRx_1;
  wire uart_top_0_oTx;

  assign iClk_1 = iClk;
  assign iRst_1 = iRst;
  assign iRx_1 = iRx;
  assign oTx = uart_top_0_oTx;
  design_1_Debounce_Switch_0_0 Debounce_Switch_0
       (.i_Clk(iClk_1),
        .i_Switch(iRst_1),
        .o_Switch(Debounce_Switch_0_o_Switch));
  design_1_uart_top_0_0 uart_top_0
       (.iClk(iClk_1),
        .iRst(Debounce_Switch_0_o_Switch),
        .iRx(iRx_1),
        .oTx(uart_top_0_oTx));
endmodule
