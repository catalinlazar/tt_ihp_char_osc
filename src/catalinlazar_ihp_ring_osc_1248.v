module catalinlazar_ihp_ring_osc_1248 #(
    parameter DRIVE = 1,
    parameter STAGES = 250 // + 1 NAND = 251
)(
    input  wire en,
    output wire clk_out
);
    wire [STAGES:0] nodes;

    // Enable gate
    (* keep *) sg13g2_stdcell_nand2_1 gate0 (.A(en), .B(nodes[STAGES]), .Y(nodes[0]));

    // Generate the long chain
   genvar i;
   generate
      for (i = 1; i <= STAGES; i = i + 1) begin : oscloop
         if (DRIVE == 1) begin : gen_drv1
            (* keep *) sg13g2_stdcell_inv_1 inv (.A(nodes[i-1]), .Y(nodes[i]));
         end else if (DRIVE == 2) begin : gen_drv2
            (* keep *) sg13g2_stdcell_inv_2 inv (.A(nodes[i-1]), .Y(nodes[i]));
         end else if (DRIVE == 4) begin : gen_drv4
            (* keep *) sg13g2_stdcell_inv_4 inv (.A(nodes[i-1]), .Y(nodes[i]));
         end else begin : gen_drv8
            (* keep *) sg13g2_stdcell_inv_8 inv (.A(nodes[i-1]), .Y(nodes[i]));
         end
      end
   endgenerate
   
   assign clk_out = nodes[STAGES];
endmodule
