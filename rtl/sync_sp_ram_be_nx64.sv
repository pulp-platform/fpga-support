///////////////////////////////////////////////////////////////////////////////
// Title        :  sync_sp_ram_be_nx64
// Project      :  PULP & co.
// Purpose      :  inferrable synchronous single port RAM for FPGAs
// Author       :  Michael Schaffner (schaffner@iis.ee.ethz.ch)
///////////////////////////////////////////////////////////////////////////////
// Major Changes:
// Date        |  Author     |  Description
// 2014/01/23  |  schaffner  |  created
///////////////////////////////////////////////////////////////////////////////
// Description: 
//
// Inferrable, synchronous single port N x 64bit RAM with byte enables.
// Contains an implementation for XILINX and an implementation for ALTERA tools.
//
// Note: you have to define FPGA_TARGET_ALTERA or FPGA_TARGET_XILINX!
// 
// See also:  - XILINX ug901 Vivado Design Suite User Guide: Synthesis (p. 106) 
//            - ALTERA Quartus II Handbook Volume 1: Design and Synthesis (p. 768)
//
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016 Integrated Systems Lab ETH Zurich
///////////////////////////////////////////////////////////////////////////////

// `define FPGA_TARGET_XILINX

`ifndef FPGA_TARGET_XILINX
    `define FPGA_TARGET_ALTERA
`endif

module sync_sp_ram_be_nx64
#(
  parameter ADDR_WIDTH = 10,
  parameter DATA_DEPTH = 1024, // usually 2**ADDR_WIDTH, but can be lower
  parameter OUT_REGS   = 0     // set to 1 to enable outregs
) (
    input  logic                  Clk_CI,
    input  logic                  Rst_RBI,
    input  logic                  CSel_SI,
    input  logic                  WrEn_SI,
    input  logic [7:0]            BEn_SI,
    input  logic [63:0]           WrData_DI,
    input  logic [ADDR_WIDTH-1:0] Addr_DI,
    output logic [63:0]           RdData_DO
);

    ////////////////////////////
    // signals, localparams
    ////////////////////////////

    // needs to be consistent with the Altera implemenation below
    localparam DATA_BYTES = 8; 

    logic [DATA_BYTES*8-1:0] RdData_DN;
    logic [DATA_BYTES*8-1:0] RdData_DP;

    ////////////////////////////
    // XILINX implementation
    ////////////////////////////
    
    `ifdef FPGA_TARGET_XILINX
        logic [DATA_BYTES*8-1:0] Mem_DP[DATA_DEPTH-1:0];
    
        always_ff @(posedge Clk_CI) begin
            if(CSel_SI) begin
                if(WrEn_SI) begin
                    if(BEn_SI[0]) Mem_DP[Addr_DI][7:0]   <= WrData_DI[7:0];
                    if(BEn_SI[1]) Mem_DP[Addr_DI][15:8]  <= WrData_DI[15:8];
                    if(BEn_SI[2]) Mem_DP[Addr_DI][23:16] <= WrData_DI[23:16];
                    if(BEn_SI[3]) Mem_DP[Addr_DI][31:24] <= WrData_DI[31:24];
                    if(BEn_SI[4]) Mem_DP[Addr_DI][39:32] <= WrData_DI[39:32];
                    if(BEn_SI[5]) Mem_DP[Addr_DI][47:40] <= WrData_DI[47:40];
                    if(BEn_SI[6]) Mem_DP[Addr_DI][55:48] <= WrData_DI[55:48];
                    if(BEn_SI[7]) Mem_DP[Addr_DI][63:56] <= WrData_DI[63:56];
                end
                RdData_DN <= Mem_DP[Addr_DI];
            end    
        end
    `endif 
       
    ////////////////////////////
    // ALTERA implementation
    ////////////////////////////

    `ifdef FPGA_TARGET_ALTERA
        logic [DATA_BYTES-1:0][7:0] Mem_DP[0:DATA_DEPTH-1];

        always_ff @(posedge Clk_CI) begin
            if(CSel_SI) begin
                if(WrEn_SI) begin // needs to be static, otherwise Altera wont infer it
                    if(BEn_SI[0]) Mem_DP[Addr_DI][0] <= WrData_DI[7:0];
                    if(BEn_SI[1]) Mem_DP[Addr_DI][1] <= WrData_DI[15:8];
                    if(BEn_SI[2]) Mem_DP[Addr_DI][2] <= WrData_DI[23:16];
                    if(BEn_SI[3]) Mem_DP[Addr_DI][3] <= WrData_DI[31:24];
                    if(BEn_SI[4]) Mem_DP[Addr_DI][4] <= WrData_DI[39:32];
                    if(BEn_SI[5]) Mem_DP[Addr_DI][5] <= WrData_DI[47:40];
                    if(BEn_SI[6]) Mem_DP[Addr_DI][6] <= WrData_DI[55:48];
                    if(BEn_SI[7]) Mem_DP[Addr_DI][7] <= WrData_DI[63:56];
                end
                RdData_DN <= Mem_DP[Addr_DI];
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

    `ifndef FPGA_TARGET_XILINX
        `ifndef FPGA_TARGET_ALTERA
            $error("FPGA target not defined, define  FPGA_TARGET_XILINX or FPGA_TARGET_ALTERA.");
        `endif    
    `endif    
    
endmodule // sync_sp_ram_be_nx64
