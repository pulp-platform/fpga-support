///////////////////////////////////////////////////////////////////////////////
// Title        :  sync_dp_ram
// Project      :  PULP & co.
// Purpose      :  inferrable synchronous dual port RAM for FPGAs
// Author       :  Michael Schaffner (schaffner@iis.ee.ethz.ch)
///////////////////////////////////////////////////////////////////////////////
// Major Changes:
// Date        |  Author     |  Description
// 2014/01/23  |  schaffner  |  created
///////////////////////////////////////////////////////////////////////////////
// Description: 
//
// Inferrable, synchronous dual port RAM. Works with XILINX and ALTERA tools.
//
// 
// See also:  - XILINX ug901 Vivado Design Suite User Guide: Synthesis (p. 106) 
//            - ALTERA Quartus II Handbook Volume 1: Design and Synthesis (p. 768)
//
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016 Integrated Systems Lab ETH Zurich
///////////////////////////////////////////////////////////////////////////////

// this automatically switches the behavioral description
// synopsys translate_off
`define SIMULATION
// synopsys translate_on


module sync_dp_ram
#(
  parameter ADDR_WIDTH = 10,
  parameter DATA_DEPTH = 1024, // usually 2**ADDR_WIDTH, but can be lower
  parameter DATA_WIDTH = 32,
  parameter OUT_REGS   = 0
) (
    input  logic                  Clk_CI,
    input  logic                  Rst_RBI,
    // port A
    input  logic                  CSelA_SI,
    input  logic                  WrEnA_SI,
    input  logic [DATA_WIDTH-1:0] WrDataA_DI,
    input  logic [ADDR_WIDTH-1:0] AddrA_DI,
    output logic [DATA_WIDTH-1:0] RdDataA_DO,
    // port B
    input  logic                  CSelB_SI,
    input  logic                  WrEnB_SI,
    input  logic [DATA_WIDTH-1:0] WrDataB_DI,
    input  logic [ADDR_WIDTH-1:0] AddrB_DI,
    output logic [DATA_WIDTH-1:0] RdDataB_DO
);

    ////////////////////////////
    // signals, localparams
    ////////////////////////////

    logic [DATA_WIDTH-1:0] RdDataA_DN;
    logic [DATA_WIDTH-1:0] RdDataA_DP;
    logic [DATA_WIDTH-1:0] RdDataB_DN;
    logic [DATA_WIDTH-1:0] RdDataB_DP;
    logic [DATA_WIDTH-1:0] Mem_DP [DATA_DEPTH-1:0];

    ////////////////////////////
    // XILINX/ALTERA implementation
    ////////////////////////////
    
    `ifdef SIMULATION    
    always_ff @(posedge Clk_CI) 
    begin
        if (CSelA_SI) begin
            if (WrEnA_SI) begin
                Mem_DP[AddrA_DI] <= WrDataA_DI; 
                // RdDataA_DN       <= WrDataA_DI; 
            end
            else
            begin
                RdDataA_DN <= Mem_DP[AddrA_DI];
            end    
        end

        if (CSelB_SI) begin
            if (WrEnB_SI) begin
                Mem_DP[AddrB_DI] <= WrDataB_DI; 
                // RdDataB_DN       <= WrDataB_DI; 
            end
            else
            begin
                RdDataB_DN <= Mem_DP[AddrB_DI];
            end
        end
    end
    `endif    
    

    ////////////////////////////
    // XILINX/ALTERA implementation
    ////////////////////////////
    
    `ifndef SIMULATION    
    always_ff @(posedge Clk_CI) 
    begin
        if (CSelA_SI) begin
            if (WrEnA_SI) begin
                Mem_DP[AddrA_DI] <= WrDataA_DI; 
                // RdDataA_DN       <= WrDataA_DI; 
            end
            else
            begin
                RdDataA_DN <= Mem_DP[AddrA_DI];
            end    
        end
    end

    always_ff @(posedge Clk_CI) 
    begin
        if (CSelB_SI) begin
            if (WrEnB_SI) begin
                Mem_DP[AddrB_DI] <= WrDataB_DI; 
                // RdDataB_DN       <= WrDataB_DI; 
            end
            else
            begin
                RdDataB_DN <= Mem_DP[AddrB_DI];
            end
        end
    end
    `endif    

    ////////////////////////////
    // optional output regs
    ////////////////////////////

    // output regs
    generate 
        if (OUT_REGS>0) begin : g_outreg
            always_ff @(posedge Clk_CI or negedge Rst_RBI) begin
                if(Rst_RBI == 1'b0)
                begin
                    RdDataA_DP  <= 0;
                    RdDataB_DP  <= 0;
                end
                else
                begin
                    RdDataA_DP  <= RdDataA_DN;
                    RdDataB_DP  <= RdDataB_DN;
                end    
            end
        end    
    endgenerate // g_outreg

    // output reg bypass
    generate 
        if (OUT_REGS==0) begin : g_oureg_byp
            assign RdDataA_DP  = RdDataA_DN;
            assign RdDataB_DP  = RdDataB_DN;
        end
    endgenerate// g_oureg_byp

    assign RdDataA_DO = RdDataA_DP;
    assign RdDataB_DO = RdDataB_DP;

    ////////////////////////////
    // assertions
    ////////////////////////////

    // pragma translate_off
    assert property (@(posedge Clk_CI) (longint'(2)**longint'(ADDR_WIDTH) >= longint'(DATA_DEPTH))) else $error("depth out of bounds");
    assert property (@(posedge Clk_CI) (CSelA_SI & CSelB_SI & WrEnA_SI & WrEnB_SI) |-> (AddrA_DI != AddrB_DI)) else $error("A and B write to the same address");
    // pragma translate_on
    
endmodule // sync_dp_ram
