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

module data_generator #
(
    parameter[63:0] RAM_ADDR = 64'h0000_0001_0000_0000,
    parameter       RAM_SIZE = 256 * 1024
)
(
    input clk, resetn,

    // These are useful for debugging when reading data back from RAM
    output[`M_AXI_DATA_WIDTH-1:0] expected_rdata,
    output reg                    selftest_ok,

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
    output reg                         M_AXI_RREADY,
    //==========================================================================
   
   

    //======================  An AXI Master Interface  =========================

    // "Specify write address"         -- Master --    -- Slave --
    output reg[`M_AXI_ADDR_WIDTH-1:0]  M2_AXI_AWADDR,
    output reg                         M2_AXI_AWVALID,
    output    [2:0]                    M2_AXI_AWPROT,
    output    [3:0]                    M2_AXI_AWID,
    output    [7:0]                    M2_AXI_AWLEN,
    output    [2:0]                    M2_AXI_AWSIZE,
    output    [1:0]                    M2_AXI_AWBURST,
    output                             M2_AXI_AWLOCK,
    output    [3:0]                    M2_AXI_AWCACHE,
    output    [3:0]                    M2_AXI_AWQOS,
    input                                              M2_AXI_AWREADY,


    // "Write Data"                    -- Master --    -- Slave --
    output reg [`M_AXI_DATA_WIDTH-1:0] M2_AXI_WDATA,
    output reg                         M2_AXI_WVALID,
    output     [`M_AXI_DATA_BYTES-1:0] M2_AXI_WSTRB,
    output                             M2_AXI_WLAST,
    input                                              M2_AXI_WREADY,


    // "Send Write Response"           -- Master --    -- Slave --
    input [1:0]                                        M2_AXI_BRESP,
    input                                              M2_AXI_BVALID,
    output                             M2_AXI_BREADY,

    // "Specify read address"          -- Master --    -- Slave --
    output reg[`M_AXI_ADDR_WIDTH-1:0]  M2_AXI_ARADDR,
    output reg                         M2_AXI_ARVALID,
    output[2:0]                        M2_AXI_ARPROT,
    output                             M2_AXI_ARLOCK,
    output[3:0]                        M2_AXI_ARID,
    output[7:0]                        M2_AXI_ARLEN,
    output[2:0]                        M2_AXI_ARSIZE,
    output[1:0]                        M2_AXI_ARBURST,
    output[3:0]                        M2_AXI_ARCACHE,
    output[3:0]                        M2_AXI_ARQOS,
    input                                              M2_AXI_ARREADY,

    // "Read data back to master"      -- Master --    -- Slave --
    input[`M_AXI_DATA_WIDTH-1:0]                       M2_AXI_RDATA,
    input                                              M2_AXI_RVALID,
    input[1:0]                                         M2_AXI_RRESP,
    input                                              M2_AXI_RLAST,
    output reg                         M2_AXI_RREADY,
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

// The state of the bursting state machine
reg[7:0] bsm_state;

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
reg[2:0] start_mode;
localparam SM_FILL      = 1;
localparam SM_NARROW    = 2;
localparam SM_READBACK  = 3;

// The geometry of a set of bursts
reg[31:0] burst_count, block_size, beats_per_burst, initial_value, write_delay;

// When sending a single, short beat, this is the number of data bytes in that beat
reg[31:0] byte_count;

// The state of the Read Check State Machine
reg[3:0]  rcsm_state;  /* rcsm = (r)am (c)heck (s)tate (m)achine */

// This determine whether the RCSM is idle
wire rcsm_idle = (rcsm_state == 0 && start_mode != SM_READBACK);

localparam REG_INITIAL_VALUE = 0;
localparam REG_WRITE_DELAY   = 1;
localparam REG_START_WRITE   = 2;
localparam REG_READ_BACK     = 3;
localparam REG_NARROW_WRITE  = 4;

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
        initial_value    <= 1;
        write_delay      <= 0;

    // If we're not in reset, and a write-request has occured...        
    end else case (axi4_write_state)
        
        0:  if (ashi_write) begin
       
                // Assume for the moment that the result will be OKAY
                ashi_wresp <= OKAY;              
            
                // Convert the byte address into a register index
                case ((ashi_waddr & ADDR_MASK) >> 2)
                
                    REG_INITIAL_VALUE:
                        initial_value <= ashi_wdata;

                    REG_WRITE_DELAY:
                        write_delay <= ashi_wdata;

                    REG_START_WRITE:
                        case (ashi_wdata)
                            0:  /* Writing a zero just clears RAM */
                                begin
                                    burst_count <= 0;
                                    start_mode  <= SM_FILL;
                                end
                            
                            64:
                                begin
                                    burst_count     <= RAM_SIZE / 64;
                                    block_size      <= ashi_wdata;
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;
                                end

                            128:
                                begin 
                                    burst_count     <= RAM_SIZE / 128;
                                    block_size      <= ashi_wdata;                                    
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;                                    
                                end

                            256:
                                begin
                                    burst_count     <= RAM_SIZE / 256;
                                    block_size      <= ashi_wdata;
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;                                                                                                            
                                end

                            512:
                                begin
                                    burst_count     <= RAM_SIZE / 512;
                                    block_size      <= ashi_wdata;                                    
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;                                    
                                end

                            1024:
                                begin
                                    burst_count     <= RAM_SIZE / 1024;
                                    block_size      <= ashi_wdata;                                    
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;                                    
                                end

                            2048:
                                begin
                                    burst_count     <= RAM_SIZE / 2048;
                                    block_size      <= ashi_wdata;                                    
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;                                    
                                end

                            4096:
                                begin
                                    burst_count     <= RAM_SIZE / 4096;                                    
                                    block_size      <= ashi_wdata;                                    
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;                                    
                                end

                            8192:
                                begin
                                    burst_count     <= RAM_SIZE / 8192;
                                    block_size      <= ashi_wdata;                                    
                                    beats_per_burst <= ashi_wdata >> 6;
                                    start_mode      <= SM_FILL;                                    
                                end
                        endcase

                    REG_NARROW_WRITE:
                        begin
                            byte_count <= ashi_wdata;
                            start_mode <= SM_NARROW;
                        end

                    REG_READ_BACK:
                        start_mode <= SM_READBACK;

        
                    // Writes to any other register are a decode-error
                    default: ashi_wresp <= DECERR;
                endcase
            end

        // This is just here as a place-holder for future modifications
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
            REG_INITIAL_VALUE: ashi_rdata <= initial_value;
            REG_WRITE_DELAY  : ashi_rdata <= write_delay;
            REG_START_WRITE  : ashi_rdata <= (start_mode == 0 && bsm_state == 0);
            REG_NARROW_WRITE : ashi_rdata <= byte_count;
            REG_READ_BACK    : ashi_rdata <= {selftest_ok, rcsm_idle};
            
            // Reads of any other register are a decode-error
            default: ashi_rresp <= DECERR;
        endcase
    end
end
//==========================================================================



//==========================================================================
// This state machine writes bursts of data on the AXI-Master interface
//
// Drives:
//    The AW-channel of M_AXI
//    the  W-channel of M_AXI
//==========================================================================
reg[31:0] data_word;
reg[31:0] bursts_remaining;
reg[15:0] beats_remaining;
//==========================================================================

// Constant settings for writing to the M_AXI interface
assign M_AXI_AWSIZE  = $clog2(M_AXI_DATA_BYTES);
assign M_AXI_AWBURST = 1;
assign M_AXI_WLAST   = (M_AXI_WVALID & (beats_remaining == 0));
assign M_AXI_BREADY  = 1;
assign M_AXI_WDATA   = {
                        data_word+15, data_word+14, data_word+13, data_word+12,
                        data_word+11, data_word+10, data_word+ 9, data_word+ 8,
                        data_word+ 7, data_word+ 6, data_word+ 5, data_word+ 4,
                        data_word+ 3, data_word+ 2, data_word+ 1, data_word+ 0
                      };


// When we erase RAM, bursts are this many bytes
localparam ERASE_BURST_SIZE = 1024;

// Constant settings for writing to the M2_AXI interface
assign M2_AXI_AWSIZE  = $clog2(M_AXI_DATA_BYTES);
assign M2_AXI_AWBURST = 1;
assign M2_AXI_WLAST   = M2_AXI_WVALID & (beats_remaining == 0);
assign M2_AXI_BREADY  = 1;
assign M2_AXI_AWLEN   = (ERASE_BURST_SIZE / M_AXI_DATA_BYTES) - 1;
assign M2_AXI_WSTRB   = -1;


// After we raise M_AXI_AWVALID, we've seen a handshake on the AW-channel
// if we've lowered M_AXI_AWVALID or if the slave has indidicated he's ready
wire aw_handshake = (M_AXI_AWVALID == 0 || M_AXI_AWREADY == 1);

// After we raise M2_AXI_AWVALID, we've seen a handshake on the AW-channel
// if we've lowered M2_AXI_AWVALID or if the slave has indicated he's ready
wire m2_aw_handshake = (M2_AXI_AWVALID == 0 || M2_AXI_AWREADY == 1);

// We use this for delays between AXI write transactions
reg[31:0] delay_countdown;

always @(posedge clk) begin
    if (resetn == 0) begin
        bsm_state      <= 0;
        M_AXI_AWVALID  <= 0;
        M_AXI_WVALID   <= 0;
        M2_AXI_AWVALID <= 0;
        M2_AXI_WVALID  <= 0;

    end else case (bsm_state)
        0:  if (start_mode == SM_FILL) begin
                bsm_state <= 10;
            end
            
            else if (start_mode == SM_NARROW) begin
                bsm_state <= 30;
            end

        // This group of states clears RAM to zero
        10: begin
                M2_AXI_WDATA     <= 0;
                M2_AXI_AWADDR    <= RAM_ADDR;
                bursts_remaining <= RAM_SIZE / ERASE_BURST_SIZE;
                bsm_state        <= 11;                                
            end
        
        11:  if (bursts_remaining == 0)
                bsm_state        <= 20;
            else begin
                bursts_remaining <= bursts_remaining - 1;
                beats_remaining  <= M2_AXI_AWLEN;
                M2_AXI_AWVALID   <= 1;
                M2_AXI_WVALID    <= 1;
                bsm_state        <= 12;
            end

        12:  begin
                if (m2_aw_handshake) M2_AXI_AWVALID <= 0;
                
                if (M2_AXI_WVALID & M2_AXI_WREADY & M2_AXI_WLAST) begin
                    M2_AXI_WVALID  <= 0;
                    if (m2_aw_handshake) begin
                        M2_AXI_AWADDR  <= M_AXI_AWADDR + ERASE_BURST_SIZE;
                        bsm_state      <= 11;
                    end else begin
                        bsm_state      <= 13;
                    end
                end

                else beats_remaining <= beats_remaining - 1;
            end 

        13:  if (m2_aw_handshake) begin
                M2_AXI_AWVALID <= 0;
                M2_AXI_AWADDR  <= M_AXI_AWADDR + ERASE_BURST_SIZE;
                bsm_state      <= 11;
            end

        // This group of states fills RAM with data
        20: begin
                data_word        <= initial_value;
                M_AXI_AWADDR     <= RAM_ADDR;
                M_AXI_AWLEN      <= beats_per_burst - 1;
                M_AXI_WSTRB      <= -1;
                bursts_remaining <= burst_count;
                delay_countdown  <= 0;
                bsm_state        <= 21;                                
            end
        
        21:  if (bursts_remaining == 0)
                bsm_state        <= 0;
            else if (delay_countdown)
                delay_countdown  <= delay_countdown - 1;
            else begin
                bursts_remaining <= bursts_remaining - 1;
                beats_remaining  <= M_AXI_AWLEN;
                delay_countdown  <= write_delay;
                M_AXI_AWVALID    <= 1;
                M_AXI_WVALID     <= 1;
                bsm_state        <= 22;
            end

        22:  begin
                if (aw_handshake) M_AXI_AWVALID <= 0;
                
                if (M_AXI_WVALID & M_AXI_WREADY) begin
                    data_word <= data_word + 16;

                    if (M_AXI_WLAST) begin
                        M_AXI_WVALID  <= 0;
                        if (aw_handshake) begin
                            M_AXI_AWADDR  <= M_AXI_AWADDR + block_size;
                            bsm_state     <= 21;
                        end else begin
                            bsm_state     <= 23;
                        end
                    end

                    else beats_remaining <= beats_remaining - 1;
                end

            end 

        23:  if (aw_handshake) begin
                M_AXI_AWVALID <= 0;
                M_AXI_AWADDR  <= M_AXI_AWADDR + block_size;
                bsm_state     <= 21;
            end

        // This group of states performs a "narrow" write to RAM
        30: begin
                data_word       <= 32'hDEADBEEF - 15;
                beats_remaining <= 0;
                M_AXI_AWADDR    <= RAM_ADDR;
                M_AXI_AWLEN     <= 0;
                M_AXI_AWVALID   <= 1;
                M_AXI_WSTRB     <= (1 << byte_count) - 1;
                M_AXI_WVALID    <= 1;
                bsm_state       <= 31;
            end

        31: begin
                if ( M_AXI_AWVALID &  M_AXI_AWREADY) M_AXI_AWVALID <= 0;
                if ( M_AXI_WVALID  &  M_AXI_WREADY ) M_AXI_WVALID  <= 0;
                if (~M_AXI_AWVALID & ~M_AXI_AWREADY) bsm_state     <= 0;
            end

    endcase
end
//==========================================================================


//==========================================================================
// This state machine reads a block of RAM and confirms that its contents
// are as expected
//==========================================================================

// When reading back the RAM, we're going to read it in blocks of this 
// many bytes
localparam READ_BLOCK_SIZE = 256;

// Assign all of the AR-channel values that remain fixed
assign M2_AXI_ARPROT  = 0;
assign M2_AXI_ARLOCK  = 0;
assign M2_AXI_ARID    = 0;
assign M2_AXI_ARLEN   = (READ_BLOCK_SIZE/M_AXI_DATA_BYTES) - 1;
assign M2_AXI_ARCACHE = 0;
assign M2_AXI_ARQOS   = 0;
assign M2_AXI_ARBURST = 1;
assign M2_AXI_ARSIZE  = $clog2(M_AXI_DATA_BYTES);


//==========================================================================
// This state machine read the RAM and confirms that it contains expected
// values.
//
// Drives:
//    The AR-channel of M2_AXI
//    the  R-channel of M2_AXI
//    rcsm_state
//    read_count
//    expected_word (and therefore, expected_rdata)
//    selftest_ok
//==========================================================================

reg[31:0] read_count;
reg[31:0] expected_word;

assign expected_rdata = {
                            expected_word+15, expected_word+14, expected_word+13, expected_word+12,
                            expected_word+11, expected_word+10, expected_word+ 9, expected_word+ 8,
                            expected_word+ 7, expected_word+ 6, expected_word+ 5, expected_word+ 4,
                            expected_word+ 3, expected_word+ 2, expected_word+ 1, expected_word+ 0
                        };


always @(posedge clk) begin
    
    // If we're in reset...
    if (resetn == 0) begin
        rcsm_state    <= 0;
        M2_AXI_RREADY <= 0;
        selftest_ok   <= 0;

    end else case (rcsm_state)

        0:  if (start_mode == SM_READBACK) begin
                selftest_ok    <= 1;
                read_count     <= RAM_SIZE / READ_BLOCK_SIZE;
                M2_AXI_ARADDR  <= RAM_ADDR;
                M2_AXI_ARVALID <= 1;
                M2_AXI_RREADY  <= 0;
                expected_word  <= initial_value;
                rcsm_state     <= 1;
            end

        // Here we wait for the slave to accept our read-request on the AR channel
        1:  if (M2_AXI_ARVALID & M2_AXI_ARREADY) begin
                M2_AXI_ARVALID <= 0;
                M2_AXI_RREADY  <= 1;
                rcsm_state     <= 2;
            end

        // Handle data from RAM as it arrives...
        2:  if (M2_AXI_RVALID & M2_AXI_RREADY) begin        // If a data-cycle has arrived in the R-channel...
                
                if (M2_AXI_RDATA != expected_rdata)         // If data-cycle we just read isn't what we expected...
                    selftest_ok <= 0;                       //   the self-test just failed
                
                expected_word <= expected_word + 16;        // Compute the first 32-bit word of the next cycle
                
                if (M2_AXI_RLAST) begin                     // If this was the last data-beat of the burst...
                    M2_AXI_RREADY  <= 0;                    //   We're no longer ready to recv data
                    if (read_count == 1)                    //   If this was the last burst we want to read...
                        rcsm_state <= 0;                    //     Go back to idle, we're done  
                    else begin                              //   Otherwise...
                        read_count     <= read_count - 1;   //     Keep track of how many bursts remain
                        M2_AXI_ARADDR  <= M2_AXI_ARADDR + READ_BLOCK_SIZE;
                        M2_AXI_ARVALID <= 1;                //     Indicate that the read-address is valid
                        rcsm_state     <= 1;                //     Go wait for the slave to ack the read request
                    end
                end
            end

    endcase
end
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

    // ASHI read registers
    .ASHI_RADDR     (ashi_raddr),
    .ASHI_RDATA     (ashi_rdata),
    .ASHI_READ      (ashi_read ),
    .ASHI_RRESP     (ashi_rresp),
    .ASHI_RIDLE     (ashi_ridle)
);
//==========================================================================


endmodule
