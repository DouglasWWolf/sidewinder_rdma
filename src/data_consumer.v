//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 04-Oct-22  DWW  1000  Initial creation
//====================================================================================

module data_consumer
(
    input clk, resetn,

    output reg[31:0] packet_id,
    output reg[31:0] cycle_id,

    //===============  AXI Stream interface for outputting data ================
    input[511:0] AXIS_RX_TDATA,
    input        AXIS_RX_TVALID,
    input        AXIS_RX_TLAST,
    output       AXIS_RX_TREADY
    //==========================================================================
 );


assign AXIS_RX_TREADY = resetn;

always @(posedge clk) begin

    if (resetn == 0) begin
        packet_id <= 0;
        cycle_id  <= 0;
    end else if (AXIS_RX_TVALID) begin
        cycle_id  <= AXIS_RX_TDATA[00 +: 32];
        packet_id <= AXIS_RX_TDATA[64 +: 32];
    end
end

endmodule






