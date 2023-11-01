//===================================================================================================
//                            ------->  Revision History  <------
//===================================================================================================
//
//   Date     Who   Ver  Changes
//===================================================================================================
// 30-Oct-23  DWW     1  Initial creation
//===================================================================================================

/*

    This module receives RDMA packets on an AXI-Stream bus and performs the relevant AXI write
    transactions.

    And RDMA packet consists of a header that is one data-cycle wide (i.e., 64 bytes) followed
    by the data-cycles that comprise the outgoing W-channel on the M_AXI bus.

    The RDMA header contains the AXI target-address and burst-length of the write transaction.

*/

module rdma_recv #
(
    parameter integer AXI_DATA_WIDTH = 512,
    parameter integer AXI_ADDR_WIDTH = 64,
    parameter integer RDMA_HDR_LEN = (AXI_ADDR_WIDTH + 8)
)
(
    input wire  clk, resetn,

    //=================  This is the main AXI4-master interface  ================

    // "Specify write address"              -- Master --    -- Slave --
    output reg[AXI_ADDR_WIDTH-1:0]           M_AXI_AWADDR,
    output reg                               M_AXI_AWVALID,
    output reg[7:0]                          M_AXI_AWLEN,
    output[2:0]                              M_AXI_AWSIZE,
    output[3:0]                              M_AXI_AWID,
    output[1:0]                              M_AXI_AWBURST,
    output                                   M_AXI_AWLOCK,
    output[3:0]                              M_AXI_AWCACHE,
    output[3:0]                              M_AXI_AWQOS,
    output[2:0]                              M_AXI_AWPROT,

    input                                                   M_AXI_AWREADY,

    // "Write Data"                         -- Master --    -- Slave --
    output[AXI_DATA_WIDTH-1:0]               M_AXI_WDATA,
    output                                   M_AXI_WVALID,
    output[(AXI_DATA_WIDTH/8)-1:0]           M_AXI_WSTRB,
    output                                   M_AXI_WLAST,
    input                                                   M_AXI_WREADY,

    // "Send Write Response"                -- Master --    -- Slave --
    input[1:0]                                              M_AXI_BRESP,
    input                                                   M_AXI_BVALID,
    output                                  M_AXI_BREADY,

    // "Specify read address"               -- Master --    -- Slave --
    output[AXI_ADDR_WIDTH-1:0]              M_AXI_ARADDR,
    output                                  M_AXI_ARVALID,
    output[2:0]                             M_AXI_ARPROT,
    output                                  M_AXI_ARLOCK,
    output[3:0]                             M_AXI_ARID,
    output[7:0]                             M_AXI_ARLEN,
    output[1:0]                             M_AXI_ARBURST,
    output[3:0]                             M_AXI_ARCACHE,
    output[3:0]                             M_AXI_ARQOS,
    input                                                   M_AXI_ARREADY,

    // "Read data back to master"           -- Master --    -- Slave --
    input[AXI_DATA_WIDTH-1:0]                              M_AXI_RDATA,
    input                                                  M_AXI_RVALID,
    input[1:0]                                             M_AXI_RRESP,
    input                                                  M_AXI_RLAST,
    output                                  M_AXI_RREADY,
    //==========================================================================


    //==========================================================================
    //                     AXI Stream for incoming RDMA packets
    //==========================================================================
    input[AXI_DATA_WIDTH  -1:0] AXIS_RDMA_TDATA,
    input[AXI_DATA_WIDTH/8-1:0] AXIS_RDMA_TKEEP,
    input                       AXIS_RDMA_TVALID,
    input                       AXIS_RDMA_TLAST,
    output                      AXIS_RDMA_TREADY
    //==========================================================================

);

// The state of the input state-machine
reg[1:0] ism_state;

// These are the possible states of ism_state
localparam ISM_STARTING     = 0;
localparam ISM_WAIT_FOR_HDR = 1;
localparam ISM_XFER_PACKET  = 2;
localparam ISM_WAIT_FOR_AW  = 3;

// We're always ready to receive an AXI "write acknowledgement"
assign M_AXI_BREADY = 1;

// Set up constant fields in the AW channel
assign M_AXI_AWID    = 0;
assign M_AXI_AWSIZE  = $clog2(AXI_DATA_WIDTH / 8);
assign M_AXI_AWBURST = 1;       /* Burst type = Increment */
assign M_AXI_AWLOCK  = 0;       /* Not locked             */
assign M_AXI_AWCACHE = 0;       /* No caching             */
assign M_AXI_AWPROT  = 1;       /* Privileged Access      */
assign M_AXI_AWQOS   = 0;       /* No QoS                 */

// In state 2, the W channel is wired directly to the AXIS_RDMA input stream
assign M_AXI_WDATA  = (ism_state == ISM_XFER_PACKET) ? AXIS_RDMA_TDATA : 0;
assign M_AXI_WSTRB  = (ism_state == ISM_XFER_PACKET) ? AXIS_RDMA_TKEEP : 0;
assign M_AXI_WLAST  = (ism_state == ISM_XFER_PACKET) ? AXIS_RDMA_TLAST : 0;
assign M_AXI_WVALID = (ism_state == ISM_XFER_PACKET) & AXIS_RDMA_TVALID;

// We're ready to receive data on the RDMA stream:
//  (1) Whenever we're waiting for a packet header to arrive
//  (2) When we're transferring the packet and the slave is ready to receive
assign AXIS_RDMA_TREADY = (ism_state == ISM_WAIT_FOR_HDR) || (ism_state == ISM_XFER_PACKET && M_AXI_WREADY);

// This will tell us whether we've seen a handshake on the W-channel of M_AXI
wire aw_handshake = (M_AXI_AWVALID == 0) || (M_AXI_AWREADY == 1);

// Create a byte-swapped version of AXIS_RDMA_TDATA
wire[AXI_DATA_WIDTH-1:0] AXIS_RDMA_TDATA_swapped;
genvar i;
for (i=0; i<AXI_DATA_WIDTH/8; i=i+1) begin
    assign AXIS_RDMA_TDATA_swapped[i*8 +:8] = AXIS_RDMA_TDATA[(AXI_DATA_WIDTH/8-1-i)*8 +:8];
end 

// These are where these two fields live in the RDMA header
wire target_addr = AXIS_RDMA_TDATA_swapped[42*8 +: 64];
wire burst_len   = AXIS_RDMA_TDATA_swapped[50*8 +:  8];

always @(posedge clk) begin
    if (resetn == 0) begin
        ism_state  <= ISM_STARTING;

    end else case (ism_state)

        // Here we're just coming out of reset
        ISM_STARTING:
            begin
                ism_state <= ISM_WAIT_FOR_HDR;
            end

        // If we've received an RDMA header, write the appropriate data to the AXI AW channel...
        ISM_WAIT_FOR_HDR:
            if (AXIS_RDMA_TREADY & AXIS_RDMA_TVALID) begin
                M_AXI_AWADDR  <= target_addr;
                M_AXI_AWLEN   <= burst_len;
                M_AXI_AWVALID <= 1;
                ism_state     <= ISM_XFER_PACKET;
            end

        // Here, we're reading in data-beats from the stream and writing them to the W-channel of M_AXI
        ISM_XFER_PACKET:
            begin

                // Lower M_AXI_AWVALID if we see a handshake on that channel
                if (aw_handshake) M_AXI_AWVALID <= 0;

                // If the last beat of the packet has been exchanged, determine whether or not
                // we need to go wait for the AW channel handshake to occur
                if (M_AXI_WREADY & M_AXI_WVALID & M_AXI_WLAST) begin
                    ism_state = (aw_handshake) ? ISM_WAIT_FOR_HDR : ISM_WAIT_FOR_AW;
                end
            end

        // Here we're in the unusual situation of the entire packet data transfer occured, but
        // we're still waiting for the handshake on the AW channel
        ISM_WAIT_FOR_AW:
            if (aw_handshake) begin
                M_AXI_AWVALID <= 0;
                ism_state     <= ISM_WAIT_FOR_HDR;
            end
    endcase
end


endmodule