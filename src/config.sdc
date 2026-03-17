# Define the main system clock (10MHz from Tiny Tapeout infrastructure)
create_clock -name clk -period 100 [get_ports clk]

# Define the high-speed oscillator clock
# We use a 1ns period (1GHz) as a constraint target for the ring oscillator path
create_clock -name hsc_clk -period 1.0 [get_nets selected_hsc]

# Define the clocks as asynchronous since the ring oscillator is not phase-aligned with the system clock
set_clock_groups -asynchronous -group [get_clocks clk] -group [get_clocks hsc_clk]