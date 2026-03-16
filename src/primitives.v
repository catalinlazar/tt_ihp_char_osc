`timescale 1ns/1ps

module sg13g2_stdcell_nand2_1 (input A, input B, output Y);
    assign #0.1 Y = ~(A & B); // 100ps delay
endmodule

module sg13g2_stdcell_inv_1 (input A, output Y);
    assign #0.1 Y = ~A; // 100ps delay
endmodule

// Add similar models for _2, _4, and _8 drive strengths
module sg13g2_stdcell_inv_2 (input A, output Y); assign #0.09 Y = ~A; endmodule
module sg13g2_stdcell_inv_4 (input A, output Y); assign #0.08 Y = ~A; endmodule
module sg13g2_stdcell_inv_8 (input A, output Y); assign #0.07 Y = ~A; endmodule
