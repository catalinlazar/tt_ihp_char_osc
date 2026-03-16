`timescale 1ns/1ps

module tb;
    reg [7:0] ui_in;
    wire [7:0] uo_out;
    reg clk;
    reg rst_n;

    // Instantiate the Top Module
   tt_um_catalinlazar_big_ihp_osc_array dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Generate 10MHz System Clock (100ns period)
    always #50 clk = ~clk;

    initial begin
        // Setup Waveform Dump
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        ui_in = 8'b0000_0000; // Reset active, Enable low

        #200;
        rst_n = 1;            // Release Reset
        #100;
        
        // 1. Select Flavor 0 (ui_in[7:4] = 0) and Enable (ui_in[1] = 1)
        ui_in = 8'b0000_0010; 
        //$display("Oscillator Enabled. Waiting for 10ms measurement window...");
        $display("Oscillator Enabled. Waiting for 100us measurement window...");

        // In simulation, we don't want to wait 10 actual milliseconds.
        // Let's wait long enough for the 'timer' in the DUT to hit 100,000.
        // (100,000 * 100ns = 10ms, respecivelly 1000 * 100n = 100us)
        // wait(dut.timer == 20'd100_000);
        wait(dut.timer == 20'd1000); //shorter simulation time
        #100; // Small buffer

        // 2. Read the 24-bit result via Mux
        $display("Reading 24-bit Counter Value:");
        
        ui_in[3:2] = 2'b00; #100; // Select Low Byte
        $display("Byte 0 (LSB): %h", uo_out);
        
        ui_in[3:2] = 2'b01; #100; // Select Mid Byte
        $display("Byte 1:       %h", uo_out);
        
        ui_in[3:2] = 2'b10; #100; // Select High Byte
        $display("Byte 2 (MSB): %h", uo_out);

        #1000;
        $display("Simulation Finished.");
        $finish;
    end
endmodule
