module ring_osc #(
    parameter TYPE = 1 // 1, 2, or 4 for drive strength
)(
    input  wire en,
    output wire clk_out
);
    wire [31:0] nodes;

    // Stage 0: NAND gate (Enable/Disable)
    // Using drive strength 1 for the control gate
    (* keep *) sg13g2_stdcell_nand2_1 gate0 (
        .A(en), 
        .B(nodes[31]), 
        .Y(nodes[0])
    );

    // Stages 1 to 31: Inverter Chain
    genvar i;
    generate
        for (i = 1; i <= 31; i = i + 1) begin : oscloop
            if (TYPE == 1) begin : type1
                (* keep *) sg13g2_stdcell_inv_1 inv ( .A(nodes[i-1]), .Y(nodes[i]) );
            end else if (TYPE == 2) begin : type2
                (* keep *) sg13g2_stdcell_inv_2 inv ( .A(nodes[i-1]), .Y(nodes[i]) );
            end else begin : type4
                (* keep *) sg13g2_stdcell_inv_4 inv ( .A(nodes[i-1]), .Y(nodes[i]) );
            end
        end
    endgenerate

    assign clk_out = nodes[31];
endmodule
