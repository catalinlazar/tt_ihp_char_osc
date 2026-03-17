`default_nettype none
`timescale 1ns/1ps

/*
  This testbench is a simple wrapper for cocotb.
  Logic, resets, and timing are handled in test.py.
*/
module tb;
    // Signals
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Instantiate the Top Module
    tt_um_catalinlazar_big_ihp_osc_array dut (
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe),
        .ena     (ena),
        .clk     (clk),
        .rst_n   (rst_n)
    );

    // Setup Waveform Dump for GitHub Actions / Local debugging
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
    end

endmodule
