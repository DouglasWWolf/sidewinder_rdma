`timescale 1ns / 1ps

//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 27-Oct-23  DWW  1000  Initial creation
//====================================================================================

`define M_AXI_DATA_WIDTH 512
`define M_AXI_ADDR_WIDTH 64
`define M_AXI_DATA_BYTES (`M_AXI_DATA_WIDTH/8)

module data_generator
(
    input clk, resetn,

    //======================  An AXI Master Interface  =========================

    // "Specify write address"         -- Master --    -- Slave --
    output reg[`M_AXI_ADDR_WIDTH-1:0]  M_AXI_AWADDR,
    output reg                         M_AXI_AWVALID,
    output    [2:0]                    M_AXI_AWPROT,
    output    [3:0]                    M_AXI_AWID,
    output reg[7:0]                    M_AXI_AWLEN,
    output    [2:0]                    M_AXI_AWSIZE,
    output    [1:0]                    M_AXI_AWBURST,
    output                             M_AXI_AWLOCK,
    output    [3:0]                    M_AXI_AWCACHE,
    output    [3:0]                    M_AXI_AWQOS,
    input                                              M_AXI_AWREADY,


    // "Write Data"                    -- Master --    -- Slave --
    output    [`M_AXI_DATA_WIDTH-1:0]  M_AXI_WDATA,
    output reg                         M_AXI_WVALID,
    output reg[`M_AXI_DATA_BYTES-1:0]  M_AXI_WSTRB,
    output                             M_AXI_WLAST,
    input                                              M_AXI_WREADY,


    // "Send Write Response"           -- Master --    -- Slave --
    input [1:0]                                        M_AXI_BRESP,
    input                                              M_AXI_BVALID,
    output                             M_AXI_BREADY,

    // "Specify read address"          -- Master --    -- Slave --
    output reg[`M_AXI_ADDR_WIDTH-1:0]  M_AXI_ARADDR,
    output reg                         M_AXI_ARVALID,
    output[2:0]                        M_AXI_ARPROT,
    output                             M_AXI_ARLOCK,
    output[3:0]                        M_AXI_ARID,
    output[7:0]                        M_AXI_ARLEN,
    output[2:0]                        M_AXI_ARSIZE,
    output[1:0]                        M_AXI_ARBURST,
    output[3:0]                        M_AXI_ARCACHE,
    output[3:0]                        M_AXI_ARQOS,
    input                                              M_AXI_ARREADY,

    // "Read data back to master"      -- Master --    -- Slave --
    input[`M_AXI_DATA_WIDTH-1:0]                       M_AXI_RDATA,
    input                                              M_AXI_RVALID,
    input[1:0]                                         M_AXI_RRESP,
    input                                              M_AXI_RLAST,
    output                             M_AXI_RREADY,
    //==========================================================================
   
   
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

// Some convenience declarations
localparam M_AXI_ADDR_WIDTH = `M_AXI_ADDR_WIDTH;
localparam M_AXI_DATA_WIDTH = `M_AXI_DATA_WIDTH;
localparam M_AXI_DATA_BYTES = M_AXI_DATA_WIDTH / 8;

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

// The state of the state-machines that handle AXI4-Lite read and AXI4-Lite write
reg[3:0] axi4_write_state, axi4_read_state;

// The AXI4 slave state machines are idle when in state 0 and their "start" signals are low
assign ashi_widle = (ashi_write == 0) && (axi4_write_state == 0);
assign ashi_ridle = (ashi_read  == 0) && (axi4_read_state  == 0);

// These are the valid values for ashi_rresp and ashi_wresp
localparam OKAY   = 0;
localparam SLVERR = 2;
localparam DECERR = 3;

// An AXI slave is gauranteed a minimum of 128 bytes of address space
// (128 bytes is 32 32-bit registers)
localparam ADDR_MASK = 7'h7F;

// When this strobes high, one or more data-bursts are emitted
reg[1:0] start_mode;

// The geometry of a set of bursts
reg[31:0] burst_count, beats_per_burst;

// When sending a single, short beat, this is the number of data bytes in that beat
reg[31:0] byte_count;

//==========================================================================
// This state machine handles AXI4-Lite write requests
//
// Drives: start_mode
//         beats_per_burst
//         burst_count
//         byte_count
//==========================================================================
always @(posedge clk) begin

    start_mode <= 0;

    // If we're in reset, initialize important registers
    if (resetn == 0) begin
        axi4_write_state <= 0;
        beats_per_burst  <= 4;
    
    // If we're not in reset, and a write-request has occured...        
    end else case (axi4_write_state)
        
        0:  if (ashi_write) begin
       
                // Assume for the moment that the result will be OKAY
                ashi_wresp <= OKAY;              
            
                // Convert the byte address into a register index
                case ((ashi_waddr & ADDR_MASK) >> 2)
                
                    0:  begin
                            burst_count <= ashi_wdata;
                            start_mode  <= 1;
                        end

                    1:  beats_per_burst <= ashi_wdata;

                    2:  begin
                            byte_count <= ashi_wdata;
                            start_mode <= 2;
                        end

                    // Writes to any other register are a decode-error
                    default: ashi_wresp <= DECERR;
                endcase
            end

        // In this state, we're just waiting for the FIFO reset counters 
        // to both go back to zero
        1:  if (axi4_write_state) axi4_write_state <= 0;

    endcase
end
//==========================================================================





//==========================================================================
// World's simplest state machine for handling AXI4-Lite read requests
//==========================================================================
always @(posedge clk) begin

    // If we're in reset, initialize important registers
    if (resetn == 0) begin
        axi4_read_state <= 0;
        
    // If we're not in reset, and a read-request has occured...        
    end else if (ashi_read) begin
       
        // Assume for the moment that the result will be OKAY
        ashi_rresp <= OKAY;              
            
        // Convert the byte address into a register index
        case ((ashi_raddr & ADDR_MASK) >> 2)
 
            // Allow a read from any valid register                
            0:  ashi_rdata <= burst_count;
            1:  ashi_rdata <= beats_per_burst;

            // Reads of any other register are a decode-error
            default: ashi_rresp <= DECERR;
        endcase
    end
end
//==========================================================================



//==========================================================================
// This state machine writes bursts of data on the AXI-Master interface
//==========================================================================
reg[5:0]  bsm_state;
reg[15:0] data_word;
reg[31:0] bursts_remaining;
reg[7:0]  beats_remaining;
reg       addr_handshake, data_handshake;
//==========================================================================
assign M_AXI_AWSIZE  = 6; // 6 = 2^6 (i.e., 64) bytes per beat
assign M_AXI_AWBURST = 1;
assign M_AXI_WLAST   = (beats_remaining == 0);
assign M_AXI_BREADY  = 1;
assign M_AXI_WDATA   = {32{data_word}};

always @(posedge clk) begin
    if (resetn == 0) begin
        bsm_state     <= 0;
        data_word     <= 1;
        M_AXI_AWVALID <= 0;
        M_AXI_WVALID  <= 0;

    end else case (bsm_state)
        0:  if (start_mode == 1) begin
                M_AXI_AWADDR     <= 64'h0000_0001_0000_0000 - 64;
                bursts_remaining <= burst_count;
                bsm_state        <= 1;                                
            end
            
            else if (start_mode == 2) begin
                bsm_state <= 10;
            end

        1:  if (bursts_remaining) begin
                bursts_remaining <= bursts_remaining - 1;
                
                M_AXI_AWADDR    <= M_AXI_AWADDR + 64;
                M_AXI_AWLEN     <= beats_per_burst - 1;
                M_AXI_AWVALID   <= 1;

                M_AXI_WSTRB     <= -1;
                M_AXI_WVALID    <= 1;

                beats_remaining <= beats_per_burst - 1;
                bsm_state       <= 2;
            end else begin
                bsm_state       <= 0;
            end

        2:  begin
                if (M_AXI_AWVALID & M_AXI_AWREADY) M_AXI_AWVALID <= 0;
                
                if (M_AXI_WVALID & M_AXI_WREADY) begin
                    data_word <= data_word + 1;

                    if (M_AXI_WLAST) begin
                        M_AXI_WVALID  <= 0;
                        if (M_AXI_AWVALID == 0 || M_AXI_AWREADY)
                            bsm_state <= 1;
                        else
                            bsm_state <= 3;
                    end

                    else beats_remaining <= beats_remaining - 1;
                end

            end 

        3:  if (M_AXI_AWVALID & M_AXI_AWREADY) begin
                M_AXI_AWVALID <= 0;
                bsm_state     <= 1;
            end

        10: begin
                data_word       <= 32'hBEEF;
                beats_remaining <= 0;
                M_AXI_AWADDR    <= 64'h11223344_AABBCCDD;
                M_AXI_AWLEN     <= 0;
                M_AXI_AWVALID   <= 1;
                M_AXI_WSTRB     <= (1 << byte_count) - 1;
                M_AXI_WVALID    <= 1;
                bsm_state       <= 11;
            end

        11: begin
                if ( M_AXI_AWVALID &  M_AXI_AWREADY) M_AXI_AWVALID <= 0;
                if ( M_AXI_WVALID  &  M_AXI_WREADY ) M_AXI_WVALID  <= 0;
                if (~M_AXI_AWVALID & ~M_AXI_AWREADY) bsm_state     <= 0;
            end

    endcase
end


//========================================================================
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

    // ASHI read registers
    .ASHI_RADDR     (ashi_raddr),
    .ASHI_RDATA     (ashi_rdata),
    .ASHI_READ      (ashi_read ),
    .ASHI_RRESP     (ashi_rresp),
    .ASHI_RIDLE     (ashi_ridle)
);
//==========================================================================

endmodule
