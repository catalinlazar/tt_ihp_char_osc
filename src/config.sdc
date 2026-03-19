# Basic clock definition (required)
create_clock -name clk -period 20 [get_ports clk]

# Small uncertainty to avoid false warnings
set_clock_uncertainty 0.1 [get_clocks clk]

# Reasonable I/O constraints for async inputs/outputs
set_input_delay  0.5 -clock clk [get_ports ui_in]
set_output_delay 0.5 -clock clk [get_ports uo_out]

# Optional: treat async reset and enable as false paths
set_false_path -from [get_ports rst_n]
set_false_path -from [get_ports ui_in[*]] -to [get_clocks clk]

# No set_dont_touch here — OpenROAD rejects it in early SDC
# (your ring oscillators are async/combinational anyway,
#  so they won't be optimized away or heavily buffered in practice)