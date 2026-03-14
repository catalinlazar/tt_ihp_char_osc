import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # Set the clock period to 100ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test Enable and Byte Select")
    # Enable the oscillator (ui_in[1])
    dut.ui_in.value = 2 
    
    # Wait for the 10ms window (we can't wait 10ms in sim, so we just wait some cycles)
    await ClockCycles(dut.clk, 100)

    dut._log.info("Finished Test")
