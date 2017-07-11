/**
 * AXI to AXI Lite Protocol Converter
 *
 * This module converts from AXI4 to AXI4 Lite by performing a simple ID reflection.  It does not
 * buffer multiple outstanding transactions; instead, a transaction is only accepted from the AXI
 * master after the previous transaction has been completed by the AXI Lite slave.
 *
 * For compatibility with Xilinx AXI Lite slaves, the AW and W channels are applied simultaneously
 * at the output.
 *
 * Copyright (c) 2016 Integrated Systems Laboratory, ETH Zurich.  This is free software under the
 * terms of the GNU General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.  This software is distributed
 * without any warranty; without even the implied warranty of merchantability or fitness for
 * a particular purpose.
 *
 * Current Maintainers:
 * - Andreas Kurth  <akurth@iis.ee.ethz.ch>
 * - Pirmin Vogel   <vogelpi@iis.ee.ethz.ch>
 */

module AxiToAxiLitePc

  // Parameters {{{
  #(
    parameter AXI_ADDR_WIDTH  = 32,
    parameter AXI_ID_WIDTH    = 10
  )
  // }}}

  // Ports {{{
  (

    input  logic    Clk_CI,
    input  logic    Rst_RBI,

    AXI_BUS.Slave   Axi_PS,
    AXI_LITE.Master AxiLite_PM

  );
  // }}}

  // Signal Declarations {{{
  logic   [AXI_ID_WIDTH-1:0]  ArId_DN,    ArId_DP;
  logic [AXI_ADDR_WIDTH-1:0]  AwAddr_DN,  AwAddr_DP;
  logic   [AXI_ID_WIDTH-1:0]  AwId_DN,    AwId_DP;
  logic                       AwValid_DN, AwValid_DP;
  // }}}

  // Register AW channel for compatibility with Xilinx AXI Lite slaves. {{{
  // This is necessary because Xilinx AXI Lite slaves want the AW and W channels simultaneously.
  always_comb begin
    if (Axi_PS.aw_valid | Axi_PS.w_ready) begin
      AwValid_DN = Axi_PS.aw_valid & !Axi_PS.w_ready;
    end
    else begin
      AwValid_DN = AwValid_DP;
    end
  end
  assign AwAddr_DN = Axi_PS.aw_valid ? Axi_PS.aw_addr : AwAddr_DP;
  // }}}

  // Register IDs for reflection. {{{
  assign AwId_DN = Axi_PS.aw_valid ? Axi_PS.aw_id : AwId_DP;
  assign ArId_DN = Axi_PS.ar_valid ? Axi_PS.ar_id : ArId_DP;
  // }}}

  // Drive outputs of AXI Lite interface. {{{

  assign AxiLite_PM.aw_addr   = AwAddr_DP;
  assign AxiLite_PM.aw_valid  = Axi_PS.w_valid & AwValid_DP;

  assign AxiLite_PM.w_data    = Axi_PS.w_data;
  assign AxiLite_PM.w_valid   = Axi_PS.w_valid & AwValid_DP;
  assign AxiLite_PM.w_strb    = Axi_PS.w_strb;

  assign AxiLite_PM.b_ready   = Axi_PS.b_ready;

  assign AxiLite_PM.ar_addr   = Axi_PS.ar_addr;
  assign AxiLite_PM.ar_valid  = Axi_PS.ar_valid;

  assign AxiLite_PM.r_ready   = Axi_PS.r_ready;

  // }}}

  // Drive outputs of AXI interface. {{{

  assign Axi_PS.aw_ready = AwValid_DP & Axi_PS.aw_valid;

  assign Axi_PS.w_ready  = AxiLite_PM.w_ready;

  assign Axi_PS.ar_ready = AxiLite_PM.ar_ready;

  assign Axi_PS.r_valid  = AxiLite_PM.r_valid;
  assign Axi_PS.r_data   = AxiLite_PM.r_data;
  assign Axi_PS.r_resp   = AxiLite_PM.r_resp;
  assign Axi_PS.r_last   = AxiLite_PM.r_valid ? 'b1      : 'b0;
  assign Axi_PS.r_id     = AxiLite_PM.r_valid ? ArId_DP  : 'b0;
  assign Axi_PS.r_user   = 'b0;

  assign Axi_PS.b_valid  = AxiLite_PM.b_valid;
  assign Axi_PS.b_resp   = AxiLite_PM.b_resp;
  assign Axi_PS.b_id     = AxiLite_PM.b_valid ? AwId_DP  : 'b0;
  assign Axi_PS.b_user   = 'b0;

  // }}}

  // Flip-Flops {{{
  always_ff @ (posedge Clk_CI)
  begin
    ArId_DP     <= 'b0;
    AwAddr_DP   <= 'b0;
    AwId_DP     <= 'b0;
    AwValid_DP  <= 'b0;
    if (Rst_RBI) begin
      ArId_DP     <= ArId_DN;
      AwAddr_DP   <= AwAddr_DN;
      AwId_DP     <= AwId_DN;
      AwValid_DP  <= AwValid_DN;
    end
  end
  // }}}

endmodule

// vim: nosmartindent autoindent foldmethod=marker
