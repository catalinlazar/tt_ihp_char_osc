`default_nettype none

module tt_um_catalinlazar_ihp_osc_array (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;
   
    // Synchronize flavor selection
    reg [1:0] f_sel_reg;
    reg [1:0] b_sel_reg;
    always @(posedge clk) begin
        if (!rst_n) begin
            f_sel_reg <= 2'b0;
            b_sel_reg <= 2'b0;
        end else begin
            f_sel_reg <= ui_in[2:1]; // Use bits 1 and 2 for flavor
            b_sel_reg <= ui_in[4:3]; // Use bits 3 and 4 for byte select
        end
    end
    
    wire global_en = ui_in[0];
    wire [2:0] osc_clks;

    genvar j;
    generate
        for (j = 0; j < 3; j = j + 1) begin : gen_osc
            // local_en ensures only 1 oscillator runs at a time (saves area/power)
            wire local_en = global_en && (f_sel_reg == j);
            
            catalinlazar_ihp_ring_osc_1248 #(
                .DRIVE((j == 0) ? 1 : (j == 1) ? 2 : 4), // Stick to lower drives for area
                .STAGES(250) 
            ) v_osc (
                .en(local_en),
                .clk_out(osc_clks[j])
            );
        end
    endgenerate

    // Selection Mux
    (* keep *) wire selected_hsc = (f_sel_reg == 2'd0) ? osc_clks[0] : 
                        (f_sel_reg == 2'd1) ? osc_clks[1] : 
                        (f_sel_reg == 2'd2) ? osc_clks[2] : 1'b0;

    // Asynchronous Counter
    reg [23:0] count;
    always @(posedge selected_hsc or negedge rst_n) begin
        if (!rst_n) count <= 24'b0;
        else        count <= count + 1'b1;
    end

    // Timer Logic
    reg [19:0] timer;
    reg [23:0] snapshot;
   localparam  WAIT_TIME = 20'd5000;   // ~0.5 ms – very fast for CI
   // localparam WAIT_TIME = 20'd100_000;  // full version – comment out for now
   
   always @(posedge clk) begin
      if (!rst_n) begin
         timer <= 20'b0;
         snapshot <= 24'b0;
      end else if (global_en) begin
         if (timer < WAIT_TIME) begin
            timer <= timer + 1'b1;
         end else if (timer == WAIT_TIME) begin
            snapshot <= count;
            timer <= timer + 1'b1;
         end
      end else begin
         timer <= 20'b0;
      end
   end
   
#   always @(posedge selected_hsc) begin
#      $display("OSC EDGE at time %t, count now %d", $time, count);
#   end
   
   assign uo_out = (b_sel_reg == 2'b00) ? snapshot[7:0]   :
                    (b_sel_reg == 2'b01) ? snapshot[15:8]  :
                    (b_sel_reg == 2'b10) ? snapshot[23:16] : 8'h00;

endmodule
