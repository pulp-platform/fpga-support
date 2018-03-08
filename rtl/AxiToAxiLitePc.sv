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
 * Copyright (c) 2016 ETH Zurich and University of Bologna.  All rights reserved.
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

  enum logic {RREADY, READ}   StateRead_SP,   StateRead_SN;
  enum logic [1:0] {WREADY, WRITE, WRESP}
                              StateWrite_SP,  StateWrite_SN;
  // }}}

  // FSM to Control Handshaking Outputs for Write Channel and AW Latching. {{{
  always_comb begin
    // Default Assignments
    AwAddr_DN           = AwAddr_DP;
    AwId_DN             = AwId_DP;
    Axi_PS.aw_ready     = 1'b0;
    Axi_PS.w_ready      = 1'b0;
    AxiLite_PM.aw_valid = 1'b0;
    AxiLite_PM.w_valid  = 1'b0;
    StateWrite_SN       = StateWrite_SP;

    case (StateWrite_SP)

      WREADY: begin // Wait for aw_valid, latch address on encountering.
        if (Axi_PS.aw_valid) begin
          Axi_PS.aw_ready   = 1'b1;
          AwAddr_DN         = Axi_PS.aw_addr;
          AwId_DN           = Axi_PS.aw_id;
          StateWrite_SN     = WRITE;
        end
      end

      WRITE: begin // Wait for w_valid, forward address and data on encountering.
        if (Axi_PS.w_valid) begin
          AxiLite_PM.aw_valid = 1'b1;
          AxiLite_PM.w_valid  = 1'b1;

          if (AxiLite_PM.w_ready && AxiLite_PM.aw_ready) begin // Do the write
            Axi_PS.w_ready = 1'b1;
            StateWrite_SN  = WRESP;
          end
        end
      end

      WRESP: begin
        // b_valid and b_ready can be connected permanently.
        if (Axi_PS.b_ready && AxiLite_PM.b_valid) begin
          StateWrite_SN = WREADY;
        end
      end

      default: begin
        StateWrite_SN = WREADY;
      end

    endcase
  end
  // }}}

  // FSM to Control Handshaking Outputs for Read Channel and AR ID Latching. {{{
  always_comb begin
    // Default Assignments
    ArId_DN             = ArId_DP;
    Axi_PS.ar_ready     = 0'b0;
    Axi_PS.r_valid      = 0'b0;
    AxiLite_PM.ar_valid = 0'b0;
    StateRead_SN        = StateRead_SP;

    case (StateRead_SP)

      RREADY: begin // Wait for ar_valid, latch ID on encountering.
        AxiLite_PM.ar_valid = Axi_PS.ar_valid;
        if (Axi_PS.ar_valid && AxiLite_PM.ar_ready) begin
          Axi_PS.ar_ready = 1'b1;
          ArId_DN         = Axi_PS.ar_id;
          StateRead_SN    = READ;
        end
      end

      READ: begin // Wait for r_valid, forward on encountering.
        if (AxiLite_PM.r_valid) begin
          Axi_PS.r_valid = 1'b1;
          if (Axi_PS.r_ready) begin
            StateRead_SN = RREADY;
          end
        end
      end

      default: begin
        StateRead_SN = RREADY;
      end

    endcase
  end
  // }}}

  // Drive outputs of AXI Lite interface. {{{

  assign AxiLite_PM.aw_addr   = AwAddr_DP;

  assign AxiLite_PM.w_data    = Axi_PS.w_data;
  assign AxiLite_PM.w_strb    = Axi_PS.w_strb;

  assign AxiLite_PM.b_ready   = Axi_PS.b_ready;

  assign AxiLite_PM.ar_addr   = Axi_PS.ar_addr;

  assign AxiLite_PM.r_ready   = Axi_PS.r_ready;

  // }}}

  // Drive outputs of AXI interface. {{{

  assign Axi_PS.r_data   = AxiLite_PM.r_data;
  assign Axi_PS.r_resp   = AxiLite_PM.r_resp;
  assign Axi_PS.r_last   = AxiLite_PM.r_valid ? 'b1 : 'b0;
  assign Axi_PS.r_id     = ArId_DP;
  assign Axi_PS.r_user   = 'b0;

  assign Axi_PS.b_valid  = AxiLite_PM.b_valid;
  assign Axi_PS.b_resp   = AxiLite_PM.b_resp;
  assign Axi_PS.b_id     = AwId_DP;
  assign Axi_PS.b_user   = 'b0;

  // }}}

  // Flip-Flops {{{
  always_ff @ (posedge Clk_CI)
  begin
    ArId_DP       <= 'b0;
    AwAddr_DP     <= 'b0;
    AwId_DP       <= 'b0;
    AwValid_DP    <= 'b0;
    StateRead_SP  <= RREADY;
    StateWrite_SP <= WREADY;
    if (Rst_RBI) begin
      ArId_DP       <= ArId_DN;
      AwAddr_DP     <= AwAddr_DN;
      AwId_DP       <= AwId_DN;
      AwValid_DP    <= AwValid_DN;
      StateRead_SP  <= StateRead_SN;
      StateWrite_SP <= StateWrite_SN;
    end
  end
  // }}}

endmodule

// vim: nosmartindent autoindent foldmethod=marker
