`default_nettype none

 // // All output pins must be assigned. If not used, assign to 0.
 //  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
 //  assign uio_out = 0;
 //  assign uio_oe  = 0;

 //  // List all unused inputs to prevent warnings
 //  wire _unused = &{ena, clk, rst_n, 1'b0};

`ifdef COCOTB_SIM
module sg13g2_inv_1 (input wire A, output wire Y); assign #1 Y = ~A; endmodule
module sg13g2_inv_2 (input wire A, output wire Y); assign #1 Y = ~A; endmodule
module sg13g2_inv_4 (input wire A, output wire Y); assign #1 Y = ~A; endmodule
module sg13g2_nand2_1 (input wire A, input wire B, output wire Y); assign #1 Y = ~(A & B); endmodule
`endif

module tt_um_catalinlazar_ihp_osc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered or selected
    input  wire       clk,      // 10MHz system clock
    input  wire       rst_n     // reset_n - low to reset
);

    // --- 1. Prevent Linter Warnings for Unused Inputs ---
    // We include all inputs in a reduction AND to tell the tool they are "used"
    wire _unused = &{uio_in, ena, 1'b0};

    // --- 2. Control Signal Mapping ---
    wire rst_osc = !rst_n || ui_in[0]; 
    wire osc_en  = ui_in[1];           
    wire [1:0] byte_sel = ui_in[3:2];  
    wire [1:0] ro_sel   = ui_in[5:4];  
    // ui_in[7:6] are currently unused
    wire _unused_ui = &{ui_in[7:6], 1'b0};

    // --- 3. High-Speed Oscillator Flavors ---
    wire clk0, clk1, clk2, clk3;
    reg  selected_clk;

    ro_inv_1 ro_small (.en(osc_en), .clk_out(clk0));
    ro_inv_2 ro_med   (.en(osc_en), .clk_out(clk1));
    ro_inv_4 ro_large (.en(osc_en), .clk_out(clk2));
    ro_nand  ro_logic (.en(osc_en), .clk_out(clk3));

    // Async Clock Mux
    always @(*) begin
        case (ro_sel)
            2'b00: selected_clk = clk0;
            2'b01: selected_clk = clk1;
            2'b10: selected_clk = clk2;
            2'b11: selected_clk = clk3;
            default: selected_clk = 1'b0;
        endcase
    end

    // --- 4. 24-bit Frequency Counter ---
    reg [23:0] raw_counter;
    always @(posedge selected_clk or posedge rst_osc) begin
        if (rst_osc) raw_counter <= 24'b0;
        else         raw_counter <= raw_counter + 1'b1;
    end

    // --- 5. Snapshot Logic (Synchronous to 10MHz) ---
    reg [23:0] captured_count;
    reg [19:0] timer;

    always @(posedge clk) begin
        if (!rst_n) begin
            timer <= 20'b0;
            captured_count <= 24'b0;
        end else begin
            if (timer == 20'd100_000) begin // 10ms sampling window
                captured_count <= raw_counter;
                timer <= 20'b0;
            end else begin
                timer <= timer + 1'b1;
            end
        end
    end

    // --- 6. Output Assignment (Crucial for TT) ---
    reg [7:0] out_data;
    always @(*) begin
        case (byte_sel)
            2'b00: out_data = captured_count[7:0];
            2'b01: out_data = captured_count[15:8];
            2'b10: out_data = captured_count[23:16];
            default: out_data = 8'h00;
        endcase
    end

    assign uo_out  = out_data;
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule

// --- Sub-modules (using IHP SG13G2 primitives) ---

module ro_inv_1 (input wire en, output wire clk_out);
    wire [31:0] n;
    (* keep *) sg13g2_nand2_1 g0 (.A(en), .B(n[31]), .Y(n[0]));
    genvar i; generate for(i=1; i<=31; i=i+1) begin : l
        (* keep *) sg13g2_inv_1 g (.A(n[i-1]), .Y(n[i]));
    end endgenerate
    assign clk_out = n[31];
endmodule

module ro_inv_2 (input wire en, output wire clk_out);
    wire [31:0] n;
    (* keep *) sg13g2_nand2_1 g0 (.A(en), .B(n[31]), .Y(n[0]));
    genvar i; generate for(i=1; i<=31; i=i+1) begin : l
        (* keep *) sg13g2_inv_2 g (.A(n[i-1]), .Y(n[i]));
    end endgenerate
    assign clk_out = n[31];
endmodule

module ro_inv_4 (input wire en, output wire clk_out);
    wire [31:0] n;
    (* keep *) sg13g2_nand2_1 g0 (.A(en), .B(n[31]), .Y(n[0]));
    genvar i; generate for(i=1; i<=31; i=i+1) begin : l
        (* keep *) sg13g2_inv_4 g (.A(n[i-1]), .Y(n[i]));
    end endgenerate
    assign clk_out = n[31];
endmodule

module ro_nand (input wire en, output wire clk_out);
    wire [31:0] n;
    (* keep *) sg13g2_nand2_1 g0 (.A(en), .B(n[31]), .Y(n[0]));
    genvar i; generate for(i=1; i<=31; i=i+1) begin : l
        (* keep *) sg13g2_nand2_1 g (.A(en), .B(n[i-1]), .Y(n[i]));
    end endgenerate
    assign clk_out = n[31];
endmodule
