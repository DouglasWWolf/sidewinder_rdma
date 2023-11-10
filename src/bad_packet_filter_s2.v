//===================================================================================================
//                            ------->  Revision History  <------
//===================================================================================================
//
//   Date     Who   Ver  Changes
//===================================================================================================
// 01-Nov-23  DWW     1  Initial creation
//===================================================================================================

/*
    The module shuffles data-cycles from AXIS_IN to AXIS_OUT.   It does not allow
    data to flow from AXIS_IN to AXIS_OUT until it knows an entire packet is
    available from AXIS_IN and knows that the packet in question is "good".

    The definition of "good" incoming packet is one in which TUSER is low when TLAST 
    is high.
*/

module bad_packet_filter_s2 #
(
    parameter DATA_WBITS   = 512,
    parameter DATA_WBYTS   = DATA_WBITS / 8
)
(
    input   clk, resetn, 
   
    // Latches high if a bad packet gets dropped
    output reg bad_pkt_dropped,

    // Input stream for incoming packet data
    input[DATA_WBITS-1:0]  fpkt_out_tdata,
    input[DATA_WBYTS-1:0]  fpkt_out_tkeep,
    input                  fpkt_out_tuser,
    input                  fpkt_out_tlast,
    input                  fpkt_out_tvalid,
    output                 fpkt_out_tready,    

    // Input stream for incoming bad-packet-indicators
    input[7:0]             fbpi_out_tdata,
    input                  fbpi_out_tvalid,
    output                 fbpi_out_tready,    

    // Output stream
    output[DATA_WBITS-1:0] AXIS_OUT_TDATA,
    output[DATA_WBYTS-1:0] AXIS_OUT_TKEEP,
    output                 AXIS_OUT_TLAST,
    output                 AXIS_OUT_TVALID,
    input                  AXIS_OUT_TREADY    
);

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//           This section manages the output side of the FIFOs
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

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
wire bad_packet = waiting_first_cycle ? fbpi_out_tdata[0] : bad_packet_reg;

// We're ready for incoming BPI data when the output stream is ready for data
assign fbpi_out_tready = waiting_first_cycle & AXIS_OUT_TREADY;

// This defines a data-beat on the on the output side of the bpi FIFO
wire axis_bpi_handshake = fbpi_out_tready & fbpi_out_tvalid;

// We're ready to accept incoming packet data:
//  (1) The moment we're told that a full packet is ready to receive
//  (2) While the module on the other end of the output stream is ready to receive
assign fpkt_out_tready = (waiting_first_cycle & axis_bpi_handshake)
                       | (transferring_packet & AXIS_OUT_TREADY   );

assign AXIS_OUT_TVALID = (waiting_first_cycle & fbpi_out_tvalid & ~bad_packet)
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

    // If a "bad packet indicator" arrives, save it
    FSM_WAIT_FIRST_CYCLE:
        if (axis_bpi_handshake) begin
            bad_packet_reg <= fbpi_out_tdata[0];
            
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

endmodule