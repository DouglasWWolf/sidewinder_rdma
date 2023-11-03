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

module axis_drop_det #
(
    parameter TDATA_WIDTH = 512,
    parameter TUSER_WIDTH = 1
)
(
    input   clk,

    output reg overrun, 

    // Input stream
    input[TDATA_WIDTH  -1:0]  AXIS_IN_TDATA,
    input[TUSER_WIDTH  -1:0]  AXIS_IN_TUSER,
    input[TDATA_WIDTH/8-1:0]  AXIS_IN_TKEEP,
    input                     AXIS_IN_TLAST,
    input                     AXIS_IN_TVALID,
    output                    AXIS_IN_TREADY,    

    // Output stream
    output[TDATA_WIDTH  -1:0] AXIS_OUT_TDATA,
    output[TUSER_WIDTH  -1:0] AXIS_OUT_TUSER,
    output[TDATA_WIDTH/8-1:0] AXIS_OUT_TKEEP,
    output                    AXIS_OUT_TLAST,
    output                    AXIS_OUT_TVALID,
    input                     AXIS_OUT_TREADY    
);

// Connect the output stream directly to the input stream
assign AXIS_OUT_TDATA  = AXIS_IN_TDATA;
assign AXIS_OUT_TUSER  = AXIS_IN_TUSER;
assign AXIS_OUT_TKEEP  = AXIS_IN_TKEEP;
assign AXIS_OUT_TLAST  = AXIS_IN_TLAST;
assign AXIS_OUT_TVALID = AXIS_IN_TVALID;
assign AXIS_IN_TREADY  = AXIS_OUT_TREADY;

// The "overrun" register is high on any cycle that the input tries to 
// write a data-cycle while the output stream isn't ready
always @(posedge clk) begin
    overrun <= (AXIS_IN_TVALID && ~AXIS_OUT_TREADY);
end

endmodule