/**
 * Clock and Reset Generator
 *
 * This module generates a single-phase clock and an active-low reset signal for a simulation
 * testbench.
 *
 * Parameter Description:
 *  CLK_LOW_TIME  Duration of the phase in which the clock is low.
 *  CLK_HIGH_TIME Duration of the phase in which the clock is high.
 *  RST_TIME      Interval at the beginning of the simulation during which the reset is active.
 *
 * Port Description:
 *  EndOfSim_SI   Stops the simulation clock in the next period.
 *  Clk_CO        Single-phase clock.
 *  Rst_RBO       Active-low reset.
 *
 * Copyright (c) 2016 Integrated Systems Laboratory, ETH Zurich.  This is free software under the
 * terms of the GNU General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.  This software is distributed
 * without any warranty; without even the implied warranty of merchantability or fitness for
 * a particular purpose.
 */

//timeunit 1ns;

module ClkRstGen

  // Parameters {{{
  #(
    parameter CLK_LOW_TIME  = 5ns,
    parameter CLK_HIGH_TIME = 5ns,
    parameter RST_TIME      = 100ns
  )
  // }}}

  // Ports {{{
  (
    input  logic  EndOfSim_SI,
    output logic  Clk_CO,
    output logic  Rst_RBO
  );
  // }}}

  // Module-Wide Constants {{{
  localparam time CLK_PERIOD  = CLK_LOW_TIME + CLK_HIGH_TIME;
  // }}}

  // Clock Generation {{{
  always begin
    Clk_CO  = 0;
    if (Rst_RBO) begin
      // Reset is inactive.
      if (~EndOfSim_SI) begin
        Clk_CO = 1;
        #CLK_HIGH_TIME;
        Clk_CO = 0;
        #CLK_LOW_TIME;
      end else begin
        $stop(0);
      end
    end else begin
      // Reset is still active, wait until the next clock period.
      #CLK_PERIOD;
    end
  end
  // }}}

  // Reset Generation {{{
  initial begin
    Rst_RBO = 0;
    #RST_TIME;
    Rst_RBO = 1;
  end
  // }}}

endmodule

// vim: ts=2 sw=2 sts=2 et nosmartindent autoindent foldmethod=marker tw=100
