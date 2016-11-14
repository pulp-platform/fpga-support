/**
 * BRAM Data Width Converter
 *
 * This module performs data width conversion between a narrow master and a wide slave interface.
 *
 * Port Description:
 *  FromMaster_PS   Slave BRAM Port interface through which master control signals go to the BRAM.
 *  ToSlave_PM      Master BRAM Port interface at which the slave BRAM is connected.
 *
 * The data signal of the master interface must be narrower than that of the slave interface.  The
 * reverse situation would require handshaking and buffering and is not supported by the simple BRAM
 * Port interface.
 *
 * Parameter Description:
 *  ADDR_BITW       The width (in bits) of the address signals.  Both ports must have the same
 *                  address width.
 *  MST_DATA_BITW   The width (in bits) of the data signal coming from the master controller.
 *  SLV_DATA_BITW   The width (in bits) of the data signal of the slave BRAM.
 *
 *  The value of all parameters must match the connected interfaces.  DO NOT rely on the default
 *  values for these parameters, but explicitly set the parameters so that they are correct for your
 *  setup!  If one or more values do not match, the behavior of this module is undefined.
 *
 * Compatibility Information:
 *  ModelSim    >= 10.0b
 *  Vivado      >= 2016.1
 *
 *  Earlier versions of the tools are either untested or known to fail for this module.
 *
 * Copyright (c) 2016 Integrated Systems Laboratory, ETH Zurich.  This is free software under the
 * terms of the GNU General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.  This software is distributed
 * without any warranty; without even the implied warranty of merchantability or fitness for
 * a particular purpose.
 *
 * Current Maintainers:
 * - Andreas Kurth  <andkurt@ee.ethz.ch>
 * - Pirmin Vogel   <vogelpi@iis.ee.ethz.ch>
 */

import CfMath::ceil_div, CfMath::log2;

module BramDwc

  // Parameters {{{
  #(
    parameter integer ADDR_BITW     = 32,
    parameter integer MST_DATA_BITW = 32,
    parameter integer SLV_DATA_BITW = 96
  )
  // }}}

  // Ports {{{
  (
    BramPort    FromMaster_PS,
    BramPort    ToSlave_PM
  );
  // }}}

  // Module-Wide Constants {{{
  localparam integer  MST_DATA_BYTEW      = MST_DATA_BITW/8;
  localparam integer  MST_ADDR_WORD_BITO  = log2(MST_DATA_BYTEW);
  localparam integer  MST_ADDR_WORD_BITW  = ADDR_BITW - MST_ADDR_WORD_BITO;

  localparam integer  SLV_DATA_BYTEW      = SLV_DATA_BITW/8;
  localparam integer  SLV_ADDR_WORD_BITO  = log2(SLV_DATA_BYTEW);
  localparam integer  SLV_ADDR_WORD_BITW  = ADDR_BITW - SLV_ADDR_WORD_BITO;

  localparam integer  PAR_IDX_MAX_VAL     = ceil_div(SLV_DATA_BITW, MST_DATA_BITW) - 1;
  localparam integer  PAR_IDX_BITW        = log2(PAR_IDX_MAX_VAL+1);
  // }}}

  // Initial Assertions {{{
  initial begin
    assert (SLV_DATA_BITW >= MST_DATA_BITW)
      else $fatal(1, "Downconversion of the data bitwidth from master to slave is not possible!");
    assert (MST_DATA_BITW == FromMaster_PS.DATA_BITW)
      else $fatal(1, "Parameter for data width of master does not match connected interface!");
    assert (SLV_DATA_BITW == ToSlave_PM.DATA_BITW)
      else $fatal(1, "Parameter for data width of slave does not match connected interface!");
    assert ((ADDR_BITW == FromMaster_PS.ADDR_BITW) && (ADDR_BITW == ToSlave_PM.ADDR_BITW))
      else $fatal(1, "Parameter for address width does not match connected interfaces!");
  end
  // }}}

  // Pass clock, reset, and enable through. {{{
  assign ToSlave_PM.Clk_C = FromMaster_PS.Clk_C;
  assign ToSlave_PM.Rst_R = FromMaster_PS.Rst_R;
  assign ToSlave_PM.En_S  = FromMaster_PS.En_S;
  // }}}

  // Data Width Conversion {{{

  logic [MST_ADDR_WORD_BITW-1:0] MstWordAddr_S;
  assign MstWordAddr_S
      = FromMaster_PS.Addr_S[(MST_ADDR_WORD_BITW-1)+MST_ADDR_WORD_BITO:MST_ADDR_WORD_BITO];

  logic [SLV_ADDR_WORD_BITW-1:0] ToWordAddr_S;
  assign ToWordAddr_S = MstWordAddr_S / (PAR_IDX_MAX_VAL+1);

  always_comb begin
    ToSlave_PM.Addr_S = '0;
    ToSlave_PM.Addr_S[(SLV_ADDR_WORD_BITW-1)+SLV_ADDR_WORD_BITO:SLV_ADDR_WORD_BITO] = ToWordAddr_S;
  end

  logic [PAR_IDX_BITW-1:0] ParIdx_S;
  assign ParIdx_S = MstWordAddr_S % (PAR_IDX_MAX_VAL+1);

  logic [PAR_IDX_MAX_VAL:0] [MST_DATA_BITW-1:0]  Rd_D;
  genvar p;
  for (p = 0; p <= PAR_IDX_MAX_VAL; p++) begin
    localparam integer SLV_BYTE_LOW   = MST_DATA_BYTEW*p;
    localparam integer SLV_BYTE_HIGH  = SLV_BYTE_LOW + (MST_DATA_BYTEW-1);
    localparam integer SLV_BIT_LOW    = MST_DATA_BITW*p;
    localparam integer SLV_BIT_HIGH   = SLV_BIT_LOW + (MST_DATA_BITW-1);
    always_comb begin
      if (ParIdx_S == p) begin
        ToSlave_PM.WrEn_S[SLV_BYTE_HIGH:SLV_BYTE_LOW] = FromMaster_PS.WrEn_S;
      end else begin
        ToSlave_PM.WrEn_S[SLV_BYTE_HIGH:SLV_BYTE_LOW] = '0;
      end
    end
    assign Rd_D[p] = ToSlave_PM.Rd_D[SLV_BIT_HIGH:SLV_BIT_LOW];
    assign ToSlave_PM.Wr_D[SLV_BIT_HIGH:SLV_BIT_LOW] = FromMaster_PS.Wr_D;
  end
  assign FromMaster_PS.Rd_D = Rd_D[ParIdx_S];

  // }}}

endmodule

// vim: ts=2 sw=2 sts=2 et nosmartindent autoindent foldmethod=marker tw=100
