`default_nettype none

module tt_um_catalinlazar_big_ihp_osc_array (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path (unused)
    output wire [7:0] uio_out,  // IOs: Output path (unused)
    output wire [7:0] uio_oe,   // IOs: Enable path (set to 0 for all inputs)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n
);
   // Set bidirectional pins to high-impedance/input mode to avoid shorts
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;
   
    // 1. Synchronize Control Signals (to 10MHz domain)
    reg [6:0] sync_reg;
    always @(posedge clk) begin
        if (!rst_n) sync_reg <= 7'b0;
        else        sync_reg <= ui_in[7:1];
    end
    
    wire [3:0] f_sel     = sync_reg[6:3]; // Flavor select
    wire [1:0] b_sel     = sync_reg[2:1]; // Byte select
    wire       global_en = sync_reg[0];   // Enable oscillation

    // 2. Instantiate 16 Ring Oscillators with Clock Gating
    // This optimization prevents the simulator from calculating 15 idle rings.
    wire [15:0] osc_clks;
    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin : gen_flavors
            // Local Enable: Only HIGH if global_en is high AND this flavor is selected
            wire local_en = (global_en && (f_sel == j));
            
            catalinlazar_ihp_ring_osc_1248 #(
                .DRIVE((j%4 == 0) ? 1 : (j%4 == 1) ? 2 : (j%4 == 2) ? 4 : 8),
                .STAGES(250) // 1 NAND + 250 INVs = 251 (Prime)
            ) v_osc (
                .en(local_en),
                .clk_out(osc_clks[j])
            );
        end
    endgenerate

    // 3. High-Speed Clock Selection
    wire selected_hsc = osc_clks[f_sel];

    // 4. Asynchronous High-Speed Counter
    reg [23:0] count;
    always @(posedge selected_hsc or negedge rst_n) begin
        if (!rst_n) count <= 24'b0;
        else        count <= count + 1'b1;
    end

    // 5. Configurable Measurement Window
    reg [19:0] timer;
    reg [23:0] snapshot;

    // SIMULATION vs HARDWARE timing
    `ifdef SIM
        localparam WAIT_TIME = 20'd1000;    // 0.1ms (Fast simulation)
    `else
        localparam WAIT_TIME = 20'd100_000; // 10.0ms (Real hardware)
    `endif

    always @(posedge clk) begin
        if (!rst_n) begin
            timer <= 20'b0;
            snapshot <= 24'b0;
        end else if (timer >= WAIT_TIME) begin
            timer <= 20'b0;
            snapshot <= count; // Transfer counter to stable register
        end else begin
            timer <= timer + 1'b1;
        end
    end

    // 6. Output Mux (Slicing 24-bit to 8-bit)
    assign uo_out = (b_sel == 2'b00) ? snapshot[7:0]   :
                    (b_sel == 2'b01) ? snapshot[15:8]  :
                    (b_sel == 2'b10) ? snapshot[23:16] : 8'h00;

endmodule
