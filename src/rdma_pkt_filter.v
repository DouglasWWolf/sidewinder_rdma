//===================================================================================================
//                            ------->  Revision History  <------
//===================================================================================================
//
//   Date     Who   Ver  Changes
//===================================================================================================
// 11-Nov-23  DWW     1  Initial creation
//===================================================================================================

/*


    This module receives packets on an AXI-Stream bus and throws away any packet
    that isn't an RDMA packet.   Valid RDMA packets are passed on to the output.
 

*/

module rdma_pkt_filter #
(
    parameter DATA_WBITS         = 512,
    parameter DATA_WBYTS         = (DATA_WBITS / 8),
    parameter LOCAL_SERVER_PORT  = 111111,

    // <<< This must match REMOTE_SERVER_PORT in rdma_xmit.v !! >>>
    parameter REMOTE_SERVER_PORT = 32002    
)
(
    input wire  clk, resetn,

    //==========================================================================
    //                     AXI Stream for incoming RDMA packets
    //==========================================================================
    input[DATA_WBITS-1:0]  AXIS_IN_TDATA,
    input[DATA_WBYTS-1:0]  AXIS_IN_TKEEP,
    input                  AXIS_IN_TVALID,
    input                  AXIS_IN_TLAST,
    output                 AXIS_IN_TREADY,
    //==========================================================================


    //==========================================================================
    //                     AXI Stream for incoming RDMA packets
    //==========================================================================
    output[DATA_WBITS-1:0] AXIS_OUT_TDATA,
    output[DATA_WBYTS-1:0] AXIS_OUT_TKEEP,
    output                 AXIS_OUT_TVALID,
    output                 AXIS_OUT_TLAST,
    input                  AXIS_OUT_TREADY
    //==========================================================================

);

// This is the magic number for an RDMA packet
localparam RDMA_MAGIC = 16'h0122;

// The entire output stream (other than TVALID) is driven by the input stream
assign AXIS_OUT_TDATA = AXIS_IN_TDATA;
assign AXIS_OUT_TKEEP = AXIS_IN_TKEEP;
assign AXIS_OUT_TLAST = AXIS_IN_TLAST;
assign AXIS_IN_TREADY = AXIS_OUT_TREADY;

// The state of the input state-machine
reg[1:0] ism_state;

// These are the possible states of ism_state
localparam ISM_STARTING     = 0;
localparam ISM_WAIT_FOR_HDR = 1;
localparam ISM_XFER_PACKET  = 2;

// AXIS_IN_TDATA comes to us in little-endian order.  Create a byte-swapped version of it
// so we can easily break out the fields of the header in big-endian
wire[DATA_WBITS-1:0] AXIS_IN_TDATA_swapped;
genvar i;
for (i=0; i<DATA_WBYTS; i=i+1) begin
    assign AXIS_IN_TDATA_swapped[i*8 +:8] = AXIS_IN_TDATA[(DATA_WBYTS-1-i)*8 +:8];
end 

// These are the fields that comprise an RDMA packet header
wire[ 6 *8-1:0] eth_dst_mac, eth_src_mac;
wire[ 2 *8-1:0] eth_frame_type;
wire[ 2 *8-1:0] ip4_ver_dsf, ip4_length, ip4_id, ip4_flags, ip4_ttl_prot, ip4_checksum;
wire[ 2 *8-1:0] ip4_srcip_h, ip4_srcip_l, ip4_dstip_h, ip4_dstip_l;
wire[ 2 *8-1:0] udp_src_port, udp_dst_port, udp_length, udp_checksum;
wire[ 2 *8-1:0] rdma_magic;
wire[ 8 *8-1:0] rdma_target_addr;
wire[12 *8-1:0] rdma_reserved;

// This is the 64-byte packet header for an RDMA packet.  This is an ordinary UDP packet
// with 22 bytes of RDMA header fields appended
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
    rdma_magic,
    rdma_target_addr,
    rdma_reserved

} = AXIS_IN_TDATA_swapped;

// The first cycle of a packet is considered an RDMA packet if the protocol is
// UDP (i.e., 17) and the port number is one of the RDMA UDP port numbers
wire is_rdma_imm = (ip4_ttl_prot[7:0] == 17)
                 & (udp_dst_port      == LOCAL_SERVER_PORT || udp_dst_port == REMOTE_SERVER_PORT)
                 & (rdma_magic        == RDMA_MAGIC);
reg  is_rdma_reg;

// This will be high on any data-cycle of an RDMA packet
wire is_rdma = ((ism_state == ISM_WAIT_FOR_HDR) & is_rdma_imm)
             | ((ism_state == ISM_XFER_PACKET ) & is_rdma_reg);

// AXIS_OUT_TVALID is gated by "is_rdma".   When "is_rdma" is low, TVALID can 
// never go high.
assign AXIS_OUT_TVALID = (AXIS_IN_TVALID & is_rdma);

//====================================================================================
// The input state-machine: reads incoming packets and passes them to the output
// only if we think they are RDMA packets
//====================================================================================
always @(posedge clk) begin
    if (resetn == 0) begin
        ism_state <= ISM_STARTING;

    end else case (ism_state)

        // Here we're just coming out of reset
        ISM_STARTING: 
            begin
                ism_state <= ISM_WAIT_FOR_HDR;
            end

        // Wait for a packet header to arrive
        ISM_WAIT_FOR_HDR:
            if (AXIS_IN_TREADY & AXIS_IN_TVALID) begin
                is_rdma_reg <= is_rdma_imm;
                if (AXIS_IN_TLAST == 0) ism_state <= ISM_XFER_PACKET;
            end

        // Here we transfer the rest of the packet
        ISM_XFER_PACKET:
            if (AXIS_IN_TREADY & AXIS_IN_TVALID & AXIS_IN_TLAST) begin
                ism_state <= ISM_WAIT_FOR_HDR;
            end

    endcase
end
//====================================================================================


endmodule
