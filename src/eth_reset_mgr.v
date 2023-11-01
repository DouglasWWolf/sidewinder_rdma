//===================================================================================================
//                            ------->  Revision History  <------
//===================================================================================================
//
//   Date     Who   Ver  Changes
//===================================================================================================
// 20-Feb-23  DWW  1000  Initial creation
//===================================================================================================

module eth_reset_mgr
(
    // Clock and input reset signal.
    input clock, reset,

    output reg rx_enable,
    output reg tx_enable, 
    output reg tx_send_rfi,
    input      rx_aligned
);

reg state;

always @(posedge clock) begin

    if (reset) begin
        state       <= 0;
        rx_enable   <= 0;
        tx_enable   <= 0;
        tx_send_rfi <= 0;
    end else case(state)

        0:  begin
                rx_enable   <= 1;
                tx_send_rfi <= 1;
                if (rx_aligned) state <= 1;
            end

        1:  begin
                tx_send_rfi <= 0;
                tx_enable   <= 1;
            end

    endcase

end

endmodule
