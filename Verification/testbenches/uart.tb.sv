`timescale 1ns / 1ps

module uart_tb;

    // ------------------------------------------------
    // 1. WIRES & VARIABLES
    // ------------------------------------------------
    logic clk = 0;
    logic rst = 0;
    logic rx_serial = 1; // Idle line is High
    
    // Outputs from the DUT
    logic [7:0] rx_byte;
    logic rx_done;

    // Test Variables
    logic [7:0] test_data;
    int errors = 0;
    
    // ------------------------------------------------
    // 2. INSTANTIATE THE DUT (Device Under Test)
    // ------------------------------------------------
    // We override the parameter to 10 so we don't have to wait 
    // 10,000 clocks per bit during simulation.
    uart_rx #(.CLKS_PER_BIT(10)) dut (
        .clk(clk),
        .rst(rst),
        .rx_serial(rx_serial),
        .rx_byte(rx_byte),
        .rx_done(rx_done)
    );

    // ------------------------------------------------
    // 3. CLOCK GENERATION
    // ------------------------------------------------
    // Toggle clock every 5ns (10ns period = 100MHz)
    always #5 clk = ~clk;

    // ------------------------------------------------
    // 4. TASK: THE UART TRANSMITTER
    // ------------------------------------------------
    // This is a "Function" we can call to send a byte
    task send_byte(input [7:0] data);
        integer i;
        begin
            // A. Start Bit (Drop to 0)
            rx_serial = 0;
            #100; // Wait 1 bit duration (10 clocks * 10ns = 100ns)
            
            // B. Data Bits (0 to 7)
            for (i=0; i<8; i=i+1) begin
                rx_serial = data[i]; // Send the bit (LSB first)
                #100;                // Wait 1 bit duration
            end
            
            // C. Stop Bit (Return to 1)
            rx_serial = 1;
            #100; // Wait 1 bit duration
        end
    endtask

    // ------------------------------------------------
    // 5. THE MAIN TEST SCENARIO
    // ------------------------------------------------
    initial begin
        // A. Setup
        $display("---------------------------------------");
        $display("   STARTING UART SIMULATION            ");
        $display("---------------------------------------");
        
        // Reset the system
        rst = 1;
        #20;
        rst = 0;
        #20;

        // B. Directed Test (Send 'A' - 0x41)
        test_data = 8'h41; // 'A'
        $display("Test 1: Sending 'A' (0x41)...");
        
        send_byte(test_data); // Call our task
        
        // Wait for the "Done" flag
        @(posedge rx_done);
        
        // Check the result
        if (rx_byte == test_data) 
            $display("   [PASS] Received: %h", rx_byte);
        else begin
            $display("   [FAIL] Expected %h, Got %h", test_data, rx_byte);
            errors++;
        end
        
        // Wait a bit before next test
        #200;

        // C. Random Test (Blast 100 Random Bytes)
        $display("Test 2: Blasting 100 Random Bytes...");
        
        for (int k=0; k<100; k++) begin
            test_data = $random; // Generate random byte
            send_byte(test_data);
            
            // Wait for Done
            @(posedge rx_done);
            
            // Checker
            if (rx_byte !== test_data) begin
                $display("   [FAIL] Iteration %0d: Sent %h, Got %h", k, test_data, rx_byte);
                errors++;
            end
            
            #50; // Small delay between bytes
        end

        // D. Final Report
        $display("---------------------------------------");
        if (errors == 0)
             $display("   SIMULATION SUCCESS: 0 Errors");
        else
             $display("   SIMULATION FAILED: %0d Errors", errors);
        $display("---------------------------------------");
        
        $finish; // Stop simulation
    end

endmodule