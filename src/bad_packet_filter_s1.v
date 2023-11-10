//===================================================================================================
//                            ------->  Revision History  <------
//===================================================================================================
//
//   Date     Who   Ver  Changes
//===================================================================================================
// 01-Nov-23  DWW     1  Initial creation
//===================================================================================================

module bad_packet_filter_s1 #
(
    parameter DATA_WBITS   = 512,
    parameter DATA_WBYTS   = DATA_WBITS / 8
)
(
    input clk,

    // Goes high on any cycle where AXIS_IN_TVALID is high but AXIS_IN_TREADY isn't
    output reg overrun,

    // Input stream
    input[DATA_WBITS-1:0]  AXIS_IN_TDATA,
    input[DATA_WBYTS-1:0]  AXIS_IN_TKEEP,
    input                  AXIS_IN_TUSER,
    input                  AXIS_IN_TLAST,
    input                  AXIS_IN_TVALID,
    output                 AXIS_IN_TREADY,    

    // Output stream for the packet data
    output[DATA_WBITS-1:0] fpkt_in_tdata,
    output[DATA_WBYTS-1:0] fpkt_in_tkeep,
    output                 fpkt_in_tlast,
    output                 fpkt_in_tvalid,
    input                  fpkt_in_tready,

    // Output stream for the bad packet indicators
    output[7:0]            fbpi_in_tdata,
    output                 fbpi_in_tvalid,
    input                  fbpi_in_tready
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

// The input side of the packet fifo is driven by AXIS IN
assign fpkt_in_tdata  = AXIS_IN_TDATA;
assign fpkt_in_tkeep  = AXIS_IN_TKEEP;
assign fpkt_in_tlast  = AXIS_IN_TLAST;
assign fpkt_in_tvalid = AXIS_IN_TVALID;

// The input side of the bpi FIFO is driven by end-of-packet cycles on AXIS_IN
assign fbpi_in_tdata  = AXIS_IN_TUSER;
assign fbpi_in_tvalid = AXIS_IN_TVALID & AXIS_IN_TLAST;

// We're ready for incoming data any time the packet FIFO receiver is
assign AXIS_IN_TREADY = fpkt_in_tready;



endmodule