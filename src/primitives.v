`timescale 1ns/1ps

`ifdef SIM
    // Only used for local RTL simulation (iverilog -DSIM)
    module sg13g2_stdcell_nand2_1 (input A, input B, output Y); assign #0.1 Y = ~(A & B); endmodule
    module sg13g2_stdcell_inv_1   (input A, output Y); assign #0.1 Y = ~A; endmodule
    module sg13g2_stdcell_inv_2   (input A, output Y); assign #0.09 Y = ~A; endmodule
    module sg13g2_stdcell_inv_4   (input A, output Y); assign #0.08 Y = ~A; endmodule
    module sg13g2_stdcell_inv_8   (input A, output Y); assign #0.07 Y = ~A; endmodule
`else
    // For GDS flow: The -I flag in config.json will now point Verilator 
    // to the real library files, so we leave this section empty to avoid duplicates.
`endif
