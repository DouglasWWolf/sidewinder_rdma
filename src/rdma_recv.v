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
    parameter DATA_WBITS        = 512,
    parameter DATA_WBYTS        = (DATA_WBITS / 8),
    parameter ADDR_WBITS        = 64,
    parameter RDMA_HDR_BYTES    = 9,
    parameter PACKET_FIFO_DEPTH = 1024
)
(
    input wire  clk, resetn,

    output[7:0] DBG_new_awlen,

    //==========================================================================
    //                     AXI Stream for incoming RDMA packets
    //==========================================================================
    input[DATA_WBITS-1:0] AXIS_RDMA_TDATA,
    input[DATA_WBYTS-1:0] AXIS_RDMA_TKEEP,
    input                 AXIS_RDMA_TVALID,
    input                 AXIS_RDMA_TLAST,
    output                AXIS_RDMA_TREADY,
    //==========================================================================



    //=================  This is the main AXI4-master interface  ================

    // "Specify write address"              -- Master --    -- Slave --
    output[ADDR_WBITS-1:0]                   M_AXI_AWADDR,
    output                                   M_AXI_AWVALID,
    output[7:0]                              M_AXI_AWLEN,
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
    output                                  M_AXI_RREADY
    //==========================================================================


);

// The state of the input state-machine
reg[1:0] ism_state;

// These are the possible states of ism_state
localparam ISM_STARTING     = 0;
localparam ISM_WAIT_FOR_HDR = 1;
localparam ISM_XFER_PACKET  = 2;

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

// The "upd_length" field includes 8 bytes for the UDP header
localparam UDP_HDR_LEN  = 8;

// 22 bytes of the UDP packet data in an RDMA packet are RDMA header bytes
localparam RDMA_HDR_LEN = 22;

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
    target_addr,
    burst_len,
    reserved

} = AXIS_RDMA_TDATA_swapped;


// This is the AXI awlen value for the data packet
reg [7:0] awlen_reg;
wire[7:0] awlen_imm;
wire[7:0] awlen = (ism_state == ISM_WAIT_FOR_HDR) ? awlen_imm : awlen_reg;

// We will write an entry to the target-address FIFO when:
//     (1) We're waiting for an incoming RDMA packet header 
// and (2) We have a valid data-cycle incoming on the AXIS_RDMA bus 
wire ftain_tvalid = (ism_state == ISM_WAIT_FOR_HDR) & AXIS_RDMA_TREADY & AXIS_RDMA_TVALID;   
wire ftain_tready;


// We will write an entry to the packet-data FIFO when:
//     (1) We're waiting for an incoming RDMA packet data
// and (2) We have a valid data-cycle incoming on the AXIS_RDMA bus 
wire fpdin_tvalid = (ism_state == ISM_XFER_PACKET) & AXIS_RDMA_TREADY & AXIS_RDMA_TVALID;
wire fpdin_tready;

// We're ready to receive on the AXIS_RDMA interface:
//  (1) When waiting for a packet header, we're ready when the address FIFO is ready
//  (2) When waiting for packet data, we're ready when the data FIFO is ready
assign AXIS_RDMA_TREADY = (ism_state == ISM_WAIT_FOR_HDR) ? ftain_tready 
                        : (ism_state == ISM_XFER_PACKET ) ? fpdin_tready
                        : 0;





//====================================================================================
// This block computes the AXI AWLEN value for the packet by examining the
// "udp_length" field of the RDMA header.
//
// The proper AXI AWLEN value is stored in awlen_imm
//====================================================================================
reg[15:0] data_bytes_in_packet;
reg[ 8:0] dbip_div_64;
reg       dbip_has_remainder;
//------------------------------------------------------------------------------------
always @*
begin
    if ((ism_state == ISM_WAIT_FOR_HDR) & AXIS_RDMA_TVALID) begin
        data_bytes_in_packet = udp_length - UDP_HDR_LEN - RDMA_HDR_LEN;
        dbip_div_64          = (data_bytes_in_packet >> 6);
        dbip_has_remainder   = (data_bytes_in_packet & 6'b111111) ? 1 : 0;
        awlen_imm            = (dbip_div_64 + dbip_has_remainder - 1);
    end

    // Prevent Vivado from inferring a latch
    else awlen_imm = 0;
end
//====================================================================================




//====================================================================================
// The input state-machine: reads incoming RDMA packets and stuffs the target address
// from the header into the target-address FIFO and stuffs the remainder of the packet
// into the packet-data FIFO.
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

        // Wait for an RDMA packet header to arrive
        ISM_WAIT_FOR_HDR:
            if (AXIS_RDMA_TREADY & AXIS_RDMA_TVALID) begin
                awlen_reg <= awlen_imm;
                ism_state <= ISM_XFER_PACKET;
            end

        // Here, we're reading in data-beats from the stream and writing them to packet-data FIFO
        ISM_XFER_PACKET:
            if (AXIS_RDMA_TREADY & AXIS_RDMA_TVALID & AXIS_RDMA_TLAST) begin
                ism_state <= ISM_WAIT_FOR_HDR;
            end

    endcase
end
//====================================================================================





//====================================================================================
// This FIFO holds the incoming packet data
//====================================================================================
xpm_fifo_axis #
(
   .FIFO_DEPTH(PACKET_FIFO_DEPTH), // DECIMAL
   .TDATA_WIDTH(DATA_WBITS),       // DECIMAL
   .FIFO_MEMORY_TYPE("auto"),      // String
   .PACKET_FIFO("false"),          // String
   .USE_ADV_FEATURES("0000")       // String
)
packet_data_fifo
(
    // Clock and reset
   .s_aclk   (clk   ),                       
   .m_aclk   (clk   ),             
   .s_aresetn(resetn),

    // The input of this FIFO is the AXIS_RDMA interface
   .s_axis_tdata (AXIS_RDMA_TDATA),
   .s_axis_tkeep (AXIS_RDMA_TKEEP),
   .s_axis_tlast (AXIS_RDMA_TLAST),
   .s_axis_tvalid(fpdin_tvalid   ),
   .s_axis_tready(fpdin_tready   ),

    // The output of this FIFO drives the "W" channel of the M_AXI interface
   .m_axis_tdata (M_AXI_WDATA  ),     
   .m_axis_tkeep (M_AXI_WSTRB  ),
   .m_axis_tvalid(M_AXI_WVALID ),       
   .m_axis_tlast (M_AXI_WLAST  ),         
   .m_axis_tready(M_AXI_WREADY ),

    // Unused input stream signals
   .s_axis_tdest(),
   .s_axis_tid  (),
   .s_axis_tstrb(),
   .s_axis_tuser(),

    // Unused output stream signals
   .m_axis_tdest(),             
   .m_axis_tid  (),               
   .m_axis_tstrb(), 
   .m_axis_tuser(),         

    // Other unused signals
   .almost_empty_axis(),
   .almost_full_axis(), 
   .dbiterr_axis(),          
   .prog_empty_axis(), 
   .prog_full_axis(), 
   .rd_data_count_axis(), 
   .sbiterr_axis(),
   .wr_data_count_axis(),
   .injectdbiterr_axis(),
   .injectsbiterr_axis()
);
//====================================================================================




//====================================================================================
// This FIFO holds the target-address of the incoming data packets
//====================================================================================
xpm_fifo_axis #
(
   .FIFO_DEPTH(PACKET_FIFO_DEPTH),  // DECIMAL
   .TDATA_WIDTH(RDMA_HDR_BYTES*8),  // DECIMAL
   .FIFO_MEMORY_TYPE("auto"),       // String
   .PACKET_FIFO("false"),           // String
   .USE_ADV_FEATURES("0000")        // String
)
target_addr_fifo
(
    // Clock and reset
   .s_aclk   (clk   ),                       
   .m_aclk   (clk   ),             
   .s_aresetn(resetn),

    // The input to this FIFO is derived from packet-headers on AXIS_RDMA
   .s_axis_tdata ({awlen, target_addr}),
   .s_axis_tvalid(ftain_tvalid        ),
   .s_axis_tready(ftain_tready        ),

    // The output bus of the FIFO drives the AW-channel of the M_AXI interface
   .m_axis_tdata ({M_AXI_AWLEN, M_AXI_AWADDR}),     
   .m_axis_tvalid(M_AXI_AWVALID              ),       
   .m_axis_tready(M_AXI_AWREADY              ),     

    // Unused input stream signals
   .s_axis_tdest(),
   .s_axis_tid  (),
   .s_axis_tstrb(),
   .s_axis_tuser(),
   .s_axis_tkeep(),
   .s_axis_tlast(),

    // Unused output stream signals
   .m_axis_tdest(),             
   .m_axis_tid  (),               
   .m_axis_tstrb(), 
   .m_axis_tuser(),         
   .m_axis_tkeep(),           
   .m_axis_tlast(),         

    // Other unused signals
   .almost_empty_axis(),
   .almost_full_axis(), 
   .dbiterr_axis(),          
   .prog_empty_axis(), 
   .prog_full_axis(), 
   .rd_data_count_axis(), 
   .sbiterr_axis(),
   .wr_data_count_axis(),
   .injectdbiterr_axis(),
   .injectsbiterr_axis()
);
//====================================================================================

assign DBG_new_awlen = awlen;

endmodule