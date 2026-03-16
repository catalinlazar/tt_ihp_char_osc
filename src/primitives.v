`timescale 1ns/1ps

// If 'SIM' is defined (e.g., via iverilog -DSIM), use functional models.
// Otherwise, provide empty black-box definitions for the GDS linter.
`ifdef SIM

module sg13g2_stdcell_nand2_1 (input A, input B, output Y);
    assign #0.1 Y = ~(A & B); // 100ps delay for simulation
endmodule

module sg13g2_stdcell_inv_1 (input A, output Y);
    assign #0.1 Y = ~A;
endmodule

module sg13g2_stdcell_inv_2 (input A, output Y); 
    assign #0.09 Y = ~A; 
endmodule

module sg13g2_stdcell_inv_4 (input A, output Y); 
    assign #0.08 Y = ~A; 
endmodule

module sg13g2_stdcell_inv_8 (input A, output Y); 
    assign #0.07 Y = ~A; 
endmodule

`else

// Black-box definitions for Synthesis/GDS Linter
module sg13g2_stdcell_nand2_1 (input A, input B, output Y); endmodule
module sg13g2_stdcell_inv_1   (input A, output Y); endmodule
module sg13g2_stdcell_inv_2   (input A, output Y); endmodule
module sg13g2_stdcell_inv_4   (input A, output Y); endmodule
module sg13g2_stdcell_inv_8   (input A, output Y); endmodule

`endif
