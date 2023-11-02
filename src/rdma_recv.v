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
    parameter integer DATA_WBITS = 512,
    parameter integer DATA_WBYTS = (DATA_WBITS / 8),
    parameter integer ADDR_WBITS = 64
)
(
    input wire  clk, resetn,

    output[DATA_WBITS-1:0] DBG_TDATA,
    output[1:0]            DBG_ism_state,

    //=================  This is the main AXI4-master interface  ================

    // "Specify write address"              -- Master --    -- Slave --
    output reg[ADDR_WBITS-1:0]               M_AXI_AWADDR,
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
    output[DATA_WBITS-1:0]                  M_AXI_WDATA,
    output[DATA_WBYTS-1:0]                  M_AXI_WSTRB,
    output                                  M_AXI_WVALID,
    output                                  M_AXI_WLAST,
    input                                                   M_AXI_WREADY,

    // "Send Write Response"                -- Master --    -- Slave --
    input[1:0]                                              M_AXI_BRESP,
    input                                                   M_AXI_BVALID,
    output                                  M_AXI_BREADY,

    // "Specify read address"               -- Master --    -- Slave --
    output[ADDR_WBITS-1:0]                  M_AXI_ARADDR,
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
    input[DATA_WBITS-1:0]                                   M_AXI_RDATA,
    input                                                   M_AXI_RVALID,
    input[1:0]                                              M_AXI_RRESP,
    input                                                   M_AXI_RLAST,
    output                                  M_AXI_RREADY,
    //==========================================================================


    //==========================================================================
    //                     AXI Stream for incoming RDMA packets
    //==========================================================================
    input[DATA_WBITS-1:0] AXIS_RDMA_TDATA,
    input[DATA_WBYTS-1:0] AXIS_RDMA_TKEEP,
    input                 AXIS_RDMA_TVALID,
    input                 AXIS_RDMA_TLAST,
    output                AXIS_RDMA_TREADY
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
assign M_AXI_AWSIZE  = $clog2(DATA_WBYTS);
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

// AXIS_RDMA_TDATA comes to us in little-endian order.  Create a byte-swapped version of it
// so we can easily break out the fields of the header in big-endian
wire[DATA_WBITS-1:0] AXIS_RDMA_TDATA_swapped;
genvar i;
for (i=0; i<DATA_WBYTS; i=i+1) begin
    assign AXIS_RDMA_TDATA_swapped[i*8 +:8] = AXIS_RDMA_TDATA[(DATA_WBYTS-1-i)*8 +:8];
end 

// These are the fields that comprise an RDMA packet header
wire[ 6 *8-1:0] eth_dst_mac, eth_src_mac;
wire[ 2 *8-1:0] eth_frame_type;
wire[ 2 *8-1:0] ip4_ver_dsf, ip4_length, ip4_id, ip4_flags, ip4_ttl_prot, ip4_checksum;
wire[ 2 *8-1:0] ip4_srcip_h, ip4_srcip_l, ip4_dstip_h, ip4_dstip_l;
wire[ 2 *8-1:0] udp_src_port, udp_dst_port, udp_length, udp_checksum;
wire[ 8 *8-1:0] target_addr;
wire[ 1 *8-1:0] burst_len;
wire[13 *8-1:0] reserved;

// This is the 64-byte packet header for an RDMA packet
assign
{

    // Ethernet header fields - 14 bytes
    eth_dst_mac,
    eth_src_mac,
    eth_frame_type,

    // IPv4 header fields - 20 bytes
    ip4_ver_dsf,
    ip4_length,
    ip4_id,
    ip4_flags,
    ip4_ttl_prot,
    ip4_checksum,
    ip4_srcip_h,
    ip4_srcip_l,
    ip4_dstip_h,
    ip4_dstip_l,

    // UDP header fields - 8 bytes
    udp_src_port,
    udp_dst_port,
    udp_length,
    udp_checksum,
    
    // RDMA header fields - 22 bytes
    target_addr,
    burst_len,
    reserved

} = AXIS_RDMA_TDATA_swapped;


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

assign DBG_TDATA     = AXIS_RDMA_TDATA_swapped;
assign DBG_ism_state = ism_state;

endmodule