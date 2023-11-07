//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_f5cc_wrapper.bd
//Design : bd_f5cc_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_f5cc_wrapper
   (SLOT_0_AXIS_tdata,
    SLOT_0_AXIS_tkeep,
    SLOT_0_AXIS_tlast,
    SLOT_0_AXIS_tready,
    SLOT_0_AXIS_tuser,
    SLOT_0_AXIS_tvalid,
    SLOT_1_AXI_araddr,
    SLOT_1_AXI_arburst,
    SLOT_1_AXI_arcache,
    SLOT_1_AXI_arid,
    SLOT_1_AXI_arlen,
    SLOT_1_AXI_arlock,
    SLOT_1_AXI_arprot,
    SLOT_1_AXI_arqos,
    SLOT_1_AXI_arready,
    SLOT_1_AXI_arsize,
    SLOT_1_AXI_arvalid,
    SLOT_1_AXI_awaddr,
    SLOT_1_AXI_awburst,
    SLOT_1_AXI_awcache,
    SLOT_1_AXI_awid,
    SLOT_1_AXI_awlen,
    SLOT_1_AXI_awlock,
    SLOT_1_AXI_awprot,
    SLOT_1_AXI_awqos,
    SLOT_1_AXI_awready,
    SLOT_1_AXI_awsize,
    SLOT_1_AXI_awvalid,
    SLOT_1_AXI_bid,
    SLOT_1_AXI_bready,
    SLOT_1_AXI_bresp,
    SLOT_1_AXI_bvalid,
    SLOT_1_AXI_rdata,
    SLOT_1_AXI_rid,
    SLOT_1_AXI_rlast,
    SLOT_1_AXI_rready,
    SLOT_1_AXI_rresp,
    SLOT_1_AXI_rvalid,
    SLOT_1_AXI_wdata,
    SLOT_1_AXI_wlast,
    SLOT_1_AXI_wready,
    SLOT_1_AXI_wstrb,
    SLOT_1_AXI_wvalid,
    clk,
    probe0,
    probe1,
    probe2,
    resetn);
  input [511:0]SLOT_0_AXIS_tdata;
  input [63:0]SLOT_0_AXIS_tkeep;
  input SLOT_0_AXIS_tlast;
  input SLOT_0_AXIS_tready;
  input [0:0]SLOT_0_AXIS_tuser;
  input SLOT_0_AXIS_tvalid;
  input [63:0]SLOT_1_AXI_araddr;
  input [1:0]SLOT_1_AXI_arburst;
  input [3:0]SLOT_1_AXI_arcache;
  input [3:0]SLOT_1_AXI_arid;
  input [7:0]SLOT_1_AXI_arlen;
  input [0:0]SLOT_1_AXI_arlock;
  input [2:0]SLOT_1_AXI_arprot;
  input [3:0]SLOT_1_AXI_arqos;
  input SLOT_1_AXI_arready;
  input [2:0]SLOT_1_AXI_arsize;
  input SLOT_1_AXI_arvalid;
  input [63:0]SLOT_1_AXI_awaddr;
  input [1:0]SLOT_1_AXI_awburst;
  input [3:0]SLOT_1_AXI_awcache;
  input [3:0]SLOT_1_AXI_awid;
  input [7:0]SLOT_1_AXI_awlen;
  input [0:0]SLOT_1_AXI_awlock;
  input [2:0]SLOT_1_AXI_awprot;
  input [3:0]SLOT_1_AXI_awqos;
  input SLOT_1_AXI_awready;
  input [2:0]SLOT_1_AXI_awsize;
  input SLOT_1_AXI_awvalid;
  input [3:0]SLOT_1_AXI_bid;
  input SLOT_1_AXI_bready;
  input [1:0]SLOT_1_AXI_bresp;
  input SLOT_1_AXI_bvalid;
  input [511:0]SLOT_1_AXI_rdata;
  input [3:0]SLOT_1_AXI_rid;
  input SLOT_1_AXI_rlast;
  input SLOT_1_AXI_rready;
  input [1:0]SLOT_1_AXI_rresp;
  input SLOT_1_AXI_rvalid;
  input [511:0]SLOT_1_AXI_wdata;
  input SLOT_1_AXI_wlast;
  input SLOT_1_AXI_wready;
  input [63:0]SLOT_1_AXI_wstrb;
  input SLOT_1_AXI_wvalid;
  input clk;
  input [7:0]probe0;
  input [0:0]probe1;
  input [0:0]probe2;
  input resetn;

  wire [511:0]SLOT_0_AXIS_tdata;
  wire [63:0]SLOT_0_AXIS_tkeep;
  wire SLOT_0_AXIS_tlast;
  wire SLOT_0_AXIS_tready;
  wire [0:0]SLOT_0_AXIS_tuser;
  wire SLOT_0_AXIS_tvalid;
  wire [63:0]SLOT_1_AXI_araddr;
  wire [1:0]SLOT_1_AXI_arburst;
  wire [3:0]SLOT_1_AXI_arcache;
  wire [3:0]SLOT_1_AXI_arid;
  wire [7:0]SLOT_1_AXI_arlen;
  wire [0:0]SLOT_1_AXI_arlock;
  wire [2:0]SLOT_1_AXI_arprot;
  wire [3:0]SLOT_1_AXI_arqos;
  wire SLOT_1_AXI_arready;
  wire [2:0]SLOT_1_AXI_arsize;
  wire SLOT_1_AXI_arvalid;
  wire [63:0]SLOT_1_AXI_awaddr;
  wire [1:0]SLOT_1_AXI_awburst;
  wire [3:0]SLOT_1_AXI_awcache;
  wire [3:0]SLOT_1_AXI_awid;
  wire [7:0]SLOT_1_AXI_awlen;
  wire [0:0]SLOT_1_AXI_awlock;
  wire [2:0]SLOT_1_AXI_awprot;
  wire [3:0]SLOT_1_AXI_awqos;
  wire SLOT_1_AXI_awready;
  wire [2:0]SLOT_1_AXI_awsize;
  wire SLOT_1_AXI_awvalid;
  wire [3:0]SLOT_1_AXI_bid;
  wire SLOT_1_AXI_bready;
  wire [1:0]SLOT_1_AXI_bresp;
  wire SLOT_1_AXI_bvalid;
  wire [511:0]SLOT_1_AXI_rdata;
  wire [3:0]SLOT_1_AXI_rid;
  wire SLOT_1_AXI_rlast;
  wire SLOT_1_AXI_rready;
  wire [1:0]SLOT_1_AXI_rresp;
  wire SLOT_1_AXI_rvalid;
  wire [511:0]SLOT_1_AXI_wdata;
  wire SLOT_1_AXI_wlast;
  wire SLOT_1_AXI_wready;
  wire [63:0]SLOT_1_AXI_wstrb;
  wire SLOT_1_AXI_wvalid;
  wire clk;
  wire [7:0]probe0;
  wire [0:0]probe1;
  wire [0:0]probe2;
  wire resetn;

  bd_f5cc bd_f5cc_i
       (.SLOT_0_AXIS_tdata(SLOT_0_AXIS_tdata),
        .SLOT_0_AXIS_tkeep(SLOT_0_AXIS_tkeep),
        .SLOT_0_AXIS_tlast(SLOT_0_AXIS_tlast),
        .SLOT_0_AXIS_tready(SLOT_0_AXIS_tready),
        .SLOT_0_AXIS_tuser(SLOT_0_AXIS_tuser),
        .SLOT_0_AXIS_tvalid(SLOT_0_AXIS_tvalid),
        .SLOT_1_AXI_araddr(SLOT_1_AXI_araddr),
        .SLOT_1_AXI_arburst(SLOT_1_AXI_arburst),
        .SLOT_1_AXI_arcache(SLOT_1_AXI_arcache),
        .SLOT_1_AXI_arid(SLOT_1_AXI_arid),
        .SLOT_1_AXI_arlen(SLOT_1_AXI_arlen),
        .SLOT_1_AXI_arlock(SLOT_1_AXI_arlock),
        .SLOT_1_AXI_arprot(SLOT_1_AXI_arprot),
        .SLOT_1_AXI_arqos(SLOT_1_AXI_arqos),
        .SLOT_1_AXI_arready(SLOT_1_AXI_arready),
        .SLOT_1_AXI_arsize(SLOT_1_AXI_arsize),
        .SLOT_1_AXI_arvalid(SLOT_1_AXI_arvalid),
        .SLOT_1_AXI_awaddr(SLOT_1_AXI_awaddr),
        .SLOT_1_AXI_awburst(SLOT_1_AXI_awburst),
        .SLOT_1_AXI_awcache(SLOT_1_AXI_awcache),
        .SLOT_1_AXI_awid(SLOT_1_AXI_awid),
        .SLOT_1_AXI_awlen(SLOT_1_AXI_awlen),
        .SLOT_1_AXI_awlock(SLOT_1_AXI_awlock),
        .SLOT_1_AXI_awprot(SLOT_1_AXI_awprot),
        .SLOT_1_AXI_awqos(SLOT_1_AXI_awqos),
        .SLOT_1_AXI_awready(SLOT_1_AXI_awready),
        .SLOT_1_AXI_awsize(SLOT_1_AXI_awsize),
        .SLOT_1_AXI_awvalid(SLOT_1_AXI_awvalid),
        .SLOT_1_AXI_bid(SLOT_1_AXI_bid),
        .SLOT_1_AXI_bready(SLOT_1_AXI_bready),
        .SLOT_1_AXI_bresp(SLOT_1_AXI_bresp),
        .SLOT_1_AXI_bvalid(SLOT_1_AXI_bvalid),
        .SLOT_1_AXI_rdata(SLOT_1_AXI_rdata),
        .SLOT_1_AXI_rid(SLOT_1_AXI_rid),
        .SLOT_1_AXI_rlast(SLOT_1_AXI_rlast),
        .SLOT_1_AXI_rready(SLOT_1_AXI_rready),
        .SLOT_1_AXI_rresp(SLOT_1_AXI_rresp),
        .SLOT_1_AXI_rvalid(SLOT_1_AXI_rvalid),
        .SLOT_1_AXI_wdata(SLOT_1_AXI_wdata),
        .SLOT_1_AXI_wlast(SLOT_1_AXI_wlast),
        .SLOT_1_AXI_wready(SLOT_1_AXI_wready),
        .SLOT_1_AXI_wstrb(SLOT_1_AXI_wstrb),
        .SLOT_1_AXI_wvalid(SLOT_1_AXI_wvalid),
        .clk(clk),
        .probe0(probe0),
        .probe1(probe1),
        .probe2(probe2),
        .resetn(resetn));
endmodule
