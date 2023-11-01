
//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 04-Oct-22  DWW  1000  Initial creation
//====================================================================================

module data_sink #
(
    parameter STREAM_WIDTH = 512
)
(
    input clk, resetn,

    output reg[STREAM_WIDTH-1:0] data,

    input[STREAM_WIDTH-1:0] AXIS_RX_TDATA,
    input                   AXIS_RX_TVALID,
    input                   AXIS_RX_TLAST,
    output                  AXIS_RX_TREADY
 );


// We're ready to accept input any time we're not in reset
assign AXIS_RX_TREADY = resetn;

// Drive the input stream out the "data" line
always @(posedge clk) begin
    if (resetn == 0) begin
        data <= 0;
    end else if (AXIS_RX_TVALID) begin
        data <= AXIS_RX_TDATA;
    end
end

endmodule






