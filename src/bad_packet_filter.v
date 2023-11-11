
//===================================================================================================
//                            ------->  Revision History  <------
//===================================================================================================
//
//   Date     Who   Ver  Changes
//===================================================================================================
// 01-Nov-23  DWW     1  Initial creation
//===================================================================================================

module bad_packet_filter #
(
    parameter DATA_WBITS = 512,
    parameter DATA_WBYTS = DATA_WBITS / 8,
    parameter FIFO_DEPTH = 256
)
(
    input clk, resetn,

    // Goes high on any cycle where AXIS_IN_TVALID is high but AXIS_IN_TREADY isn't
    output reg overrun,

    // Latches high if a bad packet gets dropped
    output reg bad_pkt_dropped,

    // Input stream
    input[DATA_WBITS-1:0]  AXIS_IN_TDATA,
    input[DATA_WBYTS-1:0]  AXIS_IN_TKEEP,
    input                  AXIS_IN_TUSER,
    input                  AXIS_IN_TLAST,
    input                  AXIS_IN_TVALID,
    output                 AXIS_IN_TREADY,    

    // Output stream
    output[DATA_WBITS-1:0] AXIS_OUT_TDATA,
    output[DATA_WBYTS-1:0] AXIS_OUT_TKEEP,
    output                 AXIS_OUT_TLAST,
    output                 AXIS_OUT_TVALID,
    input                  AXIS_OUT_TREADY    
);


// The "overrun" register is high on any cycle that the input tries to 
// write a data-cycle while the output stream isn't ready
always @(posedge clk) begin
    overrun <= (AXIS_IN_TVALID && ~AXIS_IN_TREADY);
end

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//           This section manages the input side of the FIFOs
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

// The input side of the FIFO that contains packet data
wire[DATA_WBITS-1:0] fpkt_in_tdata;
wire[DATA_WBYTS-1:0] fpkt_in_tkeep;
wire                 fpkt_in_tlast;
wire                 fpkt_in_tvalid;
wire                 fpkt_in_tready;

// The input side of the FIFO that contains bad-packet-indicators
wire[7:0]            feop_in_tdata;
wire                 feop_in_tvalid;
wire                 feop_in_tready;

// The input side of the packet fifo is driven by AXIS IN
assign fpkt_in_tdata  = AXIS_IN_TDATA;
assign fpkt_in_tkeep  = AXIS_IN_TKEEP;
assign fpkt_in_tlast  = AXIS_IN_TLAST;
assign fpkt_in_tvalid = AXIS_IN_TVALID;

// The input side of the eop FIFO is driven by end-of-packet cycles on AXIS_IN
assign feop_in_tdata  = AXIS_IN_TUSER;
assign feop_in_tvalid = AXIS_IN_TVALID & AXIS_IN_TLAST;

// We're ready for incoming data any time the packet FIFO receiver is
assign AXIS_IN_TREADY = fpkt_in_tready;


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//           This section manages the output side of the FIFOs
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

// The output side of the packet data FIFO
wire[DATA_WBITS-1:0]  fpkt_out_tdata;
wire[DATA_WBYTS-1:0]  fpkt_out_tkeep;
wire                  fpkt_out_tlast;
wire                  fpkt_out_tvalid;
wire                  fpkt_out_tready;    

// The output side of the "bad packet indicators" FIFO
wire[7:0]             feop_out_tdata;
wire                  feop_out_tvalid;
wire                  feop_out_tready;    

// The output stream is largely driven from the incoming packet stream
assign AXIS_OUT_TDATA = fpkt_out_tdata;
assign AXIS_OUT_TKEEP = fpkt_out_tkeep;
assign AXIS_OUT_TLAST = fpkt_out_tlast;

// The current state of the state machine
reg[1:0]   fsm_state; 
localparam FSM_INIT             = 0;
localparam FSM_WAIT_FIRST_CYCLE = 1;
localparam FSM_XFER_PACKET      = 2;

// This is true any time we're waiting for the first cycle of a packet to arrive
wire waiting_first_cycle = (fsm_state == FSM_WAIT_FIRST_CYCLE);

// This is true any time we're transferring the 2nd or subsequent cycle of a packet
wire transferring_packet = (fsm_state == FSM_XFER_PACKET);

// bad_packet will be a 1 if the current packet being output to AXIS_OUT is bad
reg bad_packet_reg;
wire bad_packet = waiting_first_cycle ? feop_out_tdata[0] : bad_packet_reg;

// We're ready for incoming EOP data when the output stream is ready for data
assign feop_out_tready = waiting_first_cycle & AXIS_OUT_TREADY;

// This defines a data-beat on the on the output side of the eop FIFO
wire fifo_eop_handshake = feop_out_tready & feop_out_tvalid;

// We're ready to accept incoming packet data:
//  (1) The moment we're told that a full packet is ready to receive
//  (2) While the module on the other end of the output stream is ready to receive
assign fpkt_out_tready = (waiting_first_cycle & fifo_eop_handshake)
                       | (transferring_packet & AXIS_OUT_TREADY   );

assign AXIS_OUT_TVALID = (waiting_first_cycle & feop_out_tvalid & ~bad_packet)
                       | (transferring_packet & fpkt_out_tvalid & ~bad_packet);


//====================================================================================
// This state machine manages the two FIFOS
//====================================================================================

always @(posedge clk) begin 
    if (resetn == 0) begin
        fsm_state <= FSM_INIT;
    end else case (fsm_state)

    FSM_INIT:
        fsm_state <= FSM_WAIT_FIRST_CYCLE;

    // If an "end of packet" arrives, save it
    FSM_WAIT_FIRST_CYCLE:
        if (fifo_eop_handshake) begin
            bad_packet_reg <= feop_out_tdata[0];
            
            if (bad_packet) 
                bad_pkt_dropped <= 1;

            if (fpkt_out_tlast == 0)
                fsm_state <= FSM_XFER_PACKET;
        end

    // Wait for the last cycle of packet data to be transferred
    FSM_XFER_PACKET:
        if (fpkt_out_tready & fpkt_out_tvalid & fpkt_out_tlast) begin
            fsm_state  <= FSM_WAIT_FIRST_CYCLE;
        end
    endcase

end
//====================================================================================




//====================================================================================
// This FIFO holds the incoming packet data
//====================================================================================
xpm_fifo_axis #
(
   .FIFO_DEPTH      (FIFO_DEPTH),   // DECIMAL
   .TDATA_WIDTH     (DATA_WBITS),   // DECIMAL
   .FIFO_MEMORY_TYPE("auto"    ),   // String
   .PACKET_FIFO     ("false"   ),   // String
   .USE_ADV_FEATURES("0000"    )    // String
)
packet_data_fifo
(
    // Clock and reset
   .s_aclk   (clk   ),                       
   .m_aclk   (clk   ),             
   .s_aresetn(resetn),

    // The input of this FIFO is driven directly by AXIS_IN
   .s_axis_tdata (fpkt_in_tdata ),  /* Input  */
   .s_axis_tkeep (fpkt_in_tkeep ),  /* Input  */
   .s_axis_tlast (fpkt_in_tlast ),  /* Input  */
   .s_axis_tvalid(fpkt_in_tvalid),  /* Input  */
   .s_axis_tready(fpkt_in_tready),  /* Output */

    // The output of this FIFO (mostly) drives AXIS_OUT
   .m_axis_tdata (fpkt_out_tdata ), /* Output */     
   .m_axis_tkeep (fpkt_out_tkeep ), /* Output */
   .m_axis_tlast (fpkt_out_tlast ), /* Output */         
   .m_axis_tvalid(fpkt_out_tvalid), /* Output */       
   .m_axis_tready(fpkt_out_tready), /* Input  */

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
// This FIFO holds the incoming "end of packet" indicators
//====================================================================================
xpm_fifo_axis #
(
   .FIFO_DEPTH      (FIFO_DEPTH),   // DECIMAL
   .TDATA_WIDTH     (8         ),   // DECIMAL
   .FIFO_MEMORY_TYPE("auto"    ),   // String
   .PACKET_FIFO     ("false"   ),   // String
   .USE_ADV_FEATURES("0000"    )    // String
)
eop_fifo
(
    // Clock and reset
   .s_aclk   (clk   ),                       
   .m_aclk   (clk   ),             
   .s_aresetn(resetn),

    // The input of this FIFO is active once per packet
   .s_axis_tdata (feop_in_tdata ),  /* Input  */
   .s_axis_tvalid(feop_in_tvalid),  /* Input  */
   .s_axis_tready(feop_in_tready),  /* Output */

    // This FIFO outputs one entry per packet
   .m_axis_tdata (feop_out_tdata ), /* Output */
   .m_axis_tvalid(feop_out_tvalid), /* Output */      
   .m_axis_tready(feop_out_tready), /* Input  */

    // Unused input stream signals
   .s_axis_tlast(),
   .s_axis_tkeep(),
   .s_axis_tdest(),
   .s_axis_tid  (),
   .s_axis_tstrb(),
   .s_axis_tuser(),

    // Unused output stream signals
   .m_axis_tlast(),         
   .m_axis_tkeep(),
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




endmodule