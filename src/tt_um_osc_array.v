module tt_um_osc_array (
    input  wire [7:0] ui_in,    // 0:rst_n, 1:en, 3:2:byte_sel, 5:4:flavor_sel
    output wire [7:0] uo_out,   // 8-bit sliced count
    input  wire       clk,      // 10MHz System Clock
    input  wire       rst_n     // Reset (active low)
);
    // --- 1. Control Signal Synchronization (10MHz Domain) ---
    reg [4:0] sync_pipe; // en, byte_sel, flavor_sel
    always @(posedge clk) sync_pipe <= ui_in[5:1];
    
    wire osc_en      = sync_pipe[0];
    wire [1:0] b_sel = sync_pipe[2:1];
    wire [1:0] f_sel = sync_pipe[4:3];

    // --- 2. The Three Flavors of Oscillators ---
    wire clk_f0, clk_f1, clk_f2;
    // Small (inv_1), Medium (inv_2), Large (inv_4)
    ring_osc #(.TYPE(1)) osc0 (.en(osc_en), .clk_out(clk_f0));
    ring_osc #(.TYPE(2)) osc1 (.en(osc_en), .clk_out(clk_f1));
    ring_osc #(.TYPE(4)) osc2 (.en(osc_en), .clk_out(clk_f2));

    // Mux to select which high-speed clock to measure
    wire hsc; 
    assign hsc = (f_sel == 2'b00) ? clk_f0 : (f_sel == 2'b01) ? clk_f1 : clk_f2;

    // --- 3. High-Speed Counter Domain ---
    reg [23:0] count;
    always @(posedge hsc or negedge rst_n) begin
        if (!rst_n) count <= 0;
        else        count <= count + 1;
    end

    // --- 4. Snapshot Logic (10MHz Domain) ---
    reg [19:0] timer;
    reg [23:0] snapshot;
    always @(posedge clk) begin
        if (timer == 20'd100_000) begin // 10ms window
            timer <= 0;
            snapshot <= count; // Static transfer is safe here because we read 
                               // a 10ms window vs a GHz clock.
        end else begin
            timer <= timer + 1;
        end
    end

    // --- 5. Output Mux ---
    assign uo_out = (b_sel == 2'b00) ? snapshot[7:0] :
                    (b_sel == 2'b01) ? snapshot[15:8] : snapshot[23:16];
endmodule
