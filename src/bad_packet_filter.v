//===================================================================================================
//                            ------->  Revision History  <------
//===================================================================================================
//
//   Date     Who   Ver  Changes
//===================================================================================================
// 01-Nov-23  DWW     1  Initial creation
//===================================================================================================

/*
    There are AXI Stream IP cores (such as Xilinx's Ultrascale+ 100G Ethernet core) that ignore
    the TREADY signal when transmitting data.   This module detects the situation where the
    input stream has asserted TVALID while the output stream's TREADY is low.
*/

module bad_packet_filter #
(
    parameter DATA_WBITS   = 512,
    parameter DATA_WBYTS   = DATA_WBITS / 8,
    parameter FIFO_DEPTH   = 256
)
(
    input   clk, resetn,

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
    output                 AXIS_OUT_TUSER,
    output                 AXIS_OUT_TLAST,
    output                 AXIS_OUT_TVALID,
    input                  AXIS_OUT_TREADY    
);


// The "overrun" register is high on any cycle that the input tries to 
// write a data-cycle while the output stream isn't ready
always @(posedge clk) begin
    overrun <= (AXIS_IN_TVALID && ~AXIS_OUT_TREADY);
end

// The current state of the state machine
reg[1:0]   fsm_state; 
localparam FSM_INIT             = 0;
localparam FSM_WAIT_FIRST_CYCLE = 1;
localparam FSM_XFER_PACKET      = 2;


// Driven by the "bad packet indicator" FIFO to tell us it's ready for input
wire      fbpi_in_tready;

// The "bad packet indicator" FIFO receives input from the last cycle in every incoming packet
wire      fbpi_in_tvalid = AXIS_IN_TVALID & AXIS_IN_TREADY & AXIS_IN_TLAST;

// These are driven by the output of the "bad packet indicator" FIFO
wire[7:0] fbpi_out_tdata;
wire      fbpi_out_tvalid;
wire      fbpi_out_tready = (fsm_state == FSM_WAIT_FIRST_CYCLE) & AXIS_OUT_TREADY; 

// When this is true, a data-cycle transfer occurs on the output of the "bad packet indicator" FIFO
wire      fbpi_out_hsk = fbpi_out_tready & fbpi_out_tvalid;

// The valid and ready signal for the output side of the packet data FIFO
wire      fpkt_out_tvalid;
wire      fpkt_out_tready = AXIS_OUT_TREADY;

// The "bad_packet" signal is valid at the moment data appears on the output of the
// packet-data FIFO.
reg  bad_packet_reg;
wire bad_packet = ((fsm_state == FSM_WAIT_FIRST_CYCLE) & fbpi_out_hsk & fbpi_out_tdata[0])
                | ((fsm_state == FSM_XFER_PACKET     ) & bad_packet_reg);

// AXIS_OUT_TVALID is driven by the output of the packet FIFO only if we're not processing a bad packet
assign AXIS_OUT_TVALID = fpkt_out_tvalid & ~bad_packet;

//====================================================================================
// This state machine watches the output of the bad-packet-indicator (bpi) FIFO to
// determine whether the packet-data FIFO contains a good packet or a bad packet
//====================================================================================
always @(posedge clk) begin
    
    if (resetn == 0) begin
        bad_pkt_dropped <= 0;
        fsm_state       <= FSM_INIT;
    
    end else case(fsm_state)

        // Here we're coming out of reset...
        FSM_INIT:
            fsm_state <= FSM_WAIT_FIRST_CYCLE;


        // When a cycle appears on the output of the bpi FIFO, one is 
        // also appearing on the output of the packet-data FIFO.  The cycle
        // on the packet-data FIFO is simultaneously being presented on
        // the AXIS_OUT interface.
        FSM_WAIT_FIRST_CYCLE:
            if (fbpi_out_hsk) begin
                bad_packet_reg <= fbpi_out_tdata[0];

                if (bad_packet)
                    bad_pkt_dropped <= 1;

                if (AXIS_OUT_TLAST == 0)
                    fsm_state <= FSM_XFER_PACKET;

            end

        // Here, we wait for the entire packet to be extracted from 
        // the output side of the packet-data FIFO
        FSM_XFER_PACKET:
            if (fpkt_out_tready & fpkt_out_tvalid & AXIS_OUT_TLAST)
                fsm_state <= FSM_WAIT_FIRST_CYCLE;
 
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
   .PACKET_FIFO     ("true"    ),   // String
   .USE_ADV_FEATURES("0000"    )    // String
)
packet_data_fifo
(
    // Clock and reset
   .s_aclk   (clk   ),                       
   .m_aclk   (clk   ),             
   .s_aresetn(resetn),

    // The input of this FIFO is driven directly by AXIS_IN
   .s_axis_tdata (AXIS_IN_TDATA  ), /* Input  */
   .s_axis_tkeep (AXIS_IN_TKEEP  ), /* Input  */
   .s_axis_tlast (AXIS_IN_TLAST  ), /* Input  */
   .s_axis_tvalid(AXIS_IN_TVALID ), /* Input  */
   .s_axis_tready(AXIS_IN_TREADY ), /* Output */

    // The output of this FIFO (mostly) drives AXIS_OUT
   .m_axis_tdata (AXIS_OUT_TDATA ), /* Output */     
   .m_axis_tkeep (AXIS_OUT_TKEEP ), /* Output */
   .m_axis_tlast (AXIS_OUT_TLAST ), /* Output */         
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
// This FIFO holds the incoming "bad packet indicators"
//====================================================================================
xpm_fifo_axis #
(
   .FIFO_DEPTH      (FIFO_DEPTH),   // DECIMAL
   .TDATA_WIDTH     (8         ),   // DECIMAL
   .FIFO_MEMORY_TYPE("auto"    ),   // String
   .PACKET_FIFO     ("false"   ),   // String
   .USE_ADV_FEATURES("0000"    )    // String
)
bpi_fifo
(
    // Clock and reset
   .s_aclk   (clk   ),                       
   .m_aclk   (clk   ),             
   .s_aresetn(resetn),

    // The input of this FIFO is
   .s_axis_tdata (AXIS_IN_TUSER ),  /* Input  */
   .s_axis_tvalid(fbpi_in_tvalid),  /* Input  */
   .s_axis_tready(fbpi_in_tready),  /* Output */

    // This FIFO outputs one entry per packet
   .m_axis_tdata (fbpi_out_tdata ), /* Output */
   .m_axis_tvalid(fbpi_out_tvalid), /* Output */      
   .m_axis_tready(fbpi_out_tready), /* Input  */

    // Unused input stream signals
   .s_axis_tkeep(),
   .s_axis_tlast(),
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