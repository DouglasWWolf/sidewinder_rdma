
module resetn_extender #
(
    parameter STRETCH = 20
)
(
    input   clk, resetn,
    
    output  resetn_out
);

reg[7:0] stretch_counter;

always @(posedge clk) begin
    if (resetn == 0)
        stretch_counter <= 0;
    else if (stretch_counter < STRETCH)
        stretch_counter <= stretch_counter + 1;
end

// resetn_out goes inactive STRETCH clock-cycles after resetn goes inactive 
assign resetn_out = (resetn == 1) & (stretch_counter == STRETCH);

endmodule