//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 03-Nov-23  DWW  1000  Initial creation
//====================================================================================


module axi_eth_status
(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axi_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET axi_resetn"        *)
    input axi_clk,
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axi_resetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW"                   *)    
    input axi_resetn,

    // Clock that is synchronous with ss0_overrun and ss1_overrun
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 rx_clk CLK" *)
    input rx_clk,

    // Status signals for channel 0, synchronous to rx_clk
    input ss0_channel_up, ss0_overrun, ss0_pkt_dropped, 

    // Status signals for channel 1, synchronous to rx_clk
    input ss1_channel_up, ss1_overrun, ss1_pkt_dropped,

    //================== This is an AXI4-Lite slave interface ==================
        
    // "Specify write address"              -- Master --    -- Slave --
    input[31:0]                             S_AXI_AWADDR,   
    input                                   S_AXI_AWVALID,  
    output                                                  S_AXI_AWREADY,
    input[2:0]                              S_AXI_AWPROT,

    // "Write Data"                         -- Master --    -- Slave --
    input[31:0]                             S_AXI_WDATA,      
    input                                   S_AXI_WVALID,
    input[3:0]                              S_AXI_WSTRB,
    output                                                  S_AXI_WREADY,

    // "Send Write Response"                -- Master --    -- Slave --
    output[1:0]                                             S_AXI_BRESP,
    output                                                  S_AXI_BVALID,
    input                                   S_AXI_BREADY,

    // "Specify read address"               -- Master --    -- Slave --
    input[31:0]                             S_AXI_ARADDR,     
    input                                   S_AXI_ARVALID,
    input[2:0]                              S_AXI_ARPROT,     
    output                                                  S_AXI_ARREADY,

    // "Read data back to master"           -- Master --    -- Slave --
    output[31:0]                                            S_AXI_RDATA,
    output                                                  S_AXI_RVALID,
    output[1:0]                                             S_AXI_RRESP,
    input                                   S_AXI_RREADY
    //==========================================================================
 );

    // These are copies of the ss?_overrun signals, synchronous to axi_clk
    wire sync_ss0_overrun, sync_ss1_overrun;

    // These are copies of the ss?_pkt_dropped signals, synchronous to axi_clk
    wire sync_ss0_pkt_dropped, sync_ss1_pkt_dropped;

    //==========================================================================
    // We'll communicate with the AXI4-Lite Slave core with these signals.
    //==========================================================================
    // AXI Slave Handler Interface for write requests
    wire[31:0]  ashi_waddr;     // Input:  Write-address
    wire[31:0]  ashi_wdata;     // Input:  Write-data
    wire        ashi_write;     // Input:  1 = Handle a write request
    reg[1:0]    ashi_wresp;     // Output: Write-response (OKAY, DECERR, SLVERR)
    wire        ashi_widle;     // Output: 1 = Write state machine is idle

    // AXI Slave Handler Interface for read requests
    wire[31:0]  ashi_raddr;     // Input:  Read-address
    wire        ashi_read;      // Input:  1 = Handle a read request
    reg[31:0]   ashi_rdata;     // Output: Read data
    reg[1:0]    ashi_rresp;     // Output: Read-response (OKAY, DECERR, SLVERR);
    wire        ashi_ridle;     // Output: 1 = Read state machine is idle
    //==========================================================================

    // The state of our two AXI4-Lite state machines
    reg[2:0] read_state, write_state;

    // The state machines are idle when they're in state 0 and their "start" signals are low
    assign ashi_widle = (ashi_write == 0) && (write_state == 0);
    assign ashi_ridle = (ashi_read  == 0) && (read_state  == 0);

    // These are the valid values for ashi_rresp and ashi_wresp
    localparam OKAY   = 0;
    localparam SLVERR = 2;
    localparam DECERR = 3;

    // An AXI slave is gauranteed a minimum of 128 bytes of address space
    // (128 bytes is 32 32-bit registers)
    localparam ADDR_MASK = 7'h7F;

    // Latched versions of the overrun signals
    reg ss0_overrun_latch, ss1_overrun_latch;

    // Stuff our status signals into a status word
    wire[31:0] status_word;

    // These are the bit positions in the status word
    localparam BIT_SS0_UP      =  0;
    localparam BIT_SS0_OVERRUN =  1;
    localparam BIT_SS0_BAD_PKT =  2;
    localparam BIT_SS1_UP      = 16;
    localparam BIT_SS1_OVERRUN = 17;
    localparam BIT_SS1_BAD_PKT = 18;

    // Build the status word
    assign status_word[BIT_SS0_UP     ] = ss0_channel_up;
    assign status_word[BIT_SS0_OVERRUN] = ss0_overrun_latch;
    assign status_word[BIT_SS0_BAD_PKT] = ss0_pkt_dropped;
    assign status_word[BIT_SS1_UP     ] = ss1_channel_up;
    assign status_word[BIT_SS1_OVERRUN] = ss1_overrun_latch;
    assign status_word[BIT_SS1_BAD_PKT] = ss1_pkt_dropped;    
    
    //==========================================================================
    // This state machine handles AXI write-requests
    //==========================================================================
    always @(posedge axi_clk) begin
        if (axi_resetn == 0) begin
            ss0_overrun_latch <= 0;
            ss1_overrun_latch <= 0;
        end else begin

            // Latch the overrun signals
            if (sync_ss0_overrun) ss0_overrun_latch <= 1;
            if (sync_ss1_overrun) ss1_overrun_latch <= 1;

            if (ashi_write) begin
                
                // Assume for the moment that the result will be OKAY
                ashi_wresp <= OKAY;              
            
                // Convert the byte address into a register index
                case ((ashi_waddr & ADDR_MASK) >> 2)
                
                    0:  begin
                            if (ashi_wdata[BIT_SS0_OVERRUN]) ss0_overrun_latch <= sync_ss0_overrun;
                            if (ashi_wdata[BIT_SS1_OVERRUN]) ss1_overrun_latch <= sync_ss1_overrun;
                        end

                    default: ashi_wresp <= DECERR;

                endcase
            end
        end
    end
    //==========================================================================

 
    //==========================================================================
    // World's simplest state machine for handling read requests
    //==========================================================================
    always @(posedge clk) begin

        // If we're in reset, initialize important registers
        if (resetn == 0) begin
            read_state <= 0;
        
        // If we're not in reset, and a read-request has occured...        
        end else if (ashi_read) begin
        
            // We'll always acknowledge the read as valid
            ashi_rresp <= OKAY;

            // And the response data is the status word
            ashi_rdata <= status_word;
        end
    end
    //==========================================================================


    //==========================================================================
    // This CDC synchronizes signals from the rx_clk domain to the axi_clk 
    // domain
    //==========================================================================
    xpm_cdc_array_single #
    (
        .DEST_SYNC_FF  (4),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF  (0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0),   // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG (1),   // DECIMAL; 0=do not register input, 1=register input
        .WIDTH         (4)    // DECIMAL; range: 1-1024
    )
    ss_signal_cdc
    (
        .src_clk (rx_clk ),   
        .dest_clk(axi_clk), 
        
        .src_in  ({
                    ss1_pkt_dropped,
                    ss1_overrun,
                    ss0_pkt_dropped,
                    ss0_overrun       
                 }), 

        .dest_out({
                    sync_ss1_pkt_dropped,
                    sync_ss1_overrun,
                    sync_ss0_pkt_dropped,
                    sync_ss0_overrun       
                 })

    );
    //==========================================================================


    //==========================================================================
    // This connects us to an AXI4-Lite slave core
    //==========================================================================
    axi4_lite_slave axi_slave
    (
        .clk            (clk),
        .resetn         (resetn),
        
        // AXI AW channel
        .AXI_AWADDR     (S_AXI_AWADDR),
        .AXI_AWVALID    (S_AXI_AWVALID),   
        .AXI_AWPROT     (S_AXI_AWPROT),
        .AXI_AWREADY    (S_AXI_AWREADY),
        
        // AXI W channel
        .AXI_WDATA      (S_AXI_WDATA),
        .AXI_WVALID     (S_AXI_WVALID),
        .AXI_WSTRB      (S_AXI_WSTRB),
        .AXI_WREADY     (S_AXI_WREADY),

        // AXI B channel
        .AXI_BRESP      (S_AXI_BRESP),
        .AXI_BVALID     (S_AXI_BVALID),
        .AXI_BREADY     (S_AXI_BREADY),

        // AXI AR channel
        .AXI_ARADDR     (S_AXI_ARADDR), 
        .AXI_ARVALID    (S_AXI_ARVALID),
        .AXI_ARPROT     (S_AXI_ARPROT),
        .AXI_ARREADY    (S_AXI_ARREADY),

        // AXI R channel
        .AXI_RDATA      (S_AXI_RDATA),
        .AXI_RVALID     (S_AXI_RVALID),
        .AXI_RRESP      (S_AXI_RRESP),
        .AXI_RREADY     (S_AXI_RREADY),

        // ASHI write-request registers
        .ASHI_WADDR     (ashi_waddr),
        .ASHI_WDATA     (ashi_wdata),
        .ASHI_WRITE     (ashi_write),
        .ASHI_WRESP     (ashi_wresp),
        .ASHI_WIDLE     (ashi_widle),

        // AMCI-read registers
        .ASHI_RADDR     (ashi_raddr),
        .ASHI_RDATA     (ashi_rdata),
        .ASHI_READ      (ashi_read ),
        .ASHI_RRESP     (ashi_rresp),
        .ASHI_RIDLE     (ashi_ridle)
    );
    //==========================================================================

endmodule

