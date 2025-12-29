`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Majed 
// Design & Project Name: UART Controler
// Module Name: uart_rx
// Target Devices: Basys 3
// ENGINEERING CALCULATION:
// The FPGA runs at 100MHz (10ns period).
// The PC sends bits at 9600Hz (104,166ns period).
// We must count 100,000,000 / 9600 = 10416 ticks to wait for exactly ONE bit.
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter  CLKS_PER_BIT = 10416
)(
    // Physical Chip Interface ( wires & flip-flops  )
    input logic clk,       // fpga clock 100MHZ
    input logic rst,       // zero out all flip-flops to 0
    input logic rx_serial, // raw noisy voltage wire from USB-UART bridge

    output logic [7:0] rx_byte, // Buffer to hold a clean byte
    output logic rx_done,        // a Flag ( 1 cycle pulse saying a new byte is ready )
    output logic spy_pin
);
    // to see it in the scope
    assign spy_pin = rx_serial;
    
    // State Machine Definations
    typedef enum logic [2:0]{
        IDLE,      // 000 : waiting for the line to drop to 0
        START_BIT, // 001 : checking the middle of the start pulse (glitch rejection)
        DATA_BITS, // 010 : Reading 8 bits of data
        STOP_BIT,  // 011: Waiting for the line to go back to 1.
        CLEANUP    // 100: Restting everything for the next round.
    } state_t; 

    // Physical signals using the type state_t
    state_t state_q;    // current state, output of the flop-flop
    state_t state_next; // future state, input to the flip-flop

    // Timers and Counters
    // Fixed: Changed [0:13] to [13:0]. In FPGA, we always put the Big number on the Left (MSB).
    logic [13:0] clock_count_q, clock_count_next; // The stopwatch, counting to 10,416
    logic [2:0]  bit_index_q, bit_index_next;     // The finger, tracks which bit are we reading 0 to 7.
    logic [7:0]  rx_data_q, rx_data_next;         // The bucket, a shift register to cllect bits as they arrive.

    // Metastavility protection
    logic rx_sync_1; // to clean up rx_serial asynchronous noisy signals.
    logic rx_sync_2; // clean even more

    // Synchronous Logic updating all flip-flops together on the clock edge.
    always_ff @(posedge clk) begin // Fixed: 'pedge' -> 'posedge'
        
        if (rst) begin // if Reset button pressed, wipe everything clean
            state_q        <= IDLE;
            clock_count_q  <= 0;
            bit_index_q    <= 0;
            rx_data_q      <= 0;
            rx_sync_1      <= 1;
            rx_sync_2      <= 1; // Fixed: 'rx_sync+2' -> 'rx_sync_2'
        end
        else begin     // Normal operation : Move Next -> Current
            state_q        <= state_next;
            clock_count_q  <= clock_count_next;
            bit_index_q    <= bit_index_next; // Fixed: 'bit_index_ndext' -> 'bit_index_next'
            rx_data_q      <= rx_data_next; 
            
            // The Synchronizer Chain
            rx_sync_1 <= rx_serial; // capture the raw signal
            rx_sync_2 <= rx_sync_1; // pass it to a safe zone
        end
    end

    // Combinational Logic to computes next-state and timing decisions one by one before clock
    always_comb begin
        // Default assignments "to prevent latches"
        state_next       = state_q; 
        clock_count_next = clock_count_q;
        bit_index_next   = bit_index_q;
        rx_data_next     = rx_data_q;
        rx_done          = 0;
        rx_byte          = rx_data_q; // Fixed: Added missing semicolon ';'
        
        // Mux "What state to listen to"
        case (state_q)
        
            // STATE : IDLE, to detect the falling edge from 1 to 0 of a start bit
            IDLE: begin
                if (rx_sync_2 == 0) begin
                    state_next = START_BIT; // Logic droped to 0
                    clock_count_next = 0;   // starting the stopwatch !
                end
                // Logic, the line is still 1, do nothing
                else begin
                    state_next = IDLE; // Fixed: 'state_next_IDLE' -> 'state_next = IDLE'
                end
            end
            
            // State : START_BIT, wait 50% of a bit width and check again to make sure & ignore glitches/ oise
            START_BIT: begin
                // did we reach 50% of the bit
                if ( clock_count_q == (CLKS_PER_BIT/2)) begin
                    if (rx_sync_2 == 0 ) begin
                        clock_count_next = 0; // reset timer to measure first Data bit.
                        state_next       = DATA_BITS;
                    end
                    // it went back to 1, so it was just noise, back to IDLE state
                    else begin
                        state_next = IDLE;
                    end
                end 
                // no enough time passed yet, keep counting
                else begin 
                    clock_count_next = clock_count_q + 1;
                end
            end
            
            // State : DATA_BITS, to loop 8 times and collect the byte
            DATA_BITS: begin
                // 1. Wait for ONE FULL BIT duration, 10416 clicks 
                if (clock_count_q < CLKS_PER_BIT - 1) begin
                    clock_count_next = clock_count_q + 1;
                    state_next = DATA_BITS; // Stay until time is up
                end
                // 2. Time is up, we are now in the middle of the data bit.
                else begin
                    // Reset timer for the "next" bit
                    clock_count_next = 0;
                    
                    // 3. Sample, take the value from the wire and put it in the buffer.
                    rx_data_next[bit_index_q] = rx_sync_2;
                
                    // 4. Check Loop : have we gatherd all 8 bits?
                    if ( bit_index_q < 7 ) begin
                        // no, we need more increment index.
                        bit_index_next = bit_index_q + 1; // Fixed: 'bit_index+q' -> 'bit_index_q'
                        state_next = DATA_BITS; 
                    end  
                        
                    // Yes we have 8 bits, reset index & change the state
                    else begin
                        bit_index_next = 0; 
                        state_next = STOP_BIT;
                    end
                end
            end
            
            // State 3 : Stop_Bit, wait for the stop bit to finish ( one full bit duration )
            STOP_BIT: begin
                // 1. Wait for ONE FULL BIT duration, 10416 clicks 
                if (clock_count_q < CLKS_PER_BIT - 1) begin
                    clock_count_next = clock_count_q + 1; // Fixed: YOU MISSED THIS! The timer must count up!
                    state_next = STOP_BIT;
                end
                // Timer finished, we received the whole packet,
                else begin
                    state_next = CLEANUP; // Fixed: 'CLEANUPl' -> 'CLEANUP'
                end
            end
                    
            // State 4 : CLEANUP, to tell the rest of the FPGA "Done!" and reset Logic.
            CLEANUP: begin
                // ring the doorbell, high pulse
                rx_done = 1;  
                // go back to slepe and wait for the next char
                state_next = IDLE; // Fixed: 'state_next_IDLE' -> 'state_next = IDLE'
            end 
            
            default: state_next = IDLE; // Fixed: 'defauilt' -> 'default'
        endcase
    end
   
   
   
   
   
// ----------------------------------------------------------------
// FORMAL VERIFICATION
// ----------------------------------------------------------------
`ifdef FORMAL

    // Assume the system starts in Reset
    initial restrict(rst);
    
    // start the flip-flops at 0 (IDLE), just like the real hardware.
    initial state_q = IDLE;
    initial clock_count_q = 0;
    initial bit_index_q = 0;

    //SAFETY PROPERTIES (Bad things must NEVER happen)
    
    // Checking if the state machine would ever go off the rails or be in an "Undefined" state.
    always_comb assert(state_q <= CLEANUP);

    // COVERAGE : checking where we successfully receive a byte."
    always @(posedge clk) begin
        cover(rx_done == 1);
    end

`endif




endmodule