import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # Set the clock (10 MHz = 100ns period)
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize and Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Reset complete")

    # Enable Oscillator Flavor 0
    # ui_in[1] is enable, others are selects. Value 2 = 8'b0000_0010
    dut.ui_in.value = 2 
    
    # Wait for the measurement window
    # In your DUT, the SIM wait time is 1000 cycles
    dut._log.info("Waiting for measurement window...")
    await ClockCycles(dut.clk, 1200) 

    # Check outputs
    dut._log.info(f"Final uo_out value: {hex(dut.uo_out.value.integer)}")
    dut._log.info("Finished Test")
