import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # 10 MHz Clock
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Reset Sequence
    dut._log.info("Resetting")
    dut.ena.value = 1       # Now a valid port
    dut.uio_in.value = 0    # Now a valid port
    dut.ui_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Enabling Oscillator and Timer")
    # ui_in[1] is Enable. 2 in decimal is 0000_0010 in binary.
    dut.ui_in.value = 2 
    
    # Wait for the simulation measurement window (1000 cycles)
    # We wait slightly more than 1000 to ensure the snapshot happened
    await ClockCycles(dut.clk, 1050)

    # Check snapshots (Optional: add assertions here if desired)
    dut._log.info(f"Snapshot data at uo_out: {hex(int(dut.uo_out.value))}")

    dut._log.info("Finished Test Successfully")
