# Variables
# SIM = iverilog
SIM = iverilog -DSIM
VVP = vvp
VIEWER = gtkwave

# File paths
SRC_DIR = src
TEST_DIR = test
BUILD_DIR = $(TEST_DIR)/sim_build

# Source files (Excluding primitives.v from synthesis lists usually, but needed for sim)
SRCS = $(SRC_DIR)/primitives.v \
       $(SRC_DIR)/catalinlazar_ihp_ring_osc_1248.v \
       $(SRC_DIR)/tt_um_catalinlazar_big_ihp_osc_array.v

# Testbench
TB = $(TEST_DIR)/tb.v
VVP_OUT = $(BUILD_DIR)/sim.vvp
VCD_OUT = tb.vcd

# Targets
.PHONY: all sim wave clean

all: sim

# Compile and Run Simulation
sim:
	@mkdir -p $(BUILD_DIR)
	$(SIM) -g2012 -o $(VVP_OUT) $(SRCS) $(TB)
	$(VVP) $(VVP_OUT)

# Open Waveform Viewer
wave:
	$(VIEWER) $(VCD_OUT)

# Cleanup
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(VCD_OUT)
