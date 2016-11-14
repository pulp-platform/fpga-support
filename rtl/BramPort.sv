/**
 * BRAM Port Interface
 *
 * This interface contains all signals required to connect a Block RAM.
 *
 * Parameter Description:
 *  DATA_BITW   Width of the data ports in bits.  Must be a multiple of 8.
 *  ADDR_BITW   Width of the address port in bits.  Must be a multiple of 8.
 *
 * Port Description:
 *  Clk_C   All operations on this interface are synchronous to this single-phase clock port.
 *  Rst_R   Synchronous reset for the output register/latch of the interface; does NOT reset the
 *          BRAM.  Note that this reset is active high.
 *  En_S    Enables read, write, and reset operations to through this interface.
 *  Addr_S  Byte-wise address for all operations on this interface.  Note that the word address
 *          offset varies with `DATA_BITW`!
 *  Rd_D    Data output for read operations on the BRAM.
 *  Wr_D    Data input for write operations on the BRAM.
 *  WrEn_S  Byte-wise write enable.
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

interface BramPort
  #(
    parameter DATA_BITW = 32,
    parameter ADDR_BITW = 32
  );

  logic                       Clk_C;
  logic                       Rst_R;
  logic                       En_S;
  logic  [ADDR_BITW-1:0]      Addr_S;
  logic  [DATA_BITW-1:0]      Rd_D;
  logic  [DATA_BITW-1:0]      Wr_D;
  logic  [(DATA_BITW/8)-1:0]  WrEn_S;

  modport Slave (
    input  Clk_C, Rst_R, En_S, Addr_S, Wr_D, WrEn_S,
    output Rd_D
  );

  modport Master (
    input  Rd_D,
    output Clk_C, Rst_R, En_S, Addr_S, Wr_D, WrEn_S
  );

endinterface

// vim: ts=2 sw=2 sts=2 et tw=100
