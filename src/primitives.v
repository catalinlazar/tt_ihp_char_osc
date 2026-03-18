`timescale 1ns/1ps

`ifdef SIM
    // Models for simulation (with timing)
    module sg13g2_nand2_1 (input A, input B, output Y); assign #0.1 Y = ~(A & B); endmodule
    module sg13g2_inv_1   (input A, output Y); assign #0.1 Y = ~A; endmodule
    module sg13g2_inv_2   (input A, output Y); assign #0.09 Y = ~A; endmodule
    module sg13g2_inv_4   (input A, output Y); assign #0.08 Y = ~A; endmodule
    module sg13g2_inv_8   (input A, output Y); assign #0.07 Y = ~A; endmodule
`else
    // Empty black-boxes for GDS Linter/Synthesis (correct names!)
    module sg13g2_nand2_1 (input A, input B, output Y); endmodule
    module sg13g2_inv_1   (input A, output Y); endmodule
    module sg13g2_inv_2   (input A, output Y); endmodule
    module sg13g2_inv_4   (input A, output Y); endmodule
    module sg13g2_inv_8   (input A, output Y); endmodule
`endif
