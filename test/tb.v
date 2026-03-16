`timescale 1ns/1ps

module tb;
    reg [7:0] ui_in;
    wire [7:0] uo_out;
    reg clk;
    reg rst_n;

    // --- NEW: Dummy wires for standard TT ports ---
    wire [7:0] uio_in = 8'b0;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    wire ena = 1'b1;

    // --- UPDATED: Port mapping for the new module signature ---
   tt_um_catalinlazar_big_ihp_osc_array dut (
        .ui_in  (ui_in),
        .uo_out (uo_out),
        .uio_in (uio_in),
        .uio_out(uio_out),
        .uio_oe (uio_oe),
        .ena    (ena),
        .clk    (clk),
        .rst_n  (rst_n)
    );

    // Generate 10MHz System Clock (100ns period)
    always #50 clk = ~clk;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        clk = 0;
        rst_n = 0;
        ui_in = 8'b0000_0000; 

        #200;
        rst_n = 1;            
        #100;
        
        // Select Flavor 0 and Enable (ui_in[1] = 1)
        ui_in = 8'b0000_0010; 
        $display("Oscillator Enabled. Waiting for 100us measurement window...");

        // Wait for the simulation timer (1000 cycles)
        wait(dut.timer == 20'd1000); 
        #100; 

        // Read results
        ui_in = 8'b0000_0010; // Low byte (b_sel=00)
        #100;
        $display("Low Byte: %h", uo_out);
        
        ui_in = 8'b0000_0110; // Mid byte (b_sel=01)
        #100;
        $display("Mid Byte: %h", uo_out);
        
        ui_in = 8'b0000_1010; // High byte (b_sel=10)
        #100;
        $display("High Byte: %h", uo_out);

        $finish;
    end
endmodule
