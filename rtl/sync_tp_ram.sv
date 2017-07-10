///////////////////////////////////////////////////////////////////////////////
// Title        :  sync_tp_ram
// Project      :  PULP & co.
// Purpose      :  inferrable synchronous two port RAM for FPGAs
// Author       :  Michael Schaffner (schaffner@iis.ee.ethz.ch)
///////////////////////////////////////////////////////////////////////////////
// Major Changes:
// Date        |  Author     |  Description
// 2014/01/23  |  schaffner  |  created
///////////////////////////////////////////////////////////////////////////////
// Description: 
//
// Inferrable, synchronous two port RAM with read-before-write behavior. 
// Works with XILINX and ALTERA tools.
//
// 
// See also:  - XILINX ug901 Vivado Design Suite User Guide: Synthesis (p. 106) 
//            - ALTERA Quartus II Handbook Volume 1: Design and Synthesis (p. 768)
//
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016 Integrated Systems Lab ETH Zurich
///////////////////////////////////////////////////////////////////////////////

module sync_tp_ram
#(
  parameter ADDR_WIDTH = 10,
  parameter DATA_DEPTH = 1024, // usually 2**ADDR_WIDTH, but can be lower
  parameter DATA_WIDTH = 32,
  parameter OUT_REGS   = 0
) (
    input  logic                    Clk_CI,
    input  logic                    Rst_RBI,
    input  logic                    WrEn_SI,
    input  logic [ADDR_WIDTH-1:0]   WrAddr_DI,
    input  logic [DATA_WIDTH-1:0]   WrData_DI,
    input  logic                    RdEn_SI,
    input  logic [ADDR_WIDTH-1:0]   RdAddr_DI,
    output logic [DATA_WIDTH-1:0]   RdData_DO
);

    ////////////////////////////
    // signals, localparams
    ////////////////////////////

    logic [DATA_WIDTH-1:0] RdData_DN;
    logic [DATA_WIDTH-1:0] RdData_DP;
    logic [DATA_WIDTH-1:0] Mem_DP [DATA_DEPTH-1:0];

    ////////////////////////////
    // XILINX/ALTERA implementation
    ////////////////////////////
    
    always_ff @(posedge Clk_CI) 
    begin
        if (RdEn_SI) begin
            RdData_DN <= Mem_DP[RdAddr_DI];
        end    
        if (WrEn_SI) begin
            Mem_DP[WrAddr_DI] <= WrData_DI;
        end
    end
        
    ////////////////////////////
    // optional output regs
    ////////////////////////////

    // output regs
    generate 
        if (OUT_REGS>0) begin : g_outreg
            always_ff @(posedge Clk_CI or negedge Rst_RBI) begin
                if(Rst_RBI == 1'b0)
                begin
                    RdData_DP  <= 0;
                end
                else
                begin
                    RdData_DP  <= RdData_DN;
                end    
            end
        end    
    endgenerate // g_outreg

    // output reg bypass
    generate 
        if (OUT_REGS==0) begin : g_oureg_byp
            assign RdData_DP  = RdData_DN;
        end
    endgenerate// g_oureg_byp

    assign RdData_DO = RdData_DP;

    ////////////////////////////
    // assertions
    ////////////////////////////

    // pragma translate_off
    assert property (@(posedge Clk_CI) (longint'(2)**longint'(ADDR_WIDTH) >= longint'(DATA_DEPTH))) else $error("depth out of bounds");
    // pragma translate_on
    
endmodule // sync_tp_ram
