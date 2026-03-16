set_clock_groups -asynchronous -group [get_clocks clk] -group [get_clocks hsc_clk]
# Ensure hsc_clk is mapped to the internal net name:
create_clock -name hsc_clk -period 1.0 [get_nets selected_clk]